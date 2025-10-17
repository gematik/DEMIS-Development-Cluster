provider "kubernetes" {
  config_path = "${path.module}/.test_kubeconfig"
}

# Test profiles output canary is false and canary is empty
run "check_profile_versions_main_empty_canary" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version  = "2.7.1"
        weight   = 100
        profiles = ["6.0.7", "5.3.1"]
      }
      canary = {}
    }
    profile_type              = "fhir-profile-snapshots"
    default_profile_snapshots = "5.3.1"
    provisioning_mode         = "dedicated"
  }

  # assert that the canary profile versions are same like main profile versions
  assert {
    condition     = alltrue([for version in terraform_data.canary_profiles.output : contains(var.deployment_information.main.profiles, version)])
    error_message = "Expected output was ${jsonencode(var.deployment_information.main.profiles)} but is: [${join(",", terraform_data.canary_profiles.output)}]."
  }

  # assert that the main profile versions are same like main profile versions
  assert {
    condition     = alltrue([for version in terraform_data.main_profiles.output : contains(var.deployment_information.main.profiles, version)])
    error_message = "Expected output was ${jsonencode(var.deployment_information.main.profiles)} but is: [${join(",", terraform_data.main_profiles.output)}]."
  }

  # assert that subset name main is correct
  assert {
    condition     = tolist(terraform_data.subsets_main.output)[0].name == replace("${var.deployment_information.main.version}-${var.profile_type}", ".", "-")
    error_message = "Expected output was ${replace("${var.deployment_information.main.version}-${var.profile_type}-", ".", "-")} but is: ${jsonencode(tolist(terraform_data.subsets_main.output)[0].name)}."
  }

  # assert version canary is empty
  assert {
    condition     = try(tolist(terraform_data.subsets_canary.output)[0].labels.version, null) == null
    error_message = "Expected output was empty but is: ${try(tolist(terraform_data.subsets_canary.output)[0].version, "null")}."
  }

  # assert version main is correct
  assert {
    condition     = tolist(terraform_data.subsets_main.output)[0].labels.version == "2.7.1"
    error_message = "Expected output is 2.7.1 but was : ${tolist(terraform_data.subsets_main.output)[0].labels.version}."
  }

  # assert that canary subsets are empty
  assert {
    condition     = length(terraform_data.subsets_canary.output) == 0
    error_message = "Expected output was empty but is: [${jsonencode(terraform_data.subsets_canary.output)}]."
  }
}

# Test profiles output canary is false and canary is empty
run "check_profile_versions_main_and_canary" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version  = "2.7.1"
        weight   = 100
        profiles = ["6.0.7", "5.3.1"]
      }
      canary = {
        version = "2.7.2"
        weight  = 100
      }
    }
    profile_type              = "fhir-profile-snapshots"
    default_profile_snapshots = "5.3.1"
    provisioning_mode         = "dedicated"
  }

  # assert that the canary profile versions are same like main profile versions
  assert {
    condition     = alltrue([for version in terraform_data.canary_profiles.output : contains(var.deployment_information.main.profiles, version)])
    error_message = "Expected output was ${jsonencode(var.deployment_information.main.profiles)} but is: [${join(",", terraform_data.canary_profiles.output)}]."
  }

  # assert that the main profile versions are same like main profile versions
  assert {
    condition     = alltrue([for version in terraform_data.main_profiles.output : contains(var.deployment_information.main.profiles, version)])
    error_message = "Expected output was ${jsonencode(var.deployment_information.main.profiles)} but is: [${join(",", terraform_data.main_profiles.output)}]."
  }

  # assert that subset name canary is correct
  assert {
    condition     = tolist(terraform_data.subsets_canary.output)[0].name == replace("${var.deployment_information.canary.version}-${var.profile_type}", ".", "-")
    error_message = "Expected output was ${replace("${var.deployment_information.canary.version}-${var.profile_type}", ".", "-")} but is: [${jsonencode(tolist(terraform_data.subsets_canary.output)[0].name)}]."
  }

  # assert that subset name main is correct
  assert {
    condition     = tolist(terraform_data.subsets_main.output)[0].name == replace("${var.deployment_information.main.version}-${var.profile_type}", ".", "-")
    error_message = "Expected output was ${replace("${var.deployment_information.main.version}-${var.profile_type}", ".", "-")} but is: [${jsonencode(tolist(terraform_data.subsets_main.output)[0].name)}]."
  }

  # assert version canary is correct
  assert {
    condition     = tolist(terraform_data.subsets_canary.output)[0].labels.version == "2.7.2"
    error_message = "Expected output was 2.7.2 but is: ${tolist(terraform_data.subsets_canary.output)[0].labels.version}."
  }

  # assert version main is correct
  assert {
    condition     = tolist(terraform_data.subsets_main.output)[0].labels.version == "2.7.1"
    error_message = "Expected output is 2.7.1 but was : ${tolist(terraform_data.subsets_main.output)[0].labels.version}."
  }

}

