# ===========================
# VPC NETWORK
# ===========================
resource "yandex_vpc_network" "main" {
  name = var.vpc_name
}

# ===========================
# PUBLIC SUBNET
# ===========================
resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# ===========================
# NAT INSTANCE (в публичной подсети)
# ===========================
resource "yandex_compute_instance" "nat" {
  name        = "nat-instance"
  platform_id = "standard-v2"
  zone        = var.zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.nat_image_id
      type     = "network-hdd"
      size     = 20
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.public.id
    # Фиксированный внутренний IP для NAT
    ip_address = "192.168.10.254"
    # NAT-инстансу нужен публичный IP для выхода в интернет
    nat        = true
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
    # Включаем IP forwarding для работы NAT
    user-data = <<-EOF
              #cloud-config
              sysctl:
                net.ipv4.ip_forward: 1
              runcmd:
                - iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
                - iptables -A FORWARD -i eth0 -j ACCEPT
                - iptables -A FORWARD -o eth0 -j ACCEPT
              EOF
  }

  # Разрешаем пересоздание при изменении критичных параметров
  allow_stopping_for_update = true
}

# ===========================
# PUBLIC VM (с публичным IP)
# ===========================
resource "yandex_compute_instance" "public_vm" {
  name        = "public-vm"
  platform_id = "standard-v2"
  zone        = var.zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd842fimj1jg6vmfee6r"
      type     = "network-hdd"
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true # Публичный IP для доступа извне
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}

# ===========================
# PRIVATE SUBNET
# ===========================
resource "yandex_vpc_subnet" "private" {
  name           = "private"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  # Привязываем таблицу маршрутизации (создаётся ниже)
  route_table_id = yandex_vpc_route_table.private.id
}

# ===========================
# ROUTE TABLE для приватной подсети
# ===========================
resource "yandex_vpc_route_table" "private" {
  name       = "private-route-table"
  network_id = yandex_vpc_network.main.id

  static_route {
    # Весь трафик направляем на NAT-инстанс
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat.network_interface.0.ip_address
  }
}

# ===========================
# PRIVATE VM (только внутренний IP)
# ===========================
resource "yandex_compute_instance" "private_vm" {
  name        = "private-vm"
  platform_id = "standard-v2"
  zone        = var.zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id     = "fd842fimj1jg6vmfee6r"
      type         = "network-hdd"
      size         = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
    # Без nat = true — только внутренний IP
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}