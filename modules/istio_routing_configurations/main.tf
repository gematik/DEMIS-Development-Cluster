locals {
  validator_precheck_command = [
    "${path.module}/.scripts/python_wrapper.sh",
    var.python_interpreter,
    "${path.module}/.scripts/schema_validation.py",
    "--terraform",
    "--input", var.input_mapping_path,
    "--schema", "${path.module}/.scripts/traffic_routes_templates.schema.json"
  ]
  validator_command = [
    "${path.module}/.scripts/python_wrapper.sh",
    var.python_interpreter,
    "${path.module}/.scripts/schema_validation.py",
    "--terraform",
    "--input", "-",
    "--schema", "${path.module}/.scripts/traffic_routes_templates.schema.json"
  ]
  generator_command = [
    "${path.module}/.scripts/python_wrapper.sh",
    var.python_interpreter,
    "${path.module}/.scripts/generate_istio_rules.py",
    "--input", "-",
    "--format", "tfjson"
  ]
}

data "external" "precheck_schema_validation" {
  program = local.validator_precheck_command
}

data "external" "schema_validation" {
  program = local.validator_command
  query = {
    content = yamlencode({
      for key, value in yamldecode(file(var.input_mapping_path)) : key => [
        for routes in value :
        merge(routes, { variables = merge(lookup(routes, "variables", {}), var.global_template_variables) })
      ]
    })
  }

  lifecycle {
    precondition {
      condition     = data.external.precheck_schema_validation.result.valid == "true"
      error_message = data.external.precheck_schema_validation.result.error != "" ? "Rule generation failed: ${data.external.precheck_schema_validation.result.error}" : "Rule generation failed with unknown error."
    }
  }
}

data "external" "istio_rules" {
  program = local.generator_command

  query = {
    content = yamlencode({
      for key, value in yamldecode(file(var.input_mapping_path)) : key => [
        for routes in value :
        merge(routes, { variables = merge(lookup(routes, "variables", {}), var.global_template_variables) })
      ]
    })
  }

  lifecycle {
    precondition {
      condition     = data.external.schema_validation.result.valid == "true"
      error_message = data.external.schema_validation.result.error != "" ? "Schema validation failed: ${data.external.schema_validation.result.error}" : "Schema validation failed with unknown error."
    }
  }
}

locals {
  traffic_routes = {
    for rule in lookup(jsondecode(lookup(data.external.istio_rules.result, "result", "{}")), "traffic_routes", []) :
    rule.service => lookup(rule, "rules", [])
  }
  rules = {
    for s in distinct(concat(compact(var.service_list), compact(keys(local.traffic_routes)))) :
    s => try(local.traffic_routes[s], [])
  }
}

