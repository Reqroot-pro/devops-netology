variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Folder ID"
  type        = string
}

variable "sa_key_file" {
  description = "Path to service account key file"
  type        = string
  default     = ""
}