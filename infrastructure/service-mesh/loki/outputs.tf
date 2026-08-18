output "loki_port" {
  description = "The client-facing Loki port (3100 for Monolithic, 80 for the SimpleScalable gateway)"
  value       = local.service_port
}

output "loki_service_url" {
  depends_on  = [helm_release.this]
  description = "The Cluster-internal Loki base URL (host:port for Push-API, OTLP and query endpoints)"
  value       = local.service_url
}

output "loki_push_url" {
  depends_on  = [helm_release.this]
  description = "The Loki native Push-API endpoint (Loki line protocol, HTTP)"
  value       = "${local.service_url}/loki/api/v1/push"
}

output "loki_otlp_logs_url" {
  depends_on  = [helm_release.this]
  description = <<-EOT
  The Loki native OTLP logs endpoint (OTLP over HTTP). Applications can push logs
  directly via OTLP/HTTP without a collector. Note: Loki only accepts OTLP over HTTP,
  there is no OTLP/gRPC log receiver - the gRPC port 9095 is for internal component
  traffic only.
  EOT
  value       = "${local.service_url}/otlp/v1/logs"
}
