output "destination_subsets" {
  value       = var.api_version == "v1" ? module.v1_fhir_profiles_metadata[0].destination_subsets : module.v2_fhir_profiles_metadata[0].destination_subsets
  description = "values for the destination subsets"
}

output "version_labels" {
  value       = var.api_version == "v1" ? module.v1_fhir_profiles_metadata[0].version_labels : null
  description = "values for the version labels result for the main and canary deployments depending on the is_canary flag"
}

output "version_labels_main" {
  value       = var.api_version == "v1" ? module.v1_fhir_profiles_metadata[0].version_labels_main : null
  description = "values for the version labels for main deployment"
}

output "version_labels_canary" {
  value       = var.api_version == "v1" ? module.v1_fhir_profiles_metadata[0].version_labels_canary : null
  description = "values for the version labels for canary deployment"
}

output "current_profile_versions" {
  value       = var.api_version == "v1" ? module.v1_fhir_profiles_metadata[0].current_profile_versions : module.v2_fhir_profiles_metadata[0].current_profile_versions
  description = "values for the current profile versions depending on the is_canary flag"
}

output "canary_profile_versions" {
  value       = var.api_version == "v1" ? module.v1_fhir_profiles_metadata[0].canary_profile_versions : module.v2_fhir_profiles_metadata[0].canary_profile_versions
  description = "values for the canary profile versions"
}

output "main_profile_versions" {
  value       = var.api_version == "v1" ? module.v1_fhir_profiles_metadata[0].main_profile_versions : module.v2_fhir_profiles_metadata[0].main_profile_versions
  description = "values for the main profile versions"
}