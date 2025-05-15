###################################
# Install Istio Helm Charts
###################################
resource "helm_release" "authorization_policies_istio" {
  name                = "authorization-policies"
  chart               = "policies-authorizations-istio"
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
      namespace = var.target_namespace
    })
  ]

  depends_on = [module.demis_namespace.name]
}

resource "helm_release" "authentication_policies_istio" {
  name                = "authentication-policies"
  chart               = "policies-authentications-istio"
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
      keycloak_hostname = module.endpoints.keycloak_svc_hostname,
    })
  ]

  depends_on = [module.demis_namespace.name]
}

resource "helm_release" "network_rules_istio" {
  name                = "network-rules"
  chart               = "network-rules-istio"
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
      cluster_gateway       = module.endpoints.istio_gateway_fullname,
      context_path          = var.context_path,
      portal_ti_hosts       = [module.endpoints.portal_hostname],
      portal_internet_hosts = [module.endpoints.meldung_hostname],
    })
  ]

  depends_on = [module.demis_namespace.name]
}
