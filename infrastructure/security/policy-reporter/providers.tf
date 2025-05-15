terraform {
  required_version = ">=1.6.0"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }

  }
}
