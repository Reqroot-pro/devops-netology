# ===========================
# 1. VPC NETWORK + SUBNETS
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

resource "yandex_vpc_subnet" "mysql_private" {
  count          = length(var.zones)
  name           = "mysql-private-${var.zones[count.index]}"
  zone           = var.zones[count.index]
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.private_subnet_cidrs[count.index]]
}

resource "yandex_vpc_subnet" "k8s_public" {
  count          = length(var.zones)
  name           = "k8s-public-${var.zones[count.index]}"
  zone           = var.zones[count.index]
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.k8s_public_subnet_cidrs[count.index]]
}

# ===========================
# 2. SERVICE ACCOUNT 'devops' & STATIC KEY
# ===========================
data "yandex_iam_service_account" "devops" {
  name = "devops"
}

resource "yandex_iam_service_account_static_access_key" "devops-key" {
  service_account_id = data.yandex_iam_service_account.devops.id
  description        = "Static key for Object Storage API"
}

# ===========================
# 3. KMS KEY & IAM
# ===========================
resource "yandex_kms_symmetric_key" "bucket_key" {
  name        = var.kms_key_name
  description = "Symmetric key for bucket encryption and K8s secrets"
}

resource "yandex_resourcemanager_folder_iam_member" "devops_kms" {
  folder_id = var.folder_id
  role      = "kms.keys.encrypterDecrypter"
  member    = "serviceAccount:${data.yandex_iam_service_account.devops.id}"
}

# ===========================
# 4. OBJECT STORAGE
# ===========================
resource "yandex_storage_bucket" "main" {
  bucket        = var.bucket_name
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = yandex_kms_symmetric_key.bucket_key.id
      }
    }
  }
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
      nat        = false
    }

    metadata = {
      ssh-keys  = "ubuntu:${var.ssh_public_key}"
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

# ===========================
# 7. MANAGED MYSQL CLUSTER
# ===========================
resource "yandex_mdb_mysql_cluster" "mysql" {
  name        = "netology-mysql"
  environment = "PRESTABLE"
  network_id  = yandex_vpc_network.main.id
  version     = "8.0"

  backup_window_start {
    hours   = 23
    minutes = 59
  }

  maintenance_window {
    type = "ANYTIME"
  }

  deletion_protection = true

  resources {
    resource_preset_id = "s2.micro"
    disk_type_id       = "network-hdd"
    disk_size          = 20
  }

  host {
    zone      = var.zones[0]
    subnet_id = yandex_vpc_subnet.mysql_private[0].id
  }
  host {
    zone      = var.zones[1]
    subnet_id = yandex_vpc_subnet.mysql_private[1].id
  }
  host {
    zone      = var.zones[2]
    subnet_id = yandex_vpc_subnet.mysql_private[2].id
  }
}

resource "yandex_mdb_mysql_database" "netology_db" {
  cluster_id = yandex_mdb_mysql_cluster.mysql.id
  name       = "netology_db"
}

resource "yandex_mdb_mysql_user" "app_user" {
  cluster_id = yandex_mdb_mysql_cluster.mysql.id
  name       = "netology_user"
  password   = var.db_password

  permission {
    database_name = yandex_mdb_mysql_database.netology_db.name
    roles         = ["ALL"]
  }
}

# ===========================
# 8. KUBERNETES CLUSTER & NODE GROUP
# ===========================
resource "yandex_iam_service_account" "k8s_sa" {
  name = "k8s-service-account"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_sa_editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_sa.id}"
}

resource "yandex_kubernetes_cluster" "main" {
  name                    = "netology-k8s"
  network_id              = yandex_vpc_network.main.id
  service_account_id      = yandex_iam_service_account.k8s_sa.id
  node_service_account_id = yandex_iam_service_account.k8s_sa.id

  release_channel = "STABLE"

  master {
    regional {
      region = "ru-central1"
      location {
        zone      = var.zones[0]
        subnet_id = yandex_vpc_subnet.k8s_public[0].id
      }
      location {
        zone      = var.zones[1]
        subnet_id = yandex_vpc_subnet.k8s_public[1].id
      }
      location {
        zone      = var.zones[2]
        subnet_id = yandex_vpc_subnet.k8s_public[2].id
      }
    }
    public_ip = true
  }

  kms_provider {
    key_id = yandex_kms_symmetric_key.bucket_key.id
  }
}

resource "yandex_kubernetes_node_group" "main" {
  cluster_id = yandex_kubernetes_cluster.main.id
  name       = "netology-node-group"

  instance_template {
    platform_id = "standard-v2"
    resources {
      cores         = 2
      memory        = 4
      core_fraction = 20
    }
    boot_disk {
      type = "network-hdd"
      size = 30
    }
    network_interface {
      subnet_ids = [yandex_vpc_subnet.k8s_public[0].id]
      nat        = true
    }
  }

  scale_policy {
    auto_scale {
      min     = 3
      max     = 6
      initial = 3
    }
  }

  allocation_policy {
    location {
      zone = var.zones[0]
    }
  }
}

# ===========================
# 9. OUTPUTS
# ===========================
output "k8s_connect_command" {
  description = "Команда для получения kubeconfig"
  value       = "yc managed-kubernetes cluster get-credentials ${yandex_kubernetes_cluster.main.name} --external"
}

output "mysql_host_fqdn" {
  description = "Адрес для подключения к MySQL"
  value       = yandex_mdb_mysql_cluster.mysql.host[0].fqdn
}

output "nlb_ip_address" {
  description = "Публичный IP Network Load Balancer"
  value       = one(yandex_lb_network_load_balancer.main.listener[*].external_address_spec[*].address)
}