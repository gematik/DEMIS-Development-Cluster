output "kind_version" {
  description = "The version of KIND Image"
  value       = var.kind_image_tag
}

output "kind_endpoint" {
  description = "The Kubernetes API Endpoint"
  value       = kind_cluster.cluster.endpoint
}

output "kind_worker_nodes" {
  description = "The number of KIND Worker Nodes"
  value       = var.kind_worker_nodes
}

output "kubeconfig_path" {
  description = "The kubeconfig path for the cluster"
  value       = kind_cluster.cluster.kubeconfig_path
  # Kubeconfig must be generated before the kubeconfig path can be used
  depends_on = [kind_cluster.cluster]
}

output "api_server_ready" {
  description = "Signals that the kube-apiserver is ready after the ResourceQuota admission-plugin patch. Depend on this output to avoid connection errors during cluster setup."
  # Expose the null_resource id so dependent modules are forced to wait until
  # both the patch and the readiness poll have completed successfully.
  value      = null_resource.enable_resource_quota.id
  depends_on = [null_resource.enable_resource_quota]
}
