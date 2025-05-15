output "resource_name" {
  description = "Standardized resource name"
  value       = "${var.application}-${var.component}-${local.stage}"
}

output "tags" {
  description = "Standardized set of tags for all resources"
  value = {
    application  = var.application
    cluster      = var.cluster
    component    = var.component
    region       = var.region
    organisation = var.organisation_name
    managedBy    = "opentofu"
  }
}

output "stage" {
  description = "Standandized stage name"
  value       = local.stage
}
