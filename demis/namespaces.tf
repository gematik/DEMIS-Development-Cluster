########################
# Define the Namespace
########################

module "demis_namespace" {
  source = "../modules/namespace"

  name                   = var.target_namespace
  enable_istio_injection = var.istio_enabled
  labels                 = local.labels
}