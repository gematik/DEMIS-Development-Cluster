output "service_url" {
  description = "The Cluster-internal gRPC address of the Audit Log Service"
  value       = "${local.app}.${var.target_namespace}.svc.cluster.local:${local.port}"
}
