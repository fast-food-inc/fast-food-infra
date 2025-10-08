variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
  default     = "fast-food-cluster"
}

variable "kubernetes_version" {
  description = "Versão do Kubernetes"
  type        = string
  default     = "1.27"
}

variable "subnet_ids" {
  description = "IDs das subnets para o cluster EKS"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "IDs das subnets privadas para os nodes"
  type        = list(string)
}

variable "node_instance_types" {
  description = "Tipos de instância para os nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_capacity" {
  description = "Capacidade desejada do node group"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Capacidade máxima do node group"
  type        = number
  default     = 4
}

variable "min_capacity" {
  description = "Capacidade mínima do node group"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Tags para recursos"
  type        = map(string)
  default = {
    Project     = "FastFood"
    Environment = "dev"
    Terraform   = "true"
  }
}

variable "secrets_arns" {
  type        = list(string)
  description = "ARNs of secrets that the service account can access"
  default     = []
}
