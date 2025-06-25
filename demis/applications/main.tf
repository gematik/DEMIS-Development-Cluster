locals {
  # Define how are named the Files overriding the Helm Charts
  application_values_file = "app-values.tftpl.yaml"
  istio_values_file       = "istio-values.tftpl.yaml"

  # Get all the Service Names from the Deployment Information
  service_names = keys(var.deployment_information)
  # Define the Hostnames for the DEMIS Portal Istio Virtual Services
  frontend_hostnames = [var.portal_hostname, var.meldung_hostname]
  # Define the Hostnames for the DEMIS Services Istio Virtual Services
  demis_hostnames = concat(local.frontend_hostnames, [var.core_hostname])
  # Define the S3 Storage URL - Use MinIO if in local mode with default Istio Port
  s3_storage_url = var.is_local_mode ? "http://${var.s3_hostname}" : "https://${var.s3_hostname}:${var.s3_port}"

  # Define common Helm Release Settings
  common_helm_release_settings = {
    chart_image_tag_property_name = "required.image.tag"
    helm_repository               = var.helm_repository
    helm_repository_username      = var.helm_repository_username
    helm_repository_password      = var.helm_repository_password
    istio_routing_chart_version   = try(var.deployment_information["istio-routing"].main.version, "")
  }
  # The version of the FHIR Profile Snapshots to use
  fhir_profile_snapshots = var.deployment_information["fhir-profile-snapshots"].main.version
  # The version of the IGS Profile Snapshots to use
  igs_profile_snapshots = var.deployment_information["igs-profile-snapshots"].main.version
  # The version of the ARS Profile Snapshots to use
  ars_profile_snapshots = var.deployment_information["ars-profile-snapshots"].main.version
  # The version of the Routing Data to use
  routing_data_version = var.deployment_information["notification-routing-data"].main.version
}
