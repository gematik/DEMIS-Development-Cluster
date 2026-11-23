locals {
  # The audit-log-purger is deployed singularly, without Canary
  audit_log_purger_version = replace(module.observability_services.audit_log_purger_version, ".", "-")
}

# Runs the audit-log-purger once after a new version or when it is enabled or resumed (as in the demis module)
resource "terraform_data" "audit_log_purger_manual_trigger" {
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = var.kubeconfig_path
    }
    command = "if [ ${module.observability_services.audit_log_purger_enabled} = true -a ${var.audit_log_purger_suspend} != true ]; then kubectl create job -n ${local.namespace} --from=cronjob/audit-log-purger-${local.audit_log_purger_version} manual-alp-${substr(sha256(timestamp()), 0, 10)}; fi"
  }

  triggers_replace = {
    appversion = local.audit_log_purger_version
    suspend    = tostring(var.audit_log_purger_suspend)
    enabled    = tostring(module.observability_services.audit_log_purger_enabled)
  }

  depends_on = [module.observability_services]
}
