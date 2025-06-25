variable "target_namespace" {
  description = "The namespace to deploy the application to"
  type        = string
  default     = "demis"
}

variable "is_local_mode" {
  description = "Defines if the deployment is in local mode"
  type        = bool
  default     = false
}

variable "production_mode" {
  description = "Enables the frontend production mode"
  type        = bool
}

variable "external_chart_path" {
  description = "The path to the stage-dependent Helm Chart Values."
  type        = string
  validation {
    condition     = length(var.external_chart_path) > 0
    error_message = "The path to the stage-dependent Helm Chart Values must be defined"
  }
}

variable "deployment_information" {
  description = "Structure holding deployment information for the Helm Charts"
  type = map(object({
    chart-name          = optional(string) # Optional, uses a different Helm Chart name than the application name
    image-tag           = optional(string) # Optional, uses a different image tag for the deployment
    deployment-strategy = string
    enabled             = bool
    main = object({
      version  = string
      weight   = number
      profiles = optional(list(string))
    })
    canary = optional(object({
      version  = optional(string)
      weight   = optional(string)
      profiles = optional(list(string))
    }), {})
  }))

  validation {
    condition = alltrue([
      for service in var.deployment_information : true &&
      (!service.enabled || can(regex("^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-((?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\\+([0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?$", service.main.version))
    )])
    error_message = "Service Configuration is not valid. Please recheck service versions syntax."
  }

  validation {
    condition = alltrue([
      for service in var.deployment_information : true &&
      (!service.enabled || contains(["canary", "update", "replace"], service.deployment-strategy))
    ])
    error_message = "Service Configuration is not valid. Please recheck deployment-strategy. Only canary, update and replace is valid."
  }

  validation {
    condition = alltrue([
      for service in var.deployment_information : true &&
      (!service.enabled || service.canary.version == null || can(regex("^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-((?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\\+([0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?$", service.canary.version)))
    ])

    error_message = "Service Configuration is not valid. Please recheck service canary syntax."
  }

  validation {
    condition = alltrue([
      for name, service in var.deployment_information : true &&
      (!service.enabled || !contains(["validation-service-core", "validation-service-igs", "validation-service-ars", "futs-core"], name) || !can(length(service.main.profiles)) || can([for v in service.main.profiles : regex("^(([a-zA-Z]*-)*)?(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-((?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\\+([0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?$", v)]))
    ])
    error_message = "Service Configuration is not valid. Please recheck versions for profiles syntax in main."
  }

  validation {
    condition = alltrue([
      for name, service in var.deployment_information : true &&
      (!service.enabled || !contains(["validation-service-core", "validation-service-igs", "validation-service-ars", "futs-core"], name) || !can(length(service.canary.profiles)) || can([for v in service.canary.profiles : regex("^(([a-zA-Z]*-)*)?(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-((?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\\+([0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?$", v)]))
    ])
    error_message = "Service Configuration is not valid. Please recheck versions for profiles syntax in canary."
  }

  validation {
    condition = alltrue([
      for name, service in var.deployment_information : true &&
      (!service.enabled || !contains(["validation-service-core", "validation-service-igs", "validation-service-ars", "futs-core"], name) || !can(length(service.canary.profiles)) || (can(length(service.canary.version) > 0) || !can(service.canary.weight >= 0 && service.canary.weight <= 100)))
    ])
    error_message = "Service Configuration is not valid. Please recheck versions for profiles syntax in validation-service-core. Canary needs to be defined with a version and weight."
  }

  validation {
    condition = alltrue([
      for name, service in var.deployment_information : true &&
      (!service.enabled || !contains(["futs-core", "validation-service-core"], name) || can(length(var.deployment_information["fhir-profile-snapshots"].main.version) > 0))
    ])
    error_message = "Service Configuration is not valid. Profile version vor fhir-profile-snapshots is not defined. version is required for services futs-core and validation-service-core"
  }

  validation {
    condition = alltrue([
      for name, service in var.deployment_information : true &&
      (!service.enabled || !contains(["futs-igs", "validation-service-igs"], name) || can(length(var.deployment_information["igs-profile-snapshots"].main.version) > 0))
    ])
    error_message = "Service Configuration is not valid. Profile version vor igs-profile-snapshots is not defined. Version is required for services futs-igs and validation-service-igs"
  }

  validation {
    condition = alltrue([
      for name, service in var.deployment_information : true &&
      (!service.enabled || !contains(["validation-service-ars"], name) || can(var.deployment_information["ars-profile-snapshots"]))
    ])
    error_message = "Service Configuration is not valid. Profile version vor ars-profile-snapshots is not defined. Version is required for service validation-service-ars"
  }

  validation {
    condition = alltrue([
      for name, service in var.deployment_information : true &&
      (!service.enabled || !contains(["notification-routing-service"], name) || can(var.deployment_information["notification-routing-data"]))
    ])
    error_message = "Service Configuration is not valid. Notification routing data is required for service notification-routing-service."
  }

  validation {
    condition = alltrue([
      for name, service in var.deployment_information : true &&
      (!service.enabled || !contains(["istio-routing"], name) || can(var.deployment_information["istio-routing"]))
    ])
    error_message = "Service Configuration is not valid. Istio routing chart is not defined."
  }
}

