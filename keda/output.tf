# Output results, they are sorted alphabetically in the terminal
output "stage_name" {
  value       = local.stage_name
  description = "Current stage"
}

output "kms_encryption_key_used" {
  description = "The flag to indicate if the KMS encryption key is used"
  value       = length(var.kms_encryption_key) > 0 ? true : false
}

output "keda_chart_version" {
  description = "The deployed version of the DEMIS KEDA Chart"
  value       = helm_release.keda.version
}

output "keda_namespace" {
  description = "The Namespace of the KEDA deployment"
  value       = module.keda_namespace.name
}
