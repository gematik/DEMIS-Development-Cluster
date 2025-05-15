locals {
  #####################################################
  # Detect if a newer canary version has been provided
  #####################################################
  is_canary_defined   = var.deployment_information.canary != null && var.deployment_information.canary != {} && var.deployment_information.canary.version != null
  canary_version      = local.is_canary_defined ? var.deployment_information.canary.version : null
  canary_weight       = local.is_canary_defined ? var.deployment_information.canary.weight : null
  main_version        = var.deployment_information.main.version
  replacement_version = local.is_canary_defined ? var.deployment_information.canary.version : var.deployment_information.main.version
  available_versions  = var.deployment_information.deployment-strategy == "canary" ? toset(compact([local.main_version, local.canary_version])) : toset(compact([local.replacement_version]))
  #####################################################
  # evaluate given helm properties, including optional ones
  #####################################################
  image_tag_property          = var.helm_settings.chart_image_tag_property_name
  helm_repository             = var.helm_settings.helm_repository
  helm_repository_username    = var.helm_settings.helm_repository_username != null ? var.helm_settings.helm_repository_username : ""
  helm_repository_password    = var.helm_settings.helm_repository_password != null ? var.helm_settings.helm_repository_password : ""
  chart_name                  = coalesce(try(var.deployment_information.chart-name, var.application_name), var.application_name)
  istio_routing_chart_version = try(var.helm_settings.istio_routing_chart_version, null)
  deployment_timeout          = coalesce(try(var.helm_settings.deployment_timeout, 600), 600)
}

# Handle the deployment of the Helm Chart for the main and canary versions
resource "helm_release" "chart" {
  for_each            = local.available_versions
  name                = "${var.application_name}-${each.key}"
  repository          = local.helm_repository
  repository_username = local.helm_repository_username
  repository_password = local.helm_repository_password
  namespace           = var.namespace
  chart               = local.chart_name
  version             = each.key
  max_history         = 3
  lint                = true
  atomic              = true
  wait                = true
  wait_for_jobs       = true
  cleanup_on_fail     = true
  timeout             = local.deployment_timeout

  # check if values must be reused for the main version
  reuse_values = length(local.available_versions) > 1 && (each.key == local.main_version) ? true : false
  # When doing a canary deployment, we need to ensure that the values of the main version are not updated
  values = length(local.available_versions) > 1 && (each.key == local.main_version) ? [] : [var.application_values]

  set {
    name  = local.image_tag_property
    value = coalesce(try(var.deployment_information.image-tag, null), each.key)
  }
}

resource "helm_release" "istio" {
  count               = local.istio_routing_chart_version != null ? 1 : 0
  name                = "${var.application_name}-istio"
  repository          = local.helm_repository
  repository_username = local.helm_repository_username
  repository_password = local.helm_repository_password
  namespace           = var.namespace
  chart               = "istio-routing"
  version             = local.istio_routing_chart_version != null ? local.istio_routing_chart_version : ""
  max_history         = 3
  lint                = true
  atomic              = true
  wait                = true
  wait_for_jobs       = true
  cleanup_on_fail     = true
  values              = [var.istio_values]
  timeout             = local.deployment_timeout

  set {
    name  = "destinationSubsets.main.version"
    value = local.main_version
  }

  set {
    name  = "destinationSubsets.main.weight"
    value = var.deployment_information.main.weight
  }

  dynamic "set" {
    for_each = toset(compact([local.canary_version]))
    content {
      name  = "destinationSubsets.canary.version"
      value = set.value
    }
  }

  dynamic "set" {
    for_each = toset(compact([local.canary_weight]))
    content {
      name  = "destinationSubsets.canary.weight"
      value = set.value
    }
  }

  depends_on = [helm_release.chart]
}
