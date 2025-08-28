# New variable for overriding the stage name
variable "override_stage_name" {
  description = "Override the automatically detected stage name (optional)"
  type        = string
  default     = ""
}

# Retrieve the namespace metadata from the MEsh Namespace,
# containing information about the stage, region and domain of the cluster.
data "kubernetes_namespace" "mesh_namespace" {
  metadata {
    name = "mesh"
  }
}

# Define local variables based on input values
locals {
  # Extract the labels from the Istio Namespace
  cluster_labels = data.kubernetes_namespace.mesh_namespace.metadata[0].labels
  # define if the current stage is local
  is_local_mode = local.cluster_labels.cluster == "local" || local.cluster_labels.cluster == "public"

  # automatically detected stage name (original logic remains unchanged)
  detected_stage_name = local.is_local_mode ? "local" : "${local.cluster_labels.cluster}-${local.cluster_labels.region}"

  # using the override_stage_name variable if provided, otherwise fallback to detected_stage_name
  stage_name = var.override_stage_name != "" ? var.override_stage_name : local.detected_stage_name

  # define labels to be used for all resources
  labels = merge(local.cluster_labels, {
    "kubernetes.io/metadata.name" = var.target_namespace
    application                   = "demis"
    component                     = "demis"
  })

  # define the path to the source of the Helm charts values for the stage
  chart_source_path = "${path.module}/../environments/stage-${local.stage_name}/${var.target_namespace}"
  # define the path to the source of the Helm charts versions for the stage
  active_versions_source_path = "${local.chart_source_path}/active-versions.yaml"

  # Import the "active-versions.yaml" file
  deployment_information = yamldecode(file(local.active_versions_source_path))

  # retrieve the name of the pull secret from the given docker registry credentials (local)
  pull_secrets_credentials = [for pull_secret in var.docker_pull_secrets : pull_secret.name]

}

# Define the Endpoints
module "endpoints" {
  source = "../modules/endpoints"

  domain_name = local.cluster_labels.domain
}
