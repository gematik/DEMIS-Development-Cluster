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