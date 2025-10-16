output "fsp_version" {
  description = "The version of FHIR-Storage-Purger"
  value       = local.fsp_enabled ? module.fhir_storage_purger[0].app_chart_versions[0] : ""
}

output "fsp_enabled" {
  description = "Whether FHIR-Storage-Purger is enabled"
  value       = local.fsp_enabled
}

output "dlp_version" {
  description = "The version of destination-lookup-purger"
  value       = try(module.destination_lookup_purger[0].app_chart_versions[0], "")
}

output "dlp_enabled" {
  description = "Whether destination-lookup-purger is enabled"
  value       = try(local.dls_purger_information.enabled, false)
}

output "spp_ars_version" {
  description = "The version of Surveillance-Pseudonym-Purger-ARS"
  value       = local.spp_ars_enabled ? module.surveillance_pseudonym_purger_ars[0].app_chart_versions[0] : ""
}

output "spp_ars_enabled" {
  description = "Whether Surveillance-Pseudonym-Purger-ARS is enabled"
  value       = local.spp_ars_enabled
}

output "fhir_profile_snapshots" {
  description = "Version of the FHIR Profile Snapshots being used"
  value       = length(tolist(module.validation_service_core_metadata.current_profile_versions)) > 0 ? "[${join(", ", tolist(module.validation_service_core_metadata.current_profile_versions))}]" : local.fhir_profile_snapshots
}

output "igs_profile_snapshots" {
  description = "Version of the IGS Profile Snapshots being used"
  value       = length(tolist(module.validation_service_igs_metadata.current_profile_versions)) > 0 ? "[${join(", ", tolist(module.validation_service_igs_metadata.current_profile_versions))}]" : local.igs_profile_snapshots
}

output "ars_profile_snapshots" {
  description = "Version of the ARS Profile Snapshots being used"
  value       = length(tolist(module.validation_service_ars_metadata.current_profile_versions)) > 0 ? "[${join(", ", tolist(module.validation_service_ars_metadata.current_profile_versions))}]" : local.ars_profile_snapshots
}

output "version_istio_routing_chart" {
  description = "Version of the Istio Routing Chart being used"
  value       = local.common_helm_release_settings.istio_routing_chart_version
}

output "version_routing_data" {
  description = "Version of the Routing Data"
  value       = local.routing_data_version
}
