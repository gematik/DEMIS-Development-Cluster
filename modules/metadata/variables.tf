variable "cluster" {
  type        = string
  description = "Cluster name"
  validation {
    condition     = contains(["adesso-prod", "adesso-ref", "adesso-qs", "adesso-dev", "adesso-test", "local", "public"], var.cluster)
    error_message = "Environment must be one of: adesso-prod, adesso-ref, adesso-qs, adesso-dev, adesso-test, local, public"
  }
}

variable "region" {
  type        = string
  description = "Region name"
  validation {
    condition     = contains(["fra", "fkb", "local", "public"], var.region)
    error_message = "Allowed region names: fra, fkb, local, public"
  }
}

variable "application" {
  type        = string
  description = "Application name"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.application))
    error_message = "Application name must contain only lowercase letters, numbers, and hyphens"
  }
}

variable "component" {
  type        = string
  description = "Component name (e.g., web, api, db)"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.component))
    error_message = "Component name must contain only lowercase letters, numbers, and hyphens"
  }
}

variable "organisation_name" {
  type        = string
  description = "Organisation name"
  default     = "gematik_GmbH"
  validation {
    condition     = length(var.organisation_name) > 0
    error_message = "Organisation name must not be empty"
  }
}
