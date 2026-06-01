resource "yandex_vpc_network" "k8s" {
  name = "k8s-network"
}

resource "yandex_vpc_subnet" "k8s" {
  for_each = toset(["ru-central1-a", "ru-central1-b", "ru-central1-d"])

  name           = "k8s-subnet-${each.key}"
  zone           = each.key
  network_id     = yandex_vpc_network.k8s.id
  v4_cidr_blocks = ["10.0.${index(["ru-central1-a", "ru-central1-b", "ru-central1-d"], each.key)}.0/24"]
}