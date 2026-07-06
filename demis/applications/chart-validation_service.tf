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
  # Validation Service Core #
  ###########################
  vs_core_name    = "${local.vs_name}-core"
  vs_core_enabled = contains(local.service_names, local.vs_core_name) ? var.deployment_information[local.vs_core_name].enabled && !local.fhir_core_split_enabled : false
  ###########################
  # Validation Service IGS  #
  ###########################
  vs_igs_name    = "${local.vs_name}-igs"
  vs_igs_enabled = contains(local.service_names, local.vs_igs_name) ? var.deployment_information[local.vs_igs_name].enabled : false
  ###########################
  # Validation Service ARS  #
  ###########################
  vs_ars_name    = "${local.vs_name}-ars"
  vs_ars_enabled = contains(local.service_names, local.vs_ars_name) ? var.deployment_information[local.vs_ars_name].enabled : false
  ####################################
  # Validation Service Bedoccupancy  #
  ####################################
  vs_bedoccupancy_name    = "${local.vs_name}-bedoccupancy"
  vs_bedoccupancy_enabled = contains(local.service_names, local.vs_bedoccupancy_name) ? var.deployment_information[local.vs_bedoccupancy_name].enabled && local.fhir_core_split_enabled : false
  ###############################
  # Validation Service Disease  #
  ###############################
  vs_disease_name    = "${local.vs_name}-disease"
  vs_disease_enabled = contains(local.service_names, local.vs_disease_name) ? var.deployment_information[local.vs_disease_name].enabled && local.fhir_core_split_enabled : false
  ################################
  # Validation Service Pathogen  #
  ################################
  vs_pathogen_name    = "${local.vs_name}-pathogen"
  vs_pathogen_enabled = contains(local.service_names, local.vs_pathogen_name) ? var.deployment_information[local.vs_pathogen_name].enabled && local.fhir_core_split_enabled : false
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
    namespace               = var.target_namespace
    fhir_core_split_enabled = local.fhir_core_split_enabled
  })]
  timeout = 600
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [module.validation_service_core_apps, module.validation_service_igs_apps, module.validation_service_ars_apps, module.validation_service_bedoccupancy_apps, module.validation_service_disease_apps, module.validation_service_pathogen_apps]
}

moved {
  from = module.validation_service_core[0].helm_release.chart
  to   = module.validation_service_core_apps[0].module.validation_service_legacy[0].helm_release.chart
}
moved {
  from = module.validation_service_core[0].helm_release.istio[0]
  to   = module.validation_service_core_apps[0].helm_release.istio
}

module "validation_service_core_apps" {
  # Deploy if enabled
  count      = local.vs_core_enabled ? 1 : 0
  depends_on = [module.package_registry]

  source                      = "../../modules/validation_service_apps"
  name                        = local.vs_core_name
  deployment_information      = var.deployment_information[local.vs_core_name]
  helm_release_settings       = local.common_helm_release_settings
  target_namespace            = var.target_namespace
  external_template_directory = var.external_chart_path
  local_template_directory    = path.module
  profile_provisioning_mode   = var.profile_provisioning_mode_vs_core
  feature_flags               = var.feature_flags
  config_options              = var.config_options
  resource_definitions        = var.resource_definitions
  timeout_retries             = module.http_timeouts_retries.service_timeout_retry_definitions
  package_type                = "fhir-profile-snapshots"
  app_template_params = {
    image_pull_secrets      = var.pull_secrets,
    repository              = var.docker_registry,
    debug_enable            = var.debug_enabled,
    istio_enable            = var.istio_enabled,
    profile_docker_registry = var.docker_registry,
  }
  istio_template_params = {}
}

moved {
  from = module.validation_service_igs[0].helm_release.chart
  to   = module.validation_service_igs_apps[0].module.validation_service_legacy[0].helm_release.chart
}
moved {
  from = module.validation_service_igs[0].helm_release.istio[0]
  to   = module.validation_service_igs_apps[0].helm_release.istio
}

module "validation_service_igs_apps" {
  # Deploy if enabled
  count      = local.vs_igs_enabled ? 1 : 0
  depends_on = [module.package_registry]

  source                      = "../../modules/validation_service_apps"
  name                        = local.vs_igs_name
  deployment_information      = var.deployment_information[local.vs_igs_name]
  helm_release_settings       = local.common_helm_release_settings
  target_namespace            = var.target_namespace
  external_template_directory = var.external_chart_path
  local_template_directory    = path.module
  profile_provisioning_mode   = var.profile_provisioning_mode_vs_igs
  feature_flags               = var.feature_flags
  config_options              = var.config_options
  resource_definitions        = var.resource_definitions
  timeout_retries             = module.http_timeouts_retries.service_timeout_retry_definitions
  package_type                = "igs-profile-snapshots"
  app_template_params = {
    image_pull_secrets      = var.pull_secrets,
    repository              = var.docker_registry,
    debug_enable            = var.debug_enabled,
    istio_enable            = var.istio_enabled,
    profile_docker_registry = var.docker_registry,
  }
  istio_template_params = {}
}

moved {
  from = module.validation_service_ars[0].helm_release.chart
  to   = module.validation_service_ars_apps[0].module.validation_service_legacy[0].helm_release.chart
}
moved {
  from = module.validation_service_ars[0].helm_release.istio[0]
  to   = module.validation_service_ars_apps[0].helm_release.istio
}

module "validation_service_ars_apps" {
  # Deploy if enabled
  count      = local.vs_ars_enabled ? 1 : 0
  depends_on = [module.package_registry]

