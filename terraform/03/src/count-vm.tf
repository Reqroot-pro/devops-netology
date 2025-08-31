data "yandex_compute_image" "ubuntu" {
  family = var.ubuntu_image_family
}

resource "yandex_compute_instance" "web" {
  count = 2
  name  = "web-${count.index + 1}"

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

  metadata = {
    ssh-keys = "ubuntu:${file("/home/devops/.ssh/ssh-key-msi-desktop.pub")}"
  }

  depends_on = [yandex_compute_instance.db]
}
