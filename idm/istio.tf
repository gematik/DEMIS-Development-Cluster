locals {
  # define Istio Helm Chart versions
  istio_authorization_policies_chart         = coalesce(try(local.deployment_information["policies-authorizations"].chart-name, ""), "policies-authorizations-istio")
  istio_authorization_policies_chart_version = local.deployment_information["policies-authorizations"].main.version
  istio_network_policies_chart               = coalesce(try(local.deployment_information["network-rules"].chart-name, ""), "network-rules-istio")
  istio_network_policies_chart_version       = local.deployment_information["network-rules"].main.version
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
      namespace     = var.target_namespace,
      core_hostname = module.endpoints.core_hostname,
      auth_hostname = module.endpoints.auth_hostname
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
    file("${local.chart_source_path}/network-rules/istio-values.tftpl.yaml")
  ]

  depends_on = [module.demis_namespace.name]
}
