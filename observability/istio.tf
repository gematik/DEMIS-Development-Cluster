locals {
  # define Istio Helm Chart versions and charts
  istio_authorization_policies_chart         = coalesce(try(local.deployment_information["policies-authorizations"].chart-name, ""), "policies-authorizations-istio")
  istio_authorization_policies_chart_version = coalesce(try(local.deployment_information["policies-authorizations"].canary.version, null), local.deployment_information["policies-authorizations"].main.version)
  istio_network_policies_chart               = coalesce(try(local.deployment_information["network-rules"].chart-name, ""), "network-rules-istio")
  istio_network_policies_chart_version       = coalesce(try(local.deployment_information["network-rules"].canary.version, null), local.deployment_information["network-rules"].main.version)
}

###################################
# Install Istio Helm Charts
###################################
resource "helm_release" "authorization_policies_istio" {
  # Only with the observability namespace (project feature flag)
  count               = local.namespace_enabled && try(local.deployment_information["policies-authorizations"].enabled, false) ? 1 : 0
  name                = "authorization-policies"
  chart               = local.istio_authorization_policies_chart
  version             = local.istio_authorization_policies_chart_version
  namespace           = local.namespace
  repository          = local.demis_helm_repository
  repository_username = local.demis_helm_repository_username
  repository_password = local.demis_helm_repository_password
  max_history         = 3
  lint                = true
  atomic              = true
  wait                = true
  wait_for_jobs       = true
  cleanup_on_fail     = true
  timeout             = 600

  values = compact([
    fileexists("${local.chart_source_path}/policies-authorizations/istio-values.tftpl.yaml") ? templatefile("${local.chart_source_path}/policies-authorizations/istio-values.tftpl.yaml", {
      namespace                      = local.namespace,
      audit_log_service_fssr_enabled = try(var.project_feature_flags["FEATURE_FLAG_AUDIT_LOG_FSSR_ENABLED"], false),
      audit_log_service_fssw_enabled = try(var.project_feature_flags["FEATURE_FLAG_AUDIT_LOG_FSSW_ENABLED"], false)
    }) : "",
    fileexists("${local.chart_source_path}/policies-authorizations/istio-values.yaml") ? file("${local.chart_source_path}/policies-authorizations/istio-values.yaml") : "",
  ])
}

resource "helm_release" "network_rules_istio" {
  # Only with the observability namespace (project feature flag)
  count               = local.namespace_enabled && try(local.deployment_information["network-rules"].enabled, false) ? 1 : 0
  name                = "network-rules"
  chart               = local.istio_network_policies_chart
  version             = local.istio_network_policies_chart_version
  namespace           = local.namespace
  repository          = local.demis_helm_repository
  repository_username = local.demis_helm_repository_username
  repository_password = local.demis_helm_repository_password
  max_history         = 3
  lint                = true
  atomic              = true
  wait                = true
  wait_for_jobs       = true
  cleanup_on_fail     = true
  timeout             = 600

  values = compact([
    fileexists("${local.chart_source_path}/network-rules/istio-values.tftpl.yaml") ? templatefile("${local.chart_source_path}/network-rules/istio-values.tftpl.yaml", {}) : "",
    fileexists("${local.chart_source_path}/network-rules/istio-values.yaml") ? file("${local.chart_source_path}/network-rules/istio-values.yaml") : "",
  ])
}
