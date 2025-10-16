# Output results, they are sorted alphabetically in the terminal
output "stage_name" {
  value       = local.stage_name
  description = "Current stage"
}

output "kms_encryption_key_used" {
  description = "The flag to indicate if the KMS encryption key is used"
  value       = length(var.kms_encryption_key) > 0 ? true : false
}

output "istio_gateway_name" {
  value       = module.endpoints.istio_gateway_name
  description = "The name of the Istio Gateway for the DEMIS Cluster"
}