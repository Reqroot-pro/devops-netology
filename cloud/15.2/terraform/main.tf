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
# 2. ИСПОЛЬЗУЕМ СУЩЕСТВУЮЩИЙ АККАУНТ 'devops'
# ===========================
# ✅ Читаем данные существующего аккаунта, НЕ создаем новый
data "yandex_iam_service_account" "devops" {
  name = "devops"
}

# Создаем ключ только для этого аккаунта
resource "yandex_iam_service_account_static_access_key" "devops-key" {
  service_account_id = data.yandex_iam_service_account.devops.id
  description        = "Static key for Object Storage API"
}

# ===========================
# 3. OBJECT STORAGE
# ===========================
resource "yandex_storage_bucket" "main" {
  bucket = var.bucket_name
  force_destroy = true 
}

resource "yandex_storage_bucket_grant" "public_read" {
  bucket     = yandex_storage_bucket.main.bucket
  access_key = yandex_iam_service_account_static_access_key.devops-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.devops-key.secret_key

  grant {
    uri         = "http://acs.amazonaws.com/groups/global/AllUsers"
    type        = "Group"
    permissions = ["READ"]
  }
}

resource "yandex_storage_object" "logo" {
  bucket       = yandex_storage_bucket.main.bucket
  key          = var.image_object_name
  source       = "${path.module}/files/logo.png"
  content_type = "image/png"
  access_key   = yandex_iam_service_account_static_access_key.devops-key.access_key
  secret_key   = yandex_iam_service_account_static_access_key.devops-key.secret_key
}

# ===========================
# 5. INSTANCE GROUP (LAMP)
# ===========================
resource "yandex_compute_instance_group" "lamp_group" {
  name               = var.instance_group_name
  folder_id          = var.folder_id
  # ✅ Ссылаемся на существующий аккаунт devops
  service_account_id = data.yandex_iam_service_account.devops.id

  instance_template {
    platform_id = "standard-v2"

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

    network_interface {
      subnet_ids = [yandex_vpc_subnet.public.id]
      nat        = true
    }

    metadata = {
      ssh-keys = "ubuntu:${var.ssh_public_key}"
      user-data = templatefile("${path.module}/files/user-data.sh", {
        image_url = "https://${yandex_storage_bucket.main.bucket}.storage.yandexcloud.net/${var.image_object_name}"
      })
    }
  }

  scale_policy {
    fixed_scale { size = var.instance_count }
  }

  allocation_policy { zones = [var.zone] }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 1
  }

  load_balancer {
    target_group_name = "lamp-tg"
  }

  timeouts {
    create = "60m"
    update = "60m"
    delete = "20m"
  }
}

# ===========================
# 6. NETWORK LOAD BALANCER
# ===========================
resource "yandex_lb_network_load_balancer" "main" {
  name      = "lamp-nlb"
  folder_id = var.folder_id

  listener {
    name = "http-listener"
    port = 80
    external_address_spec { ip_version = "ipv4" }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.lamp_group.load_balancer[0].target_group_id

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