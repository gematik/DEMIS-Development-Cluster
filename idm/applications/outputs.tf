output "cus_version" {
  description = "The version of Certificate Update Service"
  value       = local.cus_enabled ? module.certificate_update_service[0].app_chart_versions[0] : ""
}

output "kup_version" {
  description = "The version of Keycloak-User-Purger"
  value       = local.kup_enabled ? module.keycloak_user_purger[0].app_chart_versions[0] : ""
}

output "cus_enabled" {
  description = "Whether the Certificate Update Service is enabled"
  value       = local.cus_enabled
}

output "kup_enabled" {
  description = "Whether the Keycloak-User-Purger is enabled"
  value       = local.kup_enabled
}