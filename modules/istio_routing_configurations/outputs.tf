output "rules" {
  description = "Rendered Istio rules as a Terraform object."
  value       = local.rules

  precondition {
    condition     = data.external.istio_rules.result.valid == "true"
    error_message = data.external.istio_rules.result.error != "" ? "Schema validation failed: ${data.external.schema_validation.result.error}" : "Schema validation failed with unknown error."
  }

  precondition {
    condition = length(setsubtract(toset(local.routing_fhir_package_versions), toset(var.fhir_package_versions))) == 0
    error_message = format(
      "The following FHIR package versions from the external routing have no corresponding validation-service profile: %s\n%s\n%s",
      join(", ", sort([
        for missing in setsubtract(toset(local.routing_fhir_package_versions), toset(var.fhir_package_versions)) :
        "${missing} (services: ${join(", ", distinct(sort(local.services_by_package_versions[missing])))})"
      ])),
      "in routing defined:         [${join(", ", sort(local.routing_fhir_package_versions))}]",
      "in active versions defined: [${join(", ", sort(var.fhir_package_versions))}]"
    )
  }
}
