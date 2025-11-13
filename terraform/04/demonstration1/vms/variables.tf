# SSH публичный ключ
variable "public_key" {
  type        = string
  description = "SSH public key for VM access"
}

# OAuth token
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

# Cloud ID
variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

# Folder ID
variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

# Зона
variable "default_zone" {
  type    = string
  default = "ru-central1-a"
}

# IP-адрес (строка)
variable "ip_address" {
  type        = string
  description = "IP-адрес"
  default     = "192.168.0.1"

  validation {
    condition     = can(cidrhost("${var.ip_address}/32", 0))
    error_message = "Переменная ip_address должна быть корректным IP-адресом, например 192.168.0.1"
  }
}

# Список IP-адресов
variable "ip_list" {
  type        = list(string)
  description = "Список IP-адресов"
  default     = ["192.168.0.1", "1.1.1.1", "127.0.0.1"]

  validation {
    condition = alltrue([
      for ip in var.ip_list : can(cidrhost("${ip}/32", 0))
    ])
    error_message = "Все элементы ip_list должны быть корректными IP-адресами"
  }
}
