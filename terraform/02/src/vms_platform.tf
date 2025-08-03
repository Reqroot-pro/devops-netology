# ВМ WEB

variable "vm_web_image_family" {
  type    = string
  default = "ubuntu-2004-lts"
}

variable "vm_web_name" {
  type    = string
  default = "netology-develop-platform-web"
}

variable "vm_web_platform_id" {
  type    = string
  default = "standard-v1"
}

/*
variable "vm_web_cores" {
  type    = number
  default = 2
}

variable "vm_web_memory" {
  type    = number
  default = 2
}

variable "vm_web_core_fraction" {
  type    = number
  default = 5
}
*/

# ВМ DB

variable "vm_db_name" {
  type    = string
  default = "netology-develop-platform-db"
}

variable "vm_db_platform_id" {
  type    = string
  default = "standard-v1"
}

/*
variable "vm_db_cores" {
  type    = number
  default = 2
}

variable "vm_db_memory" {
  type    = number
  default = 2
}

variable "vm_db_core_fraction" {
  type    = number
  default = 20
}
*/

variable "vm_db_zone" {
  type    = string
  default = "ru-central1-b"
}

variable "vm_db_subnet_name" {
  type    = string
  default = "develop-b"
}

variable "vm_db_cidr_block" {
  type    = list(string)
  default = ["10.0.2.0/24"]
}

variable "vms_resources" {
  description = "VM resource map for web and db"
  type = map(object({
    cores         = number
    memory        = number
    core_fraction = number
  }))
}

variable "metadata" {
  description = "Metadata block for all VMs"
  type = map(string)
}