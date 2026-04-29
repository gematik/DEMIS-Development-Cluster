locals {
  update_service_keys = [
    for key, value in var.deployment_information : key
    if can(value.canary) && can(value.canary.version) && value.canary.version != null && value.deployment-strategy == "update"
  ]
}

resource "terraform_data" "set_maintenance_mode" {
  triggers_replace = [local.update_service_keys]

  provisioner "local-exec" {
    environment = {
      KUBECONFIG                = var.kubeconfig_path
      UPDATE_SERVICE_COUNT      = length(local.update_service_keys)
      ACTIVATE_MAINTENANCE_MODE = var.activate_maintenance_mode
    }
    command = "bash ${path.module}/.scripts/set-maintenance-mode.sh"
  }
}
