variable "vpc_id" { type = string }
variable "cidr" { type = string }
variable "az" { type = string }
variable "name" { type = string }

variable "public" {
  type    = bool
  default = false
}

variable "public_route_table_id" {
  type    = string
  default = null
}
