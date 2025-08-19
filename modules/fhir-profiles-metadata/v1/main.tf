# Section for generating the profile version labels and subset names for main deployments.

resource "terraform_data" "version_main" {
  input = var.deployment_information.main.version
}

resource "terraform_data" "main_profiles" {
  input = distinct(compact(var.deployment_information.main.profiles))
}
resource "terraform_data" "subset_name_main" {
  input = length(terraform_data.main_profiles.output) > 0 ? replace(format("%s-%s%s", terraform_data.version_main.output, var.profile_type, format("-%s", substr(sha256(join("", terraform_data.main_profiles.output)), 0, 10))), "(\\.|_)+", "-") : format("%s-%s", terraform_data.version_main.output, var.profile_type)
}

resource "terraform_data" "profile_version_labels_main" {
  input = length(terraform_data.main_profiles.output) > 0 ? { for idx, profile in flatten(terraform_data.main_profiles.output) : "fhirProfileVersions_${idx}" => profile } : {}
}

resource "terraform_data" "version_labels_main" {
  input = merge({ fhirProfile = var.profile_type, fhirProfileVersion = length(terraform_data.main_profiles.output) > 0 ? terraform_data.subset_name_main.output : var.default_profile_snapshots }, terraform_data.profile_version_labels_main.output)
}


# Section for generating the profile version labels and subset names for canary deployments.

resource "terraform_data" "version_canary" {
  input = can(length(var.deployment_information.canary.version)) ? var.deployment_information.canary.version : ""
}

resource "terraform_data" "canary_profiles" {
  input = distinct(compact(can(length(var.deployment_information.canary.profiles)) ? var.deployment_information.canary.profiles : terraform_data.main_profiles.output))
}

resource "terraform_data" "subset_name_canary" {
  input = length(terraform_data.version_canary.output) > 0 && length(terraform_data.canary_profiles.output) > 0 ? replace(format("%s-%s%s", terraform_data.version_canary.output, var.profile_type, format("-%s", substr(sha256(join("", terraform_data.canary_profiles.output)), 0, 10))), "(\\.|_)+", "-") : format("%s-%s", terraform_data.version_canary.output, var.profile_type)
}

resource "terraform_data" "profile_version_labels_canary" {
  input = length(terraform_data.canary_profiles.output) > 0 ? { for idx, profile in flatten(terraform_data.canary_profiles.output) : "fhirProfileVersions_${idx}" => profile } : {}
}

resource "terraform_data" "version_labels_canary" {
  input = merge({ fhirProfile = var.profile_type, fhirProfileVersion = length(terraform_data.version_canary.output) > 0 && length(terraform_data.canary_profiles.output) > 0 ? terraform_data.subset_name_canary.output : var.default_profile_snapshots }, terraform_data.profile_version_labels_canary.output)
}


# Section for generating the profile version labels and destination subset names for both main and canary deployments.

resource "terraform_data" "version_labels" {
  input = merge({ customLabels = (var.is_canary ? terraform_data.version_labels_canary.output : terraform_data.version_labels_main.output), deploymentLabels = (var.is_canary ? terraform_data.version_labels_canary.output : terraform_data.version_labels_main.output) })
}

resource "terraform_data" "destination_subsets_main" {
  input = { destinationSubsets = { main = { name = terraform_data.subset_name_main.output, extraLabels = terraform_data.version_labels_main.output } } }
}

resource "terraform_data" "destination_subsets_canary" {
  input = { destinationSubsets = { canary = { name = terraform_data.subset_name_canary.output, extraLabels = terraform_data.version_labels_canary.output } } }
}

resource "terraform_data" "destination_subsets" {
  input = var.is_canary ? { destinationSubsets = merge(terraform_data.destination_subsets_main.output.destinationSubsets, terraform_data.destination_subsets_canary.output.destinationSubsets) } : terraform_data.destination_subsets_main.output
}
