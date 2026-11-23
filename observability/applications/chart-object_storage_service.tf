locals {
  # Enabled in the active-versions.yaml (local, public); stages with an externally managed SeaweedFS disable it
  object_storage_service_enabled = try(var.deployment_information["object-storage-service"].enabled, false)

  object_storage_service_name = "object-storage-service"
  object_storage_service_port = 8080
}

# Own object storage of the namespace, only used by Loki
module "object_storage_service" {
  source = "../../modules/helm_deployment"

  count = local.object_storage_service_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.object_storage_service_name
  deployment_information = var.deployment_information[local.object_storage_service_name]
  helm_settings          = local.common_helm_release_settings

  # Pass the values for the chart
  application_values = compact([templatefile(local.chart_files[local.object_storage_service_name].app_template, {
    docker_registry    = var.docker_registry
    image_pull_secrets = var.pull_secrets
    secret_name        = local.object_storage_service_secret_name
    # Restarts the pod on changed credentials (the s3.json is rendered on start)
    secret_checksum = nonsensitive(sha256(jsonencode(local.object_storage_service_credentials_data)))
    volume_claim    = var.volume_claims["object-storage-volume-claim"]
    loki_bucket     = var.loki_s3_bucket
    sse_enabled     = local.object_storage_service_sse_enabled
    # Replicas, resources and sidecar resources (resources.tfvars)
    replica_count         = var.resource_definitions[local.object_storage_service_name].replicas
    resource_block        = var.resource_definitions[local.object_storage_service_name].resource_block
    istio_proxy_resources = var.resource_definitions[local.object_storage_service_name].istio_proxy_resources
    # Feature flags and config options (feature_flags.tfvars, config_options.tfvars)
    feature_flags  = lookup(var.feature_flags, local.object_storage_service_name, {})
    config_options = lookup(var.config_options, local.object_storage_service_name, {})
  }), local.chart_files[local.object_storage_service_name].app_values_override])

  istio_values = compact([templatefile(local.chart_files[local.object_storage_service_name].istio_template, {
    app_name                 = local.object_storage_service_name
    namespace                = var.target_namespace
    port                     = local.object_storage_service_port
    http_timeout_retry_block = try(module.http_timeouts_retries.service_timeout_retry_definitions[local.object_storage_service_name], null)
  }), local.chart_files[local.object_storage_service_name].istio_values_override])

  # The chart reads the secret by name
  depends_on = [kubernetes_secret_v1.object_storage_service_credentials]
}
