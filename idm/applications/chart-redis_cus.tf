locals {
  rediscus_name = "redis-cus"
  # Verify whether the service is defined or the deployment is explicitly enabled
  rediscus_enabled = contains(local.service_names, local.rediscus_name) ? var.deployment_information[local.rediscus_name].enabled : false
}

module "redis_cus" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.rediscus_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.rediscus_name
  deployment_information = var.deployment_information[local.rediscus_name]
  helm_settings          = local.common_helm_release_settings

  # Pass the values for the chart
  application_values = compact([templatefile(local.chart_files[local.rediscus_name].app_template, {
    image_pull_secrets                    = var.pull_secrets,
    repository                            = var.docker_registry,
    istio_enable                          = var.istio_enabled,
    replica_count                         = var.resource_definitions[local.rediscus_name].replicas,
    resource_block                        = var.resource_definitions[local.rediscus_name].resource_block,
    redis_cus_reader_credentials_checksum = try(kubernetes_secret_v1.redis_cus_reader_credentials.metadata[0].annotations["checksum"], ""),
    redis_cus_writer_credentials_checksum = try(kubernetes_secret_v1.redis_cus_writer_credentials.metadata[0].annotations["checksum"], ""),
    redis_cus_acl_checksum                = try(kubernetes_secret_v1.redis_cus_acl.metadata[0].annotations["checksum"], "")
    istio_proxy_resources                 = var.resource_definitions[local.rediscus_name].istio_proxy_resources,
    new_redis_cus_annotation_handling     = try(var.project_feature_flags["FEATURE_FLAG_NEW_REDIS_CUS_ANNOTATION_HANDLING"], false)
  }), local.chart_files[local.rediscus_name].app_values_override])
  istio_values = compact([templatefile(local.chart_files[local.rediscus_name].istio_template, {
    namespace = var.target_namespace
  }), local.chart_files[local.rediscus_name].istio_values_override])
}
