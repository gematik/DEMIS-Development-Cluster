############################################
# Check if the Gateway Object exists 
############################################
data "kubernetes_resources" "istio_gateways_stable" {
  # Perform the check only if the variable is set to true
  count       = var.check_istio_gateway_exists ? 1 : 0
  api_version = "networking.istio.io/v1"
  kind        = "Gateway"
  namespace   = var.istio_gateway_namespace
}

# Istio has a Mutating Webhook that internally still uses the v1beta1 API.
# This should be removed in future versions of Istio, when the Mutating Webhook doen't use the v1beta1 API anymore.
data "kubernetes_resources" "istio_gateways_beta" {
  # Perform the check only if the variable is set to true
  count       = var.check_istio_gateway_exists ? 1 : 0
  api_version = "networking.istio.io/v1beta1"
  kind        = "Gateway"
  namespace   = var.istio_gateway_namespace
}

locals {
  # Access the first found Gateway v1 Object and assume it is the cluster gateway, otherwise use the default value 
  found_stable_gateway = length(data.kubernetes_resources.istio_gateways_stable) > 0 ? length(data.kubernetes_resources.istio_gateways_stable[0].objects) > 0 : false
  # Extract the Gateway Name from the Gateway Object v1
  stable_gateway_name = local.found_stable_gateway ? try(data.kubernetes_resources.istio_gateways_stable[0].objects[0].metadata[0].name, null) : null
  # Access the first found Gateway v1beta1 Object and assume it is the cluster gateway, otherwise use the default value
  found_beta_gateway = length(data.kubernetes_resources.istio_gateways_beta) > 0 ? length(data.kubernetes_resources.istio_gateways_beta[0].objects) > 0 : false
  # Extract the Gateway Name from the Gateway Object v1beta1
  beta_gateway_name = local.found_beta_gateway ? try(data.kubernetes_resources.istio_gateways_beta[0].objects[0].metadata[0].name, null) : null
  # Get one of the Gateway Names
  found_gateway_name = local.stable_gateway_name != null ? local.stable_gateway_name : local.beta_gateway_name != null ? local.beta_gateway_name : null
  # Define the Gateway Name to be used
  cluster_gateway = local.found_gateway_name != null ? local.found_gateway_name : var.istio_gateway_name
  # Define the Hostnames for the DEMIS Endpoints
  core_hostname       = var.core_subdomain != "" ? "${var.core_subdomain}.${var.domain_name}" : var.domain_name
  bundid_idp_hostname = var.bundid_idp_issuer_subdomain != "" ? "${var.bundid_idp_issuer_subdomain}.${var.domain_name}" : ""
  auth_hostname       = var.auth_issuer_subdomain != "" ? "${var.auth_issuer_subdomain}.${var.domain_name}" : ""
  portal_hostname     = var.portal_subdomain != "" ? "${var.portal_subdomain}.${var.domain_name}" : ""
  meldung_hostname    = var.meldung_subdomain != "" ? "${var.meldung_subdomain}.${var.domain_name}" : ""
  ti_idp_hostname     = var.ti_idp_subdomain != "" ? "${var.ti_idp_subdomain}.${var.domain_name}" : ""
  storage_hostname    = var.storage_subdomain != "" ? "${var.storage_subdomain}.${var.domain_name}" : ""
  # Define the Hostnames for the DEMIS Portal Istio Virtual Services
  frontend_hostnames = [local.portal_hostname, local.meldung_hostname]
  # Define the Hostnames for TLS-only Connections
  tls_hostnames = compact(concat(local.frontend_hostnames, [local.bundid_idp_hostname, local.auth_hostname, local.ti_idp_hostname, local.storage_hostname]))
}
