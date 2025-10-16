locals {
  minio_name = "minio"
  # Verify whether the service is defined or the deployment is explicitly enabled
  minio_enabled = contains(local.service_names, local.minio_name) ? var.deployment_information[local.minio_name].enabled : false
  # Check if stage-override templates are provided, otherwise use the project-defined ones
  minio_template_app   = fileexists("${var.external_chart_path}/${local.minio_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.minio_name}/${local.application_values_file}" : "${path.module}/${local.minio_name}/${local.application_values_file}"
  minio_template_istio = fileexists("${var.external_chart_path}/${local.minio_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.minio_name}/${local.istio_values_file}" : "${path.module}/${local.minio_name}/${local.istio_values_file}"
  # Define override for resources
  minio_resources_overrides = try(var.resource_definitions[local.minio_name], {})
  minio_replicas            = lookup(local.minio_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.minio_name].replicas : null
  minio_resource_block      = lookup(local.minio_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.minio_name].resource_block : null
}

module "minio" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.minio_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.minio_name
  deployment_information = var.deployment_information[local.minio_name]
  helm_settings          = local.common_helm_release_settings

  # Pass the values for the chart
  application_values = templatefile(local.minio_template_app, {
    image_pull_secrets    = var.pull_secrets,
    repository            = var.docker_registry,
    istio_enable          = var.istio_enabled,
    feature_flags         = try(var.feature_flags[local.minio_name], {}),
    config_options        = try(var.config_options[local.minio_name], {}),
    replica_count         = local.minio_replicas,
    resource_block        = local.minio_resource_block,
    minio_secret_checksum = try(kubernetes_secret.minio_credentials.metadata[0].annotations["checksum"], "")
  })
  istio_values = templatefile(local.minio_template_istio, {
    namespace        = var.target_namespace,
    context_path     = var.context_path,
    cluster_gateway  = var.cluster_gateway,
    storage_hostname = var.storage_hostname
  })
}
