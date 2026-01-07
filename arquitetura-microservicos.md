# Fast Food API - Arquitetura de Microserviços

## Visão Geral

Transformar a API monolítica do Fast Food em uma arquitetura de microserviços com 5 serviços independentes, cada um com seu próprio banco de dados, comunicando via APIs REST e protegidos através do AWS API Gateway com autenticação JWT do Cognito.

## Visão da Arquitetura

### Estado Atual (Monólito)
- Aplicação única Node.js/Express
- Banco de dados único PostgreSQL
- Toda lógica de negócio em um código
- Implantado como unidade única no EKS

### Estado Alvo (Microserviços)

```mermaid
graph TB
    subgraph "Camada de Cliente"
        A[Aplicação Web]
        B[Display da Cozinha]
        C[App Mobile]
    end
    
    subgraph "Camada API Gateway"
        D[AWS API Gateway]
        E[JWT Authorizer]
        F[Cognito User Pool]
    end
    
    subgraph "Camada de Microserviços"
        G[Serviço Auth<br/>Lambda]
        H[Serviço Catálogo<br/>EKS]
        I[Serviço Produto<br/>EKS]
        J[Serviço Pedido<br/>EKS]
        K[Serviço Pagamento<br/>EKS]
    end
    
    subgraph "Camada de Banco de Dados"
        L[(PostgreSQL<br/>catalog_db)]
        M[(DynamoDB<br/>products)]
        N[(PostgreSQL<br/>orders_db)]
        O[(PostgreSQL<br/>payments_db)]
    end
    
    subgraph "Serviços Externos"
        P[Mercado Pago API]
        Q[Webhook Handler]
    end
    
    A --> D
    B --> D
    C --> D
    D --> E
    E --> F
    D --> G
    D --> H
    D --> I
    D --> J
    D --> K
    
    H --> L
    I --> M
    J --> N
    K --> O
    
    K --> P
    P --> Q
    Q --> K
```

## Divisão dos Serviços

### 1. Serviço Auth (Lambda) - Sem Alterações
**Responsabilidade**: Autenticação e geração de tokens JWT via Cognito

**Banco de Dados**: Nenhum (chama Serviço Catálogo para busca de cliente)

**Endpoints**:
- `POST /auth/identify` - Identificar cliente por CPF

### 2. Serviço Catálogo / Produto (EKS + DynamoDB) - NOVO
**Responsabilidade**: Gerenciamento de clientes, categorias e produtos

**Banco de Dados**: DynamoDB (catalog_db)
- Tabelas: customers, categories, products

**Endpoints**:
- `GET /api/customers` - Listar todos os clientes
- `GET /api/customers/:id` - Buscar cliente por ID
- `GET /api/customers/cpf/:cpf` - Buscar cliente por CPF (para Serviço Auth)
- `POST /api/customers` - Criar cliente
- `PUT /api/customers/:id` - Atualizar cliente
- `DELETE /api/customers/:id` - Deletar cliente
- `GET /api/categories` - Listar categorias
- `GET /api/categories/:id` - Buscar categoria
- `POST /api/categories` - Criar categoria
- `PUT /api/categories/:id` - Atualizar categoria
- `DELETE /api/categories/:id` - Deletar categoria
- `GET /api/products` - Listar produtos
- `GET /api/products/:id` - Buscar produto
- `GET /api/products/category/:categoryId` - Buscar produtos por categoria
- `POST /api/products` - Criar produto
- `PUT /api/products/:id` - Atualizar produto
- `DELETE /api/products/:id` - Deletar produto


### 3. Serviço Gerenciamento de Pedidos (EKS + PostgreSQL)
**Responsabilidade**: Ciclo de vida dos pedidos e operações da cozinha

**Banco de Dados**: PostgreSQL (orders_db)

**Endpoints**:
- `GET /api/orders` - Listar todos os pedidos
- `GET /api/orders/:id` - Buscar pedido por ID
- `GET /api/orders/customer/:customerId` - Buscar pedidos por cliente
- `GET /api/orders/status/:status` - Buscar pedidos por status
- `GET /api/orders/sorted` - Buscar pedidos ordenados para cozinha
- `POST /api/orders` - Criar pedido
- `PATCH /api/orders/:id/status` - Atualizar status do pedido
- `PATCH /api/orders/:id/items` - Adicionar itens ao pedido
- `PATCH /api/orders/:orderId/items/:itemId` - Atualizar quantidade do item
- `DELETE /api/orders/:id` - Deletar pedido (apenas PENDING)
- `PATCH /api/orders/:id/status/confirmOrder` - Confirmar pedido
- `PATCH /api/orders/:id/status/startPreparing` - Iniciar preparo
- `PATCH /api/orders/:id/status/markReady` - Marcar como pronto
- `PATCH /api/orders/:id/status/markDelivered` - Marcar como entregue
- `PATCH /api/orders/:id/status/cancel` - Cancelar pedido
- `GET /api/kitchen/orders` - Visualização da cozinha (pedidos ordenados)
- `GET /api/kitchen/orders/awaiting-preparation` - Aguardando preparo

