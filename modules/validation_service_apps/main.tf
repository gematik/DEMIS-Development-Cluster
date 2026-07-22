locals {
  ##############################
  # Validation Service statics #
  ##############################
  http_rules_file = "http-rules.tftpl.yaml"

  ####################################
  # Validation Service http template #
  ####################################
  default_template_http_rules = fileexists("${var.external_template_directory}/validation-service/${local.http_rules_file}") ? "${var.external_template_directory}/validation-service/${local.http_rules_file}" : "${var.local_template_directory}/validation-service/${local.http_rules_file}"

  #############################
  # Validation Service params #
  #############################
  ## Check if stage-override templates are provided, otherwise use the project-defined ones
  template_http_rules = fileexists("${var.external_template_directory}/${var.name}/${local.http_rules_file}") ? "${var.external_template_directory}/${var.name}/${local.http_rules_file}" : (fileexists("${var.local_template_directory}/${var.name}/${local.http_rules_file}") ? "${var.local_template_directory}/${var.name}/${local.http_rules_file}" : local.default_template_http_rules)

  app_helm_settings = { for k, v in var.helm_release_settings : k => v if k != "istio_routing_chart_version" } # remove istio routing chart version from app helm settings, as it's only relevant for the istio chart
}

module "validation_service_metadata" {
  source = "../fhir-profiles-metadata"

  profile_type           = var.package_type
  deployment_information = var.deployment_information
  provisioning_mode      = var.profile_provisioning_mode
}

locals {

  # Major version per profile version: "6.1.4-b8" → "v6"
  # Used as compound key suffix: "validation-service-core:v6"
  vs_major_versions_ident = {
    for v in module.validation_service_metadata.current_profile_versions :
    v => "v${split(".", v)[0]}"
  }

  # Normalised Helm release names: dots → hyphens
  # Result: { "v6" => "validation-service-core-v6", ... }
  vs_variants = {
    for k, v in local.vs_major_versions_ident :
    v => {
      name : replace("${var.name}-${v}", ".", "-"),
      version : k
    }

  }

  # for_each only in distributed mode; dedicated/combined keep count semantics
  vs_use_for_each = var.profile_provisioning_mode != "dedicated"

  dedicated_subsets = {
    for k, v in module.validation_service_metadata.destination_subsets :
    k => [
      for entry in v : entry if entry.mode == "dedicated"
    ]
  }

  default_timeout_retries_block = var.timeout_retries[var.name]
  vs_timeout_retries_blocks = merge({
    for v in distinct(compact([for subset in concat(tolist(module.validation_service_metadata.destination_subsets.main), tolist(module.validation_service_metadata.destination_subsets.canary)) : "v${split(".", subset.labels.fhirProfileVersion)[0]}" if((subset.mode == "distributed") && can(length(subset.labels.fhirProfileVersion)))])) :
    v => try(var.timeout_retries["${var.name}:${v}"], local.default_timeout_retries_block)
    },
    { default = local.default_timeout_retries_block }
  )
}

module "validation_service" {
  source   = "../helm_deployment"
  for_each = local.vs_use_for_each || length(module.validation_service_metadata.current_profile_versions) == 1 ? local.vs_variants : {}

  namespace              = var.target_namespace
  application_name       = each.value.name
  deployment_information = var.deployment_information
  helm_settings          = local.app_helm_settings
  # Pass the values for the chart
  application_values = compact([templatefile(var.app_template_file, merge({
    namespace         = var.target_namespace
    provisioning_mode = "distributed", # for distributed subsets, the app values template needs to know to set the correct labels and not create dedicated subsets
    feature_flags = merge(
      try(var.feature_flags[var.name], {}),
      try(var.feature_flags["${var.name}:${each.key}"], {})
    ),
    config_options = merge(
      try(var.config_options[var.name], {}),
      try(var.config_options["${var.name}:${each.key}"], {})
    ),
    replica_count  = try(var.resource_definitions["${var.name}:${each.key}"].replicas, var.resource_definitions[var.name].replicas),
    resource_block = try(var.resource_definitions["${var.name}:${each.key}"].resource_block, var.resource_definitions[var.name].resource_block),
    istio_proxy_resources = merge(
      var.resource_definitions[var.name].istio_proxy_resources,
      try(var.resource_definitions["${var.name}:${each.key}"].istio_proxy_resources, {})
    ),
    profile_versions = [each.value.version],
    app_name         = each.value.name
    }, var.app_template_params)), var.app_values_override
  ])
}

module "validation_service_legacy" {
  source     = "../helm_deployment"
  count      = length(local.dedicated_subsets.main) > 0 || length(local.dedicated_subsets.canary) > 0 ? 1 : 0
  depends_on = [module.validation_service]

  namespace              = var.target_namespace
  application_name       = var.name
  deployment_information = var.deployment_information
  helm_settings          = local.app_helm_settings
  # Pass the values for the chart
  application_values = compact([templatefile(var.app_template_file, merge({
    namespace             = var.target_namespace
    provisioning_mode     = "dedicated" # for dedicated subsets, the app values template needs to know to set the correct labels and create dedicated subsets
    profile_versions      = module.validation_service_metadata.current_profile_versions,
    feature_flags         = try(var.feature_flags[var.name], {}),
    config_options        = try(var.config_options[var.name], {}),
    replica_count         = var.resource_definitions[var.name].replicas,
    resource_block        = var.resource_definitions[var.name].resource_block,
    istio_proxy_resources = var.resource_definitions[var.name].istio_proxy_resources,
    app_name              = var.name
  }, var.app_template_params)), var.app_values_override])
}

resource "helm_release" "istio" {
  name                = "${var.name}-istio"
  repository          = var.helm_release_settings.helm_repository
  repository_username = var.helm_release_settings.helm_repository_username
  repository_password = var.helm_release_settings.helm_repository_password
  namespace           = var.target_namespace
  chart               = var.helm_release_settings.istio_routing_chart_name
  version             = var.helm_release_settings.istio_routing_chart_version
  lint                = true
  atomic              = true
  wait                = true
  wait_for_jobs       = true
  cleanup_on_fail     = true
  values = compact([templatefile(var.istio_template_file, merge({
    app_name  = var.name
    namespace = var.target_namespace
    custom_virtual_service_http_rules = templatefile(local.template_http_rules, {
      subsets                  = module.validation_service_metadata.destination_subsets,
      http_timeout_retry_block = local.vs_timeout_retries_blocks,
    }),
    custom_destination_subsets = module.validation_service_metadata.destination_subsets,
  }, var.istio_template_params)), var.istio_values_override])
  timeout      = var.helm_release_settings.deployment_timeout
  reset_values = var.helm_release_settings.reset_values

  depends_on = [module.validation_service_legacy, module.validation_service]
}
