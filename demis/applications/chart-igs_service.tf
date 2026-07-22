locals {
  igs_name = "igs-service"
  # Verify whether the service is defined or the deployment is explicitly enabled
  igs_enabled = contains(local.service_names, local.igs_name) ? var.deployment_information[local.igs_name].enabled : false
  # Selects the source of the mounted S3 credentials: true -> object-storage-service-secret, false -> minio-secret (default)
  igs_object_storage_service_enabled = try(var.feature_flags[local.igs_name].FEATURE_FLAG_USE_OBJECT_STORAGE_SERVICE_SECRET, false)
}

module "igs_service" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.igs_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.igs_name
  deployment_information = var.deployment_information[local.igs_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.object_storage_service[0]]

  # Pass the values for the chart
  application_values = compact([templatefile(local.chart_files[local.igs_name].app_template, {
    image_pull_secrets                     = var.pull_secrets,
    repository                             = var.docker_registry,
    namespace                              = var.target_namespace,
    debug_enable                           = var.debug_enabled,
    istio_enable                           = var.istio_enabled,
    core_hostname                          = var.core_hostname,
    storage_hostname                       = var.storage_hostname,
    s3_storage_url                         = local.s3_storage_url,
    feature_flags                          = try(var.feature_flags[local.igs_name], {}),
    config_options                         = try(var.config_options[local.igs_name], {}),
    replica_count                          = var.resource_definitions[local.igs_name].replicas,
    resource_block                         = var.resource_definitions[local.igs_name].resource_block,
    istio_proxy_resources                  = var.resource_definitions[local.igs_name].istio_proxy_resources,
    igs_encryption_certificate_checksum    = try(kubernetes_secret_v1.igs_encryption_certificate.metadata[0].annotations["checksum"], ""),
    object_storage_service_enabled         = local.igs_object_storage_service_enabled,
    object_storage_service_secret_checksum = local.igs_object_storage_service_enabled ? try(kubernetes_secret_v1.object_storage_service_credentials.metadata[0].annotations["checksum"], "") : try(kubernetes_secret_v1.minio_credentials.metadata[0].annotations["checksum"], "")
  }), local.chart_files[local.igs_name].app_values_override])
  istio_values = compact([templatefile(local.chart_files[local.igs_name].istio_template, {
    namespace                  = var.target_namespace,
    context_path               = var.context_path,
    cluster_gateway            = var.cluster_gateway,
    demis_hostnames            = local.demis_hostnames
    http_timeout_retry_block   = try(module.http_timeouts_retries.service_timeout_retry_definitions[local.igs_name], null)
    istio_rules_block_external = try(var.external_routing_configurations.rules[local.igs_name], [])
  }), local.chart_files[local.igs_name].istio_values_override])
}
