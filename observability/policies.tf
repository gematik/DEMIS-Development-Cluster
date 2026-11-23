locals {
  kubernetes_network_policies_name = "kubernetes-network-policies"
  # define the Kubernetes Network Policies
  kubernetes_network_policies = try(local.deployment_information[local.kubernetes_network_policies_name], { main = { version = "0.0.0" }, enabled = false })
}

resource "helm_release" "kubernetes_network_policies" {
  # Only with the observability namespace (project feature flag)
  count               = local.namespace_enabled && local.kubernetes_network_policies.enabled ? 1 : 0
  name                = local.kubernetes_network_policies_name
  chart               = local.kubernetes_network_policies_name
  repository          = local.demis_helm_repository
  version             = coalesce(try(local.kubernetes_network_policies.canary.version, null), local.kubernetes_network_policies.main.version)
  namespace           = local.namespace
  repository_username = local.demis_helm_repository_username
  repository_password = local.demis_helm_repository_password
  lint                = true
  atomic              = true
  wait                = true
  wait_for_jobs       = true
  cleanup_on_fail     = true
  timeout             = 600

  values = compact([
    fileexists("${local.chart_source_path}/${local.kubernetes_network_policies_name}/values.tftpl.yaml") ? templatefile("${local.chart_source_path}/${local.kubernetes_network_policies_name}/values.tftpl.yaml", {
      namespace  = local.namespace
      repository = var.docker_registry
    }) : "",
    fileexists("${local.chart_source_path}/${local.kubernetes_network_policies_name}/app-values.yaml") ? file("${local.chart_source_path}/${local.kubernetes_network_policies_name}/app-values.yaml") : ""
  ])
}