# Test profiles output canary is false and canary is empty
run "check_profile_versions_main_and_canary_different_versions" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version  = "2.7.1"
        weight   = 100
        profiles = ["6.0.7", "5.3.1"]
      }
      canary = {
        version  = "2.7.2"
        weight   = 100
        profiles = ["6.0.8", "5.3.5"]
      }
    }
    profile_type              = "fhir-profile-snapshots"
    default_profile_snapshots = "5.3.1"
    provisioning_mode         = "dedicated"
  }

  # assert that the canary profile versions are same like main profile versions
  assert {
    condition     = alltrue([for version in terraform_data.canary_profiles.output : contains(var.deployment_information.canary.profiles, version)])
    error_message = "Expected output was ${jsonencode(var.deployment_information.canary.profiles)} but is: [${join(",", terraform_data.canary_profiles.output)}]."
  }

  # assert that the main profile versions are same like main profile versions
  assert {
    condition     = alltrue([for version in terraform_data.main_profiles.output : contains(var.deployment_information.main.profiles, version)])
    error_message = "Expected output was ${jsonencode(var.deployment_information.main.profiles)} but is: [${join(",", terraform_data.main_profiles.output)}]."
  }

  # assert that subset name canary is correct
  assert {
    condition     = tolist(terraform_data.subsets_canary.output)[0].name == replace("${var.deployment_information.canary.version}-${var.profile_type}", ".", "-")
    error_message = "Expected output was ${replace("${var.deployment_information.canary.version}-${var.profile_type}", ".", "-")} but is: [${jsonencode(tolist(terraform_data.subsets_canary.output)[0].name)}]."
  }

  # assert that subset name main is correct
  assert {
    condition     = tolist(terraform_data.subsets_main.output)[0].name == replace("${var.deployment_information.main.version}-${var.profile_type}", ".", "-")
    error_message = "Expected output was ${replace("${var.deployment_information.main.version}-${var.profile_type}", ".", "-")} but is: [${jsonencode(tolist(terraform_data.subsets_main.output)[0].name)}]."
  }

  # assert version canary is correct
  assert {
    condition     = tolist(terraform_data.subsets_canary.output)[0].labels.version == "2.7.2"
    error_message = "Expected output was 2.7.2 but is: ${tolist(terraform_data.subsets_canary.output)[0].labels.version}."
  }

  # assert version main is correct
  assert {
    condition     = tolist(terraform_data.subsets_main.output)[0].labels.version == "2.7.1"
    error_message = "Expected output is 2.7.1 but was : ${tolist(terraform_data.subsets_main.output)[0].labels.version}."
  }

}


# Test support for fhir-profile-snapshots
run "check_support_fhir_profile_snapshots_main" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version  = "2.7.1-b300"
        weight   = 100
        profiles = ["6.0.7", "5.3.1"]
      }
      canary = {}
    }
    profile_type              = "fhir-profile-snapshots"
    default_profile_snapshots = "5.3.1"
    provisioning_mode         = "dedicated"
  }

  # assert that fhire-profile-snapshots is supported
  assert {
    condition     = tolist(terraform_data.subsets_main.output)[0].labels.fhirProfile == "fhir-profile-snapshots"
    error_message = "Expected output was fhir-profile-snapshots but is: [${tolist(terraform_data.subsets_main.output)[0].labels.fhirProfile}]."
  }
}

