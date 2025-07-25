locals {
  # The Certificate Update Service is deployed singularly, without Canary
  cus_version = replace(module.idm_services.cus_version, ".", "-")
  kup_version = replace(module.idm_services.kup_version, ".", "-")
}

resource "terraform_data" "cus_manual_trigger" {
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = var.kubeconfig_path
    }
    command = "if [ ${module.idm_services.cus_enabled} = true -a ${var.certificate_update_service_suspend} != true ]; then kubectl create job -n ${var.target_namespace} --from=cronjob/certificate-update-service-${local.cus_version} manual-cus-${substr(sha256(timestamp()), 0, 10)}; fi"
  }

  # triggers the job when the deployment is executed

  triggers_replace = [timestamp()]

  depends_on = [module.idm_services]
}

resource "terraform_data" "kup_manual_trigger" {
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = var.kubeconfig_path
    }
    command = "if [ ${module.idm_services.kup_enabled} = true -a ${var.keycloak_user_purger_suspend} != true ]; then kubectl create job -n ${var.target_namespace} --from=cronjob/keycloak-user-purger-${local.kup_version} manual-kup-${substr(sha256(timestamp()), 0, 10)}; fi"
  }

  # triggers the job when the deployment is executed
  triggers_replace = [timestamp()]

  depends_on = [module.idm_services]
}