  source                      = "../../modules/validation_service_apps"
  name                        = local.vs_ars_name
  deployment_information      = var.deployment_information[local.vs_ars_name]
  helm_release_settings       = local.common_helm_release_settings
  target_namespace            = var.target_namespace
  external_template_directory = var.external_chart_path
  local_template_directory    = path.module
  profile_provisioning_mode   = var.profile_provisioning_mode_vs_ars
  feature_flags               = var.feature_flags
  config_options              = var.config_options
  resource_definitions        = var.resource_definitions
  timeout_retries             = module.http_timeouts_retries.service_timeout_retry_definitions
  package_type                = "ars-profile-snapshots"
  app_template_params = {
    image_pull_secrets      = var.pull_secrets,
    repository              = var.docker_registry,
    debug_enable            = var.debug_enabled,
    istio_enable            = var.istio_enabled,
    profile_docker_registry = var.docker_registry,
  }
  istio_template_params = {}
}

moved {
  from = module.validation_service_bedoccupancy[0].helm_release.chart
  to   = module.validation_service_bedoccupancy_apps[0].module.validation_service_legacy[0].helm_release.chart
}
moved {
  from = module.validation_service_bedoccupancy[0].helm_release.istio[0]
  to   = module.validation_service_bedoccupancy_apps[0].helm_release.istio
}

module "validation_service_bedoccupancy_apps" {
  # Deploy if enabled
  count      = local.vs_bedoccupancy_enabled ? 1 : 0
  depends_on = [module.package_registry]

  source                      = "../../modules/validation_service_apps"
  name                        = local.vs_bedoccupancy_name
  deployment_information      = var.deployment_information[local.vs_bedoccupancy_name]
  helm_release_settings       = local.common_helm_release_settings
  target_namespace            = var.target_namespace
  external_template_directory = var.external_chart_path
  local_template_directory    = path.module
  feature_flags               = var.feature_flags
  config_options              = var.config_options
  resource_definitions        = var.resource_definitions
  profile_provisioning_mode   = var.profile_provisioning_mode_vs_bedoccupancy
  timeout_retries             = module.http_timeouts_retries.service_timeout_retry_definitions
  package_type                = "fhir-profile-snapshots"
  app_template_params = {
    image_pull_secrets      = var.pull_secrets,
    repository              = var.docker_registry,
    debug_enable            = var.debug_enabled,
    istio_enable            = var.istio_enabled,
    profile_docker_registry = var.docker_registry,
  }
  istio_template_params = {}
}

moved {
  from = module.validation_service_disease[0].helm_release.chart
  to   = module.validation_service_disease_apps[0].module.validation_service_legacy[0].helm_release.chart
}
moved {
  from = module.validation_service_disease[0].helm_release.istio[0]
  to   = module.validation_service_disease_apps[0].helm_release.istio
}

module "validation_service_disease_apps" {
  # Deploy if enabled
  count      = local.vs_disease_enabled ? 1 : 0
  depends_on = [module.package_registry]

  source                      = "../../modules/validation_service_apps"
  name                        = local.vs_disease_name
  deployment_information      = var.deployment_information[local.vs_disease_name]
  helm_release_settings       = local.common_helm_release_settings
  target_namespace            = var.target_namespace
  external_template_directory = var.external_chart_path
  local_template_directory    = path.module
  profile_provisioning_mode   = var.profile_provisioning_mode_vs_disease
  feature_flags               = var.feature_flags
  config_options              = var.config_options
  resource_definitions        = var.resource_definitions
  timeout_retries             = module.http_timeouts_retries.service_timeout_retry_definitions
  package_type                = "fhir-profile-snapshots"
  app_template_params = {
    image_pull_secrets      = var.pull_secrets,
    repository              = var.docker_registry,
    debug_enable            = var.debug_enabled,
    istio_enable            = var.istio_enabled,
    profile_docker_registry = var.docker_registry,
  }
  istio_template_params = {}
}

moved {
  from = module.validation_service_pathogen[0].helm_release.chart
  to   = module.validation_service_pathogen_apps[0].module.validation_service_legacy[0].helm_release.chart
}
moved {
  from = module.validation_service_pathogen[0].helm_release.istio[0]
  to   = module.validation_service_pathogen_apps[0].helm_release.istio
}

module "validation_service_pathogen_apps" {
  # Deploy if enabled
  count      = local.vs_pathogen_enabled ? 1 : 0
  depends_on = [module.package_registry]

  source                      = "../../modules/validation_service_apps"
  name                        = local.vs_pathogen_name
  deployment_information      = var.deployment_information[local.vs_pathogen_name]
  helm_release_settings       = local.common_helm_release_settings
  target_namespace            = var.target_namespace
  external_template_directory = var.external_chart_path
  local_template_directory    = path.module
  profile_provisioning_mode   = var.profile_provisioning_mode_vs_pathogen
  feature_flags               = var.feature_flags
  config_options              = var.config_options
  resource_definitions        = var.resource_definitions
  timeout_retries             = module.http_timeouts_retries.service_timeout_retry_definitions
  package_type                = "fhir-profile-snapshots"
  app_template_params = {
    image_pull_secrets      = var.pull_secrets,
    repository              = var.docker_registry,
    debug_enable            = var.debug_enabled,
    istio_enable            = var.istio_enabled,
    profile_docker_registry = var.docker_registry,
  }
  istio_template_params = {}
}
