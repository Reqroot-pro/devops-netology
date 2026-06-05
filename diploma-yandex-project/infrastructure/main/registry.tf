resource "yandex_container_registry" "app" {
  name = "test-app-registry"
}

resource "yandex_container_registry_iam_binding" "pusher" {
  registry_id = yandex_container_registry.app.id
  role        = "container-registry.images.pusher"
  members     = ["serviceAccount:${var.ci_cd_sa_id}"]
}

resource "yandex_container_registry_iam_binding" "puller" {
  registry_id = yandex_container_registry.app.id
  role        = "container-registry.images.puller"
  members     = ["serviceAccount:${yandex_iam_service_account.k8s_nodes.id}"]
}