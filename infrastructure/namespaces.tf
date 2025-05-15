########################
# Define Metadata for Namespaces
########################

module "istio_metadata" {
  source = "../modules/metadata"

  cluster     = var.stage_name
  region      = var.cluster_region
  application = "istio"
  component   = "service-mesh"
}

module "security_metadata" {
  source = "../modules/metadata"

  cluster     = var.stage_name
  region      = var.cluster_region
  application = "security"
  component   = "security"
}

########################
# Define Namespaces
########################

module "istio_namespace" {
  source = "../modules/namespace"

  name   = var.service_mesh_namespace
  labels = module.istio_metadata.tags

  depends_on = [local.kubeconfig_path]
}

module "security_namespace" {
  source = "../modules/namespace"

  name   = var.security_namespace
  labels = module.security_metadata.tags

  depends_on = [local.kubeconfig_path]
}

module "kyverno_namespace" {
  source = "../modules/namespace"

  name = var.kyverno_namespace

  depends_on = [local.kubeconfig_path]
}
