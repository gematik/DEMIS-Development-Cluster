output "namespace" {
  description = "Namespace of the observability services"
  value       = local.namespace
}

output "url_kiali" {
  description = "Cluster-internal Kiali URL, null if not deployed"
  value       = module.observability_services.url_kiali
}

output "url_grafana" {
  description = "Grafana URL of Kiali (set from outside or of this namespace), null if none"
  value       = module.observability_services.url_grafana
}

output "url_jaeger" {
  description = "Cluster-internal Jaeger UI URL, null if not deployed"
  value       = module.observability_services.url_jaeger
}

output "url_prometheus" {
  description = "Prometheus URL of Kiali (set from outside or of this namespace), null if none"
  value       = module.observability_services.url_prometheus
}

output "url_loki" {
  description = "Cluster-internal Loki URL (the password protected gateway if enabled), null if not deployed"
  value       = module.observability_services.url_loki
}

output "kms_encryption_key_used" {
  description = "The flag to indicate if the KMS encryption key is used"
  value       = length(var.kms_encryption_key) > 0 ? true : false
}