variable "resource_definitions" {
  description = "Defines a list of definition of resources that belong to a service"
  type = map(object({
    resource_block = optional(string)
    replicas       = number
  }))
  default = {}

  validation {
    condition     = length(var.resource_definitions) > 0 ? alltrue([for key, value in var.resource_definitions : value != {}]) : true
    error_message = "Service should contain valid resource definitions. No Replicas or resource block defined"
  }
}

variable "pull_secrets" {
  type        = list(string)
  description = "The list of pull secrets to be used for downloading Docker Images"
  default     = []
}

variable "docker_registry" {
  description = "The docker registry to use for the application"
  type        = string
}

variable "helm_repository" {
  description = "The helm repository to use for the application"
  type        = string
}

variable "helm_repository_username" {
  description = "The username for the helm repository"
  type        = string
  default     = ""
}

variable "helm_repository_password" {
  description = "The password for the helm repository"
  type        = string
  sensitive   = true
  default     = ""
}

variable "istio_enabled" {
  description = "Enable istio for the application"
  type        = bool
  default     = true
}

variable "redis_cus_reader_user" {
  type        = string
  sensitive   = true
  description = "The Redis CUS User (with Reader Permissions)"
}

# Feature Flags

variable "feature_flags" {
  type        = map(map(bool))
  description = "Defines a list of feature flags to be bound in services"
  default     = {}
}

# Operational Flags

variable "config_options" {
  type        = map(map(string))
  description = "Defines a list of ops flags to be bound in services"
  default     = {}
}

#########################
# Endpoints
#########################

# No explicit validation, as it is same as domain name
variable "core_hostname" {
  type        = string
  description = "The URL to access the DEMIS Core API"
  default     = ""
}

variable "auth_hostname" {
  type        = string
  description = "The Keycloak Issuer URL to be used for the JSON Web Token (JWT) validation"
  default     = "auth"
  validation {
    condition     = length(var.auth_hostname) > 0
    error_message = "The Keycloak Issuer hostname must be defined"
  }
}

variable "portal_hostname" {
  type        = string
  description = "The URL for accessing the DEMIS Notification Portal over Telematikinfrastruktur (TI)"
  default     = "portal"
  validation {
    condition     = length(var.portal_hostname) > 0
    error_message = "The Portal hostname for access over Telematikinfrastruktur (TI) must be defined"
  }
}

variable "meldung_hostname" {
  type        = string
  description = "The URL for accessing the DEMIS Notification Portal over Internet"
  default     = "meldung"
  validation {
    condition     = length(var.meldung_hostname) > 0
    error_message = "The Portal hostname for access over Internet must be defined"
  }
}

# No explicit validation, it is only available in local and dev environments
variable "storage_hostname" {
  type        = string
  description = "The URL to access the S3 compatible storage (minio)"
  default     = "storage"
}

variable "keycloak_internal_hostname" {
  type        = string
  description = "The URL to the Keycloak Service in the internal network"
  default     = "keycloak.idm.svc.cluster.local"
  validation {
    condition     = length(var.keycloak_internal_hostname) > 0
    error_message = "The URL to the Keycloak Service must be defined"
  }
}

variable "cluster_gateway" {
  type        = string
  description = "Defines the Istio Cluster Gateway to be used"
  default     = "mesh/demis-core-gateway"
  nullable    = true
  validation {
    condition     = var.cluster_gateway != null ? length(var.cluster_gateway) > 0 : true
    error_message = "Istio Cluster Gateway Name must be a valid string"
  }
}

#########################
# Application Configuration
#########################

# Debugging 
variable "debug_enabled" {
  type        = bool
  description = "Defines if the backend Java Services must be started in Debug Mode"
  default     = false
}

# PGBouncer Database Host
variable "database_target_host" {
  type        = string
  description = "Defines the Hostname of the Database Server"
  validation {
    condition     = length(var.database_target_host) > 0
    error_message = "The Database Hostname must be defined"
  }
}

variable "fhir_storage_purger_cron_schedule" {
  type        = string
  description = "Defines the Cron Schedule for the FHIR storage purger"
  validation {
    condition     = length(var.fhir_storage_purger_cron_schedule) > 0
    error_message = "The FHIR storage purger cron Schedule must be defined"
  }
}

# used in environments with different parallel versions of DEMIS Services
variable "context_path" {
  description = "The context path for reaching the DEMIS Services externally"
  type        = string
  default     = ""
}

# S3 Storage URL
variable "s3_hostname" {
  type        = string
  description = "The Hostname of the Remote S3 Storage"
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

variable "fhir_storage_purger_suspend" {
  type        = bool
  description = "Defines if the fhir-storage-purger is suspended."
  default     = false
}
