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
  futs_core_enabled = contains(local.service_names, local.futs_core_name) ? var.deployment_information[local.futs_core_name].enabled && !local.fhir_core_split_enabled : false
  ## Check if stage-override templates are provided, otherwise use the project-defined ones
  futs_core_template_app   = fileexists("${var.external_chart_path}/${local.futs_core_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.futs_core_name}/${local.application_values_file}" : "${path.module}/${local.futs_core_name}/${local.application_values_file}"
  futs_core_template_istio = fileexists("${var.external_chart_path}/${local.futs_core_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.futs_core_name}/${local.istio_values_file}" : "${path.module}/${local.futs_core_name}/${local.istio_values_file}"
  # http timeouts and retries
  futs_core_http_timeout_retry_block = { core : try(module.http_timeouts_retries.service_timeout_retry_definitions[local.futs_core_name], null) }

  ###########################
  # FUTS bedoccupancy       #
  ###########################
  futs_bedoccupancy_name = "${local.futs_name}-bedoccupancy"
  ## Verify whether the service is defined or the deployment is explicitly enabled
  futs_bedoccupancy_enabled = contains(local.service_names, local.futs_bedoccupancy_name) ? var.deployment_information[local.futs_bedoccupancy_name].enabled && local.fhir_core_split_enabled : false
  ## Check if stage-override templates are provided, otherwise use the project-defined ones
  futs_bedoccupancy_template_app   = fileexists("${var.external_chart_path}/${local.futs_bedoccupancy_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.futs_bedoccupancy_name}/${local.application_values_file}" : "${path.module}/${local.futs_bedoccupancy_name}/${local.application_values_file}"
  futs_bedoccupancy_template_istio = fileexists("${var.external_chart_path}/${local.futs_bedoccupancy_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.futs_bedoccupancy_name}/${local.istio_values_file}" : "${path.module}/${local.futs_bedoccupancy_name}/${local.istio_values_file}"
  ## Define override for resources
  # http timeouts and retries
  futs_bedoccupancy_http_timeout_retry_block = { bedoccupancy : try(module.http_timeouts_retries.service_timeout_retry_definitions[local.futs_bedoccupancy_name], null) }

  ###########################
  # FUTS disease            #
  ###########################
  futs_disease_name = "${local.futs_name}-disease"
  ## Verify whether the service is defined or the deployment is explicitly enabled
  futs_disease_enabled = contains(local.service_names, local.futs_disease_name) ? var.deployment_information[local.futs_disease_name].enabled && local.fhir_core_split_enabled : false
  ## Check if stage-override templates are provided, otherwise use the project-defined ones
  futs_disease_template_app   = fileexists("${var.external_chart_path}/${local.futs_disease_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.futs_disease_name}/${local.application_values_file}" : "${path.module}/${local.futs_disease_name}/${local.application_values_file}"
  futs_disease_template_istio = fileexists("${var.external_chart_path}/${local.futs_disease_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.futs_disease_name}/${local.istio_values_file}" : "${path.module}/${local.futs_disease_name}/${local.istio_values_file}"
  ## Define override for resources
  # http timeouts and retries
  futs_disease_http_timeout_retry_block = { disease : try(module.http_timeouts_retries.service_timeout_retry_definitions[local.futs_disease_name], null) }

  ###########################
  # FUTS pathogen           #
  ###########################
  futs_pathogen_name = "${local.futs_name}-pathogen"
  ## Verify whether the service is defined or the deployment is explicitly enabled
  futs_pathogen_enabled = contains(local.service_names, local.futs_pathogen_name) ? var.deployment_information[local.futs_pathogen_name].enabled && local.fhir_core_split_enabled : false
  ## Check if stage-override templates are provided, otherwise use the project-defined ones
  futs_pathogen_template_app   = fileexists("${var.external_chart_path}/${local.futs_pathogen_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.futs_pathogen_name}/${local.application_values_file}" : "${path.module}/${local.futs_pathogen_name}/${local.application_values_file}"
  futs_pathogen_template_istio = fileexists("${var.external_chart_path}/${local.futs_pathogen_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.futs_pathogen_name}/${local.istio_values_file}" : "${path.module}/${local.futs_pathogen_name}/${local.istio_values_file}"
  ## Define override for resources
  # http timeouts and retries
  futs_pathogen_http_timeout_retry_block = { pathogen : try(module.http_timeouts_retries.service_timeout_retry_definitions[local.futs_pathogen_name], null) }

  ###########################
  # FUTS IGS                #
  ###########################
  futs_igs_name = "${local.futs_name}-igs"
  ## Verify whether the service is defined or the deployment is explicitly enabled
  futs_igs_enabled = contains(local.service_names, local.futs_igs_name) ? var.deployment_information[local.futs_igs_name].enabled : false
  ## Check if stage-override templates are provided, otherwise use the project-defined ones
  futs_igs_template_app   = fileexists("${var.external_chart_path}/${local.futs_igs_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.futs_igs_name}/${local.application_values_file}" : "${path.module}/${local.futs_igs_name}/${local.application_values_file}"
  futs_igs_template_istio = fileexists("${var.external_chart_path}/${local.futs_igs_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.futs_igs_name}/${local.istio_values_file}" : "${path.module}/${local.futs_igs_name}/${local.istio_values_file}"
  # http timeouts and retries
  futs_igs_http_timeout_retry_block = { igs : try(module.http_timeouts_retries.service_timeout_retry_definitions[local.futs_igs_name], null) }

  futs_http_timeout_retry_block = merge(local.futs_core_http_timeout_retry_block, local.futs_bedoccupancy_http_timeout_retry_block, local.futs_disease_http_timeout_retry_block, local.futs_pathogen_http_timeout_retry_block, local.futs_igs_http_timeout_retry_block)
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
    namespace                     = var.target_namespace,
    context_path                  = var.context_path,
    cluster_gateway               = var.cluster_gateway,
    demis_hostnames               = local.demis_hostnames,
    profile_versions_core         = try(distinct([for v in module.futs_core_metadata[0].current_profile_versions : (regex("^([0-9]+)", v)[0])]), []),
    profile_versions_bedoccupancy = try(distinct([for v in module.futs_bedoccupancy_metadata[0].current_profile_versions : (regex("^([0-9]+)", v)[0])]), []),
    profile_versions_disease      = try(distinct([for v in module.futs_disease_metadata[0].current_profile_versions : (regex("^([0-9]+)", v)[0])]), []),
    profile_versions_pathogen     = try(distinct([for v in module.futs_pathogen_metadata[0].current_profile_versions : (regex("^([0-9]+)", v)[0])]), []),
    profile_versions_igs          = try(distinct([for v in module.futs_igs_metadata[0].current_profile_versions : (regex("^([0-9]+)", v)[0])]), []),
    http_timeout_retry_block      = local.futs_http_timeout_retry_block,
    istio_rules_block_external    = try(var.external_routing_configurations.rules[local.futs_name], [])
    fhir_core_split_enabled       = local.fhir_core_split_enabled
  })]
  timeout = 600
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [module.futs_core[0], module.futs_igs[0], module.futs_bedoccupancy[0], module.futs_disease[0], module.futs_pathogen[0]]
}

module "futs_core_metadata" {
  source = "../../modules/fhir-profiles-metadata"
  count  = local.futs_core_enabled ? 1 : 0

  profile_type           = "fhir-profile-snapshots"
  deployment_information = var.deployment_information[local.futs_core_name]
  provisioning_mode      = "distributed"
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
    image_pull_secrets      = var.pull_secrets,
    repository              = var.docker_registry,
    debug_enable            = var.debug_enabled,
    istio_enable            = var.istio_enabled,
    profile_version         = element(module.futs_core_metadata[0].current_profile_versions, -1),
    profile_docker_registry = var.docker_registry,
    feature_flags           = try(var.feature_flags[local.futs_core_name], {}),
    config_options          = try(var.config_options[local.futs_core_name], {}),
    replica_count           = var.resource_definitions[local.futs_core_name].replicas,
    resource_block          = var.resource_definitions[local.futs_core_name].resource_block
    istio_proxy_resources   = var.resource_definitions[local.futs_core_name].istio_proxy_resources,
    namespace               = var.target_namespace
  })
  istio_values = templatefile(local.futs_core_template_istio, {
    namespace    = var.target_namespace,
    context_path = var.context_path
  })
}

module "futs_bedoccupancy_metadata" {
  source = "../../modules/fhir-profiles-metadata"
  count  = local.futs_bedoccupancy_enabled ? 1 : 0

  profile_type           = "fhir-profile-snapshots"
  deployment_information = var.deployment_information[local.futs_bedoccupancy_name]
  provisioning_mode      = "distributed"
}

module "futs_bedoccupancy" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.futs_bedoccupancy_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.futs_bedoccupancy_name
  deployment_information = var.deployment_information[local.futs_bedoccupancy_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.package_registry]

  # Pass the values for the chart
  application_values = templatefile(local.futs_bedoccupancy_template_app, {
    image_pull_secrets      = var.pull_secrets,
    repository              = var.docker_registry,
    debug_enable            = var.debug_enabled,
    istio_enable            = var.istio_enabled,
    profile_version         = element(module.futs_bedoccupancy_metadata[0].current_profile_versions, -1),
    profile_docker_registry = var.docker_registry,
    feature_flags           = try(var.feature_flags[local.futs_bedoccupancy_name], {}),
    config_options          = try(var.config_options[local.futs_bedoccupancy_name], {}),
    replica_count           = var.resource_definitions[local.futs_bedoccupancy_name].replicas
    resource_block          = var.resource_definitions[local.futs_bedoccupancy_name].resource_block
    istio_proxy_resources   = var.resource_definitions[local.futs_bedoccupancy_name].istio_proxy_resources
    namespace               = var.target_namespace
  })
  istio_values = templatefile(local.futs_bedoccupancy_template_istio, {
    namespace    = var.target_namespace,
    context_path = var.context_path
  })
}

module "futs_disease_metadata" {
  source = "../../modules/fhir-profiles-metadata"
  count  = local.futs_disease_enabled ? 1 : 0

  profile_type           = "fhir-profile-snapshots"
  deployment_information = var.deployment_information[local.futs_disease_name]
  provisioning_mode      = "distributed"
}

module "futs_disease" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.futs_disease_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.futs_disease_name
  deployment_information = var.deployment_information[local.futs_disease_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.package_registry]

  # Pass the values for the chart
  application_values = templatefile(local.futs_disease_template_app, {
    image_pull_secrets      = var.pull_secrets,
    repository              = var.docker_registry,
    debug_enable            = var.debug_enabled,
    istio_enable            = var.istio_enabled,
    profile_version         = element(module.futs_disease_metadata[0].current_profile_versions, -1),
    profile_docker_registry = var.docker_registry,
    feature_flags           = try(var.feature_flags[local.futs_disease_name], {}),
    config_options          = try(var.config_options[local.futs_disease_name], {}),
    replica_count           = var.resource_definitions[local.futs_disease_name].replicas
    resource_block          = var.resource_definitions[local.futs_disease_name].resource_block
    istio_proxy_resources   = var.resource_definitions[local.futs_disease_name].istio_proxy_resources
    namespace               = var.target_namespace
  })
  istio_values = templatefile(local.futs_disease_template_istio, {
    namespace    = var.target_namespace,
    context_path = var.context_path
  })
}

module "futs_pathogen_metadata" {
  source = "../../modules/fhir-profiles-metadata"
  count  = local.futs_pathogen_enabled ? 1 : 0

  profile_type           = "fhir-profile-snapshots"
  deployment_information = var.deployment_information[local.futs_pathogen_name]
  provisioning_mode      = "distributed"
}

module "futs_pathogen" {
  source = "../../modules/helm_deployment"

  # Deploy if enabled
  count = local.futs_pathogen_enabled ? 1 : 0

  namespace              = var.target_namespace
  application_name       = local.futs_pathogen_name
  deployment_information = var.deployment_information[local.futs_pathogen_name]
  helm_settings          = local.common_helm_release_settings
  depends_on             = [module.package_registry]

  # Pass the values for the chart
  application_values = templatefile(local.futs_pathogen_template_app, {
    image_pull_secrets      = var.pull_secrets,
    repository              = var.docker_registry,
    debug_enable            = var.debug_enabled,
    istio_enable            = var.istio_enabled,
    profile_version         = element(module.futs_pathogen_metadata[0].current_profile_versions, -1),
    profile_docker_registry = var.docker_registry,
    feature_flags           = try(var.feature_flags[local.futs_pathogen_name], {}),
    config_options          = try(var.config_options[local.futs_pathogen_name], {}),
    replica_count           = var.resource_definitions[local.futs_pathogen_name].replicas
    resource_block          = var.resource_definitions[local.futs_pathogen_name].resource_block
    istio_proxy_resources   = var.resource_definitions[local.futs_pathogen_name].istio_proxy_resources
    namespace               = var.target_namespace
  })
  istio_values = templatefile(local.futs_pathogen_template_istio, {
    namespace    = var.target_namespace,
    context_path = var.context_path
  })
}

module "futs_igs_metadata" {
  source = "../../modules/fhir-profiles-metadata"
  count  = local.futs_igs_enabled ? 1 : 0

  profile_type           = "igs-profile-snapshots"
  deployment_information = var.deployment_information[local.futs_igs_name]
  provisioning_mode      = "distributed"
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
    image_pull_secrets      = var.pull_secrets,
    repository              = var.docker_registry,
    debug_enable            = var.debug_enabled,
    istio_enable            = var.istio_enabled,
    profile_version         = element(module.futs_igs_metadata[0].current_profile_versions, -1),
    profile_docker_registry = var.docker_registry,
    feature_flags           = try(var.feature_flags[local.futs_igs_name], {}),
    config_options          = try(var.config_options[local.futs_igs_name], {}),
    replica_count           = var.resource_definitions[local.futs_igs_name].replicas,
    resource_block          = var.resource_definitions[local.futs_igs_name].resource_block
    istio_proxy_resources   = var.resource_definitions[local.futs_igs_name].istio_proxy_resources,
    namespace               = var.target_namespace
  })
  istio_values = templatefile(local.futs_igs_template_istio, {
    namespace    = var.target_namespace,
    context_path = var.context_path
  })
}

locals {
  futs_package_statistic_major_version  = try(regex("^([0-9]+)", element((local.fhir_core_split_enabled ? module.futs_bedoccupancy_metadata[0] : module.futs_core_metadata[0]).current_profile_versions, -1))[0], "")
  futs_package_disease_major_version    = try(regex("^([0-9]+)", element((local.fhir_core_split_enabled ? module.futs_disease_metadata[0] : module.futs_core_metadata[0]).current_profile_versions, -1))[0], "")
  futs_package_laboratory_major_version = try(regex("^([0-9]+)", element((local.fhir_core_split_enabled ? module.futs_pathogen_metadata[0] : module.futs_core_metadata[0]).current_profile_versions, -1))[0], "")
}