# Test support for fhir-profile-snapshots canary deployment
run "check_support_fhir_profile_snapshots_canary" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version  = "2.7.1"
        weight   = 100
        profiles = ["6.0.7", "5.3.1"]
      }
      canary = {
        version = "2.7.2"
        weight  = 0
      }
    }
    profile_type              = "fhir-profile-snapshots"
    default_profile_snapshots = "5.3.1"
    provisioning_mode         = "dedicated"
  }

  # assert that fhire-profile-snapshots is supported
  assert {
    condition     = tolist(terraform_data.subsets_canary.output)[0].labels.fhirProfile == "fhir-profile-snapshots"
    error_message = "Expected output was fhir-profile-snapshots but is: [${tolist(terraform_data.subsets_canary.output)[0].labels.fhirProfile}]."
  }
}

# Test support for igs-profile-snapshots
run "check_support_igs_profile_snapshots_main" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version  = "2.7.1"
        weight   = 100
        profiles = ["6.0.6", "5.3.1"]
      }
      canary = {}
    }
    profile_type              = "igs-profile-snapshots"
    default_profile_snapshots = "5.3.1"
    provisioning_mode         = "dedicated"
  }

  # assert that igs-profile-snapshots is supported
  assert {
    condition     = tolist(terraform_data.subsets_main.output)[0].labels.fhirProfile == "igs-profile-snapshots"
    error_message = "Expected output was igs-profile-snapshots but is: [${tolist(terraform_data.subsets_main.output)[0].labels.fhirProfile}]."
  }
}

# Test support for igs-profile-snapshots canary deployment
run "check_support_igs_profile_snapshots_canary" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version  = "2.7.1"
        weight   = 100
        profiles = ["6.0.0", "5.3.1"]
      }
      canary = {
        version = "2.7.2"
        weight  = 0
      }
    }
    profile_type              = "igs-profile-snapshots"
    default_profile_snapshots = "5.3.1"
    provisioning_mode         = "dedicated"
  }

  # assert that igs-profile-snapshots is supported
  assert {
    condition     = tolist(terraform_data.subsets_canary.output)[0].labels.fhirProfile == "igs-profile-snapshots"
    error_message = "Expected output was igs-profile-snapshots but is: [${tolist(terraform_data.subsets_canary.output)[0].labels.fhirProfile}]."
  }
}

# Test support for ars-profile-snapshots
run "check_support_ars_profile_snapshots_main" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version  = "2.7.1"
        weight   = 100
        profiles = ["6.0.0", "5.3.1"]
      }
      canary = {}
    }
    profile_type              = "ars-profile-snapshots"
    default_profile_snapshots = "5.3.1"
    provisioning_mode         = "dedicated"
  }

  # assert that ars-profile-snapshots is supported
  assert {
    condition     = tolist(terraform_data.subsets_main.output)[0].labels.fhirProfile == "ars-profile-snapshots"
    error_message = "Expected output was ars-profile-snapshots but is: [${tolist(terraform_data.subsets_main.output)[0].labels.fhirProfile}]."
  }
}

# Test support for ars-profile-snapshots canary deployment
run "check_support_ars_profile_snapshots_canary" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version  = "2.7.1"
        weight   = 100
        profiles = ["6.0.0", "5.3.1"]
      }
      canary = {
        version = "2.7.2"
        weight  = 0
      }
    }
    profile_type              = "ars-profile-snapshots"
    default_profile_snapshots = "5.3.1"
    provisioning_mode         = "dedicated"
  }

  # assert that ars-profile-snapshots is supported
  assert {
    condition     = tolist(terraform_data.subsets_canary.output)[0].labels.fhirProfile == "ars-profile-snapshots"
    error_message = "Expected output was ars-profile-snapshots but is: [${tolist(terraform_data.subsets_canary.output)[0].labels.fhirProfile}]."
  }

}

