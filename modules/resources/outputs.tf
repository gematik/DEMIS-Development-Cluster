output "service_resource_definitions" {
  description = "Map containing all the resources definitions, grouped by service"
  value       = local.service_resource_definitions
}

output "istio_proxy_default_resources" {
  description = "Default values for istio proxy resource requests and limits"
  value       = local.istio_proxy_default_resources
}
