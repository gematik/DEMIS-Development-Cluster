output "kiali_public_url" {
  depends_on  = [helm_release.this]
  description = "Kiali Dashboard URL (requires port-forwarding)"
  value       = "http://localhost:${local.port}/kiali"
}

output "kiali_service_url" {
  depends_on  = [helm_release.this]
  description = "Cluster-internal Kiali Dashboard URL"
  value       = "http://kiali.${var.target_namespace}.svc.cluster.local:${local.port}/kiali"
}
