module "metadata" {
  source = "../../modules/metadata"

  cluster     = var.stage_name
  region      = var.cluster_region
  application = "istio"
  component   = "service-mesh"
}

module "namespace" {
  source = "../../modules/namespace"

  name   = var.namespace
  labels = module.metadata.tags
}
