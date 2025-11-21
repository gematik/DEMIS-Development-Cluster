module "activate_maintenance_mode" {
  source                    = "../modules/maintenance_mode"
  deployment_information    = local.deployment_information
  activate_maintenance_mode = true
  kubeconfig_path           = var.kubeconfig_path
}

module "deactivate_maintenance_mode" {
  source                    = "../modules/maintenance_mode"
  deployment_information    = local.deployment_information
  activate_maintenance_mode = false
  kubeconfig_path           = var.kubeconfig_path
  depends_on                = [module.dmz_services]
}
