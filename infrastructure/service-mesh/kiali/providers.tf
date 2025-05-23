terraform {
  required_version = ">=1.6.0"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">=3.6.3, < 4.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.35.0, < 3.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.17.0, < 3.0.0"
    }
  }
}
