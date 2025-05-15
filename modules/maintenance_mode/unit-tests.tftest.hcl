# Test replace Deployment of two versions of the same application, no istio

run "maintenance_mode_activate" {
  command = plan

  variables {
    // canary version is set and activate_maintenance_mode is true -> maintenance mode should be activated
    deployment_information = {
      postgres : {
        deployment-strategy = "update"
        enabled             = true
        main = {
          version = "1.0.0"
          weight  = 100
        }
        canary = {
          version = "1.0.1"
        }
      }
    }
    activate_maintenance_mode = true
  }

  assert {
    condition     = length(terraform_data.update_services.output) == 1
    error_message = "Expected update_services to have one element but was: [${join(",", terraform_data.update_services.output)}]"
  }

  assert {
    condition     = output.maintenance_mode_status == "activated"
    error_message = "Expected output.maintenance_mode_status to be 'activated' but was: '${output.maintenance_mode_status}'"
  }
}

run "maintenance_mode_deactivate" {
  command = plan

  variables {
    // canary version is set and activate_maintenance_mode is false -> maintenance mode should be deactivated
    deployment_information = {
      postgres : {
        deployment-strategy = "update"
        enabled             = true
        main = {
          version = "1.0.0"
          weight  = 100
        }
        canary = {
          version = "1.0.1"
        }
      }
    }
    activate_maintenance_mode = false
  }

  assert {
    condition     = length(terraform_data.update_services.output) == 1
    error_message = "Expected update_services to have one element but was: [${join(",", terraform_data.update_services.output)}]"
  }

  assert {
    condition     = output.maintenance_mode_status == "deactivated"
    error_message = "Expected output.maintenance_mode_status to be 'deactivated' but was: '${output.maintenance_mode_status}'"
  }
}

run "no_maintenance_mode_for_replace" {
  command = plan

  variables {
    // deployment-strategy is "replace" -> maintenance mode should not be activated
    deployment_information = {
      postgres : {
        deployment-strategy = "replace"
        enabled             = true
        main = {
          version = "1.0.0"
          weight  = 100
        }
        canary = {
          version = "1.0.1"
        }
      }
    }
    activate_maintenance_mode = true
  }

  assert {
    condition     = length(terraform_data.update_services.output) == 0
    error_message = "Expected update_services to have one element but was: [${join(",", terraform_data.update_services.output)}]"
  }

  assert {
    condition     = output.maintenance_mode_status == "deactivated"
    error_message = "Expected output.maintenance_mode_status to be 'unchanged' but was: '${output.maintenance_mode_status}'"
  }
}
