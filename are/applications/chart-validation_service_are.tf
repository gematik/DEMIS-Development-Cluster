locals {
  vs_http_rules_file = "http-rules.tftpl.yaml"
  vs_name = "validation-service"

  ####################################
  # Validation Service http template #
  ####################################
  vs_template_http_rules = fileexists("${var.external_chart_path}/${local.vs_name}/${local.vs_http_rules_file}") ? "${var.external_chart_path}/${local.vs_name}/${local.vs_http_rules_file}" : "${path.module}/${local.vs_name}/${local.vs_http_rules_file}"

  ###########################
  # Validation Service ARE  #
  ###########################
  vs_are_name = "${local.vs_name}-are"
  vs_are_enabled = contains(local.service_names, local.vs_are_name) ? var.deployment_information[local.vs_are_name].enabled : false
  vs_are_template_app   = fileexists("${var.external_chart_path}/${local.vs_are_name}/${local.application_values_file}") ? "${var.external_chart_path}/${local.vs_are_name}/${local.application_values_file}" : "${path.module}/${local.vs_are_name}/${local.application_values_file}"
  vs_are_template_istio = fileexists("${var.external_chart_path}/${local.vs_are_name}/${local.istio_values_file}") ? "${var.external_chart_path}/${local.vs_are_name}/${local.istio_values_file}" : "${path.module}/${local.vs_are_name}/${local.istio_values_file}"
  vs_are_resources_overrides = try(var.resource_definitions[local.vs_are_name], {})
  vs_are_replicas           = lookup(local.vs_are_resources_overrides, "replicas", null) != null ? var.resource_definitions[local.vs_are_name].replicas : null
  vs_are_resource_block     = lookup(local.vs_are_resources_overrides, "resource_block", null) != null ? var.resource_definitions[local.vs_are_name].resource_block : null
  vs_are_template_http_rules = fileexists("${var.external_chart_path}/${local.vs_are_name}/${local.vs_http_rules_file}") ? "${var.external_chart_path}/${local.vs_are_name}/${local.vs_http_rules_file}" : (fileexists("${path.module}/${local.vs_are_name}/${local.vs_http_rules_file}") ? "${path.module}/${local.vs_are_name}/${local.vs_http_rules_file}" : local.vs_template_http_rules)
  fhir_profile_metadata_api_version_are = var.profile_provisioning_mode_vs_are == null ? "v1" : "v2"

}

module "validation_service_are_metadata" {
  source = "../../modules/fhir-profiles-metadata"
  profile_type              = local.fhir_profile_metadata_api_version_are == "v1" && strcontains(var.docker_registry, "gematik1") ? "demis-are-profile-snapshots" : "are-profile-snapshots"
  is_canary                 = can(length(var.deployment_information[local.vs_are_name].canary.version))
  deployment_information    = var.deployment_information[local.vs_are_name]
  default_profile_snapshots = local.are_profile_snapshots
  provisioning_mode         = var.profile_provisioning_mode_vs_are
  api_version               = local.fhir_profile_metadata_api_version_are
}

resource "terraform_data" "validation_service_are_http_rules" {
  count = local.fhir_profile_metadata_api_version_are != "v1" ? 1 : 0
  input = templatefile(local.vs_are_template_http_rules, { subsets = module.validation_service_are_metadata.destination_subsets })
}

module "validation_service_are" {
  source = "../../modules/helm_deployment"
  count  = local.vs_are_enabled ? 1 : 0
  namespace              = var.target_namespace
  application_name       = local.vs_are_name
  deployment_information = var.deployment_information[local.vs_are_name]
  helm_settings          = local.common_helm_release_settings
  # remove? depends_on             = [module.package_registry]
  application_values = templatefile(local.vs_are_template_app, {
    image_pull_secrets                                 = var.pull_secrets,
    repository                                         = var.docker_registry,
    debug_enable                                       = var.debug_enabled,
    istio_enable                                       = var.istio_enabled,
    profile_version                                    = local.are_profile_snapshots,
    profile_docker_registry                            = "crg.apkg.io/noves1", # FIXME This will break at gematik var.docker_registry,
    feature_flags                                      = try(var.feature_flags[local.vs_are_name], {}),
    config_options                                     = try(var.config_options[local.vs_are_name], {}),
    replica_count                                      = local.vs_are_replicas,
    resource_block                                     = local.vs_are_resource_block,
    profile_versions                                   = module.validation_service_are_metadata.current_profile_versions,
    provisioning_mode                                  = var.profile_provisioning_mode_vs_are,
    labels                                             = try(yamlencode(module.validation_service_are_metadata.version_labels), "")
    profile_handling_api_version                       = local.fhir_profile_metadata_api_version_are
    feature_flag_new_istio_sidecar_requests_and_limits = try(var.feature_flags[local.vs_are_name].FEATURE_FLAG_NEW_ISTIO_SIDECAR_REQUEST_AND_LIMITS, false)
    istio_proxy_resources                              = try(local.vs_are_resources_overrides.istio_proxy_resources, var.istio_proxy_default_resources)
  })
  istio_values = templatefile(local.vs_are_template_istio, {
    namespace                         = var.target_namespace,
    custom_virtual_service_http_rules = try(terraform_data.validation_service_are_http_rules[0].output, ""),
    custom_destination_subsets        = module.validation_service_are_metadata.destination_subsets,
    profile_handling_api_version      = local.fhir_profile_metadata_api_version_are
    destinationSubsets                = try(yamlencode(module.validation_service_are_metadata.destination_subsets), "")
  })
}
