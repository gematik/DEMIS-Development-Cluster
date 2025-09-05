terraform {
  required_version = ">=1.9.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.36.0, < 3.0.0"
    }
  }
}
