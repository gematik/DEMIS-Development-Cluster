output "kiali_public_url" {
  depends_on  = [helm_release.this]
  description = "Kiali Dashboard URL (requires port-forwarding)"
  value       = "http://localhost:${local.port}/kiali"
}
