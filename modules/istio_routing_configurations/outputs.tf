output "rules" {
  description = "Rendered Istio rules as a Terraform object."
  value       = terraform_data.rules.output
}
