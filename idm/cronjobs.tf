locals {
  # The Certificate Update Service is deployed singularly, without Canary
  cus_version = replace(module.idm_services.cus_version, ".", "-")
  kup_version = replace(module.idm_services.kup_version, ".", "-")
}

resource "null_resource" "cus_manual_trigger" {
  count = module.idm_services.cus_enabled ? 1 : 0
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = var.kubeconfig_path
    }
    command = "kubectl create job -n ${var.target_namespace} --from=cronjob/certificate-update-service-${local.cus_version} manual-cus-${substr(sha256(timestamp()), 0, 10)}"
  }

  # triggers the job when the deployment is executed
  triggers = {
    last_execution = timestamp()
  }

  depends_on = [module.idm_services]
}

resource "null_resource" "kup_manual_trigger" {
  count = module.idm_services.kup_enabled ? 1 : 0
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = var.kubeconfig_path
    }
    command = "kubectl create job -n ${var.target_namespace} --from=cronjob/keycloak-user-purger-${local.kup_version} manual-kup-${substr(sha256(timestamp()), 0, 10)}"
  }

  # triggers the job when the deployment is executed
  triggers = {
    last_execution = timestamp()
  }

  depends_on = [module.idm_services]
}