### 4. Serviço Pagamento (EKS + PostgreSQL)
**Responsabilidade**: Processamento de pagamentos e integração Mercado Pago

**Banco de Dados**: PostgreSQL (payments_db)

**Endpoints**:
- `POST /api/orders/:orderId/payment` - Criar pagamento (gerar QR code)
- `GET /api/payments/order/:orderId/status` - Buscar status do pagamento
- `POST /webhooks/paymentwebhook` - Webhook Mercado Pago (público)

## Fluxo de Autenticação

```mermaid
sequenceDiagram
    participant C as Cliente
    participant AG as API Gateway
    participant A as Serviço Auth (Lambda)
    participant CP as Cognito
    participant CS as Serviço Catálogo
    participant OS as Serviço Pedido
    
    C->>A: POST /auth/identify {cpf}
    A->>CS: GET /api/customers/cpf/{cpf}
    CS-->>A: dados do cliente
    A->>CP: Criar/Buscar Usuário Cognito
    CP-->>A: Token JWT Cognito
    A-->>C: {token, customer}
    
    Note over C,OS: Requisições subsequentes
    
    C->>AG: GET /api/orders {Authorization: Bearer token}
    AG->>CP: Validar JWT
    CP-->>AG: Claims válidos
    AG->>OS: Encaminhar requisição + headers do usuário
    OS-->>AG: Resposta
    AG-->>C: Resposta
```

## Arquitetura de Banco de Dados

### Bancos SQL (PostgreSQL)

#### Banco do Serviço Catálogo
```mermaid
erDiagram
    CUSTOMERS {
        uuid id PK
        string name
        string email UK
        string cpf UK
        string phone
        timestamp created_at
        timestamp updated_at
    }
    
    CATEGORIES {
        uuid id PK
        string name
        text description
        timestamp created_at
        timestamp updated_at
    }
```

#### Banco do Serviço Pedidos
```mermaid
erDiagram
    ORDERS {
        uuid id PK
        uuid customer_id FK
        string status
        string payment_status
        decimal total_amount
        string payment_provider_id
        integer order_number
        timestamp created_at
        timestamp updated_at
    }
    
    ORDER_ITEMS {
        uuid id PK
        uuid order_id FK
        uuid product_id
        integer quantity
        decimal unit_price
        decimal total_price
        text observation
        timestamp created_at
        timestamp updated_at
    }
```

#### Banco do Serviço Pagamento
```mermaid
erDiagram
    PAYMENTS {
        uuid id PK
        uuid order_id UK
        string payment_provider_id
        decimal amount
        string status
        text qr_code
        text qr_code_base64
        timestamp created_at
        timestamp updated_at
    }
```

### Banco NoSQL (DynamoDB)

#### Serviço Produto - Design da Tabela DynamoDB
```mermaid
graph LR
    subgraph "Tabela DynamoDB Products"
        A[Chave Primária: productId]
        B[Chave de Ordenação: createdAt]
        C[GSI: CategoryIndex]
        D[Atributos: name, price, stock, etc.]
    end
    
    A --> B
    A --> C
    A --> D
```

**Esquema da Tabela:**
- **Chave Primária**: `productId` (String)
- **GSI**: `CategoryIndex` com `categoryId` (Chave de Partição) e `name` (Chave de Ordenação)
- **Atributos**: name, description, price, categoryId, imageUrl, isAvailable, stock, metadata

## Comunicação Entre Serviços

### Fluxo de Criação de Pedido
```mermaid
sequenceDiagram
    participant C as Cliente
    participant AG as API Gateway
    participant OS as Serviço Pedido
    participant PS as Serviço Produto
    participant CS as Serviço Catálogo
    
    C->>AG: POST /api/orders {items}
    AG->>OS: Encaminhar requisição
    OS->>PS: GET /api/products/{id} (validar cada produto)
    PS-->>OS: Detalhes do produto
    OS->>PS: POST /api/products/{id}/reserve-stock
    PS-->>OS: Estoque reservado
    OS->>CS: GET /api/customers/{id} (se customerId fornecido)
    CS-->>OS: Detalhes do cliente
    OS->>OS: Criar pedido com status PENDING
    OS-->>AG: Pedido criado
    AG-->>C: Resposta do pedido
```

### Fluxo de Pagamento
```mermaid
sequenceDiagram
    participant C as Cliente
    participant AG as API Gateway
    participant PS as Serviço Pagamento
    participant OS as Serviço Pedido
    participant MP as Mercado Pago
    
    C->>AG: POST /api/orders/{id}/payment
    AG->>PS: Encaminhar requisição
    PS->>OS: GET /api/orders/{id}
    OS-->>PS: Detalhes do pedido
    PS->>MP: Criar preferência de pagamento
    MP-->>PS: Preferência de pagamento + QR code
    PS->>PS: Armazenar registro de pagamento
    PS-->>AG: Resposta do QR code
    AG-->>C: Detalhes do pagamento
    
    Note over MP,PS: Webhook assíncrono
    MP->>PS: POST /webhooks/paymentwebhook
    PS->>OS: PATCH /api/orders/{id}/status/confirmPayment
    OS-->>PS: Pedido atualizado
    PS->>PS: Atualizar status do pagamento
```

