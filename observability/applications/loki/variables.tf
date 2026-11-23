variable "target_namespace" {
  description = "Namespace where to install the services"
  type        = string
  default     = "observability"
}

variable "loki_helm_repository" {
  description = "The Helm Repository to download the Loki Chart"
  type        = string
  default     = "oci://ghcr.io/grafana-community/helm-charts"
  nullable    = false
  validation {
    condition     = can(regex("^(https?|file|oci)://.*$", var.loki_helm_repository)) || can(regex("^[a-z0-9][a-z0-9._-]*$", var.loki_helm_repository))
    error_message = "The Loki Helm Repository must be a valid URL or a repository name"
  }
}

variable "loki_version" {
  description = "The version of Loki to be installed"
  type        = string
  validation {
    condition     = can(regex("^\\d+\\.\\d+\\.\\d+$", var.loki_version))
    error_message = "The Loki version must be provided in a valid Semantic Version format (e.g., 1.2.3)"
  }
}

variable "loki_storage_type" {
  description = "Storage backend for Loki chunks/indexes. Options: \"filesystem\" (local disk, default) or \"s3\" (external S3-compatible object storage, required for more than one replica)."
  type        = string
  default     = "filesystem"
  validation {
    condition     = contains(["filesystem", "s3"], var.loki_storage_type)
    error_message = "The loki_storage_type must be either \"filesystem\" or \"s3\"."
  }
}

variable "loki_s3_endpoint" {
  description = "S3 endpoint host used when loki_storage_type is \"s3\" (e.g. \"s3.eu-central-1.amazonaws.com\" or a MinIO host)."
  type        = string
  default     = ""
}

variable "loki_s3_region" {
  description = "S3 region used when loki_storage_type is \"s3\" (may be empty for MinIO / non-AWS endpoints)."
  type        = string
  default     = ""
}

variable "loki_s3_bucket" {
  description = "Own S3 bucket of Loki for chunks, ruler rules and admin/compactor objects (used when loki_storage_type is \"s3\"). Created by the bucket Job of this module."
  type        = string
  default     = "loki"
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.loki_s3_bucket))
    error_message = "The loki_s3_bucket must be a valid S3 bucket name."
  }
}

variable "loki_s3_object_lock_days" {
  description = "Object lock of every object in the Loki bucket in days (mode loki_s3_object_lock_mode), 0 disables object lock. Can only be enabled when the bucket is created."
  type        = number
  default     = 0
  validation {
    condition     = var.loki_s3_object_lock_days >= 0 && floor(var.loki_s3_object_lock_days) == var.loki_s3_object_lock_days
    error_message = "The loki_s3_object_lock_days must be a whole number >= 0."
  }
}

variable "loki_s3_object_lock_mode" {
  description = "Object lock mode: \"COMPLIANCE\" (nobody can delete or shorten the lock before it expires, not even an admin) or \"GOVERNANCE\" (identities with the bypass right can delete locked objects)."
  type        = string
  default     = "COMPLIANCE"
  validation {
    condition     = contains(["COMPLIANCE", "GOVERNANCE"], var.loki_s3_object_lock_mode)
    error_message = "The loki_s3_object_lock_mode must be either \"COMPLIANCE\" or \"GOVERNANCE\"."
  }
}

variable "loki_s3_sse_type" {
  description = "Server-side encryption of the Loki objects by the object storage: none, SSE-S3 (key of the object storage) or SSE-KMS (key from its KMS, loki_s3_sse_kms_key_id)."
  type        = string
  default     = "none"
  validation {
    condition     = contains(["none", "SSE-S3", "SSE-KMS"], var.loki_s3_sse_type)
    error_message = "The loki_s3_sse_type must be one of \"none\", \"SSE-S3\" or \"SSE-KMS\"."
  }
}

variable "loki_s3_sse_kms_key_id" {
  description = "KMS key id of the object storage, required for loki_s3_sse_type = \"SSE-KMS\"."
  type        = string
  default     = ""
}

variable "loki_bucket_job_image" {
  description = "aws-cli image of the Job creating and configuring the Loki bucket"
  type        = string
  default     = "amazon/aws-cli:2.27.50@sha256:48c3d4212e2f5b0e24bdc6af7708f9412ce65425a79575e0f78b8f8c0dcd70ab"
}

variable "loki_s3_force_path_style" {
  description = "Use path-style S3 URLs. true for MinIO / most non-AWS endpoints, false for real AWS S3."
  type        = bool
  default     = true
}

variable "loki_s3_insecure" {
  description = "Talk to the S3 endpoint over plain HTTP instead of HTTPS."
  type        = bool
  default     = false
}

variable "loki_s3_access_key_id" {
  description = "The S3 access key id used when loki_storage_type is \"s3\". Leave empty to rely on an IAM role / instance profile."
  type        = string
  default     = ""
  sensitive   = true
}

variable "loki_s3_secret_access_key" {
  description = "The S3 secret access key used when loki_storage_type is \"s3\". Leave empty to rely on an IAM role / instance profile."
  type        = string
  default     = ""
  sensitive   = true
}

variable "loki_volume" {
  description = "PersistentVolumeClaim per monolithic Loki instance (WAL, unflushed chunks; with filesystem storage all data). null: ephemeral pod storage, lost on restart."
  type = object({
    storage_class = string
    capacity      = string
  })
  default = null
}

variable "loki_retention_period" {
  description = "How long ingested logs are kept before the compactor deletes them (Go duration, e.g. 24h, 168h, 720h)."
  type        = string
  default     = "168h"
  validation {
    condition     = can(regex("^[0-9]+[smhd]$", var.loki_retention_period))
    error_message = "The loki_retention_period must be a valid Go duration (e.g. 24h, 168h)."
  }
}

variable "resource_definitions" {
  description = "Per workload of the module (output of the resources module): replicas, resource block (YAML) and Istio proxy resources; null or missing keeps the defaults"
  type = map(object({
    replicas       = optional(number)
    resource_block = optional(string)
    istio_proxy_resources = optional(object({
      limits   = optional(map(string), {})
      requests = optional(map(string), {})
    }))
  }))
  default = {}
}

variable "loki_s3_credentials_secret" {
  description = "Secret with the AWS shared credentials file (key credentials) of the Loki identity, mounted into the bucket Job (secrets of the root module)"
  type        = string
  default     = "loki-bucket-credentials"
}
