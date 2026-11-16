module "metadata" {
  source = "../../modules/metadata"

  cluster     = var.stage_name
  region      = var.cluster_region
  application = "security"
  component   = "security"
}

module "namespace" {
  source = "../../modules/namespace"

  name   = var.namespace
  labels = module.metadata.tags
}