## Configuração do API Gateway

### Regras de Roteamento
```mermaid
graph TD
    A[API Gateway] --> B{Padrão de Caminho}
    
    B -->|/auth/*| C[Serviço Auth Lambda]
    B -->|/api/customers/*| D[Serviço Catálogo]
    B -->|/api/categories/*| D
    B -->|/api/products/*| E[Serviço Produto]
    B -->|/api/orders/*| F[Serviço Pedido]
    B -->|/api/kitchen/*| F
    B -->|/api/payments/*| G[Serviço Pagamento]
    B -->|/webhooks/*| G
    
    H[JWT Authorizer] --> B
    I[Cognito User Pool] --> H
```

### Configuração de Segurança
```mermaid
graph LR
    subgraph "Endpoints Públicos"
        A[POST /auth/identify]
        B[POST /webhooks/paymentwebhook]
        C[GET /api/orders/sorted]
        D[GET /api/orders/status/*]
    end
    
    subgraph "Endpoints Autenticados"
        E[Todos /api/customers/*]
        F[Todos /api/categories/*]
        G[Todos /api/products/*]
        H[Todos /api/orders/* exceto públicos]
        I[Todos /api/payments/*]
    end
    
    J[JWT Authorizer] --> E
    J --> F
    J --> G
    J --> H
    J --> I
```

## Arquitetura de Infraestrutura

### Recursos AWS
```mermaid
graph TB
    subgraph "API Gateway"
        AG[API Gateway]
        JA[JWT Authorizer]
    end
    
    subgraph "Computação"
        L[Lambda - Serviço Auth]
        EKS[Cluster EKS]
    end
    
    subgraph "Bancos de Dados"
        RDS1[(RDS PostgreSQL<br/>catalog_db)]
        RDS2[(RDS PostgreSQL<br/>orders_db)]
        RDS3[(RDS PostgreSQL<br/>payments_db)]
        DD[(DynamoDB<br/>products)]
    end
    
    subgraph "Externo"
        CP[Cognito User Pool]
        MP[Mercado Pago]
    end
    
    subgraph "Serviços EKS"
        CS[Pod Serviço Catálogo]
        PS[Pod Serviço Produto]
        OS[Pod Serviço Pedido]
        PYS[Pod Serviço Pagamento]
    end
    
    AG --> L
    AG --> EKS
    EKS --> CS
    EKS --> PS
    EKS --> OS
    EKS --> PYS
    
    CS --> RDS1
    PS --> DD
    OS --> RDS2
    PYS --> RDS3
    
    L --> CP
    PYS --> MP
    MP --> PYS
```

## Arquitetura de Segurança

### Estrutura do Token JWT
```mermaid
graph LR
    A[Cabeçalho JWT] --> B[Payload JWT]
    B --> C[Assinatura JWT]
    
    D[Cabeçalho: alg=RS256, typ=JWT] --> A
    E[Payload: sub, cpf, iss, aud, exp] --> B
    F[Chave Privada Cognito] --> C
```

### Fluxo de Segurança do API Gateway
```mermaid
sequenceDiagram
    participant C as Cliente
    participant AG as API Gateway
    participant CP as Cognito
    participant S as Microserviço
    
    C->>AG: Requisição + JWT
    AG->>CP: Validar JWT
    CP-->>AG: Claims válidos
    AG->>S: Requisição + headers do usuário
    S-->>AG: Resposta
    AG-->>C: Resposta
```

## Lista de Verificação de Implementação

- [ ] Configurar 3 instâncias RDS PostgreSQL
- [ ] Criar tabela DynamoDB products
- [ ] Atualizar Terraform para nova infraestrutura
- [ ] Configurar API Gateway com JWT authorizer
- [ ] Extrair Serviço Catálogo (clientes, categorias)
- [ ] Extrair Serviço Produto (DynamoDB)
- [ ] Extrair Serviço Gerenciamento de Pedidos
- [ ] Extrair Serviço Pagamento
- [ ] Atualizar Lambda para usar Cognito
- [ ] Configurar comunicação serviço-a-serviço
- [ ] Implementar health checks
- [ ] Configurar monitoramento e logging
- [ ] Criar pipelines de deploy
- [ ] Testar fluxos end-to-end
- [ ] Deploy em produção
- [ ] Descomissionar monólito

Esta arquitetura fornece uma solução de microserviços escalável, manutenível e segura que atende a todos os requisitos mantendo a complexidade gerenciável.
