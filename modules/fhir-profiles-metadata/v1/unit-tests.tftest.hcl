provider "kubernetes" {
  config_path = "${path.module}/.test_kubeconfig"
}

# Test profiles output canary is false and canary is empty
run "check_profile_versions_main_empty_canary" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version  = "2.7.1-b300"
        weight   = 100
        profiles = ["latest-6.0.0", "5.3.1-b94"]
      }
      canary = {}
    }
    profile_type              = "fhir-profile-snapshots"
    is_canary                 = false
    default_profile_snapshots = "5.3.1-b94"
  }

  # assert that the canary profile versions are same like main profile versions
  assert {
    condition     = alltrue([for version in terraform_data.canary_profiles.output : contains(["latest-6.0.0", "5.3.1-b94"], version)])
    error_message = "Expected output was [\"latest-6.0.0\",\"5.3.1-b94\"] but is: [${join(",", terraform_data.canary_profiles.output)}]."
  }

  # assert that the main profile versions are same like main profile versions
  assert {
    condition     = alltrue([for version in terraform_data.main_profiles.output : contains(["latest-6.0.0", "5.3.1-b94"], version)])
    error_message = "Expected output was [\"latest-6.0.0\",\"5.3.1-b94\"] but is: [${join(",", terraform_data.main_profiles.output)}]."
  }

  # assert that subset name main is correct
  assert {
    condition     = terraform_data.subset_name_main.output == "2.7.1-b300-fhir-profile-snapshots-6db26c008b"
    error_message = "Expected output was 2.7.1-b300-fhir-profile-snapshots-6db26c008b but is: [${terraform_data.subset_name_main.output}]."
  }

  # assert version canary is empty
  assert {
    condition     = terraform_data.version_canary.output == ""
    error_message = "Expected output was empty but is: [${terraform_data.version_canary.output}]."
  }

  # assert version main is correct
  assert {
    condition     = terraform_data.version_main.output == "2.7.1-b300"
    error_message = "Expected output was empty but is: [${terraform_data.version_main.output}]."
  }
}

# Test profiles output canary is true and canary is empty
run "check_profile_versions_canary_empty_canary" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version  = "2.7.1-b300"
        weight   = 100
        profiles = ["latest-6.0.0", "5.3.1-b94"]
      }
      canary = {}
    }
    profile_type              = "fhir-profile-snapshots"
    is_canary                 = true
    default_profile_snapshots = "5.3.1-b94"
  }

  # assert that the canary profile versions are same like main profile versions
  assert {
    condition     = alltrue([for version in terraform_data.canary_profiles.output : contains(["latest-6.0.0", "5.3.1-b94"], version)])
    error_message = "Expected output was [\"latest-6.0.0\",\"5.3.1-b94\"] but is: [${join(",", terraform_data.canary_profiles.output)}]."
  }

  # assert that the main profile versions are same like main profile versions
  assert {
    condition     = alltrue([for version in terraform_data.main_profiles.output : contains(["latest-6.0.0", "5.3.1-b94"], version)])
    error_message = "Expected output was [\"latest-6.0.0\",\"5.3.1-b94\"] but is: [${join(",", terraform_data.main_profiles.output)}]."
  }

  # assert that subset name main is correct
  assert {
    condition     = terraform_data.subset_name_main.output == "2.7.1-b300-fhir-profile-snapshots-6db26c008b"
    error_message = "Expected output was 2.7.1-b300-fhir-profile-snapshots-6db26c008b but is: [${terraform_data.subset_name_main.output}]."
  }

  # assert version canary is empty
  assert {
    condition     = terraform_data.version_canary.output == ""
    error_message = "Expected output was empty but is: [${terraform_data.version_canary.output}]."
  }

  # assert version main is correct
  assert {
    condition     = terraform_data.version_main.output == "2.7.1-b300"
    error_message = "Expected output was empty but is: [${terraform_data.version_main.output}]."
  }
}

