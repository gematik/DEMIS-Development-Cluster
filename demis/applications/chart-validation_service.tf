locals {
  vs_http_rules_file = "http-rules.tftpl.yaml"
  #################################
  # Validation Service Delegation #
  #################################
  vs_name = "validation-service"
  # Verify whether the service is defined or the deployment is explicitly enabled
  vs_enabled = contains(local.service_names, local.vs_name) ? var.deployment_information[local.vs_name].enabled : false
  ## Check if stage-override templates are provided, otherwise use the project-defined ones
  vs_template_istio = fileexists("${var.external_chart_path}/${local.vs_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.vs_name}/${local.istio_values_file}" : "${path.module}/${local.vs_name}/${local.istio_values_file}"

  ####################################
  # Validation Service http template #
  ####################################
  vs_template_http_rules = fileexists("${var.external_chart_path}/${local.vs_name}/${local.vs_http_rules_file}") ? "${var.external_chart_path}/${local.vs_name}/${local.vs_http_rules_file}" : "${path.module}/${local.vs_name}/${local.vs_http_rules_file}"

  ###########################
  # Validation Service Core #
  ###########################
  vs_core_name = "${local.vs_name}-core"
  # Verify whether the service is defined or the deployment is explicitly enabled
  vs_core_enabled = contains(local.service_names, local.vs_core_name) ? var.deployment_information[local.vs_core_name].enabled : false
  ## Check if stage-override templates are provided, otherwise use the project-defined ones
  vs_core_template_app   = fileexists("${var.external_chart_path}/${local.vs_core_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.vs_core_name}/${local.application_values_file}" : "${path.module}/${local.vs_core_name}/${local.application_values_file}"
  vs_core_template_istio = fileexists("${var.external_chart_path}/${local.vs_core_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.vs_core_name}/${local.istio_values_file}" : "${path.module}/${local.vs_core_name}/${local.istio_values_file}"
  # Define override for resources for Core
  vs_core_resources_overrides            = try(var.resource_definitions[local.vs_core_name], {})
  vs_core_replicas                       = lookup(local.vs_core_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.vs_core_name].replicas : null
  vs_core_resource_block                 = lookup(local.vs_core_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.vs_core_name].resource_block : null
  vs_core_template_http_rules            = fileexists("${var.external_chart_path}/${local.vs_core_name}/${local.vs_http_rules_file}") ? "${var.external_chart_path}/${local.vs_core_name}/${local.vs_http_rules_file}" : (fileexists("${path.module}/${local.vs_core_name}/${local.vs_http_rules_file}") ? "${path.module}/${local.vs_core_name}/${local.vs_http_rules_file}" : local.vs_template_http_rules)
  fhir_profile_metadata_api_version_core = var.profile_provisioning_mode_vs_core == null ? "v1" : "v2"
  # http timeouts and retries
  vs_core_http_timeout_retry_block = { core : try(module.http_timeouts_retries.service_timeout_retry_definitions[local.vs_core_name], null) }

  ###########################
  # Validation Service IGS  #
  ###########################
  vs_igs_name = "${local.vs_name}-igs"
  # Verify whether the service is defined or the deployment is explicitly enabled
  vs_igs_enabled = contains(local.service_names, local.vs_igs_name) ? var.deployment_information[local.vs_igs_name].enabled : false
  ## Check if stage-override templates are provided, otherwise use the project-defined ones
  vs_igs_template_app   = fileexists("${var.external_chart_path}/${local.vs_igs_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.vs_igs_name}/${local.application_values_file}" : "${path.module}/${local.vs_igs_name}/${local.application_values_file}"
  vs_igs_template_istio = fileexists("${var.external_chart_path}/${local.vs_igs_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.vs_igs_name}/${local.istio_values_file}" : "${path.module}/${local.vs_igs_name}/${local.istio_values_file}"
  # Define override for resources for IGS
  vs_igs_resources_overrides            = try(var.resource_definitions[local.vs_igs_name], {})
  vs_igs_replicas                       = lookup(local.vs_igs_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.vs_igs_name].replicas : null
  vs_igs_resource_block                 = lookup(local.vs_igs_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.vs_igs_name].resource_block : null
  vs_igs_template_http_rules            = fileexists("${var.external_chart_path}/${local.vs_igs_name}/${local.vs_http_rules_file}") ? "${var.external_chart_path}/${local.vs_igs_name}/${local.vs_http_rules_file}" : (fileexists("${path.module}/${local.vs_igs_name}/${local.vs_http_rules_file}") ? "${path.module}/${local.vs_igs_name}/${local.vs_http_rules_file}" : local.vs_template_http_rules)
  fhir_profile_metadata_api_version_igs = var.profile_provisioning_mode_vs_igs == null ? "v1" : "v2"
  # http timeouts and retries
  vs_igs_http_timeout_retry_block = { igs : try(module.http_timeouts_retries.service_timeout_retry_definitions[local.vs_igs_name], null) }

  ###########################
  # Validation Service ARS  #
  ###########################
  vs_ars_name = "${local.vs_name}-ars"
  # Verify whether the service is defined or the deployment is explicitly enabled
  vs_ars_enabled = contains(local.service_names, local.vs_ars_name) ? var.deployment_information[local.vs_ars_name].enabled : false
  ## Check if stage-override templates are provided, otherwise use the project-defined ones
  vs_ars_template_app   = fileexists("${var.external_chart_path}/${local.vs_ars_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.vs_ars_name}/${local.application_values_file}" : "${path.module}/${local.vs_ars_name}/${local.application_values_file}"
  vs_ars_template_istio = fileexists("${var.external_chart_path}/${local.vs_ars_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.vs_ars_name}/${local.istio_values_file}" : "${path.module}/${local.vs_ars_name}/${local.istio_values_file}"
  # Define override for resources for ARS
  vs_ars_resources_overrides            = try(var.resource_definitions[local.vs_ars_name], {})
  vs_ars_replicas                       = lookup(local.vs_ars_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.vs_ars_name].replicas : null
  vs_ars_resource_block                 = lookup(local.vs_ars_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.vs_ars_name].resource_block : null
  vs_ars_template_http_rules            = fileexists("${var.external_chart_path}/${local.vs_ars_name}/${local.vs_http_rules_file}") ? "${var.external_chart_path}/${local.vs_ars_name}/${local.vs_http_rules_file}" : (fileexists("${path.module}/${local.vs_ars_name}/${local.vs_http_rules_file}") ? "${path.module}/${local.vs_ars_name}/${local.vs_http_rules_file}" : local.vs_template_http_rules)
  fhir_profile_metadata_api_version_ars = var.profile_provisioning_mode_vs_ars == null ? "v1" : "v2"
  # http timeouts and retries
  vs_ars_http_timeout_retry_block = { ars : try(module.http_timeouts_retries.service_timeout_retry_definitions[local.vs_ars_name], null) }

  vs_http_timeout_retry_block = merge(local.vs_core_http_timeout_retry_block, local.vs_igs_http_timeout_retry_block, local.vs_ars_http_timeout_retry_block)
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
    namespace                = var.target_namespace
    http_timeout_retry_block = local.vs_http_timeout_retry_block
  })]
  timeout = 600
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [module.validation_service_core[0], module.validation_service_igs[0], module.validation_service_ars[0]]
}

module "validation_service_core_metadata" {
  source = "../../modules/fhir-profiles-metadata"

  profile_type              = local.fhir_profile_metadata_api_version_core == "v1" && strcontains(var.docker_registry, "gematik1") ? "demis-fhir-profile-snapshots" : "fhir-profile-snapshots"
  is_canary                 = can(length(var.deployment_information[local.vs_core_name].canary.version))
  deployment_information    = var.deployment_information[local.vs_core_name]
  default_profile_snapshots = local.fhir_profile_snapshots
  provisioning_mode         = var.profile_provisioning_mode_vs_core
  api_version               = local.fhir_profile_metadata_api_version_core
}

resource "terraform_data" "validation_service_core_http_rules" {
  count = local.fhir_profile_metadata_api_version_core != "v1" ? 1 : 0
  input = templatefile(local.vs_core_template_http_rules, {
    subsets = module.validation_service_core_metadata.destination_subsets
  })
}

module "validation_service_core" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.vs_core_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.vs_core_name
  deployment_information = var.deployment_information[local.vs_core_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.package_registry]

  # Pass the values for the chart
  application_values = templatefile(local.vs_core_template_app, {
    image_pull_secrets                                 = var.pull_secrets,
    repository                                         = var.docker_registry,
    debug_enable                                       = var.debug_enabled,
    istio_enable                                       = var.istio_enabled,
    profile_version                                    = local.fhir_profile_snapshots,
    profile_docker_registry                            = var.docker_registry,
    feature_flags                                      = try(var.feature_flags[local.vs_core_name], {}),
    config_options                                     = try(var.config_options[local.vs_core_name], {}),
    replica_count                                      = local.vs_core_replicas,
    resource_block                                     = local.vs_core_resource_block,
    profile_versions                                   = module.validation_service_core_metadata.current_profile_versions,
    provisioning_mode                                  = var.profile_provisioning_mode_vs_core,
    labels                                             = try(yamlencode(module.validation_service_core_metadata.version_labels), "")
    profile_handling_api_version                       = local.fhir_profile_metadata_api_version_core
    feature_flag_new_istio_sidecar_requests_and_limits = try(var.feature_flags[local.vs_core_name].FEATURE_FLAG_NEW_ISTIO_SIDECAR_REQUEST_AND_LIMITS, false)
    istio_proxy_resources                              = try(local.vs_core_resources_overrides.istio_proxy_resources, var.istio_proxy_default_resources),
    namespace                                          = var.target_namespace
  })
  istio_values = templatefile(local.vs_core_template_istio, {
    namespace                         = var.target_namespace,
    custom_virtual_service_http_rules = try(terraform_data.validation_service_core_http_rules[0].output, ""),
    custom_destination_subsets        = module.validation_service_core_metadata.destination_subsets,
    profile_handling_api_version      = local.fhir_profile_metadata_api_version_core
    destinationSubsets                = try(yamlencode(module.validation_service_core_metadata.destination_subsets), "")
  })
}

module "validation_service_igs_metadata" {
  source = "../../modules/fhir-profiles-metadata"

  profile_type              = local.fhir_profile_metadata_api_version_igs == "v1" && strcontains(var.docker_registry, "gematik1") ? "demis-igs-profile-snapshots" : "igs-profile-snapshots"
  is_canary                 = can(length(var.deployment_information[local.vs_igs_name].canary.version))
  deployment_information    = var.deployment_information[local.vs_igs_name]
  default_profile_snapshots = local.igs_profile_snapshots
  provisioning_mode         = var.profile_provisioning_mode_vs_igs
  api_version               = local.fhir_profile_metadata_api_version_igs
}

resource "terraform_data" "validation_service_igs_http_rules" {
  count = local.fhir_profile_metadata_api_version_igs != "v1" ? 1 : 0
  input = templatefile(local.vs_igs_template_http_rules, {
    subsets = module.validation_service_igs_metadata.destination_subsets
  })
}

module "validation_service_igs" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.vs_igs_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.vs_igs_name
  deployment_information = var.deployment_information[local.vs_igs_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.package_registry]

  # Pass the values for the chart
  application_values = templatefile(local.vs_igs_template_app, {
    image_pull_secrets                                 = var.pull_secrets,
    repository                                         = var.docker_registry,
    debug_enable                                       = var.debug_enabled,
    istio_enable                                       = var.istio_enabled,
    profile_version                                    = local.igs_profile_snapshots,
    profile_docker_registry                            = var.docker_registry,
    feature_flags                                      = try(var.feature_flags[local.vs_igs_name], {}),
    config_options                                     = try(var.config_options[local.vs_igs_name], {}),
    replica_count                                      = local.vs_igs_replicas,
    resource_block                                     = local.vs_igs_resource_block,
    profile_versions                                   = module.validation_service_igs_metadata.current_profile_versions,
    provisioning_mode                                  = var.profile_provisioning_mode_vs_igs,
    labels                                             = try(yamlencode(module.validation_service_igs_metadata.version_labels), "")
    profile_handling_api_version                       = local.fhir_profile_metadata_api_version_igs
    feature_flag_new_istio_sidecar_requests_and_limits = try(var.feature_flags[local.vs_core_name].FEATURE_FLAG_NEW_ISTIO_SIDECAR_REQUEST_AND_LIMITS, false)
    istio_proxy_resources                              = try(local.vs_igs_resources_overrides.istio_proxy_resources, var.istio_proxy_default_resources)
    namespace                                          = var.target_namespace
  })
  istio_values = templatefile(local.vs_igs_template_istio, {
    namespace                         = var.target_namespace,
    custom_virtual_service_http_rules = try(terraform_data.validation_service_igs_http_rules[0].output, ""),
    custom_destination_subsets        = module.validation_service_igs_metadata.destination_subsets,
    profile_handling_api_version      = local.fhir_profile_metadata_api_version_igs
    destinationSubsets                = try(yamlencode(module.validation_service_igs_metadata.destination_subsets), "")
  })
}

module "validation_service_ars_metadata" {
  source = "../../modules/fhir-profiles-metadata"

  profile_type              = local.fhir_profile_metadata_api_version_ars == "v1" && strcontains(var.docker_registry, "gematik1") ? "demis-ars-profile-snapshots" : "ars-profile-snapshots"
  is_canary                 = can(length(var.deployment_information[local.vs_ars_name].canary.version))
  deployment_information    = var.deployment_information[local.vs_ars_name]
  default_profile_snapshots = local.ars_profile_snapshots
  provisioning_mode         = var.profile_provisioning_mode_vs_ars
  api_version               = local.fhir_profile_metadata_api_version_ars
}

resource "terraform_data" "validation_service_ars_http_rules" {
  count = local.fhir_profile_metadata_api_version_ars != "v1" ? 1 : 0
  input = templatefile(local.vs_ars_template_http_rules, {
    subsets = module.validation_service_ars_metadata.destination_subsets
  })
}

module "validation_service_ars" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.vs_ars_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.vs_ars_name
  deployment_information = var.deployment_information[local.vs_ars_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.package_registry]

  # Pass the values for the chart
  application_values = templatefile(local.vs_ars_template_app, {
    image_pull_secrets                                 = var.pull_secrets,
    repository                                         = var.docker_registry,
    debug_enable                                       = var.debug_enabled,
    istio_enable                                       = var.istio_enabled,
    profile_version                                    = local.ars_profile_snapshots,
    profile_docker_registry                            = var.docker_registry,
    feature_flags                                      = try(var.feature_flags[local.vs_ars_name], {}),
    config_options                                     = try(var.config_options[local.vs_ars_name], {}),
    replica_count                                      = local.vs_ars_replicas,
    resource_block                                     = local.vs_ars_resource_block,
    profile_versions                                   = module.validation_service_ars_metadata.current_profile_versions,
    provisioning_mode                                  = var.profile_provisioning_mode_vs_ars,
    labels                                             = try(yamlencode(module.validation_service_ars_metadata.version_labels), "")
    profile_handling_api_version                       = local.fhir_profile_metadata_api_version_ars
    feature_flag_new_istio_sidecar_requests_and_limits = try(var.feature_flags[local.vs_core_name].FEATURE_FLAG_NEW_ISTIO_SIDECAR_REQUEST_AND_LIMITS, false)
    istio_proxy_resources                              = try(local.vs_ars_resources_overrides.istio_proxy_resources, var.istio_proxy_default_resources),
    namespace                                          = var.target_namespace
  })
  istio_values = templatefile(local.vs_ars_template_istio, {
    namespace                         = var.target_namespace,
    custom_virtual_service_http_rules = try(terraform_data.validation_service_ars_http_rules[0].output, ""),
    custom_destination_subsets        = module.validation_service_ars_metadata.destination_subsets,
    profile_handling_api_version      = local.fhir_profile_metadata_api_version_ars
    destinationSubsets                = try(yamlencode(module.validation_service_ars_metadata.destination_subsets), "")
  })
}
