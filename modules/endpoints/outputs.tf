output "core_hostname" {
  value       = local.core_hostname
  description = "The URL for accessing the DEMIS Core Services"
}

output "bundid_idp_hostname" {
  value       = local.bundid_idp_hostname
  description = "The URL for for performing the login with BundID"
}

output "auth_hostname" {
  value       = local.auth_hostname
  description = "The URL for accessing the Keycloak Authentication Services"
}

output "portal_hostname" {
  value       = local.portal_hostname
  description = "The URL for accessing the DEMIS Notification Portal over the Telematikinfrastruktur (TI)"
}

output "meldung_hostname" {
  value       = local.meldung_hostname
  description = "The URL for accessing the DEMIS Notification Portal over Internet"
}

output "ti_idp_hostname" {
  value       = local.ti_idp_hostname
  description = "The URL for performing the login over the Telematikinfrastruktur (TI)"
}

output "storage_hostname" {
  value       = local.storage_hostname
  description = "The URL for accessing the S3 compatible storage (minio)"
}

output "frontend_hostnames" {
  value       = local.frontend_hostnames
  description = "The Hostnames for the DEMIS Portal Istio Virtual Services"
}

output "tls_hostnames" {
  value       = local.tls_hostnames
  description = "The Hostnames for TLS-only Connections"
}

output "keycloak_svc_hostname" {
  value       = var.keycloak_internal_hostname
  description = "The Internal Service Hostname for the Keycloak Service"
}

output "istio_gateway_name" {
  value       = local.cluster_gateway
  description = "The name of the Istio Gateway Object for accessing the DEMIS Cluster"
}

output "istio_gateway_fullname" {
  value       = "${var.istio_gateway_namespace}/${local.cluster_gateway}"
  description = "The full name of the Istio Gateway Object for accessing the DEMIS Cluster"
}