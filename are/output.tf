# Output results, they are sorted alphabetically in the terminal
output "service_feature_flags" {
  value       = module.application_flags.service_feature_flags
  description = "Current feature flags defined in the stage"
}

output "service_config_options" {
  value       = module.application_flags.service_config_options
  description = "Current ops flags defined in the stage"
}

output "stage_name" {
  value       = local.stage_name
  description = "Current stage"
}

output "version_istio_routing_chart" {
  value       = module.are_services.version_istio_routing_chart
  description = "Version of the Istio Routing Chart being used"
}

output "kms_encryption_key_used" {
  description = "The flag to indicate if the KMS encryption key is used"
  value       = length(var.kms_encryption_key) > 0 ? true : false
}
