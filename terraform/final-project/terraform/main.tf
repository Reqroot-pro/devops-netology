terraform {
  backend "s3" {
    bucket = "yc-terraform-state-b1g37f"
    key    = "terraform.tfstate"
    region = "ru-central1"
    use_lockfile = true

    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    use_path_style              = true
  }
}


terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.89"  # можно выбрать актуальную версию
    }
  }
}

provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
  service_account_key_file = "./sa-key.json"
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

# VPC
resource "yandex_vpc_network" "default" {
  name = "net"
}

# Подсеть
resource "yandex_vpc_subnet" "default" {
  name       = "subnet"
  zone       = var.zone
  network_id = yandex_vpc_network.default.id
  v4_cidr_blocks = [var.subnet_cidr]
}

# Группа безопасности
resource "yandex_vpc_security_group" "web-sg" {
  name        = "web-sg"
  network_id  = yandex_vpc_network.default.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    port           = -1
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# MySQL
resource "yandex_vpc_security_group" "mysql_sg" {
  name       = "mysql-sg"
  network_id = yandex_vpc_network.default.id

  ingress {
    protocol       = "TCP"
    port           = 3306
    v4_cidr_blocks = [var.subnet_cidr]  # доступ из подсети ВМ
  }

  egress {
    protocol       = "ANY"
    port           = -1
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}


# MYSQL кластер
resource "yandex_mdb_mysql_cluster" "mysql" {
  name        = "mysql-cluster"
  environment = "PRESTABLE"
  network_id  = yandex_vpc_network.default.id
  version     = "8.0"

  resources {
    resource_preset_id = "s2.micro"
    disk_type_id       = "network-ssd"
    disk_size          = 10
  }

  host {
    zone      = var.zone
    subnet_id = yandex_vpc_subnet.default.id
  }

  security_group_ids = [yandex_vpc_security_group.mysql_sg.id]
}

# Отдельно — база данных
resource "yandex_mdb_mysql_database" "appdb" {
  cluster_id = yandex_mdb_mysql_cluster.mysql.id
  name       = "appdb"
}

# Отдельно — пользователь
resource "yandex_mdb_mysql_user" "appuser" {
  cluster_id = yandex_mdb_mysql_cluster.mysql.id
  name       = "appuser"
  password   = "appuser_password"
  permission {
    database_name = yandex_mdb_mysql_database.appdb.name
    roles         = ["ALL"]
  }

  depends_on = [yandex_mdb_mysql_database.appdb]
}

# ВМ для приложения
resource "yandex_compute_instance" "app-vm" {
  name        = "app-vm"
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.default.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.web-sg.id]
  }

  metadata = {
    user-data = file("${path.module}/cloud-init.yaml")
    ssh-keys  = "ubuntu:${file("/home/devops/.ssh/ssh-key-asus-laptop.pub")}"
    serial-port-enable = "1"
  }

  depends_on = [yandex_mdb_mysql_cluster.mysql]
}

output "vm_public_ip" {
  value = yandex_compute_instance.app-vm.network_interface.0.nat_ip_address
}

output "mysql_host" {
  value = yandex_mdb_mysql_cluster.mysql.host.0.fqdn
}