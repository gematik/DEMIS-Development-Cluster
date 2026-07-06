terraform {
  required_version = ">=1.9.0"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "3.2.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.2.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.9.0"
    }
  }
}

provider "helm" {
  kubernetes = {
    config_path = local.kubeconfig_path
  }
}

provider "kubernetes" {
  config_path = local.kubeconfig_path
}

provider "random" {}