# Test for dedicated profile main deployment
run "check_dedicated_main_deployment" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version  = "2.7.1"
        weight   = 100
        profiles = ["6.0.0", "5.3.1"]
      }
      canary = {}
    }
    profile_type              = "fhir-profile-snapshots"
    default_profile_snapshots = "5.3.1"
    provisioning_mode         = "dedicated"
  }

  # assert that subsets_main length is correct
  assert {
    condition     = length(tolist(terraform_data.subsets_main.output)) == 1
    error_message = "Expected output was 1 but is: ${length(tolist(terraform_data.subsets_main.output))}."
  }

  # assert that subsets_main labels length is correct
  assert {
    condition     = length(tolist(terraform_data.subsets_main.output)[0].labels) == 3
    error_message = "Expected output was 3 but is: ${length(tolist(terraform_data.subsets_main.output)[0].labels)}."
  }

  # assert that subsets_canary length is correct
  assert {
    condition     = length(tolist(terraform_data.subsets_canary.output)) == 0
    error_message = "Expected output was 0 but is: ${length(tolist(terraform_data.subsets_canary.output))}."
  }
}

# Test for dedicated profile canary deployment
run "check_dedicated_canary_deployment" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version  = "2.7.1"
        weight   = 100
        profiles = ["6.0.0", "5.3.1"]
      }
      canary = {
        version = "2.7.2"
        weight  = 0
      }
    }
    profile_type              = "fhir-profile-snapshots"
    default_profile_snapshots = "5.3.1"
    provisioning_mode         = "dedicated"
  }

  # assert that subsets_main length is correct
  assert {
    condition     = length(tolist(terraform_data.subsets_main.output)) == 1
    error_message = "Expected output was 1 but is: ${length(tolist(terraform_data.subsets_main.output))}."
  }

  # assert that subsets_main labels length is correct
  assert {
    condition     = length(tolist(terraform_data.subsets_main.output)[0].labels) == 3
    error_message = "Expected output was 3 but is: ${length(tolist(terraform_data.subsets_main.output)[0].labels)}."
  }

  # assert that subsets_canary length is correct
  assert {
    condition     = length(tolist(terraform_data.subsets_canary.output)) == 1
    error_message = "Expected output was 1 but is: ${length(tolist(terraform_data.subsets_canary.output))}."
  }

  # assert that subsets_main labels length is correct
  assert {
    condition     = length(tolist(terraform_data.subsets_canary.output)[0].labels) == 3
    error_message = "Expected output was 3 but is: ${length(tolist(terraform_data.subsets_canary.output)[0].labels)}."
  }
}

# Test for distributed main deployment
run "check_distributed_main_deployment" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version  = "2.7.1"
        weight   = 100
        profiles = ["6.0.0", "5.3.1"]
      }
      canary = {}
    }
    profile_type              = "fhir-profile-snapshots"
    default_profile_snapshots = "5.3.1"
    provisioning_mode         = "distributed"
  }

  # assert that subsets_main length is correct
  assert {
    condition     = length(tolist(terraform_data.subsets_main.output)) == 2
    error_message = "Expected output was 1 but is: ${length(tolist(terraform_data.subsets_main.output))}."
  }

  # assert that subsets_main labels length is correct
  assert {
    condition     = alltrue([for subset in tolist(terraform_data.subsets_main.output) : (length(subset.labels) == 3)])
    error_message = "Expected output was 3 for all but is: ${jsonencode([for subset in tolist(terraform_data.subsets_main.output) : length(subset.labels)])}."
  }

  # assert that subsets_canary length is correct
  assert {
    condition     = length(tolist(terraform_data.subsets_canary.output)) == 0
    error_message = "Expected output was 0 but is: ${length(tolist(terraform_data.subsets_canary.output))}."
  }
}

