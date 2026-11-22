variable "key_name" {
  description = "Existing EC2 key pair name in us-east-1 (not the .pem path)."
  type        = string
  default     = "depi-tasks"
}

variable "ssh_allowed_cidr" {
  description = "Your public IPv4 address with /32, e.g. 203.0.113.10/32."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.ssh_allowed_cidr)) && endswith(var.ssh_allowed_cidr, "/32")
    error_message = "Use your public IPv4 address ending in /32. Never use 0.0.0.0/0."
  }
}