# Test profiles output canary is false and canary is filled
run "check_profile_versions_main_filled_canary" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version  = "2.7.1-b300"
        weight   = 100
        profiles = ["latest-6.0.0", "5.3.1-b94"]
      }
      canary = {
        version  = "2.7.1-b301"
        weight   = 0
        profiles = ["latest-preview-6.0.0", "5.3.1-b94"]
      }
    }
    profile_type              = "fhir-profile-snapshots"
    is_canary                 = false
    default_profile_snapshots = "5.3.1-b94"
  }

  # assert that the canary profile versions are same like main profile versions
  assert {
    condition     = alltrue([for version in terraform_data.canary_profiles.output : contains(["latest-preview-6.0.0", "5.3.1-b94"], version)])
    error_message = "Expected output was [\"latest-preview-6.0.0\",\"5.3.1-b94\"] but is: [${join(",", terraform_data.canary_profiles.output)}]."
  }

  # assert that the main profile versions are same like main profile versions
  assert {
    condition     = alltrue([for version in terraform_data.main_profiles.output : contains(["latest-6.0.0", "5.3.1-b94"], version)])
    error_message = "Expected output was [\"latest-6.0.0\",\"5.3.1-b94\"] but is: [${join(",", terraform_data.main_profiles.output)}]."
  }

  # assert that subset name canary is correct
  assert {
    condition     = terraform_data.subset_name_canary.output == "2.7.1-b301-fhir-profile-snapshots-aa5906c72a"
    error_message = "Expected output was 2.7.1-b301-fhir-profile-snapshots-aa5906c72a but is: [${terraform_data.subset_name_canary.output}]."
  }

  # assert version labels main has all required keys
  assert {
    condition     = length(keys(terraform_data.version_labels_main.output)) == 4 && contains(keys(terraform_data.version_labels_main.output), "fhirProfile") && contains(keys(terraform_data.version_labels_main.output), "fhirProfileVersion") && contains(keys(terraform_data.version_labels_main.output), "fhirProfileVersions_0") && contains(keys(terraform_data.version_labels_main.output), "fhirProfileVersions_1")
    error_message = "Expected Keys fhirProfile, fhirProfileVersion, fhirProfileVersions_0, fhirProfileVersions_1 to be present in output but is: ${jsonencode(keys(terraform_data.version_labels_main.output))}."
  }

  # assert version labels main has correct value for fhirProfile
  assert {
    condition     = terraform_data.version_labels_main.output.fhirProfile == "fhir-profile-snapshots"
    error_message = "Expected output was fhir-profile-snapshots but is: [${terraform_data.version_labels_main.output.fhirProfile}]."
  }

  # assert version labels main has correct value for fhirProfileVersion
  assert {
    condition     = terraform_data.version_labels_main.output.fhirProfileVersion == "2.7.1-b300-fhir-profile-snapshots-6db26c008b"
    error_message = "Expected output was 2.7.1-b300-fhir-profile-snapshots-6db26c008b but is: [${terraform_data.version_labels_main.output.fhirProfileVersion}]."
  }

  # assert version labels main has correct value for fhirProfileVersions_0
  assert {
    condition     = terraform_data.version_labels_main.output.fhirProfileVersions_0 == "latest-6.0.0"
    error_message = "Expected output was latest-6.0.0 but is: [${terraform_data.version_labels_main.output.fhirProfileVersions_0}]."
  }

  # assert version labels main has correct value for fhirProfileVersions_1
  assert {
    condition     = terraform_data.version_labels_main.output.fhirProfileVersions_1 == "5.3.1-b94"
    error_message = "Expected output was 5.3.1-b94 but is: [${terraform_data.version_labels_main.output.fhirProfileVersions_1}]."
  }

  # assert version labels canary has all required keys
  assert {
    condition     = length(keys(terraform_data.version_labels_canary.output)) == 4 && contains(keys(terraform_data.version_labels_canary.output), "fhirProfile") && contains(keys(terraform_data.version_labels_canary.output), "fhirProfileVersion") && contains(keys(terraform_data.version_labels_canary.output), "fhirProfileVersions_0") && contains(keys(terraform_data.version_labels_canary.output), "fhirProfileVersions_1")
    error_message = "Expected Keys fhirProfile, fhirProfileVersion, fhirProfileVersions_0, fhirProfileVersions_1 to be present in output but is: ${jsonencode(keys(terraform_data.version_labels_canary.output))}."
  }

  # assert version labels canary has correct value for fhirProfile
  assert {
    condition     = terraform_data.version_labels_canary.output.fhirProfile == "fhir-profile-snapshots"
    error_message = "Expected output was fhir-profile-snapshots but is: ${terraform_data.version_labels_canary.output.fhirProfile}."
  }

  # assert version labels canary has correct value for fhirProfileVersion
  assert {
    condition     = terraform_data.version_labels_canary.output.fhirProfileVersion == "2.7.1-b301-fhir-profile-snapshots-aa5906c72a"
    error_message = "Expected output was 2.7.1-b301-fhir-profile-snapshots-aa5906c72a but is: ${terraform_data.version_labels_canary.output.fhirProfileVersion}."
  }

  # assert version labels canary has correct value for fhirProfileVersions_0
  assert {
    condition     = terraform_data.version_labels_canary.output.fhirProfileVersions_0 == "latest-preview-6.0.0"
    error_message = "Expected output was latest-preview-6.0.0 but is: ${terraform_data.version_labels_canary.output.fhirProfileVersions_0}."
  }

  # assert version labels canary has correct value for fhirProfileVersions_1
  assert {
    condition     = terraform_data.version_labels_canary.output.fhirProfileVersions_1 == "5.3.1-b94"
    error_message = "Expected output was 5.3.1-b94 but is: ${terraform_data.version_labels_canary.output.fhirProfileVersions_1}."
  }

  # assert destination subsets main has all required keys
  assert {
    condition     = length(keys(terraform_data.destination_subsets_main.output)) == 1 && contains(keys(terraform_data.destination_subsets_main.output), "destinationSubsets") && length(keys(terraform_data.destination_subsets_main.output.destinationSubsets)) == 1 && contains(keys(terraform_data.destination_subsets_main.output.destinationSubsets), "main")
    error_message = "Expected Keys destinationSubsets to be present in output but is: ${jsonencode(keys(terraform_data.destination_subsets_main.output))}."
  }

  # assert destination subsets main has correct value for destinationSubsets.main.name
  assert {
    condition     = terraform_data.destination_subsets_main.output.destinationSubsets.main.name == "2.7.1-b300-fhir-profile-snapshots-6db26c008b"
    error_message = "Expected output was 2.7.1-b300-fhir-profile-snapshots-6db26c008b but is: ${terraform_data.destination_subsets_main.output.destinationSubsets.main.name}."
  }

  # assert destination subsets main has correct value for destinationSubsets.main.extraLabels.fhirProfile
  assert {
    condition     = terraform_data.destination_subsets_main.output.destinationSubsets.main.extraLabels.fhirProfile == "fhir-profile-snapshots"
    error_message = "Expected output was fhir-profile-snapshots but is: ${terraform_data.destination_subsets_main.output.destinationSubsets.main.extraLabels.fhirProfile}."
  }
  # assert destination subsets main has correct value for destinationSubsets.main.extraLabels.fhirProfileVersion
  assert {
    condition     = terraform_data.destination_subsets_main.output.destinationSubsets.main.extraLabels.fhirProfileVersion == "2.7.1-b300-fhir-profile-snapshots-6db26c008b"
    error_message = "Expected output was 2.7.1-b300-fhir-profile-snapshots-6db26c008b but is: ${terraform_data.destination_subsets_main.output.destinationSubsets.main.extraLabels.fhirProfileVersion}."
  }

  # assert destination subsets main has correct value for destinationSubsets.main.extraLabels.fhirProfileVersions_0
  assert {
    condition     = terraform_data.destination_subsets_main.output.destinationSubsets.main.extraLabels.fhirProfileVersions_0 == "latest-6.0.0"
    error_message = "Expected output was latest-6.0.0 but is: ${terraform_data.destination_subsets_main.output.destinationSubsets.main.extraLabels.fhirProfileVersions_0}."
  }

  # assert destination subsets main has correct value for destinationSubsets.main.extraLabels.fhirProfileVersions_1
  assert {
    condition     = terraform_data.destination_subsets_main.output.destinationSubsets.main.extraLabels.fhirProfileVersions_1 == "5.3.1-b94"
    error_message = "Expected output was 5.3.1-b94 but is: ${terraform_data.destination_subsets_main.output.destinationSubsets.main.extraLabels.fhirProfileVersions_1}."
  }

  # destination subsets canary has all required keys
  assert {
    condition     = length(keys(terraform_data.destination_subsets_canary.output)) == 1 && contains(keys(terraform_data.destination_subsets_canary.output), "destinationSubsets") && length(keys(terraform_data.destination_subsets_canary.output.destinationSubsets)) == 1 && contains(keys(terraform_data.destination_subsets_canary.output.destinationSubsets), "canary")
    error_message = "Expected Keys destinationSubsets canary to be present in output but is: ${jsonencode(keys(terraform_data.destination_subsets_canary.output.destinationSubsets))}."
  }

  # assert destination subsets canary has correct value for destinationSubsets.canary.name
  assert {
    condition     = terraform_data.destination_subsets_canary.output.destinationSubsets.canary.name == "2.7.1-b301-fhir-profile-snapshots-aa5906c72a"
    error_message = "Expected output was 2.7.1-b301-fhir-profile-snapshots-aa5906c72a but is: ${terraform_data.destination_subsets_canary.output.destinationSubsets.canary.name}."
  }

  # assert destination subsets canary has correct value for destinationSubsets.canary.extraLabels.fhirProfile
  assert {
    condition     = terraform_data.destination_subsets_canary.output.destinationSubsets.canary.extraLabels.fhirProfile == "fhir-profile-snapshots"
    error_message = "Expected output was fhir-profile-snapshots but is: ${terraform_data.destination_subsets_canary.output.destinationSubsets.canary.extraLabels.fhirProfile}."
  }

  # assert destination subsets canary has correct value for destinationSubsets.canary.extraLabels.fhirProfileVersion
  assert {
    condition     = terraform_data.destination_subsets_canary.output.destinationSubsets.canary.extraLabels.fhirProfileVersion == "2.7.1-b301-fhir-profile-snapshots-aa5906c72a"
    error_message = "Expected output was 2.7.1-b301-fhir-profile-snapshots-aa5906c72a but is: ${terraform_data.destination_subsets_canary.output.destinationSubsets.canary.extraLabels.fhirProfileVersion}."
  }

  # assert destination subsets canary has correct value for destinationSubsets.canary.extraLabels.fhirProfileVersions_0
  assert {
    condition     = terraform_data.destination_subsets_canary.output.destinationSubsets.canary.extraLabels.fhirProfileVersions_0 == "latest-preview-6.0.0"
    error_message = "Expected output was latest-preview-6.0.0 but is: ${terraform_data.destination_subsets_canary.output.destinationSubsets.canary.extraLabels.fhirProfileVersions_0}."
  }

  # assert destination subsets canary has correct value for destinationSubsets.canary.extraLabels.fhirProfileVersions_1
  assert {
    condition     = terraform_data.destination_subsets_canary.output.destinationSubsets.canary.extraLabels.fhirProfileVersions_1 == "5.3.1-b94"
    error_message = "Expected output was 5.3.1-b94 but is: ${terraform_data.destination_subsets_canary.output.destinationSubsets.canary.extraLabels.fhirProfileVersions_1}."
  }

  # assert destination subsets main has all required keys
  assert {
    condition     = length(keys(terraform_data.destination_subsets.output)) == 1 && contains(keys(terraform_data.destination_subsets.output), "destinationSubsets") && length(keys(terraform_data.destination_subsets.output.destinationSubsets)) == 1 && contains(keys(terraform_data.destination_subsets.output.destinationSubsets), "main")
    error_message = "Expected Keys destinationSubsets to be present in output but is: ${jsonencode(keys(terraform_data.destination_subsets.output))}."
  }

  # assert destination subsets main has correct value for destinationSubsets.main.name
  assert {
    condition     = terraform_data.destination_subsets.output.destinationSubsets.main.name == "2.7.1-b300-fhir-profile-snapshots-6db26c008b"
    error_message = "Expected output was 2.7.1-b300-fhir-profile-snapshots-6db26c008b but is: ${terraform_data.destination_subsets.output.destinationSubsets.main.name}."
  }

  # assert destination subsets main has correct value for destinationSubsets.main.extraLabels.fhirProfile
  assert {
    condition     = terraform_data.destination_subsets.output.destinationSubsets.main.extraLabels.fhirProfile == "fhir-profile-snapshots"
    error_message = "Expected output was fhir-profile-snapshots but is: ${terraform_data.destination_subsets.output.destinationSubsets.main.extraLabels.fhirProfile}."
  }
  # assert destination subsets main has correct value for destinationSubsets.main.extraLabels.fhirProfileVersion
  assert {
    condition     = terraform_data.destination_subsets.output.destinationSubsets.main.extraLabels.fhirProfileVersion == "2.7.1-b300-fhir-profile-snapshots-6db26c008b"
    error_message = "Expected output was 2.7.1-b300-fhir-profile-snapshots-6db26c008b but is: ${terraform_data.destination_subsets.output.destinationSubsets.main.extraLabels.fhirProfileVersion}."
  }

  # assert destination subsets main has correct value for destinationSubsets.main.extraLabels.fhirProfileVersions_0
  assert {
    condition     = terraform_data.destination_subsets.output.destinationSubsets.main.extraLabels.fhirProfileVersions_0 == "latest-6.0.0"
    error_message = "Expected output was latest-6.0.0 but is: ${terraform_data.destination_subsets.output.destinationSubsets.main.extraLabels.fhirProfileVersions_0}."
  }

  # assert destination subsets main has correct value for destinationSubsets.main.extraLabels.fhirProfileVersions_1
  assert {
    condition     = terraform_data.destination_subsets.output.destinationSubsets.main.extraLabels.fhirProfileVersions_1 == "5.3.1-b94"
    error_message = "Expected output was 5.3.1-b94 but is: ${terraform_data.destination_subsets.output.destinationSubsets.main.extraLabels.fhirProfileVersions_1}."
  }
}

