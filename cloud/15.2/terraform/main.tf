# ===========================
# 1. VPC NETWORK + SUBNET
# ===========================
resource "yandex_vpc_network" "main" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "public" {
  name           = "hw152-public"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.subnet_cidr]
}

# ===========================
# 2. OBJECT STORAGE BUCKET
# ===========================
resource "yandex_storage_bucket" "main" {
  bucket     = var.bucket_name
  access_key = yandex_iam_service_account_static_access_key.sa-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-key.secret_key
  acl        = "public-read"
}

# Сервисный аккаунт для доступа к Object Storage
resource "yandex_iam_service_account" "storage-sa" {
  folder_id = var.folder_id
  name      = "storage-sa-hw152"
}

# Права на управление бакетом
resource "yandex_resourcemanager_folder_iam_member" "storage-sa-editor" {
  folder_id = var.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.storage-sa.id}"
}

# Статический ключ для S3 API
resource "yandex_iam_service_account_static_access_key" "sa-key" {
  service_account_id = yandex_iam_service_account.storage-sa.id
  description        = "Static key for Object Storage API"
}

# Загрузка картинки
resource "yandex_storage_object" "logo" {
  bucket       = yandex_storage_bucket.main.bucket
  key          = var.image_object_name
  source       = var.image_file_path
  content_type = "image/png"
  acl          = "public-read"
  access_key   = yandex_iam_service_account_static_access_key.sa-key.access_key
  secret_key   = yandex_iam_service_account_static_access_key.sa-key.secret_key
}

# ===========================
# 3. INSTANCE GROUP (LAMP)
# ===========================
resource "yandex_compute_instance_group" "lamp_group" {
  name               = var.instance_group_name
  folder_id          = var.folder_id
  service_account_id = yandex_iam_service_account.storage-sa.id

  instance_template {
    platform_id = "standard-v2"
    name        = "lamp-vm"

    # Образ с LAMP
    boot_disk {
      initialize_params {
        image_id = var.lamp_image_id
        type     = "network-hdd"
        size     = 20
      }
    }

    resources {
      cores         = 2
      memory        = 2
      core_fraction = 20
    }

    # Сеть: публичная подсеть + внешний IP
    network_interface {
      subnet_id = yandex_vpc_subnet.public.id
      nat       = true
    }

    # SSH + user-data скрипт
    metadata = {
      ssh-keys = "ubuntu:${var.ssh_public_key}"
      user-data = templatefile("${path.module}/files/user-data.sh", {
        image_url = "https://${yandex_storage_bucket.main.bucket}.storage.yandexcloud.net/${var.image_object_name}"
      })
    }

    # Health check для балансировщика
    health_check_type = "http"
  }

  # Фиксированное количество ВМ
  scale_policy {
    fixed_scale {
      size = var.instance_count
    }
  }

  # Зона развёртывания
  allocation_policy {
    zones = [var.zone]
  }

  # Стратегия обновления
  deploy_policy {
    max_unavailable = 1
    max_expansion   = 1
  }

  # Подключение к балансировщику
  load_balancer {
    target_group_name = yandex_lb_target_group.lamp.name
  }
}

# ===========================
# 4. TARGET GROUP + LOAD BALANCER
# ===========================
resource "yandex_lb_target_group" "lamp" {
  name      = "lamp-target-group"
  folder_id = var.folder_id

  target {
    subnet_id = yandex_vpc_subnet.public.id
    # Адреса добавляются автоматически из instance group
  }
}

resource "yandex_lb_network_load_balancer" "main" {
  name      = "lamp-nlb"
  folder_id = var.folder_id

  listener {
    name = "http-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.lamp.id

    healthcheck {
      name = "http-health-check"
      http_options {
        port = 80
        path = "/"
      }
      interval            = 10
      timeout             = 5
      unhealthy_threshold = 3
      healthy_threshold   = 2
    }
  }
}