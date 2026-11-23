locals {
  # Own namespace of the observability layer, always created as in demis (the applications decide which components run in it)
  namespace = module.namespace.name
}

module "metadata" {
  source = "../modules/metadata"

  cluster     = local.stage_name
  region      = local.cluster_region
  application = "observability"
  component   = "monitoring"
}

module "namespace" {
  source = "../modules/namespace"

  name                   = var.namespace
  labels                 = module.metadata.tags
  enable_istio_injection = true
}
