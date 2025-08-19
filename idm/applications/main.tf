locals {
  # Define how are named the Files overriding the Helm Charts
  application_values_file = "app-values.tftpl.yaml"
  istio_values_file       = "istio-values.tftpl.yaml"

  # Get all the Service Names from the Deployment Information
  service_names = keys(var.deployment_information)
  # Define URL for accessing the DEMIS Endpoints
  core_hostname       = var.core_hostname
  bundid_idp_hostname = var.bundid_idp_hostname
  auth_hostname       = var.auth_hostname
  ti_idp_hostname     = var.ti_idp_hostname
  # Define common Helm Release Settings
  common_helm_release_settings = {
    chart_image_tag_property_name = "required.image.tag"
    helm_repository               = var.helm_repository
    helm_repository_username      = var.helm_repository_username
    helm_repository_password      = var.helm_repository_password
    istio_routing_chart_version   = try(var.deployment_information["istio-routing"].main.version)
    istio_routing_chart_name      = coalesce(try(var.deployment_information["istio-routing"].chart-name, ""), "istio-routing")
  }
  stage_configuration_data_version = try(var.deployment_information["stage-configuration-data"].main.version, "")
  stage_configuration_data_name    = try(var.deployment_information["stage-configuration-data"].chart-name, "")
}
