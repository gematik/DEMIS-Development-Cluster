########################
# Define the Namespace
########################

module "idm_namespace" {
  source = "../modules/namespace"

  name                   = var.target_namespace
  enable_istio_injection = var.istio_enabled
  labels                 = local.labels
}

########################
# Define the Namespace ResourceQuota
########################

module "idm_namespace_quota" {
  source = "../modules/namespace_quota"

  namespace      = module.idm_namespace.name
  resource_quota = var.namespace_resource_quota
}
