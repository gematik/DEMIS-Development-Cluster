terraform {
  required_version = ">=1.6.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.36.0, < 3.0.0"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.2, < 3.0.0"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.3, < 4.0.0"
    }
  }
}
