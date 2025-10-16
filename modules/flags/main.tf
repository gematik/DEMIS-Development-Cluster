locals {
  # extract all the feature flags, grouped by service
  service_feature_flags = { for s in distinct(flatten([for ff in var.feature_flags : ff.services])) : s => { for ff in var.feature_flags : ff.flag_name => ff.flag_value if contains(ff.services, s) } }
  # extract all the configuration options, grouped by service
  service_config_options = {
    for s in distinct(flatten([for co in var.config_options : co.services])) :
    s => {
      for co in var.config_options :
      co.option_name => co.option_value
      if contains(co.services, s) && co.option_value != null
    }
  }
}
