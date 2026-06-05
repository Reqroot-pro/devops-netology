resource "yandex_kubernetes_node_group" "workers" {
  name       = "workers-preemptible"
  cluster_id = yandex_kubernetes_cluster.k8s.id
  version    = "1.33"

  allocation_policy {
    location { zone = "ru-central1-a" }
    location { zone = "ru-central1-b" }
    location { zone = "ru-central1-d" }
  }

  instance_template {
    platform_id = "standard-v3"

    resources {
      memory        = 2
      cores         = 2
      core_fraction = 20
    }

    boot_disk {
      type = "network-hdd"
      size = 30
    }

    scheduling_policy {
      preemptible = true
    }

    network_interface {
      subnet_ids = [
        yandex_vpc_subnet.k8s["ru-central1-a"].id,
        yandex_vpc_subnet.k8s["ru-central1-b"].id,
        yandex_vpc_subnet.k8s["ru-central1-d"].id
      ]
      nat = true
    }
  }

  scale_policy {
    fixed_scale { size = 3 }
  }

  deploy_policy {
    max_expansion   = 1
    max_unavailable = 1
  }
}