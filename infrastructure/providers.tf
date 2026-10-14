terraform {
  required_version = ">=1.9.0"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "3.3.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.3.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.9.1"
    }
  }
}

# For KIND the credentials are taken from the cluster resource instead of the kubeconfig file,
# because the kubernetes provider (>= 3.2.1) fails on a config_path that does not exist yet
# at plan time (the file is only written by kind_cluster during apply).
provider "helm" {
  kubernetes = {
    config_path            = var.local_cluster ? null : var.kubeconfig_path
    host                   = var.local_cluster ? module.local_cluster[0].kind_endpoint : null
    client_certificate     = var.local_cluster ? module.local_cluster[0].client_certificate : null
    client_key             = var.local_cluster ? module.local_cluster[0].client_key : null
    cluster_ca_certificate = var.local_cluster ? module.local_cluster[0].cluster_ca_certificate : null
  }
}

provider "kubernetes" {
  config_path            = var.local_cluster ? null : var.kubeconfig_path
  host                   = var.local_cluster ? module.local_cluster[0].kind_endpoint : null
  client_certificate     = var.local_cluster ? module.local_cluster[0].client_certificate : null
  client_key             = var.local_cluster ? module.local_cluster[0].client_key : null
  cluster_ca_certificate = var.local_cluster ? module.local_cluster[0].cluster_ca_certificate : null
}

provider "random" {}
