# Section for generating the profile version labels and subset names for main deployments.
locals {
  non_canary_extra_profiles = can(length(var.deployment_information.canary.profiles)) && !can(length(var.deployment_information.canary.version)) ? var.deployment_information.canary.profiles : []
  raw_main_profiles         = length(var.deployment_information.main.profiles) > 0 ? var.deployment_information.main.profiles : [var.default_profile_snapshots]
}

resource "terraform_data" "main_profiles" {
  input = distinct(compact(concat(local.raw_main_profiles, local.non_canary_extra_profiles)))
}

resource "terraform_data" "subsets_main" {
  input = yamldecode(templatefile("${path.module}/.scripts/subset.tftpl.yaml", {
    provisioning_mode = var.provisioning_mode
    versions          = terraform_data.main_profiles.output
    extra_versions    = local.non_canary_extra_profiles
    profile_type      = var.profile_type
    version           = var.deployment_information.main.version
    weight            = var.deployment_information.main.weight
  }))
}

# Section for generating the profile version labels and subset names for canary deployments.

resource "terraform_data" "canary_profiles" {
  input = distinct(compact(can(length(var.deployment_information.canary.profiles)) ? var.deployment_information.canary.profiles : terraform_data.main_profiles.output))
}

resource "terraform_data" "subsets_canary" {
  input = yamldecode(templatefile("${path.module}/.scripts/subset.tftpl.yaml", {
    provisioning_mode = var.provisioning_mode
    versions          = length(terraform_data.canary_profiles.output) > 0 ? terraform_data.canary_profiles.output : [var.default_profile_snapshots]
    extra_versions    = []
    profile_type      = var.profile_type
    version           = can(length(var.deployment_information.canary.version)) ? var.deployment_information.canary.version : null
    weight            = can(length(var.deployment_information.canary.weight)) ? var.deployment_information.canary.weight : null
  }))
}

# Section for generating the profile version labels and destination subset names for both main and canary deployments.

resource "terraform_data" "destination_subsets" {
  input = { main : terraform_data.subsets_main.output, canary : terraform_data.subsets_canary.output }
}