# Test profiles output canary is true and canary is filled
run "check_profile_versions_canary_filled_canary" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version  = "2.7.1-b300"
        weight   = 100
        profiles = ["latest-6.0.0", "5.3.1-b94"]
      }
      canary = {
        version  = "2.7.1-b301"
        weight   = 0
        profiles = ["latest-preview-6.0.0", "5.3.1-b94"]
      }
    }
    profile_type              = "fhir-profile-snapshots"
    is_canary                 = true
    default_profile_snapshots = "5.3.1-b94"
  }

  # assert that the canary profile versions are same like main profile versions
  assert {
    condition     = alltrue([for version in terraform_data.canary_profiles.output : contains(["latest-preview-6.0.0", "5.3.1-b94"], version)])
    error_message = "Expected output was [\"latest-preview-6.0.0\",\"5.3.1-b94\"] but is: [${join(",", terraform_data.canary_profiles.output)}]."
  }

  # assert that the main profile versions are same like main profile versions
  assert {
    condition     = alltrue([for version in terraform_data.main_profiles.output : contains(["latest-6.0.0", "5.3.1-b94"], version)])
    error_message = "Expected output was [\"latest-6.0.0\",\"5.3.1-b94\"] but is: [${join(",", terraform_data.main_profiles.output)}]."
  }

  # assert that subset name canary is correct
  assert {
    condition     = terraform_data.subset_name_canary.output == "2.7.1-b301-fhir-profile-snapshots-aa5906c72a"
    error_message = "Expected output was 2.7.1-b301-fhir-profile-snapshots-aa5906c72a but is: [${terraform_data.subset_name_canary.output}]."
  }

  # assert version labels main has all required keys
  assert {
    condition     = length(keys(terraform_data.version_labels_main.output)) == 4 && contains(keys(terraform_data.version_labels_main.output), "fhirProfile") && contains(keys(terraform_data.version_labels_main.output), "fhirProfileVersion") && contains(keys(terraform_data.version_labels_main.output), "fhirProfileVersions_0") && contains(keys(terraform_data.version_labels_main.output), "fhirProfileVersions_1")
    error_message = "Expected Keys fhirProfile, fhirProfileVersion, fhirProfileVersions_0, fhirProfileVersions_1 to be present in output but is: ${jsonencode(keys(terraform_data.version_labels_main.output))}."
  }

  # assert version labels main has correct value for fhirProfile
  assert {
    condition     = terraform_data.version_labels_main.output.fhirProfile == "fhir-profile-snapshots"
    error_message = "Expected output was fhir-profile-snapshots but is: [${terraform_data.version_labels_main.output.fhirProfile}]."
  }

  # assert version labels main has correct value for fhirProfileVersion
  assert {
    condition     = terraform_data.version_labels_main.output.fhirProfileVersion == "2.7.1-b300-fhir-profile-snapshots-6db26c008b"
    error_message = "Expected output was 2.7.1-b300-fhir-profile-snapshots-6db26c008b but is: [${terraform_data.version_labels_main.output.fhirProfileVersion}]."
  }

  # assert version labels main has correct value for fhirProfileVersions_0
  assert {
    condition     = terraform_data.version_labels_main.output.fhirProfileVersions_0 == "latest-6.0.0"
    error_message = "Expected output was latest-6.0.0 but is: [${terraform_data.version_labels_main.output.fhirProfileVersions_0}]."
  }

  # assert version labels main has correct value for fhirProfileVersions_1
  assert {
    condition     = terraform_data.version_labels_main.output.fhirProfileVersions_1 == "5.3.1-b94"
    error_message = "Expected output was 5.3.1-b94 but is: [${terraform_data.version_labels_main.output.fhirProfileVersions_1}]."
  }

  # assert version labels canary has all required keys
  assert {
    condition     = length(keys(terraform_data.version_labels_canary.output)) == 4 && contains(keys(terraform_data.version_labels_canary.output), "fhirProfile") && contains(keys(terraform_data.version_labels_canary.output), "fhirProfileVersion") && contains(keys(terraform_data.version_labels_canary.output), "fhirProfileVersions_0") && contains(keys(terraform_data.version_labels_canary.output), "fhirProfileVersions_1")
    error_message = "Expected Keys fhirProfile, fhirProfileVersion, fhirProfileVersions_0, fhirProfileVersions_1 to be present in output but is: ${jsonencode(keys(terraform_data.version_labels_canary.output))}."
  }

  # assert version labels canary has correct value for fhirProfile
  assert {
    condition     = terraform_data.version_labels_canary.output.fhirProfile == "fhir-profile-snapshots"
    error_message = "Expected output was fhir-profile-snapshots but is: ${terraform_data.version_labels_canary.output.fhirProfile}."
  }

  # assert version labels canary has correct value for fhirProfileVersion
  assert {
    condition     = terraform_data.version_labels_canary.output.fhirProfileVersion == "2.7.1-b301-fhir-profile-snapshots-aa5906c72a"
    error_message = "Expected output was 2.7.1-b301-fhir-profile-snapshots-aa5906c72a but is: ${terraform_data.version_labels_canary.output.fhirProfileVersion}."
  }

  # assert version labels canary has correct value for fhirProfileVersions_0
  assert {
    condition     = terraform_data.version_labels_canary.output.fhirProfileVersions_0 == "latest-preview-6.0.0"
    error_message = "Expected output was latest-preview-6.0.0 but is: ${terraform_data.version_labels_canary.output.fhirProfileVersions_0}."
  }

  # assert version labels canary has correct value for fhirProfileVersions_1
  assert {
    condition     = terraform_data.version_labels_canary.output.fhirProfileVersions_1 == "5.3.1-b94"
    error_message = "Expected output was 5.3.1-b94 but is: ${terraform_data.version_labels_canary.output.fhirProfileVersions_1}."
  }

  # assert destination subsets main has all required keys
  assert {
    condition     = length(keys(terraform_data.destination_subsets_main.output)) == 1 && contains(keys(terraform_data.destination_subsets_main.output), "destinationSubsets") && length(keys(terraform_data.destination_subsets_main.output.destinationSubsets)) == 1 && contains(keys(terraform_data.destination_subsets_main.output.destinationSubsets), "main")
    error_message = "Expected Keys destinationSubsets to be present in output but is: ${jsonencode(keys(terraform_data.destination_subsets_main.output))}."
  }

  # assert destination subsets main has correct value for destinationSubsets.main.name
  assert {
    condition     = terraform_data.destination_subsets_main.output.destinationSubsets.main.name == "2.7.1-b300-fhir-profile-snapshots-6db26c008b"
    error_message = "Expected output was 2.7.1-b300-fhir-profile-snapshots-6db26c008b but is: ${terraform_data.destination_subsets_main.output.destinationSubsets.main.name}."
  }

  # assert destination subsets main has correct value for destinationSubsets.main.extraLabels.fhirProfile
  assert {
    condition     = terraform_data.destination_subsets_main.output.destinationSubsets.main.extraLabels.fhirProfile == "fhir-profile-snapshots"
    error_message = "Expected output was fhir-profile-snapshots but is: ${terraform_data.destination_subsets_main.output.destinationSubsets.main.extraLabels.fhirProfile}."
  }
  # assert destination subsets main has correct value for destinationSubsets.main.extraLabels.fhirProfileVersion
  assert {
    condition     = terraform_data.destination_subsets_main.output.destinationSubsets.main.extraLabels.fhirProfileVersion == "2.7.1-b300-fhir-profile-snapshots-6db26c008b"
    error_message = "Expected output was 2.7.1-b300-fhir-profile-snapshots-6db26c008b but is: ${terraform_data.destination_subsets_main.output.destinationSubsets.main.extraLabels.fhirProfileVersion}."
  }

  # assert destination subsets main has correct value for destinationSubsets.main.extraLabels.fhirProfileVersions_0
  assert {
    condition     = terraform_data.destination_subsets_main.output.destinationSubsets.main.extraLabels.fhirProfileVersions_0 == "latest-6.0.0"
    error_message = "Expected output was latest-6.0.0 but is: ${terraform_data.destination_subsets_main.output.destinationSubsets.main.extraLabels.fhirProfileVersions_0}."
  }

  # assert destination subsets main has correct value for destinationSubsets.main.extraLabels.fhirProfileVersions_1
  assert {
    condition     = terraform_data.destination_subsets_main.output.destinationSubsets.main.extraLabels.fhirProfileVersions_1 == "5.3.1-b94"
    error_message = "Expected output was 5.3.1-b94 but is: ${terraform_data.destination_subsets_main.output.destinationSubsets.main.extraLabels.fhirProfileVersions_1}."
  }

  # destination subsets canary has all required keys
  assert {
    condition     = length(keys(terraform_data.destination_subsets_canary.output)) == 1 && contains(keys(terraform_data.destination_subsets_canary.output), "destinationSubsets") && length(keys(terraform_data.destination_subsets_canary.output.destinationSubsets)) == 1 && contains(keys(terraform_data.destination_subsets_canary.output.destinationSubsets), "canary")
    error_message = "Expected Keys destinationSubsets canary to be present in output but is: ${jsonencode(keys(terraform_data.destination_subsets_canary.output.destinationSubsets))}."
  }

  # assert destination subsets canary has correct value for destinationSubsets.canary.name
  assert {
    condition     = terraform_data.destination_subsets_canary.output.destinationSubsets.canary.name == "2.7.1-b301-fhir-profile-snapshots-aa5906c72a"
    error_message = "Expected output was 2.7.1-b301-fhir-profile-snapshots-aa5906c72a but is: ${terraform_data.destination_subsets_canary.output.destinationSubsets.canary.name}."
  }

  # assert destination subsets canary has correct value for destinationSubsets.canary.extraLabels.fhirProfile
  assert {
    condition     = terraform_data.destination_subsets_canary.output.destinationSubsets.canary.extraLabels.fhirProfile == "fhir-profile-snapshots"
    error_message = "Expected output was fhir-profile-snapshots but is: ${terraform_data.destination_subsets_canary.output.destinationSubsets.canary.extraLabels.fhirProfile}."
  }

  # assert destination subsets canary has correct value for destinationSubsets.canary.extraLabels.fhirProfileVersion
  assert {
    condition     = terraform_data.destination_subsets_canary.output.destinationSubsets.canary.extraLabels.fhirProfileVersion == "2.7.1-b301-fhir-profile-snapshots-aa5906c72a"
    error_message = "Expected output was 2.7.1-b301-fhir-profile-snapshots-aa5906c72a but is: ${terraform_data.destination_subsets_canary.output.destinationSubsets.canary.extraLabels.fhirProfileVersion}."
  }

  # assert destination subsets canary has correct value for destinationSubsets.canary.extraLabels.fhirProfileVersions_0
  assert {
    condition     = terraform_data.destination_subsets_canary.output.destinationSubsets.canary.extraLabels.fhirProfileVersions_0 == "latest-preview-6.0.0"
    error_message = "Expected output was latest-preview-6.0.0 but is: ${terraform_data.destination_subsets_canary.output.destinationSubsets.canary.extraLabels.fhirProfileVersions_0}."
  }

  # assert destination subsets canary has correct value for destinationSubsets.canary.extraLabels.fhirProfileVersions_1
  assert {
    condition     = terraform_data.destination_subsets_canary.output.destinationSubsets.canary.extraLabels.fhirProfileVersions_1 == "5.3.1-b94"
    error_message = "Expected output was 5.3.1-b94 but is: ${terraform_data.destination_subsets_canary.output.destinationSubsets.canary.extraLabels.fhirProfileVersions_1}."
  }

  # assert destination subsets main has all required keys
  assert {
    condition     = length(keys(terraform_data.destination_subsets.output)) == 1 && contains(keys(terraform_data.destination_subsets.output), "destinationSubsets") && length(keys(terraform_data.destination_subsets.output.destinationSubsets)) == 2 && contains(keys(terraform_data.destination_subsets.output.destinationSubsets), "main") && contains(keys(terraform_data.destination_subsets.output.destinationSubsets), "canary")
    error_message = "Expected Keys destinationSubsets to be present in output but is: ${jsonencode(keys(terraform_data.destination_subsets.output))}."
  }

  # assert destination subsets main has correct value for destinationSubsets.main.name
  assert {
    condition     = terraform_data.destination_subsets.output.destinationSubsets.main.name == "2.7.1-b300-fhir-profile-snapshots-6db26c008b"
    error_message = "Expected output was 2.7.1-b300-fhir-profile-snapshots-6db26c008b but is: ${terraform_data.destination_subsets.output.destinationSubsets.main.name}."
  }

  # assert destination subsets canary has correct value for destinationSubsets.canary.name
  assert {
    condition     = terraform_data.destination_subsets.output.destinationSubsets.canary.name == "2.7.1-b301-fhir-profile-snapshots-aa5906c72a"
    error_message = "Expected output was 2.7.1-b301-fhir-profile-snapshots-aa5906c72a but is: ${terraform_data.destination_subsets.output.destinationSubsets.canary.name}."
  }

  # assert destination subsets main has correct value for destinationSubsets.main.extraLabels.fhirProfile
  assert {
    condition     = terraform_data.destination_subsets.output.destinationSubsets.main.extraLabels.fhirProfile == "fhir-profile-snapshots"
    error_message = "Expected output was fhir-profile-snapshots but is: ${terraform_data.destination_subsets.output.destinationSubsets.main.extraLabels.fhirProfile}."
  }

  # assert destination subsets canary has correct value for destinationSubsets.canary.extraLabels.fhirProfile
  assert {
    condition     = terraform_data.destination_subsets.output.destinationSubsets.canary.extraLabels.fhirProfile == "fhir-profile-snapshots"
    error_message = "Expected output was fhir-profile-snapshots but is: ${terraform_data.destination_subsets.output.destinationSubsets.canary.extraLabels.fhirProfile}."
  }

  # assert destination subsets main has correct value for destinationSubsets.main.extraLabels.fhirProfileVersion
  assert {
    condition     = terraform_data.destination_subsets.output.destinationSubsets.main.extraLabels.fhirProfileVersion == "2.7.1-b300-fhir-profile-snapshots-6db26c008b"
    error_message = "Expected output was 2.7.1-b300-fhir-profile-snapshots-6db26c008b but is: ${terraform_data.destination_subsets.output.destinationSubsets.main.extraLabels.fhirProfileVersion}."
  }

  # assert destination subsets canary has correct value for destinationSubsets.canary.extraLabels.fhirProfileVersion
  assert {
    condition     = terraform_data.destination_subsets.output.destinationSubsets.canary.extraLabels.fhirProfileVersion == "2.7.1-b301-fhir-profile-snapshots-aa5906c72a"
    error_message = "Expected output was 2.7.1-b301-fhir-profile-snapshots-aa5906c72a but is: ${terraform_data.destination_subsets.output.destinationSubsets.canary.extraLabels.fhirProfileVersion}."
  }

  # assert destination subsets main has correct value for destinationSubsets.main.extraLabels.fhirProfileVersions_0
  assert {
    condition     = terraform_data.destination_subsets.output.destinationSubsets.main.extraLabels.fhirProfileVersions_0 == "latest-6.0.0"
    error_message = "Expected output was latest-6.0.0 but is: ${terraform_data.destination_subsets.output.destinationSubsets.main.extraLabels.fhirProfileVersions_0}."
  }

  # assert destination subsets canary has correct value for destinationSubsets.canary.extraLabels.fhirProfileVersions_0
  assert {
    condition     = terraform_data.destination_subsets.output.destinationSubsets.canary.extraLabels.fhirProfileVersions_0 == "latest-preview-6.0.0"
    error_message = "Expected output was latest-preview-6.0.0 but is: ${terraform_data.destination_subsets.output.destinationSubsets.canary.extraLabels.fhirProfileVersions_0}."
  }

  # assert destination subsets main has correct value for destinationSubsets.main.extraLabels.fhirProfileVersions_1
  assert {
    condition     = terraform_data.destination_subsets.output.destinationSubsets.main.extraLabels.fhirProfileVersions_1 == "5.3.1-b94"
    error_message = "Expected output was 5.3.1-b94 but is: ${terraform_data.destination_subsets.output.destinationSubsets.main.extraLabels.fhirProfileVersions_1}."
  }

  # assert destination subsets canary has correct value for destinationSubsets.canary.extraLabels.fhirProfileVersions_1
  assert {
    condition     = terraform_data.destination_subsets.output.destinationSubsets.canary.extraLabels.fhirProfileVersions_1 == "5.3.1-b94"
    error_message = "Expected output was 5.3.1-b94 but is: ${terraform_data.destination_subsets.output.destinationSubsets.canary.extraLabels.fhirProfileVersions_1}."
  }
}

