########################
# Retrieve the Feature Flags and Config Options for each service application
########################

module "application_flags" {
  source = "../modules/flags"
  # pass the feature flags to the module
  feature_flags = var.feature_flags
  # pass the ops flags to the module
  config_options = var.config_options
}