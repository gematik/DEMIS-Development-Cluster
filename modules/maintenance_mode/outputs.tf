output "maintenance_mode_status" {
  description = "new status of the maintenance mode"
  value       = length(terraform_data.update_services.output) > 0 && var.activate_maintenance_mode ? "activated" : "deactivated"
}
