output "grafana_public_url" {
  depends_on  = [kubernetes_deployment_v1.this]
  description = "Grafana Dashboard Public URL (Requires Port Forwarding)"
  value       = "http://localhost:3000/"
}

output "grafana_service_url" {
  depends_on  = [kubernetes_deployment_v1.this]
  description = "Grafana Dashboard URL"
  value       = "http://${local.app}.${var.target_namespace}:${local.port}"
}
