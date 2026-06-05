variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Folder ID"
  type        = string
}

variable "cluster_name" {
  type    = string
  default = "prod-k8s"
}

variable "state_bucket" {
  description = "S3 bucket name for Terraform state"
  type        = string
}

variable "state_key" {
  description = "Path to state file inside bucket"
  type        = string
  default     = "main/terraform.tfstate"
}

variable "ci_cd_sa_id" {
  description = "Service Account ID used by CI/CD for pushing images"
  type        = string
}

variable "sa_key_file" {
  description = "Path to service account key file"
  type        = string
  default     = ""
}