# Test support for fhir-profile-snapshots canary is false
run "check_support_fhir_profile_snapshots_main" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version  = "2.7.1-b300"
        weight   = 100
        profiles = ["latest-6.0.0", "5.3.1-b94"]
      }
      canary = {}
    }
    profile_type              = "fhir-profile-snapshots"
    is_canary                 = false
    default_profile_snapshots = "5.3.1-b94"
  }

  # assert that fhire-profile-snapshots is supported
  assert {
    condition     = terraform_data.version_labels_main.output.fhirProfile == "fhir-profile-snapshots"
    error_message = "Expected output was fhir-profile-snapshots but is: [${terraform_data.version_labels_main.output.fhirProfile}]."
  }

  # assert that fhire-profile-snapshots is supported
  assert {
    condition     = terraform_data.version_labels_canary.output.fhirProfile == "fhir-profile-snapshots"
    error_message = "Expected output was fhir-profile-snapshots but is: [${terraform_data.version_labels_main.output.fhirProfile}]."
  }

}

# Test support for fhir-profile-snapshots canary is true
run "check_support_fhir_profile_snapshots_canary" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version  = "2.7.1-b300"
        weight   = 100
        profiles = ["latest-6.0.0", "5.3.1-b94"]
      }
      canary = {}
    }
    profile_type              = "fhir-profile-snapshots"
    is_canary                 = false
    default_profile_snapshots = "5.3.1-b94"
  }

  # assert that fhire-profile-snapshots is supported
  assert {
    condition     = terraform_data.version_labels_main.output.fhirProfile == "fhir-profile-snapshots"
    error_message = "Expected output was fhir-profile-snapshots but is: [${terraform_data.version_labels_main.output.fhirProfile}]."
  }

  # assert that fhire-profile-snapshots is supported
  assert {
    condition     = terraform_data.version_labels_canary.output.fhirProfile == "fhir-profile-snapshots"
    error_message = "Expected output was fhir-profile-snapshots but is: [${terraform_data.version_labels_main.output.fhirProfile}]."
  }

}

