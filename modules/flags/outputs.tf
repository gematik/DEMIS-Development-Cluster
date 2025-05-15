output "service_feature_flags" {
  description = "Map containing all the feature flags, grouped by service"
  value       = local.service_feature_flags
}

output "service_config_options" {
  description = "Map containing all the configuration options, grouped by service"
  value       = local.service_config_options
}
