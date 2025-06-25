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
  vs_core_name = "${local.vs_name}-core"
  # Verify whether the service is defined or the deployment is explicitly enabled
  vs_core_enabled = contains(local.service_names, local.vs_core_name) ? var.deployment_information[local.vs_core_name].enabled : false
  ## Check if stage-override templates are provided, otherwise use the project-defined ones
  vs_core_template_app   = fileexists("${var.external_chart_path}/${local.vs_core_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.vs_core_name}/${local.application_values_file}" : "${path.module}/${local.vs_core_name}/${local.application_values_file}"
  vs_core_template_istio = fileexists("${var.external_chart_path}/${local.vs_core_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.vs_core_name}/${local.istio_values_file}" : "${path.module}/${local.vs_core_name}/${local.istio_values_file}"
  # Define override for resources for Core
  vs_core_resources_overrides = try(var.resource_definitions[local.vs_core_name], {})
  vs_core_replicas            = lookup(local.vs_core_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.vs_core_name].replicas : null
  vs_core_resource_block      = lookup(local.vs_core_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.vs_core_name].resource_block : null

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
  vs_igs_resources_overrides = try(var.resource_definitions[local.vs_igs_name], {})
  vs_igs_replicas            = lookup(local.vs_igs_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.vs_igs_name].replicas : null
  vs_igs_resource_block      = lookup(local.vs_igs_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.vs_igs_name].resource_block : null

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
  vs_ars_resources_overrides = try(var.resource_definitions[local.vs_ars_name], {})
  vs_ars_replicas            = lookup(local.vs_ars_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.vs_ars_name].replicas : null
  vs_ars_resource_block      = lookup(local.vs_ars_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.vs_ars_name].resource_block : null

  profile_prefix = strcontains(var.docker_registry, "gematik1") ? "demis-" : ""
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
  chart               = "istio-routing"
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

  depends_on = [module.validation_service_core[0], module.validation_service_igs[0], module.validation_service_ars[0]]
}

module "validation_service_core_metadata" {
  source = "../../modules/fhir-profiles-metadata"

  profile_type              = "${local.profile_prefix}fhir-profile-snapshots"
  is_canary                 = can(length(var.deployment_information[local.vs_core_name].canary.version))
  deployment_information    = var.deployment_information[local.vs_core_name]
  default_profile_snapshots = local.fhir_profile_snapshots
}

module "validation_service_core" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.vs_core_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.vs_core_name
  deployment_information = var.deployment_information[local.vs_core_name]
  helm_settings          = local.common_helm_release_settings

  # Pass the values for the chart
  application_values = templatefile(local.vs_core_template_app, {
    image_pull_secrets      = var.pull_secrets,
    repository              = var.docker_registry,
    debug_enable            = var.debug_enabled,
    istio_enable            = var.istio_enabled,
    profile_version         = local.fhir_profile_snapshots,
    profile_docker_registry = var.docker_registry,
    feature_flags           = try(var.feature_flags[local.vs_core_name], {}),
    config_options          = try(var.config_options[local.vs_core_name], {}),
    replica_count           = local.vs_core_replicas,
    resource_block          = local.vs_core_resource_block
    profile_versions        = module.validation_service_core_metadata.current_profile_versions
    labels                  = yamlencode(module.validation_service_core_metadata.version_labels)
  })
  istio_values = templatefile(local.vs_core_template_istio, {
    namespace          = var.target_namespace
    destinationSubsets = yamlencode(module.validation_service_core_metadata.destination_subsets)
  })
}

module "validation_service_igs_metadata" {
  source = "../../modules/fhir-profiles-metadata"

  profile_type              = "${local.profile_prefix}igs-profile-snapshots"
  is_canary                 = can(length(var.deployment_information[local.vs_igs_name].canary.version))
  deployment_information    = var.deployment_information[local.vs_igs_name]
  default_profile_snapshots = local.igs_profile_snapshots
}

module "validation_service_igs" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.vs_igs_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.vs_igs_name
  deployment_information = var.deployment_information[local.vs_igs_name]
  helm_settings          = local.common_helm_release_settings

  # Pass the values for the chart
  application_values = templatefile(local.vs_igs_template_app, {
    image_pull_secrets      = var.pull_secrets,
    repository              = var.docker_registry,
    debug_enable            = var.debug_enabled,
    istio_enable            = var.istio_enabled,
    profile_version         = local.igs_profile_snapshots,
    profile_docker_registry = var.docker_registry,
    feature_flags           = try(var.feature_flags[local.vs_igs_name], {}),
    config_options          = try(var.config_options[local.vs_igs_name], {}),
    replica_count           = local.vs_igs_replicas,
    resource_block          = local.vs_igs_resource_block
    profile_versions        = module.validation_service_igs_metadata.current_profile_versions
    labels                  = yamlencode(module.validation_service_igs_metadata.version_labels)
  })
  istio_values = templatefile(local.vs_igs_template_istio, {
    namespace          = var.target_namespace
    destinationSubsets = yamlencode(module.validation_service_igs_metadata.destination_subsets)
  })
}

module "validation_service_ars_metadata" {
  # Deploy if enabled
  source = "../../modules/fhir-profiles-metadata"

  profile_type              = "${local.profile_prefix}ars-profile-snapshots"
  is_canary                 = can(length(var.deployment_information[local.vs_ars_name].canary.version))
  deployment_information    = var.deployment_information[local.vs_ars_name]
  default_profile_snapshots = local.ars_profile_snapshots
}

module "validation_service_ars" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.vs_ars_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.vs_ars_name
  deployment_information = var.deployment_information[local.vs_ars_name]
  helm_settings          = local.common_helm_release_settings

  # Pass the values for the chart
  application_values = templatefile(local.vs_ars_template_app, {
    image_pull_secrets      = var.pull_secrets,
    repository              = var.docker_registry,
    debug_enable            = var.debug_enabled,
    istio_enable            = var.istio_enabled,
    profile_version         = local.ars_profile_snapshots,
    profile_docker_registry = var.docker_registry,
    feature_flags           = try(var.feature_flags[local.vs_ars_name], {}),
    config_options          = try(var.config_options[local.vs_ars_name], {}),
    replica_count           = local.vs_ars_replicas,
    resource_block          = local.vs_ars_resource_block
    profile_versions        = module.validation_service_ars_metadata.current_profile_versions
    labels                  = yamlencode(module.validation_service_ars_metadata.version_labels)
  })
  istio_values = templatefile(local.vs_ars_template_istio, {
    namespace          = var.target_namespace
    destinationSubsets = yamlencode(module.validation_service_ars_metadata.destination_subsets)
  })
}
