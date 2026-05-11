variable "cloud_id" {
  description = "ID облака"
  type        = string
}

variable "folder_id" {
  description = "ID каталога"
  type        = string
}

variable "zone" {
  description = "Основная зона доступности"
  type        = string
  default     = "ru-central1-a"
}

variable "zones" {
  description = "Список зон доступности для отказоустойчивости"
  type        = list(string)
  default     = ["ru-central1-a", "ru-central1-b", "ru-central1-d"]
}

variable "ssh_public_key" {
  description = "Публичный SSH-ключ"
  type        = string
}

# Network
variable "vpc_name" {
  description = "Имя VPC"
  type        = string
  default     = "hw154-vpc"
}

variable "subnet_cidr" {
  description = "CIDR основной публичной подсети"
  type        = string
  default     = "192.168.100.0/24"
}

variable "private_subnet_cidrs" {
  description = "CIDR для приватных подсетей (MySQL)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "k8s_public_subnet_cidrs" {
  description = "CIDR для дополнительных публичных подсетей (K8s)"
  type        = list(string)
  default     = ["192.168.101.0/24", "192.168.102.0/24", "192.168.103.0/24"]
}

# Object Storage
variable "bucket_name" {
  description = "Имя бакета"
  type        = string
}

variable "image_object_name" {
  description = "Имя объекта в бакете"
  type        = string
  default     = "images/logo.png"
}

# Instance Group
variable "instance_group_name" {
  description = "Имя группы инстансов"
  type        = string
  default     = "lamp-group"
}

variable "instance_count" {
  description = "Количество ВМ"
  type        = number
  default     = 3
}

variable "lamp_image_id" {
  description = "Image ID для LAMP"
  type        = string
  default     = "fd827b91d99psvq5fjit"
}

# KMS
variable "kms_key_name" {
  description = "Имя симметричного ключа KMS"
  type        = string
  default     = "bucket-encryption-key"
}

# Database
variable "db_password" {
  description = "Пароль для пользователя MySQL"
  type        = string
  sensitive   = true
}