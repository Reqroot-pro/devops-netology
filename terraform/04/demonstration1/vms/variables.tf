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
