# Section for generating the profile version labels and subset names for main deployments.
locals {
  non_canary_extra_profiles = can(length(var.deployment_information.canary.profiles)) && !can(length(var.deployment_information.canary.version)) ? var.deployment_information.canary.profiles : []
  raw_main_profiles         = length(var.deployment_information.main.profiles) > 0 ? var.deployment_information.main.profiles : [var.default_profile_snapshots]
  main_profiles             = distinct(compact(concat(local.raw_main_profiles, local.non_canary_extra_profiles)))

  subsets_main = yamldecode(templatefile("${path.module}/.scripts/subset.tftpl.yaml", {
    provisioning_mode = var.provisioning_mode
    versions          = local.main_profiles
    extra_versions    = local.non_canary_extra_profiles
    profile_type      = var.profile_type
    version           = var.deployment_information.main.version
    weight            = var.deployment_information.main.weight
  }))

  # Section for generating the profile version labels and subset names for canary deployments.
  canary_profiles = distinct(compact(can(length(var.deployment_information.canary.profiles)) ? var.deployment_information.canary.profiles : local.main_profiles))

  subsets_canary = yamldecode(templatefile("${path.module}/.scripts/subset.tftpl.yaml", {
    provisioning_mode = var.provisioning_mode
    versions          = length(local.canary_profiles) > 0 ? local.canary_profiles : [var.default_profile_snapshots]
    extra_versions    = []
    profile_type      = var.profile_type
    version           = can(length(var.deployment_information.canary.version)) ? var.deployment_information.canary.version : null
    weight            = can(length(var.deployment_information.canary.weight)) ? var.deployment_information.canary.weight : null
  }))

  # Section for generating the profile version labels and destination subset names for both main and canary deployments.
  destination_subsets = { main : local.subsets_main, canary : local.subsets_canary }
}

# Legacy terraform_data resources kept to avoid destroy cycle during migration.
# Their inputs now reference always-known locals, so no "known after apply" propagates.
# Can be removed in a future release once state is clean.
resource "terraform_data" "main_profiles" {
  input = local.main_profiles
}

resource "terraform_data" "subsets_main" {
  input = local.subsets_main
}

resource "terraform_data" "canary_profiles" {
  input = local.canary_profiles
}

resource "terraform_data" "subsets_canary" {
  input = local.subsets_canary
}

resource "terraform_data" "destination_subsets" {
  input = local.destination_subsets
}
