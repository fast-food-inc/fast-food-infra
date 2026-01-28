# --- Cosmos DB for MongoDB (Catalog) ---
resource "azurerm_cosmosdb_account" "mongo" {
  name                = "fast-food-cosmos-mongo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  offer_type          = "Standard"
  kind                = "MongoDB"

  capabilities {
    name = "EnableMongo"
  }

  count = 1 

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_mongo_database" "catalog_db" {
  name                = var.mongo_db_name
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.mongo[0].name
}


# --- PostgreSQL Flexible Server (Order & Payment) ---
resource "azurerm_postgresql_flexible_server" "postgres" {
  name                   = "fast-food-postgres-server"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  version                = "13"
  administrator_login    = var.postgres_admin_login
  administrator_password = var.postgres_admin_password
  storage_mb             = 32768
  sku_name               = "B_Standard_B1ms" # Cost effective

  # For simplicity in this challenge, using public access with firewall
  # In production, use VNet integration
}

# Allow Azure Services to access Postgres
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure_services" {
  name             = "allow-azure-services"
  server_id        = azurerm_postgresql_flexible_server.postgres.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Allow All IPs for easier first debugging (NOT RESPOMMENDED FOR PROD), 
# or specific dev IP. Let's allow all for now as user requested "simplest possible".
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_all" {
  name             = "allow-all"
  server_id        = azurerm_postgresql_flexible_server.postgres.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

resource "azurerm_postgresql_flexible_server_database" "order_db" {
  name      = "fast_food_production"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

resource "azurerm_postgresql_flexible_server_database" "payment_db" {
  name      = "fast_food_payment"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

output "cosmos_connection_string" {
  value     = azurerm_cosmosdb_account.mongo[0].connection_strings[0]
  sensitive = true
}

output "postgres_fqdn" {
  value = azurerm_postgresql_flexible_server.postgres.fqdn
}
