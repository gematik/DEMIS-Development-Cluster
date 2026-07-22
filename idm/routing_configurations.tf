locals {
  route_configuration_path = "${local.chart_source_path}/external_routing_configuration.yaml"
}

module "external_routing_configurations" {
  source             = "../modules/istio_routing_configurations"
  service_list       = keys(local.deployment_information)
  input_mapping_path = local.route_configuration_path
  global_template_variables = {
    namespace    = var.target_namespace,
    context_path = ""
  }
}
