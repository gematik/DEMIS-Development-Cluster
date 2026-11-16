output "namespace" {
  description = "Namespace of Prometheus, Grafana, Loki and the Audit Log Service"
  value       = local.namespace
}

output "kiali_jaeger_namespace" {
  description = "Namespace of Kiali and Jaeger"
  value       = local.kiali_jaeger_namespace
}

output "url_kiali" {
  description = "Kiali Dashboard URL"
  value = !local.kiali_enabled ? "Not deployed" : join("\n", [
    "Type the following command in the terminal. When you're done, press Ctrl+C to stop the forwarding:",
    "",
    "kubectl -n ${local.kiali_jaeger_namespace} port-forward services/kiali 20001:20001",
    "",
    "The service will be available at the address: ${module.kiali[0].kiali_public_url}",
    "",
    "Alternatively, you can type 'make kiali'"
  ])
}

output "url_grafana" {
  description = "Grafana Dashboard URL"
  value = !local.grafana_enabled ? "Not deployed" : join("\n", [
    "Type the following command in the terminal. When you're done, press Ctrl+C to stop the forwarding:",
    "",
    "kubectl -n ${local.namespace} port-forward service/grafana 3000:3000",
    "",
    "The service will be available at the address: ${module.grafana[0].grafana_public_url}",
    "",
    "Alternatively, you can type 'make grafana'"
  ])
}

output "url_jaeger" {
  description = "Jaeger URL"
  value = !local.jaeger_enabled ? "Not deployed" : join("\n", [
    "Type the following command in the terminal. When you're done, press Ctrl+C to stop the forwarding:",
    "",
    "kubectl -n ${local.kiali_jaeger_namespace} port-forward services/tracing 10000:80",
    "",
    "The service will be available at the address: http://localhost:10000",
    "",
    "Alternatively, you can type 'make jaeger'"
  ])
}

output "kms_encryption_key_used" {
  description = "The flag to indicate if the KMS encryption key is used"
  value       = length(var.kms_encryption_key) > 0 ? true : false
}
