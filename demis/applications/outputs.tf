output "fsp_version" {
  description = "The version of FHIR-Storage-Purger"
  value       = local.fsp_enabled ? module.fhir_storage_purger[0].app_chart_versions[0] : ""
}

output "fsp_enabled" {
  description = "Whether FHIR-Storage-Purger is enabled"
  value       = local.fsp_enabled
}