locals {
  route_configuration_path = "${var.external_chart_path}/external_routing_configuration.yaml"
}

module "external_routing_configurations" {
  count              = try(var.project_feature_flags["FEATURE_FLAG_SEPARATION_API_VERSION_AND_PROFILE_VERSION"], false) ? 1 : 0
  source             = "../../modules/istio_routing_configurations"
  service_list       = local.service_names
  input_mapping_path = local.route_configuration_path
  global_template_variables = {
    namespace    = var.target_namespace,
    context_path = ""
  }
}
