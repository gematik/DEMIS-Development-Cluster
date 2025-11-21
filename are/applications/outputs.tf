output "version_istio_routing_chart" {
  description = "Version of the Istio Routing Chart being used"
  value       = local.common_helm_release_settings.istio_routing_chart_version
}
