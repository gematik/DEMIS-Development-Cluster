# Components of the observability namespace (as demis/applications): charts, secrets and timeouts/retries
locals {
  # Define how are named the Files overriding the Helm Charts
  application_values_file     = "app-values.tftpl.yaml"
  istio_values_file           = "istio-values.tftpl.yaml"
  application_values_override = "app-values.yaml"
  istio_values_override       = "istio-values.yaml"

  chart_dirs = distinct(concat(
    [for f in fileset(path.module, "*/${local.application_values_file}") : dirname(f)],
    [for f in fileset(path.module, "*/${local.istio_values_file}") : dirname(f)],
  ))
  chart_files = {
    for name in local.chart_dirs : name => {
      app_template          = fileexists("${var.external_chart_path}/${name}/${local.application_values_file}") ? "${var.external_chart_path}/${name}/${local.application_values_file}" : (fileexists("${path.module}/${name}/${local.application_values_file}") ? "${path.module}/${name}/${local.application_values_file}" : null)
      istio_template        = fileexists("${var.external_chart_path}/${name}/${local.istio_values_file}") ? "${var.external_chart_path}/${name}/${local.istio_values_file}" : (fileexists("${path.module}/${name}/${local.istio_values_file}") ? "${path.module}/${name}/${local.istio_values_file}" : null)
      app_values_override   = fileexists("${var.external_chart_path}/${name}/${local.application_values_override}") ? file("${var.external_chart_path}/${name}/${local.application_values_override}") : ""
      istio_values_override = fileexists("${var.external_chart_path}/${name}/${local.istio_values_override}") ? file("${var.external_chart_path}/${name}/${local.istio_values_override}") : ""
    }
  }
  # Helm release settings of the DEMIS charts (as in demis/applications), Service and DestinationRule via the istio-routing chart
  common_helm_release_settings = {
    chart_image_tag_property_name = "required.image.tag"
    helm_repository               = var.demis_helm_repository
    helm_repository_username      = var.demis_helm_repository_username
    helm_repository_password      = var.demis_helm_repository_password
    istio_routing_chart_version   = try(coalesce(try(var.deployment_information["istio-routing"].canary.version, null), var.deployment_information["istio-routing"].main.version), "")
    istio_routing_chart_name      = coalesce(try(var.deployment_information["istio-routing"].chart-name, ""), "istio-routing")
  }
}

