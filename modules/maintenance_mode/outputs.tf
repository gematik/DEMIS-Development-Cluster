output "maintenance_mode_status" {
  description = "new status of the maintenance mode"
  value       = length(local.update_service_keys) > 0 && var.activate_maintenance_mode ? "activated" : "deactivated"
}
