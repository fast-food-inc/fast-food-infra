variable "role_name" {
  type = string
}

variable "secrets_arns" {
  type    = list(string)
  default = []
}

variable "cognito_arns" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
