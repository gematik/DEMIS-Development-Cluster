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
    file("${local.chart_source_path}/policies-authorizations/istio-values.tftpl.yaml")
  ]

  depends_on = [module.mesh_namespace.name]
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
      gateway_name   = module.endpoints.istio_gateway_name,
      tls_credential = kubernetes_secret.demis_gateway_tls_credential.metadata[0].name,
      # In Remote Clusters also the Core Hostname is reachable via TLS and not over mutual TLS
      tls_hosts                     = local.is_local_mode ? module.endpoints.tls_hostnames : concat(module.endpoints.tls_hostnames, [module.endpoints.core_hostname]),
      mutual_tls_credential         = length(kubernetes_secret.demis_gateway_mutual_tls_credential) > 0 ? kubernetes_secret.demis_gateway_mutual_tls_credential[0].metadata[0].name : "",
      mutual_tls_hosts              = [module.endpoints.core_hostname],
      core_hostname                 = module.endpoints.core_hostname,
      portal_hostname               = module.endpoints.portal_hostname,
      portal_test_token_certificate = var.portal_test_token_certificate,
      keycloak_internal_hostname    = module.endpoints.keycloak_svc_hostname,
      auth_hostname                 = module.endpoints.auth_hostname,
      token_cert_header             = local.is_local_mode ? "x-forwarded-client-cert-kind" : "ssl-client-cert",
      storage_hostname              = module.endpoints.storage_hostname,
      s3_hostname                   = local.is_local_mode ? "" : var.s3_hostname,
      s3_port                       = local.is_local_mode ? "" : var.s3_port,
      s3_tls_credential             = local.is_local_mode ? "" : kubernetes_secret.s3_tls_credential[0].metadata[0].name
    })
  ]

  depends_on = [module.mesh_namespace.name]
}
