variable "folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
}

variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "zone" {
  description = "Availability zone"
  default     = "ru-central1-a"
}

variable "subnet_cidr" {
  default = "10.0.1.0/24"
}