locals {
  ###########################
  # FUTS Delegation Service #
  ###########################
  futs_name = "futs"
  ## Verify whether the service is defined or the deployment is explicitly enabled
  futs_enabled = contains(local.service_names, local.futs_name) ? var.deployment_information[local.futs_name].enabled : false
  ## Check if stage-override templates are provided, otherwise use the project-defined ones
  futs_template_istio = fileexists("${var.external_chart_path}/${local.futs_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.futs_name}/${local.istio_values_file}" : "${path.module}/${local.futs_name}/${local.istio_values_file}"

  ###########################
  # FUTS Core               #
  ###########################
  futs_core_name = "${local.futs_name}-core"
  ## Verify whether the service is defined or the deployment is explicitly enabled
  futs_core_enabled = contains(local.service_names, local.futs_core_name) ? var.deployment_information[local.futs_core_name].enabled : false
  ## Check if stage-override templates are provided, otherwise use the project-defined ones
  futs_core_template_app   = fileexists("${var.external_chart_path}/${local.futs_core_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.futs_core_name}/${local.application_values_file}" : "${path.module}/${local.futs_core_name}/${local.application_values_file}"
  futs_core_template_istio = fileexists("${var.external_chart_path}/${local.futs_core_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.futs_core_name}/${local.istio_values_file}" : "${path.module}/${local.futs_core_name}/${local.istio_values_file}"
  ## Define override for resources
  futs_core_resources_overrides = try(var.resource_definitions[local.futs_core_name], {})
  futs_core_replicas            = lookup(local.futs_core_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.futs_core_name].replicas : null
  futs_core_resource_block      = lookup(local.futs_core_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.futs_core_name].resource_block : null


  ###########################
  # FUTS IGS                #
  ###########################
  futs_igs_name = "${local.futs_name}-igs"
  ## Verify whether the service is defined or the deployment is explicitly enabled
  futs_igs_enabled = contains(local.service_names, local.futs_igs_name) ? var.deployment_information[local.futs_igs_name].enabled : false
  ## Check if stage-override templates are provided, otherwise use the project-defined ones
  futs_igs_template_app   = fileexists("${var.external_chart_path}/${local.futs_igs_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.futs_igs_name}/${local.application_values_file}" : "${path.module}/${local.futs_igs_name}/${local.application_values_file}"
  futs_igs_template_istio = fileexists("${var.external_chart_path}/${local.futs_igs_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.futs_igs_name}/${local.istio_values_file}" : "${path.module}/${local.futs_igs_name}/${local.istio_values_file}"
  ## Define override for resources
  futs_igs_resources_overrides = try(var.resource_definitions[local.futs_igs_name], {})
  futs_igs_replicas            = lookup(local.futs_igs_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.futs_igs_name].replicas : null
  futs_igs_resource_block      = lookup(local.futs_igs_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.futs_igs_name].resource_block : null
}

# Creates the Virtual Service for the Validation Service delegates
resource "helm_release" "futs" {
  # Deploy if enabled
  count = local.futs_enabled ? 1 : 0

  name                = "${local.futs_name}-istio"
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
  values = [templatefile(local.futs_template_istio, {
    namespace                      = var.target_namespace,
    context_path                   = var.context_path,
    cluster_gateway                = var.cluster_gateway,
    demis_hostnames                = local.demis_hostnames,
    feature_flag_new_api_endpoints = try(var.feature_flags[local.futs_name].FEATURE_FLAG_NEW_API_ENDPOINTS, false),
    profile_versions_core          = distinct([for v in module.futs_core_metadata.current_profile_versions : (regex("^([0-9]+)", v)[0])]),
    profile_versions_igs           = distinct([for v in module.futs_igs_metadata.current_profile_versions : (regex("^([0-9]+)", v)[0])])
  })]
  timeout = 600
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [module.futs_core[0], module.futs_igs[0]]
}

module "futs_core_metadata" {
  source = "../../modules/fhir-profiles-metadata"

  profile_type              = "fhir-profile-snapshots"
  is_canary                 = can(length(var.deployment_information[local.futs_core_name].canary.version))
  deployment_information    = var.deployment_information[local.futs_core_name]
  default_profile_snapshots = local.fhir_profile_snapshots
  provisioning_mode         = "distributed"
  api_version               = "v2"
}

module "futs_core" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.futs_core_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.futs_core_name
  deployment_information = var.deployment_information[local.futs_core_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.package_registry]

  # Pass the values for the chart
  application_values = templatefile(local.futs_core_template_app, {
    image_pull_secrets                                 = var.pull_secrets,
    repository                                         = var.docker_registry,
    debug_enable                                       = var.debug_enabled,
    istio_enable                                       = var.istio_enabled,
    profile_version                                    = element(module.futs_core_metadata.current_profile_versions, -1),
    profile_docker_registry                            = var.docker_registry,
    feature_flags                                      = try(var.feature_flags[local.futs_core_name], {}),
    config_options                                     = try(var.config_options[local.futs_core_name], {}),
    replica_count                                      = local.futs_core_replicas,
    resource_block                                     = local.futs_core_resource_block
    feature_flag_new_istio_sidecar_requests_and_limits = try(var.feature_flags[local.futs_core_name].FEATURE_FLAG_NEW_ISTIO_SIDECAR_REQUEST_AND_LIMITS, false)
    istio_proxy_resources                              = try(local.futs_core_resources_overrides.istio_proxy_resources, var.istio_proxy_default_resources)
    namespace                                          = var.target_namespace
  })
  istio_values = templatefile(local.futs_core_template_istio, {
    namespace    = var.target_namespace,
    context_path = var.context_path
  })
}

module "futs_igs_metadata" {
  source = "../../modules/fhir-profiles-metadata"

  profile_type              = "igs-profile-snapshots"
  is_canary                 = can(length(var.deployment_information[local.futs_igs_name].canary.version))
  deployment_information    = var.deployment_information[local.futs_igs_name]
  default_profile_snapshots = local.igs_profile_snapshots
  provisioning_mode         = "distributed"
  api_version               = "v2"
}

module "futs_igs" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.futs_igs_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.futs_igs_name
  deployment_information = var.deployment_information[local.futs_igs_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.package_registry]

  # Pass the values for the chart
  application_values = templatefile(local.futs_igs_template_app, {
    image_pull_secrets                                 = var.pull_secrets,
    repository                                         = var.docker_registry,
    debug_enable                                       = var.debug_enabled,
    istio_enable                                       = var.istio_enabled,
    profile_version                                    = element(module.futs_igs_metadata.current_profile_versions, -1),
    profile_docker_registry                            = var.docker_registry,
    feature_flags                                      = try(var.feature_flags[local.futs_igs_name], {}),
    config_options                                     = try(var.config_options[local.futs_igs_name], {}),
    replica_count                                      = local.futs_igs_replicas,
    resource_block                                     = local.futs_igs_resource_block
    feature_flag_new_istio_sidecar_requests_and_limits = try(var.feature_flags[local.futs_igs_name].FEATURE_FLAG_NEW_ISTIO_SIDECAR_REQUEST_AND_LIMITS, false)
    istio_proxy_resources                              = try(local.futs_igs_resources_overrides.istio_proxy_resources, var.istio_proxy_default_resources),
    namespace                                          = var.target_namespace
  })
  istio_values = templatefile(local.futs_igs_template_istio, {
    namespace    = var.target_namespace,
    context_path = var.context_path
  })
}
