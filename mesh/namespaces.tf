########################
# Define the Namespace
########################

module "mesh_namespace" {
  source = "../modules/namespace"

  name                   = var.target_namespace
  enable_istio_injection = true
  labels                 = local.labels
}