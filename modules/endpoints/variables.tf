#########################
# Endpoints
#########################
variable "domain_name" {
  type        = string
  description = "The Domain Name to be used for the DEMIS Environment"
  validation {
    condition     = length(var.domain_name) > 0
    error_message = "The Domain Name must be defined"
  }
}

# No explicit validation, as it is same as domain name
variable "core_subdomain" {
  type        = string
  description = "The URL to access the DEMIS Core API"
  default     = ""
}

variable "bundid_idp_issuer_subdomain" {
  type        = string
  description = "The BundID IDP Issuer URL to be used for the JSON Web Token (JWT) validation"
  default     = ""
}

variable "auth_issuer_subdomain" {
  type        = string
  description = "The Issuer URL to be used for the JSON Web Token (JWT) validation"
  default     = "auth"
  validation {
    condition     = length(var.auth_issuer_subdomain) > 0
    error_message = "The Issuer Subdomain must be defined"
  }
}

variable "portal_subdomain" {
  type        = string
  description = "The URL for accessing the DEMIS Notification Portal over thr Telematikinfrastruktur (TI)"
  default     = "portal"
  validation {
    condition     = length(var.portal_subdomain) > 0
    error_message = "The Portal Subdomain for access over the Telematikinfrastruktur (TI) must be defined"
  }
}

variable "meldung_subdomain" {
  type        = string
  description = "The URL for accessing the DEMIS Notification Portal over Internet"
  default     = "meldung"
  validation {
    condition     = length(var.meldung_subdomain) > 0
    error_message = "The Portal Subdomain for access over Internet must be defined"
  }
}

# no validation, it is present only in local / dev environments
variable "ti_idp_subdomain" {
  type        = string
  description = "The URL to access the DEMIS Notification Portal over the Telematikinfrastruktur (TI)"
  default     = ""
}

variable "storage_subdomain" {
  type        = string
  description = "The URL to access the S3 compatible storage (minio)"
  default     = "storage"
  validation {
    condition     = length(var.storage_subdomain) > 0
    error_message = "The Storage Subdomain must be defined"
  }
}

variable "keycloak_internal_hostname" {
  type        = string
  description = "The internal hostname of the Keycloak service"
  default     = "keycloak.idm.svc.cluster.local"
  validation {
    condition     = length(var.keycloak_internal_hostname) > 0
    error_message = "The Keycloak Internal Hostname must be defined"
  }
}

variable "istio_gateway_namespace" {
  type        = string
  description = "The Namespace where the Istio Gateway Object is configured"
  default     = "mesh"
  validation {
    condition     = length(var.istio_gateway_namespace) > 0
    error_message = "The Namespace must be defined"
  }
}

variable "istio_gateway_name" {
  type        = string
  description = "The name of the Istio Gateway Object for accessing the DEMIS Cluster"
  default     = "demis-core-gateway"
  validation {
    condition     = length(var.istio_gateway_name) > 0
    error_message = "The Gateway Name must be defined"
  }
}

variable "check_istio_gateway_exists" {
  type        = bool
  description = "Flag to check if the Istio Gateway Object exists"
  default     = true
}