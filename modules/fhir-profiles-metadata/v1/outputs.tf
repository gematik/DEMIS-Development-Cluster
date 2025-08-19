output "destination_subsets" {
  value       = terraform_data.destination_subsets.output
  description = "values for the destination subsets"
}

output "version_labels" {
  value       = terraform_data.version_labels.output
  description = "values for the version labels result for the main and canary deployments depending on the is_canary flag"
}

output "version_labels_main" {
  value       = terraform_data.version_labels_main.output
  description = "values for the version labels for main deployment"
}

output "version_labels_canary" {
  value       = terraform_data.version_labels_canary.output
  description = "values for the version labels for canary deployment"
}

output "current_profile_versions" {
  value       = var.is_canary ? terraform_data.canary_profiles.output : terraform_data.main_profiles.output
  description = "values for the current profile versions depending on the is_canary flag"
}

output "canary_profile_versions" {
  value       = terraform_data.canary_profiles.output
  description = "values for the canary profile versions"
}

output "main_profile_versions" {
  value       = terraform_data.main_profiles.output
  description = "values for the main profile versions"
}