variable "cloud_id" {
  description = "ID облака Yandex Cloud"
  type        = string
}

variable "folder_id" {
  description = "ID каталога для размещения ресурсов"
  type        = string
}

variable "zone" {
  description = "Зона доступности"
  type        = string
  default     = "ru-central1-a"
}

variable "vpc_name" {
  description = "Имя VPC сети"
  type        = string
  default     = "homework-vpc"
}

variable "ssh_public_key" {
  description = "Публичный SSH-ключ для доступа к ВМ"
  type        = string
}

# Image ID для NAT-инстанса (из задания)
variable "nat_image_id" {
  description = "Image ID для NAT-инстанса"
  type        = string
  default     = "fd80mrhj8fl2oe87o4e1"
}

# Image для обычных ВМ (Ubuntu 22.04 LTS)
variable "vm_image_family" {
  description = "Семейство образов для ВМ"
  type        = string
  default     = "ubuntu-2204-lts"
}