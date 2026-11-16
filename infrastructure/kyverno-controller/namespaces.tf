# Namespace and Pull Secrets are created even if Kyverno is disabled
module "namespace" {
  source = "../../modules/namespace"

  name = var.namespace
}
