resource "yandex_iam_service_account" "k8s_master" {
  name = "k8s-master"
}

resource "yandex_iam_service_account" "k8s_nodes" {
  name = "k8s-nodes"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_master_compute" {
  folder_id = var.folder_id
  role      = "compute.admin"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_master.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_nodes_compute" {
  folder_id = var.folder_id
  role      = "compute.editor"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_nodes.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_master_editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_master.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_master_agent" {
  folder_id = var.folder_id
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_master.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_master_vpc" {
  folder_id = var.folder_id
  role      = "vpc.publicAdmin"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_master.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_nodes_puller" {
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_nodes.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_master_lb" {
  folder_id = var.folder_id
  role      = "load-balancer.admin"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_master.id}"
}