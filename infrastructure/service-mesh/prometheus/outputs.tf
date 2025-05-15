output "prometheus_port" {
  description = "The exposed Prometheus port"
  value       = local.port
}

output "prometheus_service_url" {
  depends_on  = [helm_release.this]
  description = "The Cluster-internal Prometheus URL"
  value       = "http://${local.app}.${var.target_namespace}:${local.port}"
}