# Test support for igs-profile-snapshots canary is false
run "check_support_igs_profile_snapshots_main" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version  = "2.7.1-b300"
        weight   = 100
        profiles = ["latest-6.0.0", "5.3.1-b94"]
      }
      canary = {}
    }
    profile_type              = "igs-profile-snapshots"
    is_canary                 = false
    default_profile_snapshots = "5.3.1-b94"
  }

  # assert that igs-profile-snapshots is supported
  assert {
    condition     = terraform_data.version_labels_main.output.fhirProfile == "igs-profile-snapshots"
    error_message = "Expected output was igs-profile-snapshots but is: [${terraform_data.version_labels_main.output.fhirProfile}]."
  }

  # assert that igs-profile-snapshots is supported
  assert {
    condition     = terraform_data.version_labels_canary.output.fhirProfile == "igs-profile-snapshots"
    error_message = "Expected output was igs-profile-snapshots but is: [${terraform_data.version_labels_main.output.fhirProfile}]."
  }

}

# Test support for igs-profile-snapshots canary is true
run "check_support_igs_profile_snapshots_canary" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version  = "2.7.1-b300"
        weight   = 100
        profiles = ["latest-6.0.0", "5.3.1-b94"]
      }
      canary = {}
    }
    profile_type              = "igs-profile-snapshots"
    is_canary                 = false
    default_profile_snapshots = "5.3.1-b94"
  }

  # assert that igs-profile-snapshots is supported
  assert {
    condition     = terraform_data.version_labels_main.output.fhirProfile == "igs-profile-snapshots"
    error_message = "Expected output was igs-profile-snapshots but is: [${terraform_data.version_labels_main.output.fhirProfile}]."
  }

  # assert that igs-profile-snapshots is supported
  assert {
    condition     = terraform_data.version_labels_canary.output.fhirProfile == "igs-profile-snapshots"
    error_message = "Expected output was igs-profile-snapshots but is: [${terraform_data.version_labels_main.output.fhirProfile}]."
  }

}

