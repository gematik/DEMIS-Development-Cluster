########################
# Feature Flags and Config Options of the DEMIS charts in the namespace (feature_flags.tfvars, config_options.tfvars)
########################

module "application_flags" {
  source = "../modules/flags"
  # list of all available services
  all_services   = keys(local.deployment_information)
  feature_flags  = var.feature_flags
  config_options = var.config_options
}
