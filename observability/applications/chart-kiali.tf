# Kiali: own module in the kiali folder (chart, signing key, service account token)
locals {
  kiali_name = "kiali"
  # Enable only if explicitly set (active-versions.yaml)
  kiali_deployment_information = try(var.deployment_information[local.kiali_name], { main = { version = "0.0.0" }, enabled = false })
  kiali_enabled                = try(local.kiali_deployment_information.enabled, false)
  # URLs of Prometheus, Tracing (Jaeger) and Grafana: set from outside (application-configuration.tfvars),
  # otherwise the component of this namespace (null if not deployed)
  prometheus_url       = var.prometheus_service_url != null ? var.prometheus_service_url : (local.prometheus_enabled ? local.prometheus_service_url : null)
  tracing_url          = var.tracing_service_url != null ? var.tracing_service_url : (local.jaeger_enabled ? module.jaeger[0].tracing_service_url : null)
  tracing_port         = var.tracing_service_port != null ? var.tracing_service_port : (local.jaeger_enabled ? module.jaeger[0].grpc_query_port : "16685")
  grafana_url          = var.grafana_service_url != null ? var.grafana_service_url : (local.grafana_enabled ? module.grafana[0].grafana_service_url : null)
  grafana_external_url = var.grafana_public_url != null ? var.grafana_public_url : (local.grafana_enabled ? module.grafana[0].grafana_public_url : null)
}

module "kiali" {
  source = "./kiali"

  # Enable only if explicitly set
  count = local.kiali_enabled ? 1 : 0

  target_namespace      = var.target_namespace
  kiali_version         = coalesce(try(local.kiali_deployment_information.canary.version, null), local.kiali_deployment_information.main.version)
  kiali_helm_repository = var.helm_repository_by_key.kiali
  resource_definitions  = { kiali = try(var.resource_definitions[local.kiali_name], {}) }
  # Cluster-internal URLs of Prometheus, Tracing (Jaeger) and Grafana, an integration without URL is switched off
  prometheus_service_url = local.prometheus_url
  tracing_service_url    = local.tracing_url
  tracing_service_port   = local.tracing_port
  grafana_service_url    = local.grafana_url
  # Public URL for Grafana (might require Port-Forwarding)
  grafana_public_url = local.grafana_external_url
}
