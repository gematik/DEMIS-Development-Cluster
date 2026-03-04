########################
# Define the Namespace
########################

module "mesh_namespace" {
  source = "../modules/namespace"

  name                   = var.target_namespace
  enable_istio_injection = true
  labels                 = local.labels
}

########################
# Define the Namespace ResourceQuota
########################

module "mesh_namespace_quota" {
  source = "../modules/namespace_quota"

  namespace      = module.mesh_namespace.name
  resource_quota = var.namespace_resource_quota
}