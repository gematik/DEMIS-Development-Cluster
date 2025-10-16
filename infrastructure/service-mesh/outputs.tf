output "istio_health_port" {
  description = "The Istio Health port"
  value       = module.istio.istio_health_port
}

output "istio_http_port" {
  description = "The Istio HTTP port"
  value       = module.istio.istio_http_port
}

output "istio_https_port" {
  description = "The Istio HTTPS port"
  value       = module.istio.istio_https_port
}

output "url_kiali" {
  description = "Kiali Dashboard URL"
  value = !var.kiali_enabled ? "Not deployed" : join("\n", [
    "Type the following command in the terminal. When you're done, press Ctrl+C to stop the forwarding:",
    "",
    "kubectl -n istio-system port-forward services/kiali 20001:20001",
    "",
    "The service will be available at the address: ${module.kiali[0].kiali_public_url}",
    "",
    "Alternatively, you can type 'make kiali'"
  ])
}

output "url_grafana" {
  description = "Grafana Dashboard URL"
  value = !var.grafana_enabled ? "Not deployed" : join("\n", [
    "Type the following command in the terminal. When you're done, press Ctrl+C to stop the forwarding:",
    "",
    "kubectl -n istio-system port-forward service/grafana 3000:3000",
    "",
    "The service will be available at the address: ${module.grafana[0].grafana_public_url}",
    "",
    "Alternatively, you can type 'make grafana'"
  ])
}

output "url_jaeger" {
  description = "Jaeger URL"
  value = !var.jaeger_enabled ? "Not deployed" : join("\n", [
    "Type the following command in the terminal. When you're done, press Ctrl+C to stop the forwarding:",
    "",
    "kubectl -n istio-system port-forward services/tracing 10000:80",
    "",
    "The service will be available at the address: http://localhost:10000",
    "",
    "Alternatively, you can type 'make jaeger'"
  ])
}
