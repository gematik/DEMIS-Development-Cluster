locals {
  # define Istio Helm Chart versions and charts
  istio_authentication_policies_chart         = coalesce(try(local.deployment_information["policies-authentications"].chart-name, ""), "policies-authentications-istio")
  istio_authentication_policies_chart_version = local.deployment_information["policies-authentications"].main.version
  istio_authorization_policies_chart          = coalesce(try(local.deployment_information["policies-authorizations"].chart-name, ""), "policies-authorizations-istio")
  istio_authorization_policies_chart_version  = local.deployment_information["policies-authorizations"].main.version
  istio_network_policies_chart                = coalesce(try(local.deployment_information["network-rules"].chart-name, ""), "network-rules-istio")
  istio_network_policies_chart_version        = local.deployment_information["network-rules"].main.version
}

###################################
# Install Istio Helm Charts
###################################
resource "helm_release" "authorization_policies_istio" {
  name                = "authorization-policies"
  chart               = local.istio_authorization_policies_chart
  version             = local.istio_authorization_policies_chart_version
  namespace           = var.target_namespace
  repository          = var.helm_repository
  repository_username = var.helm_repository_username
  repository_password = var.helm_repository_password
  max_history         = 3
  lint                = true
  atomic              = true
  wait                = true
  wait_for_jobs       = true
  cleanup_on_fail     = true
  timeout             = 600

  values = [
    templatefile("${local.chart_source_path}/policies-authorizations/istio-values.tftpl.yaml", {
      namespace                      = var.target_namespace,
      feature_flag_new_api_endpoints = try(module.application_flags.service_feature_flags["policies-authorizations"].FEATURE_FLAG_NEW_API_ENDPOINTS, false)
    })
  ]

  depends_on = [module.demis_namespace.name]
}

resource "helm_release" "authentication_policies_istio" {
  name                = "authentication-policies"
  chart               = local.istio_authentication_policies_chart
  version             = local.istio_authentication_policies_chart_version
  namespace           = var.target_namespace
  repository          = var.helm_repository
  repository_username = var.helm_repository_username
  repository_password = var.helm_repository_password
  max_history         = 3
  lint                = true
  atomic              = true
  wait                = true
  wait_for_jobs       = true
  cleanup_on_fail     = true
  timeout             = 600

  values = [
    templatefile("${local.chart_source_path}/policies-authentications/istio-values.tftpl.yaml", {
      issuer_hostname   = module.endpoints.auth_hostname,
      keycloak_hostname = module.endpoints.keycloak_svc_hostname
    })
  ]

  depends_on = [module.demis_namespace.name]
}

resource "helm_release" "network_rules_istio" {
  name                = "network-rules"
  chart               = local.istio_network_policies_chart
  version             = local.istio_network_policies_chart_version
  namespace           = var.target_namespace
  repository          = var.helm_repository
  repository_username = var.helm_repository_username
  repository_password = var.helm_repository_password
  max_history         = 3
  lint                = true
  atomic              = true
  wait                = true
  wait_for_jobs       = true
  cleanup_on_fail     = true
  timeout             = 600

  values = [
    templatefile("${local.chart_source_path}/network-rules/istio-values.tftpl.yaml", {
      cluster_gateway                = module.endpoints.istio_gateway_fullname,
      context_path                   = var.context_path,
      portal_ti_hosts                = [module.endpoints.portal_hostname],
      portal_internet_hosts          = [module.endpoints.meldung_hostname],
      feature_flag_new_api_endpoints = try(module.application_flags.service_feature_flags["network-rules"].FEATURE_FLAG_NEW_API_ENDPOINTS, false)
    })
  ]

  depends_on = [module.demis_namespace.name]
}
