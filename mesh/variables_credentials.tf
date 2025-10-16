#########################
# Helm Repository Credentials
#########################

variable "helm_repository_username" {
  type        = string
  sensitive   = true
  description = "The Username credential for the Helm Repository"
  default     = ""
}

variable "helm_repository_password" {
  type        = string
  sensitive   = true
  description = "The Password credential for the Helm Repository"
  default     = ""
}

################################
# Certificates for DEMIS Istio Gateway
################################
variable "istio_gateway_tls_certificate" {
  type        = string
  description = "Base64-encoded, PEM certificate to be used for configuring the TLS Settings for the Istio Gateway for Portal, Keycloak and MinIO subdomains."
  validation {
    condition     = length(var.istio_gateway_tls_certificate) > 0 && can(base64decode(var.istio_gateway_tls_certificate))
    error_message = "The provided istio_gateway_tls_certificate is invalid"
  }
}

variable "istio_gateway_tls_private_key" {
  type        = string
  sensitive   = true
  description = "Base64-encoded, PEM private key associated to the certificate for the TLS Settings."
  validation {
    condition     = length(var.istio_gateway_tls_private_key) > 0 && can(base64decode(var.istio_gateway_tls_private_key))
    error_message = "The provided istio_gateway_tls_private_key is invalid"
  }
}

variable "istio_gateway_mutual_tls_ca_certificate" {
  type        = string
  default     = ""
  description = "Base64-encoded, PEM Certificate Authority certificate to be used for configuring the Mutual-TLS Settings for the Istio Gateway for core services."
  # if provided, the certificate must be valid
  validation {
    condition     = length(var.istio_gateway_mutual_tls_ca_certificate) > 0 ? can(base64decode(var.istio_gateway_mutual_tls_ca_certificate)) : true
    error_message = "The provided istio_gateway_mutual_tls_ca_certificate is not a base64 encoded string"
  }
}

variable "istio_gateway_mutual_tls_certificate" {
  type        = string
  default     = ""
  description = "Base64-encoded, PEM certificate to be used for configuring the Mutual-TLS Settings for the Istio Gateway for core services."
  # if provided, the certificate must be valid
  validation {
    condition     = length(var.istio_gateway_mutual_tls_certificate) > 0 ? can(base64decode(var.istio_gateway_mutual_tls_certificate)) : true
    error_message = "The provided istio_gateway_mutual_tls_certificate is not a base64 encoded string"
  }
}

variable "istio_gateway_mutual_tls_private_key" {
  type        = string
  default     = ""
  sensitive   = true
  description = "Base64-encoded, PEM private key associated to the certificate for the Mutual-TLS Settings."
  # if provided, the private key must be valid
  validation {
    condition     = length(var.istio_gateway_mutual_tls_private_key) > 0 ? can(base64decode(var.istio_gateway_mutual_tls_private_key)) : true
    error_message = "The provided istio_gateway_mutual_tls_private_key is not a base64 encoded string"
  }
}

################################
# Portal Token Injection Certificate
################################
variable "portal_test_token_certificate" {
  type        = string
  default     = ""
  sensitive   = true
  description = "Base64-encoded, PEM certificate to be used for injecting the test token into the Portal."
}

################################
# TLS Certificate for Remote S3 Storage
################################
variable "s3_tls_credential" {
  type        = string
  default     = ""
  sensitive   = true
  description = "Base64-encoded, PEM certificate to be used for configuring the TLS Settings for the S3 Storage Server."
  # if provided, the certificate must be valid
  validation {
    condition     = length(var.s3_tls_credential) > 0 ? can(base64decode(var.s3_tls_credential)) : true
    error_message = "The provided s3_tls_credential is not a base64 encoded string"
  }
}
