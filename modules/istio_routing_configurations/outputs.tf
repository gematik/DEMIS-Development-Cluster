output "rules" {
  description = "Rendered Istio rules as a Terraform object."
  value       = local.rules

  precondition {
    condition     = data.external.istio_rules.result.valid == "true"
    error_message = data.external.istio_rules.result.error != "" ? "Schema validation failed: ${data.external.schema_validation.result.error}" : "Schema validation failed with unknown error."
  }
}
