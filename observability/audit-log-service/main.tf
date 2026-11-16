locals {
  app  = "audit-log-service"
  port = 50051
  # istio-routing chart (Service, DestinationRule); the infrastructure hands over the canary version as main
  istio_routing_chart_version = var.istio_routing_deployment_information.main.version
  istio_routing_chart_name    = coalesce(try(var.istio_routing_deployment_information.chart-name, ""), "istio-routing")
}

# Same deployment logic as in the application modules (versions, image tag and digest from the active-versions.yaml)
module "deployment" {
  source = "../../modules/helm_deployment"

  namespace              = var.target_namespace
  application_name       = local.app
  deployment_information = var.deployment_information
  helm_settings = {
    chart_image_tag_property_name = "required.image.tag"
    helm_repository               = var.helm_repository
    helm_repository_username      = var.helm_username
    helm_repository_password      = var.helm_password
    istio_routing_chart_version   = local.istio_routing_chart_version
    istio_routing_chart_name      = local.istio_routing_chart_name
  }

  application_values = [templatefile("${path.module}/chart-values.tftpl.yaml", {
    docker_registry    = var.docker_registry
    image_pull_secrets = var.image_pull_secrets
    replica_count      = var.replica_count
    port               = local.port
    filter_namespace   = var.filter_namespace
    audited_namespace  = var.audited_namespace
    fssr_enabled       = var.fssr_enabled
    fssw_enabled       = var.fssw_enabled
  })]

  # Service of the ext_proc gRPC port (cluster outbound|50051||audit-log-service.<namespace>)
  istio_values = [templatefile("${path.module}/istio-values.tftpl.yaml", {
    app_name  = local.app
    namespace = var.target_namespace
    port      = local.port
  })]
}
