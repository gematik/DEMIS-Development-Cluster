variable "stage_name" {
  description = "The name of the stage"
  type        = string
  validation {
    condition     = length(var.stage_name) > 0
    error_message = "The stage name must not be empty"
  }
}

variable "target_namespace" {
  type        = string
  description = "The Namespace to use for deployment"
  default     = "kc-management"
  validation {
    condition     = length(var.target_namespace) > 0
    error_message = "Invalid Namespace provided: ${var.target_namespace}"
  }
}

variable "local_cluster" {
  type        = bool
  default     = true
  description = "Defines if the current setup is for a local cluster (using KIND)"
}

variable "insecure_connection" {
  type        = bool
  default     = false
  description = "Whether TLS certificate verification should be skipped for HTTPS connections"
}

# only used for remote clusters deployment with GCP KMS state encryption
variable "kms_encryption_key" {
  description = "The GCP KMS encryption key for OpenTofu state encryption"
  type        = string
  default     = ""
  validation {
    condition     = length(var.kms_encryption_key) > 0 ? startswith(var.kms_encryption_key, "projects/") : true
    error_message = "Invalid KMS encryption key format, must start with 'projects/...'"
  }
}

variable "project_feature_flags" {
  type        = map(bool)
  description = "Map of feature flags to enable or disable specific features in the keycloak deployment. The keys are the names of the feature flags, and the values are booleans indicating whether the feature is enabled (true) or disabled (false)."
  default     = {}
}

variable "kc_options" {
  description = <<EOT
  Stage specific Keycloak options for the current environment.
  - realms_with_managed_clients: List of realms that have managed clients. Clients of not named realms will not be managed
  - multi_stage_kc: List of Keycloak instances that are managed in a multi-stage setup on PORTAL_REALM. Each instance got their own client of "meldeportal" and "meldeportal-internet"
  - additional_default_groups: Map of additional default groups for each realm. The keys are the realm names, and the values are lists of group names
  - additional_roles: Map of additional roles for each realm. The keys are the realm names, and the values are lists of role names
  - replace_group_attributes: Map of replacing group attributes per realm and group. Structure: realm name => group key => attribute name => attribute value
  - additional_client_roles_to_groups: Map of additional client roles assigned to groups per realm. Structure: realm name => group key => list of client-role objects (with client and name fields)
  - rki_admin_mapper: Boolean flag indicating whether the RKI Admin Mapper should be enabled
  EOT

  type = object({
    realms_with_managed_clients       = optional(list(string), [])
    multi_stage_kc                    = optional(list(object({ name_suffix = string, stage_name = string })), [{ name_suffix = "", stage_name = "" }])
    additional_default_groups         = optional(map(list(string)), {})
    additional_roles                  = optional(map(list(string)), {})
    replace_group_attributes          = optional(map(map(map(string))), {})
    additional_client_roles_to_groups = optional(map(list(object({ client = string, name = string }))), {})
    rki_admin_mapper                  = optional(bool, false)
  })
  default = {}
}
