locals {
  # The FHIR Storage Purger is deployed singularly, without Canary
  fsp_version     = replace(module.demis_services.fsp_version, ".", "-")
  dlp_version     = replace(module.demis_services.dlp_version, ".", "-")
  spp_ars_version = replace(module.demis_services.spp_ars_version, ".", "-")
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

resource "terraform_data" "dls_manual_trigger" {
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = var.kubeconfig_path
    }
    command = "if [ ${module.demis_services.dlp_enabled} = true -a ${var.destination_lookup_purger_suspend} != true ]; then kubectl create job -n ${var.target_namespace} --from=cronjob/destination-lookup-purger-${local.dlp_version} manual-dlp-${substr(sha256(timestamp()), 0, 10)}; fi"
  }

  triggers_replace = [timestamp()]

  depends_on = [module.demis_services]
}

resource "terraform_data" "spp_ars_manual_trigger" {
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = var.kubeconfig_path
    }
    command = "if [ ${module.demis_services.spp_ars_enabled} = true -a ${var.surveillance_pseudonym_purger_ars_suspend} != true ]; then kubectl create job -n ${var.target_namespace} --from=cronjob/surveillance-pseudonym-purger-ars-${local.spp_ars_version} manual-spp-ars-${substr(sha256(timestamp()), 0, 10)}; fi"
  }

  triggers_replace = [timestamp()]

  depends_on = [module.demis_services]
}