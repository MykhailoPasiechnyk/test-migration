output "namespace_name" {
  value = kubernetes_namespace.namespace.metadata.0.name
}

output "service_account_name" {
  value = kubernetes_service_account.service_account.metadata.0.name
}

output "cluster_role_name" {
  value = kubernetes_cluster_role.cluster_role.metadata.0.name
}

output "pv_name" {
  value = kubernetes_persistent_volume.pv.metadata.0.name
}