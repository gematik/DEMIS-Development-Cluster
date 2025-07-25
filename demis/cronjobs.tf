locals {
  # The FHIR Storage Purger is deployed singularly, without Canary
  fsp_version = replace(module.demis_services.fsp_version, ".", "-")
}

resource "terraform_data" "fsp_manual_trigger" {
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = var.kubeconfig_path
    }
    command = "if [ ${module.demis_services.fsp_enabled} = true -a ${var.fhir_storage_purger_suspend} != true ]; then kubectl create job -n ${var.target_namespace} --from=cronjob/fhir-storage-purger-${local.fsp_version} manual-fsp-${substr(sha256(timestamp()), 0, 10)}; fi"
  }

  triggers_replace = [timestamp()]

  depends_on = [module.demis_services]
}
