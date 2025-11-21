locals {
  # define Istio Helm Chart versions
  istio_authentication_policies_chart         = coalesce(try(local.deployment_information["policies-authentications"].chart-name, ""), "policies-authentications-istio")
  istio_authentication_policies_chart_version = local.deployment_information["policies-authentications"].main.version
  istio_authorization_policies_chart          = coalesce(try(local.deployment_information["policies-authorizations"].chart-name, ""), "policies-authorizations-istio")
  istio_authorization_policies_chart_version  = local.deployment_information["policies-authorizations"].main.version
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
      namespace = var.target_namespace,
    })
  ]

  depends_on = [module.are_namespace.name]
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

  depends_on = [module.are_namespace.name]
}
