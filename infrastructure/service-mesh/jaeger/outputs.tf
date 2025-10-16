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
  value       = "http://${kubernetes_service_v1.tracing.metadata[0].name}.${var.target_namespace}:${local.grpc_query_port}/jaeger"
}
