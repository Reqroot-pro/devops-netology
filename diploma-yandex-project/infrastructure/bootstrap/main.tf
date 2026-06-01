terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.136"
    }
  }
  # Первый запуск — локальный бекенд
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = "ru-central1-a"
  service_account_key_file = "/home/devops/.config/yandex-cloud/sa-key.json"
}

# Случайный суффикс для имени бакета
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Сервисный аккаунт для Terraform
resource "yandex_iam_service_account" "terraform" {
  name        = "terraform-infra"
  description = "Service account for Terraform infrastructure"
}

# Права редактора в папке для этого СА
resource "yandex_resourcemanager_folder_iam_member" "terraform_editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.terraform.id}"
}

# Статический ключ доступа для S3 backend
resource "yandex_iam_service_account_static_access_key" "terraform_sa_key" {
  service_account_id = yandex_iam_service_account.terraform.id
  description        = "Static access key for S3 backend"
}

# Бакет для хранения state
resource "yandex_storage_bucket" "tf_state" {
  bucket = "tf-state-${random_id.bucket_suffix.hex}"

  grant {
    type        = "CanonicalUser"
    id          = yandex_iam_service_account.terraform.id
    permissions = ["FULL_CONTROL"]
  }

  # Запрет публичного доступа
  anonymous_access_flags {
    read        = false
    list        = false
    config_read = false
  }

  versioning {
    enabled = true
  }
}

# Права для создания Managed Kubernetes
resource "yandex_resourcemanager_folder_iam_member" "terraform_k8s_agent" {
  folder_id = var.folder_id
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.terraform.id}"
}

# Права для выделения публичного IP мастеру
resource "yandex_resourcemanager_folder_iam_member" "terraform_vpc_public" {
  folder_id = var.folder_id
  role      = "vpc.publicAdmin"
  member    = "serviceAccount:${yandex_iam_service_account.terraform.id}"
}