# Test for distributed canary deployment
run "check_distributed_canary_deployment" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version  = "2.7.1"
        weight   = 100
        profiles = ["6.0.0", "5.3.1"]
      }
      canary = {
        version = "2.7.2"
        weight  = 0
      }
    }
    profile_type              = "fhir-profile-snapshots"
    default_profile_snapshots = "5.3.1"
    provisioning_mode         = "distributed"
  }

  # assert that subsets_main length is correct
  assert {
    condition     = length(tolist(terraform_data.subsets_main.output)) == 2
    error_message = "Expected output was 1 but is: ${length(tolist(terraform_data.subsets_main.output))}."
  }

  # assert that subsets_main labels length is correct
  assert {
    condition     = alltrue([for subset in tolist(terraform_data.subsets_main.output) : (length(subset.labels) == 3)])
    error_message = "Expected output was 3 for all but is: ${jsonencode([for subset in tolist(terraform_data.subsets_main.output) : length(subset.labels)])}."
  }

  # assert that subsets_canary length is correct
  assert {
    condition     = length(tolist(terraform_data.subsets_canary.output)) == 2
    error_message = "Expected output was 1 but is: ${length(tolist(terraform_data.subsets_canary.output))}."
  }

  # assert that subsets_canary labels length is correct
  assert {
    condition     = alltrue([for subset in tolist(terraform_data.subsets_canary.output) : (length(subset.labels) == 3)])
    error_message = "Expected output was 3 for all but is: ${jsonencode([for subset in tolist(terraform_data.subsets_canary.output) : length(subset.labels)])}."
  }
}

# Test for combined main deployment
run "check_combined_main_deployment" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version  = "2.7.1"
        weight   = 100
        profiles = ["6.0.0", "5.3.1"]
      }
      canary = {}
    }
    profile_type              = "fhir-profile-snapshots"
    default_profile_snapshots = "5.3.1"
    provisioning_mode         = "combined"
  }

  # assert that subsets_main length is correct
  assert {
    condition     = length(tolist(terraform_data.subsets_main.output)) == 3
    error_message = "Expected output was 3 but is: ${length(tolist(terraform_data.subsets_main.output))}."
  }

  # assert that subsets_main labels length is correct
  assert {
    condition     = alltrue([for subset in tolist(terraform_data.subsets_main.output) : (length(subset.labels) == 3)])
    error_message = "Expected output was 3 for all but is: ${jsonencode([for subset in tolist(terraform_data.subsets_main.output) : length(subset.labels)])}."
  }
}

# Test for combined canary deployment
run "check_combined_canary_deployment" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version  = "2.7.1"
        weight   = 100
        profiles = ["6.0.0", "5.3.1"]
      }
      canary = {
        version = "2.7.2"
        weight  = 0
      }
    }
    profile_type              = "fhir-profile-snapshots"
    default_profile_snapshots = "5.3.1"
    provisioning_mode         = "combined"
  }

  # assert that subsets_main length is correct
  assert {
    condition     = length(tolist(terraform_data.subsets_main.output)) == 3
    error_message = "Expected output was 3 but is: ${length(tolist(terraform_data.subsets_main.output))}."
  }

  # assert that subsets_main labels length is correct
  assert {
    condition     = alltrue([for subset in tolist(terraform_data.subsets_main.output) : (length(subset.labels) == 3)])
    error_message = "Expected output was 3 for all but is: ${jsonencode([for subset in tolist(terraform_data.subsets_main.output) : length(subset.labels)])}."
  }

  # assert that subsets_canary length is correct
  assert {
    condition     = length(tolist(terraform_data.subsets_canary.output)) == 3
    error_message = "Expected output was 3 but is: ${length(tolist(terraform_data.subsets_main.output))}."
  }

  # assert that subsets_canary labels length is correct
  assert {
    condition     = alltrue([for subset in tolist(terraform_data.subsets_canary.output) : (length(subset.labels) == 3)])
    error_message = "Expected output was 3 for all but is: ${jsonencode([for subset in tolist(terraform_data.subsets_main.output) : length(subset.labels)])}."
  }
}

