locals {
  # The FHIR Storage Purger is deployed singularly, without Canary
  fsp_version = replace(module.demis_services.fsp_version, ".", "-")
}

resource "null_resource" "fsp_manual_trigger" {
  count = module.demis_services.fsp_enabled ? 1 : 0
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = var.kubeconfig_path
    }
    command = "kubectl create job -n ${var.target_namespace} --from=cronjob/fhir-storage-purger-${local.fsp_version} manual-fsp-${substr(sha256(timestamp()), 0, 10)}"
  }

  depends_on = [module.demis_services]
}
