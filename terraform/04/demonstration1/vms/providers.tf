terraform {
  required_version = ">=1.5"

  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }

  backend "s3" {
    bucket  = "terraform-05-state"
    key     = "terraform.tfstate"
    region  = "ru-central1"

    use_lockfile = true

    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    use_path_style            = true     # <— ВАЖНО для Yandex Object Storage
  }
}

provider "yandex" {
  cloud_id   = var.cloud_id
  folder_id  = var.folder_id
  token      = var.token
  zone       = var.default_zone
}
