variable "env_name" {
  description = "Name of the network"
  type        = string
}

variable "zone" {
  description = "Availability zone for subnet"
  type        = string
}

variable "cidr" {
  description = "IPv4 CIDR block for subnet"
  type        = string
}
