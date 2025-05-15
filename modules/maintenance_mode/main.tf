resource "terraform_data" "update_services" {
  input = [
    for key, value in var.deployment_information : key
    if can(value.canary) && can(value.canary.version) && value.canary.version != null && value.deployment-strategy == "update"
  ]
}

resource "terraform_data" "set_maintenance_mode" {
  provisioner "local-exec" {
    environment = {
      KUBECONFIG                = var.kubeconfig_path
      UPDATE_SERVICE_COUNT      = length(terraform_data.update_services.output)
      ACTIVATE_MAINTENANCE_MODE = var.activate_maintenance_mode
    }
    command = "bash ${path.module}/.scripts/set-maintenance-mode.sh"
  }
  lifecycle {
    replace_triggered_by = [terraform_data.update_services]
  }
  depends_on = [terraform_data.update_services]
}
