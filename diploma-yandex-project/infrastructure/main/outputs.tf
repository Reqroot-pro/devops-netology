output "cluster_id" {
  value = yandex_kubernetes_cluster.k8s.id
}

output "registry_endpoint" {
  value = "cr.yandex/${yandex_container_registry.app.id}"
}