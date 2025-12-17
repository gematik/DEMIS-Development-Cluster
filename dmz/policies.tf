locals {
  kubernetes_network_policies_name = "kubernetes-network-policies"
  # define the Kyverno Admission Policies
  kubernetes_network_policies = try(local.deployment_information[local.kubernetes_network_policies_name], { main = { version = "0.0.0" }, enabled = false })
}

resource "helm_release" "kubernetes_network_policies" {
  count               = local.kubernetes_network_policies.enabled ? 1 : 0
  name                = local.kubernetes_network_policies_name
  chart               = local.kubernetes_network_policies_name
  repository          = var.helm_repository
  version             = local.kubernetes_network_policies.main.version
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
    templatefile("${local.chart_source_path}/${local.kubernetes_network_policies_name}/values.tftpl.yaml", {
      namespace  = var.target_namespace
      repository = var.docker_registry
    })
  ]
}
