resource "yandex_kubernetes_cluster" "k8s" {
  name       = var.cluster_name
  network_id = yandex_vpc_network.k8s.id

  service_account_id      = yandex_iam_service_account.k8s_master.id
  node_service_account_id = yandex_iam_service_account.k8s_nodes.id

  release_channel = "STABLE"

  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s_master_compute,
    yandex_resourcemanager_folder_iam_member.k8s_master_editor,
    yandex_resourcemanager_folder_iam_member.k8s_master_agent,
    yandex_resourcemanager_folder_iam_member.k8s_master_vpc,
    yandex_resourcemanager_folder_iam_member.k8s_master_lb,
    yandex_resourcemanager_folder_iam_member.k8s_nodes_compute,
    yandex_resourcemanager_folder_iam_member.k8s_nodes_puller
  ]

  master {
    version   = "1.33"
    public_ip = true

    regional {
      region = "ru-central1"

      location {
        zone      = "ru-central1-a"
        subnet_id = yandex_vpc_subnet.k8s["ru-central1-a"].id
      }

      location {
        zone      = "ru-central1-b"
        subnet_id = yandex_vpc_subnet.k8s["ru-central1-b"].id
      }

      location {
        zone      = "ru-central1-d"
        subnet_id = yandex_vpc_subnet.k8s["ru-central1-d"].id
      }
    }
  }
}