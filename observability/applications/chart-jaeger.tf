# Jaeger: own module in the jaeger folder (Deployment, Services, configuration)
locals {
  jaeger_name = "jaeger"
  # Enable only if explicitly set (active-versions.yaml)
  jaeger_deployment_information = try(var.deployment_information[local.jaeger_name], { main = { version = "0.0.0" }, enabled = false })
  jaeger_enabled                = try(local.jaeger_deployment_information.enabled, false)
}

module "jaeger" {
  source = "./jaeger"

  # Enable only if explicitly set
  count = local.jaeger_enabled ? 1 : 0

  target_namespace       = var.target_namespace
  jaeger_version         = coalesce(try(local.jaeger_deployment_information.canary.version, null), local.jaeger_deployment_information.main.version)
  jaeger_digest          = try(local.jaeger_deployment_information.canary.version, null) != null ? local.jaeger_deployment_information.canary.image-digest : local.jaeger_deployment_information.main.image-digest
  resource_definitions   = { jaeger = try(var.resource_definitions[local.jaeger_name], {}) }
  jaeger_max_traces      = coalesce(var.jaeger_max_traces, "50000")
  jaeger_storage_backend = coalesce(var.jaeger_storage_backend, "memory")
  jaeger_ttl_spans       = coalesce(var.jaeger_ttl_spans, "48h")
  # TCP Service for the in-mesh OTLP exports (Jaeger only runs in the observability namespace)
  internal_service_enabled = true
}
