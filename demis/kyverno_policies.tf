########################
# Define Modules
#######################

locals {
  kyverno_policies_name = "kyverno-admission-policies"
  # define the Kyverno Admission Policies
  kyverno_admission_policies = try(local.deployment_information["kyverno-admission-policies"], { main = { version = "0.0.0" }, enabled = false })
}

resource "helm_release" "kyverno_admission_policies" {
  count               = local.kyverno_admission_policies.enabled ? 1 : 0
  name                = local.kyverno_policies_name
  chart               = local.kyverno_policies_name
  repository          = var.helm_repository
  version             = local.kyverno_admission_policies.main.version
  namespace           = var.target_namespace
  repository_username = var.helm_repository_username
  repository_password = var.helm_repository_password
  lint                = true
  atomic              = true
  wait                = true
  wait_for_jobs       = true
  cleanup_on_fail     = true
  timeout             = 600

  values = [
    templatefile("${local.chart_source_path}/${local.kyverno_policies_name}/values.tftpl.yaml", {
      namespace  = var.target_namespace
      repository = var.docker_registry
    })
  ]
}