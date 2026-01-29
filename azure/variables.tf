variable "resource_group_name" {
  default = "fast-food-rg"
}

variable "location" {
  default = "centralus"
}

variable "aks_cluster_name" {
  default = "fast-food-aks"
}

variable "acr_name" {
  default = "fastfoodacrrg"
}

variable "postgres_admin_login" {
  default = "azureuser"
}

variable "postgres_admin_password" {
  description = "Password for PostgreSQL Admin"
  sensitive   = true
}

variable "mongo_db_name" {
  default = "fast-food-catalog-db"
}

variable "node_count" {
  default = 1
}

variable "ssh_public_key" {
  description = "SSH Public Key for AKS Nodes"
  type        = string
}
