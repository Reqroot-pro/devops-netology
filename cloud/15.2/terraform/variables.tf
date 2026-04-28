variable "cloud_id" {
  description = "ID облака"
  type        = string
}

variable "folder_id" {
  description = "ID каталога"
  type        = string
}

variable "zone" {
  description = "Зона доступности"
  type        = string
  default     = "ru-central1-a"
}

variable "ssh_public_key" {
  description = "Публичный SSH-ключ"
  type        = string
}

# Object Storage
variable "bucket_name" {
  description = "Имя бакета (глобально уникальное)"
  type        = string
}

variable "image_file_path" {
  description = "Путь к файлу картинки"
  type        = string
  default     = "${path.module}/files/logo.png"
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

# Network
variable "vpc_name" {
  description = "Имя VPC"
  type        = string
  default     = "hw152-vpc"
}

variable "subnet_cidr" {
  description = "CIDR публичной подсети"
  type        = string
  default     = "192.168.100.0/24"
}