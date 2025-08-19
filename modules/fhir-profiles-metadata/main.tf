module "v1_fhir_profiles_metadata" {
  count                     = var.api_version == "v1" ? 1 : 0
  source                    = "./v1"
  default_profile_snapshots = var.default_profile_snapshots
  deployment_information    = var.deployment_information
  profile_type              = var.profile_type
  is_canary                 = var.is_canary
}

module "v2_fhir_profiles_metadata" {
  count                     = var.api_version == "v2" ? 1 : 0
  source                    = "./v2"
  default_profile_snapshots = var.default_profile_snapshots
  deployment_information    = var.deployment_information
  profile_type              = var.profile_type
  provisioning_mode         = var.provisioning_mode
}