# Test for combined main deployment profile empty
run "check_combined_main_deployment_profiles_empty" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version = "2.7.1"
        weight  = 100
      }
      canary = {}
    }
    profile_type              = "fhir-profile-snapshots"
    default_profile_snapshots = "5.3.1"
    provisioning_mode         = "combined"
  }

  # assert that subsets_main length is correct
  assert {
    condition     = length(tolist(terraform_data.subsets_main.output)) == 1
    error_message = "Expected output was 3 but is: ${length(tolist(terraform_data.subsets_main.output))}."
  }

  # assert that subsets_main labels length is correct
  assert {
    condition     = alltrue([for subset in tolist(terraform_data.subsets_main.output) : (length(subset.labels) == 3)])
    error_message = "Expected output was 3 all but is: ${jsonencode([for subset in tolist(terraform_data.subsets_main.output) : length(subset.labels)])}."
  }
}

# Test for combined canary deployment profile empty
run "check_combined_canary_deployment_profiles_empty" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version = "2.7.1"
        weight  = 100
      }
      canary = {
        version = "2.7.2"
        weight  = 0
      }
    }
    profile_type              = "fhir-profile-snapshots"
    default_profile_snapshots = "5.3.1"
    provisioning_mode         = "combined"
  }

  # assert that subsets_main length is correct
  assert {
    condition     = length(tolist(terraform_data.subsets_main.output)) == 1
    error_message = "Expected output was 3 but is: ${length(tolist(terraform_data.subsets_main.output))}."
  }

  # assert that subsets_main labels length is correct
  assert {
    condition     = alltrue([for subset in tolist(terraform_data.subsets_main.output) : (length(subset.labels) == 3)])
    error_message = "Expected output was 3 for all but is: ${jsonencode([for subset in tolist(terraform_data.subsets_main.output) : length(subset.labels)])}."
  }

  # assert that subsets_canary length is correct
  assert {
    condition     = length(tolist(terraform_data.subsets_canary.output)) == 1
    error_message = "Expected output was 3 but is: ${length(tolist(terraform_data.subsets_main.output))}."
  }

  # assert that subsets_canary labels length is correct
  assert {
    condition     = alltrue([for subset in tolist(terraform_data.subsets_canary.output) : (length(subset.labels) == 3)])
    error_message = "Expected output was 3 for all but is: ${jsonencode([for subset in tolist(terraform_data.subsets_main.output) : length(subset.labels)])}."
  }

  # assert that canary labels are correct
  assert {
    condition     = alltrue([for subset in tolist(terraform_data.subsets_canary.output) : alltrue([for k, v in subset.labels : (k == "version" || k == "fhirProfile" || k == "fhirProfileVersion")])])
    error_message = "Expected output was version, fhirProfile and fhirProfileVersion but is: ${jsonencode([for subset in tolist(terraform_data.subsets_canary.output) : subset.labels])}."
  }

  # assert that main labels are correct
  assert {
    condition     = alltrue([for subset in tolist(terraform_data.subsets_main.output) : alltrue([for k, v in subset.labels : (k == "version" || k == "fhirProfile" || k == "fhirProfileVersion")])])
    error_message = "Expected output was version, fhirProfile and fhirProfileVersion but is: ${jsonencode([for subset in tolist(terraform_data.subsets_main.output) : subset.labels])}."
  }
}

# Test for combined main deployment profile empty
run "check_combined_canary_deployment_profiles_filed" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version = "2.7.1"
        weight  = 100
      }
      canary = {
        version  = "2.7.2"
        weight   = 0
        profiles = ["6.0.8", "5.3.5"]
      }
    }
    profile_type              = "fhir-profile-snapshots"
    default_profile_snapshots = "5.3.1"
    provisioning_mode         = "combined"
  }

  # assert that subsets_main length is correct
  assert {
    condition     = length(tolist(terraform_data.subsets_main.output)) == 1
    error_message = "Expected output was 3 but is: ${length(tolist(terraform_data.subsets_main.output))}."
  }

  # assert that subsets_main labels length is correct
  assert {
    condition     = alltrue([for subset in tolist(terraform_data.subsets_main.output) : (length(subset.labels) == 3)])
    error_message = "Expected output was 3 for all but is: ${jsonencode([for subset in tolist(terraform_data.subsets_main.output) : length(subset.labels)])}."
  }

  # assert that subsets_canary length is correct
  assert {
    condition     = length(tolist(terraform_data.subsets_canary.output)) == 3
    error_message = "Expected output was 3 but is: ${length(tolist(terraform_data.subsets_main.output))}."
  }

  # assert that subsets_canary labels length is correct
  assert {
    condition     = alltrue([for subset in tolist(terraform_data.subsets_canary.output) : (length(subset.labels) == 3)])
    error_message = "Expected output was 3 for all but is: ${jsonencode([for subset in tolist(terraform_data.subsets_main.output) : length(subset.labels)])}."
  }
}

