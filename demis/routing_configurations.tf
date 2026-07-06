locals {
  route_configuration_path = "${local.chart_source_path}/external_routing_configuration.yaml"
  fhir_package_renames = {
    bedoccupancy = "statistic"
    pathogen     = "laboratory"
  }
  fhir_package_versions = distinct(flatten([
    for service_name, info in local.deployment_information : [
      for profile in(can(length(info.canary.profiles)) ? info.canary.profiles : info.main.profiles) :
      "${lookup(local.fhir_package_renames, trimprefix(service_name, "validation-service-"), trimprefix(service_name, "validation-service-"))}:v${split(".", profile)[0]}"
    ]
    if startswith(service_name, "validation-service-") && (can(length(info.main.profiles)) || can(length(info.canary.profiles)))
  ]))
}

module "external_routing_configurations" {
  count                 = try(var.project_feature_flags["FEATURE_FLAG_SEPARATION_API_VERSION_AND_PROFILE_VERSION"], false) ? 1 : 0
  source                = "../modules/istio_routing_configurations"
  service_list          = keys(local.deployment_information)
  fhir_package_versions = local.fhir_package_versions
  input_mapping_path    = local.route_configuration_path
  global_template_variables = {
    namespace    = var.target_namespace,
    context_path = var.context_path
  }
}
