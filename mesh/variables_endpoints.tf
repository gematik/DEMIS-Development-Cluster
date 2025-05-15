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

# Subdomain of TI IDP Mock
variable "ti_idp_subdomain" {
  type        = string
  description = "The URL to access the DEMIS Notification Portal over the Telematikinfrastruktur (TI)"
  default     = ""
}
variable "bundid_idp_issuer_subdomain" {
  type        = string
  description = "The BundID IDP Issuer URL to be used for the JSON Web Token (JWT) validation"
  default     = ""
}

variable "s3_hostname" {
  type        = string
  description = "The Hostname of the S3 Storage Server"
  default     = ""
}

variable "s3_port" {
  type        = number
  description = "The Port of the Remote S3 Storage"
  default     = 9000
  validation {
    condition     = var.s3_port > 0 && var.s3_port < 65536
    error_message = "The Port of the Remote S3 Storage must be between 0 and 65535"
  }
}