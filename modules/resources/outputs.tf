output "service_resource_definitions" {
  description = "Map containing all the resources definitions, grouped by service"
  value       = local.service_resource_definitions
}

output "istio_proxy_default_resources" {
  description = <<EOT
  Default values for istio proxy resource requests and limits
  DEPRECATED: This output 'istio_proxy_default_resources' is deprecated and will be removed in a future version."
EOT
  value       = local.istio_proxy_default_resources
}
