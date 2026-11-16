########################
# Define the Namespace
########################

# No Istio injection: the kube-apiserver calls the KEDA metrics API and webhooks directly
module "keda_namespace" {
  source = "../modules/namespace"

  name   = var.target_namespace
  labels = local.labels
}

########################
# Define the Namespace ResourceQuota
########################

module "keda_namespace_quota" {
  source = "../modules/namespace_quota"

  namespace      = module.keda_namespace.name
  resource_quota = var.namespace_resource_quota
}
