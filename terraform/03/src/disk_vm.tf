# Создание дополнительных дисков
resource "yandex_compute_disk" "extra" {
  count = 3
  name  = "extra-disk-${count.index + 1}"
  size  = 1
  type  = "network-hdd"
  zone  = var.default_zone
}

# ВМ storage
resource "yandex_compute_instance" "storage" {
  name = "storage"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.extra
    content {
      disk_id     = secondary_disk.value.id
      auto_delete = true
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${file("/home/devops/.ssh/ssh-key-msi-desktop.pub")}"
  }
}