# Test support for ars-profile-snapshots canary is false
run "check_support_ars_profile_snapshots_main" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version  = "2.7.1-b300"
        weight   = 100
        profiles = ["latest-6.0.0", "5.3.1-b94"]
      }
      canary = {}
    }
    profile_type              = "ars-profile-snapshots"
    is_canary                 = false
    default_profile_snapshots = "5.3.1-b94"
  }

  # assert that ars-profile-snapshots is supported
  assert {
    condition     = terraform_data.version_labels_main.output.fhirProfile == "ars-profile-snapshots"
    error_message = "Expected output was ars-profile-snapshots but is: [${terraform_data.version_labels_main.output.fhirProfile}]."
  }

  # assert that ars-profile-snapshots is supported
  assert {
    condition     = terraform_data.version_labels_canary.output.fhirProfile == "ars-profile-snapshots"
    error_message = "Expected output was ars-profile-snapshots but is: [${terraform_data.version_labels_main.output.fhirProfile}]."
  }

}

# Test support for ars-profile-snapshots canary is true
run "check_support_ars_profile_snapshots_canary" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version  = "2.7.1-b300"
        weight   = 100
        profiles = ["latest-6.0.0", "5.3.1-b94"]
      }
      canary = {}
    }
    profile_type              = "ars-profile-snapshots"
    is_canary                 = false
    default_profile_snapshots = "5.3.1-b94"
  }

  # assert that ars-profile-snapshots is supported
  assert {
    condition     = terraform_data.version_labels_main.output.fhirProfile == "ars-profile-snapshots"
    error_message = "Expected output was ars-profile-snapshots but is: [${terraform_data.version_labels_main.output.fhirProfile}]."
  }

  # assert that ars-profile-snapshots is supported
  assert {
    condition     = terraform_data.version_labels_canary.output.fhirProfile == "ars-profile-snapshots"
    error_message = "Expected output was ars-profile-snapshots but is: [${terraform_data.version_labels_main.output.fhirProfile}]."
  }

}