# Test for combined main deployment destination_subsets
run "check_combined_main_deployment_destination_subsets" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version = "2.7.1"
        weight  = 100
      }
      canary = {}
    }
    profile_type              = "fhir-profile-snapshots"
    default_profile_snapshots = "5.3.1"
    provisioning_mode         = "combined"
  }

  # assert that destination_subsets main length is correct
  assert {
    condition     = length(tolist(terraform_data.destination_subsets.output.main)) == 1
    error_message = "Expected output was 1 but is: ${length(tolist(terraform_data.destination_subsets.output.main))}."
  }

  # assert that destination_subsets canary length is correct
  assert {
    condition     = length(tolist(terraform_data.destination_subsets.output.canary)) == 0
    error_message = "Expected output was 0 but is: ${length(tolist(terraform_data.destination_subsets.output.canary))}."
  }

}

# Test for combined main deployment destination_subsets
run "check_combined_canary_deployment_destination_subsets" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version = "2.7.1"
        weight  = 100
      }
      canary = {
        version = "2.7.2"
        weight  = 0
      }
    }
    profile_type              = "fhir-profile-snapshots"
    default_profile_snapshots = "5.3.1"
    provisioning_mode         = "combined"
  }

  # assert that destination_subsets main length is correct
  assert {
    condition     = length(tolist(terraform_data.destination_subsets.output.main)) == 1
    error_message = "Expected output was 1 but is: ${length(tolist(terraform_data.destination_subsets.output.main))}."
  }

  # assert that destination_subsets main has correct weight
  assert {
    condition     = tolist(terraform_data.destination_subsets.output.main)[0].weight == 100
    error_message = "Expected output was 100 but is: ${tolist(terraform_data.destination_subsets.output.main)[0].weight}."
  }

  # assert that destination_subsets main has correct mode
  assert {
    condition     = tolist(terraform_data.destination_subsets.output.main)[0].mode == "distributed"
    error_message = "Expected output was distributed but is: ${tolist(terraform_data.destination_subsets.output.main)[0].mode}."
  }

  # assert that destination_subsets canary length is correct
  assert {
    condition     = length(tolist(terraform_data.destination_subsets.output.canary)) == 1
    error_message = "Expected output was 0 but is: ${length(tolist(terraform_data.destination_subsets.output.canary))}."
  }

  # assert that destination_subsets canary has correct weight
  assert {
    condition     = tolist(terraform_data.destination_subsets.output.canary)[0].weight == 0
    error_message = "Expected output was 0 but is: ${tolist(terraform_data.destination_subsets.output.canary)[0].weight}."
  }

  # assert that destination_subsets canary has correct mode
  assert {
    condition     = tolist(terraform_data.destination_subsets.output.canary)[0].mode == "distributed"
    error_message = "Expected output was distributed but is: ${tolist(terraform_data.destination_subsets.output.canary)[0].mode}."
  }
}

