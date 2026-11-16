# Configure Trivy
module "trivy" {
  count           = var.trivy_enabled ? 1 : 0
  source          = "./trivy"
  helm_repository = var.trivy_helm_repository
  namespace       = module.namespace.name
  # Configure Trivy settings
  chart_version                 = var.trivy_chart_version
  additional_report_fields      = var.trivy_additional_report_fields
  cron_job_schedule             = var.trivy_cron_job_schedule
  scan_namespaces               = var.trivy_scan_namespaces
  ignore_unfixed                = var.trivy_ignore_unfixed
  private_registry_secret_names = var.trivy_private_registry_secret_names
  scan_jobs_limit               = var.trivy_scan_jobs_limit
  severity_levels               = var.trivy_severity_levels
  use_less_resources            = var.trivy_use_less_resources
}

# Configure Falco
module "falco" {
  count                     = var.falco_enabled ? 1 : 0
  source                    = "./falco"
  helm_repository           = var.falco_helm_repository
  namespace                 = module.namespace.name
  chart_version             = var.falco_chart_version
  kubernetes_meta_collector = var.falco_kubernetes_meta_collector
  falcosidekick_enabled     = var.falco_falcosidekick_enabled
  falcosidekick_ui_enabled  = var.falco_falcosidekick_ui_enabled
  driver_kind               = var.falco_driver_kind
}

# Configure the Kyverno Policy Reporter (needs Kyverno, see the depends_on of this module)
module "policy_reporter" {
  count           = var.policy_reporter_enabled ? 1 : 0
  source          = "./policy-reporter"
  helm_repository = var.policy_reporter_helm_repository
  namespace       = module.namespace.name
  chart_version   = var.policy_reporter_chart_version
}
