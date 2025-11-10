terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=1.5"
}

# Создаем сеть
resource "yandex_vpc_network" "this" {
  name = var.env_name
}

# Создаем подсеть
resource "yandex_vpc_subnet" "this" {
  name           = "${var.env_name}-${var.zone}"
  zone           = var.zone
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = [var.cidr]
}