# Test for combined main deployment without canary version but canary profiles
run "check_canary_deployemnt_without_apllication_update" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version  = "2.7.1"
        weight   = 100
        profiles = ["6.0.0", "5.3.1"]
      }
      canary = {
        profiles = ["6.0.8", "5.3.1"]
      }
    }
    profile_type              = "fhir-profile-snapshots"
    default_profile_snapshots = "5.3.1"
    provisioning_mode         = "combined"
  }

  # assert that subsets_canary length is correct
  assert {
    condition     = length(tolist(terraform_data.subsets_canary.output)) == 0
    error_message = "Expected output was 0 but is: ${length(tolist(terraform_data.subsets_canary.output))}."
  }

  # assert that subsets_main length is correct
  assert {
    condition     = length(tolist(terraform_data.subsets_main.output)) == 4
    error_message = "Expected output was 1 but is: ${length(tolist(terraform_data.subsets_main.output))}."
  }

  # assert that subsets_main labels length is correct
  assert {
    condition = alltrue([
      for subset in tolist(terraform_data.subsets_main.output) :
      (length(subset.labels) == 3)
    ])
    error_message = "Expected output was 3 for all but is: ${jsonencode([for subset in tolist(terraform_data.subsets_main.output) : length(subset.labels)])}."
  }

  # assert profiles in main are correct
  assert {
    condition     = alltrue([for version in terraform_data.main_profiles.output : contains(concat(var.deployment_information.main.profiles, var.deployment_information.canary.profiles), version)])
    error_message = "Expected output was ${jsonencode(var.deployment_information.main.profiles)} but is: [${join(",", terraform_data.main_profiles.output)}]."
  }

  # assert profiles in canary are not empty
  assert {
    condition     = length(terraform_data.canary_profiles.output) == 2
    error_message = "Expected output was empty but is: [${jsonencode(terraform_data.canary_profiles.output)}]."
  }
  # assert profiles in canary are correct
  assert {
    condition     = alltrue([for version in terraform_data.canary_profiles.output : contains(concat(var.deployment_information.main.profiles, var.deployment_information.canary.profiles), version)])
    error_message = "Expected output was ${jsonencode(var.deployment_information.canary.profiles)} but is: [${join(",", terraform_data.canary_profiles.output)}]."
  }
}


# Test for combined main deployment without canary version but canary profiles
run "check_canary_deployemnt_without_apllication_update" {
  command = apply

  variables {
    deployment_information = {
      main = {
        version = "2.7.1"
        weight  = 100
      }
      canary = {
        profiles = ["6.0.8", "5.3.1"]
      }
    }
    profile_type              = "fhir-profile-snapshots"
    default_profile_snapshots = "5.3.1"
    provisioning_mode         = "combined"
  }

  # assert that subsets_canary length is correct
  assert {
    condition     = length(tolist(terraform_data.subsets_canary.output)) == 0
    error_message = "Expected output was 0 but is: ${length(tolist(terraform_data.subsets_canary.output))}."
  }

  # assert that subsets_main length is correct
  assert {
    condition     = length(tolist(terraform_data.subsets_main.output)) == 3
    error_message = "Expected output was 3 but is: ${length(tolist(terraform_data.subsets_main.output))}."
  }

  # assert that subsets_main labels length is correct
  assert {
    condition = alltrue([
      for subset in tolist(terraform_data.subsets_main.output) :
      (length(subset.labels) == 3)
    ])
    error_message = "Expected output was 3 for all but is: ${jsonencode([for subset in tolist(terraform_data.subsets_main.output) : length(subset.labels)])}."
  }

  # assert profiles in main are correct
  assert {
    condition     = alltrue([for version in terraform_data.main_profiles.output : contains(concat(var.deployment_information.main.profiles, var.deployment_information.canary.profiles), version)])
    error_message = "Expected output was ${jsonencode(var.deployment_information.main.profiles)} but is: [${join(",", terraform_data.main_profiles.output)}]."
  }

  # assert profiles in canary are not empty
  assert {
    condition     = length(terraform_data.canary_profiles.output) == 2
    error_message = "Expected output was empty but is: [${jsonencode(terraform_data.canary_profiles.output)}]."
  }
  # assert profiles in canary are correct
  assert {
    condition     = alltrue([for version in terraform_data.canary_profiles.output : contains(concat(var.deployment_information.main.profiles, var.deployment_information.canary.profiles), version)])
    error_message = "Expected output was ${jsonencode(var.deployment_information.canary.profiles)} but is: [${join(",", terraform_data.canary_profiles.output)}]."
  }
}
