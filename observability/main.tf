# Retrieve the labels of the Istio namespace (created by the infrastructure, as demis reads the mesh namespace),
# containing the stage and region of the cluster.
data "kubernetes_namespace_v1" "istio_namespace" {
  metadata {
    name = "istio-system"
  }
}

locals {
  # Helm Chart sources: repository name from the Helm repositories.yaml or null (module default URL)
  helm_use_local         = var.helm_repository_source == "local"
  helm_repository_by_key = { for k, v in var.helm_repository_names : k => local.helm_use_local ? v : null }
  # DEMIS Helm Repository: repository name from the Helm repositories.yaml or URL with credentials
  demis_helm_repository          = local.helm_use_local ? var.helm_repository_names.demis : var.demis_helm_repository
  demis_helm_repository_username = local.helm_use_local ? null : var.helm_repository_username
  demis_helm_repository_password = local.helm_use_local ? null : var.helm_repository_password

  cluster_labels = data.kubernetes_namespace_v1.istio_namespace.metadata[0].labels
  stage_name     = local.cluster_labels.cluster
  cluster_region = local.cluster_labels.region
  # Stage folder as in the application modules: "local" for KIND (and public), otherwise <cluster>-<region>
  stage_folder = coalesce(var.override_stage_name, contains(["local", "public"], local.stage_name) ? "local" : "${local.stage_name}-${local.cluster_region}")

  # define the path to the source of the Helm charts values for the stage (as in demis)
  chart_source_path           = "${path.module}/../environments/stage-${local.stage_folder}/observability"
  active_versions_source_path = "${local.chart_source_path}/active-versions.yaml"
  # Import the "active-versions.yaml" file
  deployment_information = yamldecode(file(local.active_versions_source_path))

  # Switched together with the infrastructure: without FEATURE_FLAG_OBSERVABILITY_NAMESPACE_ENABLED the legacy observability of the
  # infrastructure (service-mesh) is active and nothing is deployed here
  namespace_enabled = try(var.project_feature_flags["FEATURE_FLAG_OBSERVABILITY_NAMESPACE_ENABLED"], false)

}
