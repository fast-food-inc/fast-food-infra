variable "location" {
  description = "Azure Region"
  default     = "centralus"
}

variable "resource_group_name" {
  description = "Name of the Resource Group"
  default     = "fast-food-rg"
}

variable "aks_cluster_name" {
  description = "Name of the AKS Cluster"
  default     = "fast-food-aks"
}

variable "node_count" {
  description = "Number of nodes in the AKS node pool"
  default     = 2
}

variable "acr_name" {
  description = "Name of the Azure Container Registry"
  default     = "fastfoodacrrg" # Must be globally unique
}

variable "postgres_admin_user" {
  description = "Admin username for PostgreSQL"
  default     = "azureuser"
}

variable "postgres_admin_password" {
  description = "Admin password for PostgreSQL"
  sensitive   = true
}

variable "mongo_db_name" {
  default = "fast-food-catalog"
}
