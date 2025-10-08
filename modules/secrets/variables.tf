variable "secret_name" { type = string }
variable "description" {
  type    = string
  default = ""
}
variable "secret_string" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}
