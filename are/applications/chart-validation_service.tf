locals {
  #################################
  # Validation Service Delegation #
  #################################
  vs_name = "validation-service"
  # Verify whether the service is defined or the deployment is explicitly enabled
  vs_enabled = contains(local.service_names, local.vs_name) ? var.deployment_information[local.vs_name].enabled : false
  ## Check if stage-override templates are provided, otherwise use the project-defined ones
  vs_template_istio = fileexists("${var.external_chart_path}/${local.vs_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.vs_name}/${local.istio_values_file}" : "${path.module}/${local.vs_name}/${local.istio_values_file}"

  ###########################
  # Validation Service ARE  #
  ###########################
  vs_are_name    = "${local.vs_name}-are"
  vs_are_enabled = contains(local.service_names, local.vs_are_name) ? var.deployment_information[local.vs_are_name].enabled : false
}

# Creates the Virtual Service for the Validation Service delegates
resource "helm_release" "validation_service" {
  # Deploy if enabled
  count = local.vs_enabled ? 1 : 0

  name                = "${local.vs_name}-istio"
  repository          = local.common_helm_release_settings.helm_repository
  repository_username = local.common_helm_release_settings.helm_repository_username
  repository_password = local.common_helm_release_settings.helm_repository_password
  namespace           = var.target_namespace
  chart               = local.common_helm_release_settings.istio_routing_chart_name
  version             = local.common_helm_release_settings.istio_routing_chart_version
  max_history         = 3
  lint                = true
  atomic              = true
  wait                = true
  wait_for_jobs       = true
  cleanup_on_fail     = true
  values = [templatefile(local.vs_template_istio, {
    namespace = var.target_namespace
  })]
  timeout = 600
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [module.validation_service_are_apps[0]]
}

moved {
  from = module.validation_service_are[0].helm_release.chart
  to   = module.validation_service_are_apps[0].module.validation_service_legacy[0].helm_release.chart
}
moved {
  from = module.validation_service_are[0].helm_release.istio[0]
  to   = module.validation_service_are_apps[0].helm_release.istio
}

module "validation_service_are_apps" {
  # Deploy if enabled
  count = local.vs_are_enabled ? 1 : 0

  source                      = "../../modules/validation_service_apps"
  name                        = local.vs_are_name
  deployment_information      = var.deployment_information[local.vs_are_name]
  helm_release_settings       = local.common_helm_release_settings
  target_namespace            = var.target_namespace
  external_template_directory = var.external_chart_path
  local_template_directory    = path.module
  profile_provisioning_mode   = coalesce(var.profile_provisioning_mode_vs_are, "dedicated")
  feature_flags               = var.feature_flags
  config_options              = var.config_options
  resource_definitions        = var.resource_definitions
  timeout_retries             = module.http_timeouts_retries.service_timeout_retry_definitions
  package_type                = "are-profile-snapshots"
  app_template_params = {
    image_pull_secrets      = var.pull_secrets,
    repository              = var.docker_registry,
    debug_enable            = var.debug_enabled,
    istio_enable            = var.istio_enabled,
    profile_docker_registry = var.docker_registry,
  }
  istio_template_params = {}
}
