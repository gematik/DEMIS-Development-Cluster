output "http_query_port" {
  description = "The HTTP query port"
  value       = local.http_query_port
}

output "grpc_query_port" {
  description = "The gRPC query port"
  value       = local.grpc_query_port
}

output "otlp_grpc_port" {
  description = "The OpenTelemetry gRPC port"
  value       = local.grpc_otlp_collector_port
}

output "otlp_http_port" {
  description = "The OpenTelemetry HTTP port"
  value       = local.http_otlp_collector_port
}

output "tracing_service_url" {
  depends_on  = [kubernetes_deployment_v1.this]
  description = "The Jaeger gRPC Query URL"
  value       = "http://${kubernetes_service_v1.tracing.metadata[0].name}.${var.target_namespace}.svc.cluster.local:${local.grpc_query_port}"
}

output "tracing_ui_url" {
  depends_on  = [kubernetes_deployment_v1.this]
  description = "Cluster-internal Jaeger UI URL"
  value       = "http://${kubernetes_service_v1.tracing.metadata[0].name}.${var.target_namespace}.svc.cluster.local"
}

output "otlp_internal_grpc_url" {
  description = "The OTLP/gRPC endpoint for the workloads inside the mesh, null if the internal Service is not created"
  value       = var.internal_service_enabled ? "http://${local.otlp_internal_service}.${var.target_namespace}.svc.cluster.local:${local.grpc_otlp_collector_port}" : null
}
