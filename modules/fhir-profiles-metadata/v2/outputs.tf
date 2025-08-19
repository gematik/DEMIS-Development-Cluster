output "destination_subsets" {
  value       = terraform_data.destination_subsets.output
  description = "values for the destination subsets"
}

output "current_profile_versions" {
  value       = try(var.deployment_information.canary.version, null) == null ? terraform_data.main_profiles.output : terraform_data.canary_profiles.output
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