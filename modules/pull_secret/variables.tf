variable "namespace" {
  type        = string
  description = "The Namespace to use for deployment"
  validation {
    condition     = length(var.namespace) > 0
    error_message = "You must provide a valid Namespace."
  }
}

variable "labels" {
  type        = map(string)
  description = "The Labels to apply to the Secret"
  default     = {}
}

variable "annotations" {
  type        = map(string)
  description = "The Annotations to apply to the Secret"
  default     = {}
}

variable "name" {
  type        = string
  description = "The Name of the Pull Secret"
  validation {
    condition     = length(var.name) > 0
    error_message = "You must provide a valid Pull Secret Name."
  }
}

variable "registry" {
  type        = string
  description = "The Registry to use for the Pull Secret"
  validation {
    condition     = length(var.registry) > 0
    error_message = "You must provide a valid Registry."
  }
}

variable "user_name" {
  sensitive   = true
  type        = string
  description = "The User Name to use for the Pull Secret"
  validation {
    condition     = length(var.user_name) > 0
    error_message = "You must provide a valid User Name."
  }
}

variable "user_email" {
  sensitive   = true
  type        = string
  description = "The User E-Mail Address to use for the Pull Secret"
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.user_email))
    error_message = "You must provide a valid User E-Mail Address."
  }
}

variable "user_password" {
  sensitive   = true
  type        = string
  description = "The User Password to use for the Pull Secret"
  validation {
    condition     = length(var.user_password) > 0
    error_message = "You must provide a valid User Password."
  }
}

variable "password_type" {
  type        = string
  description = <<EOT
  This variable defines the type of user password used for the Pull Secret. It accepts one of the following values: "json_key", "gcloud_token", or "plain".

  * "token": If selected, the `user_password` variable should contain an Access Token. This token is typically generated using the command, e.g. for Google Cloud, `gcloud auth print-access-token`.
  * "json_key": If selected, the `user_password` variable should contain the base64 encoded content of a JSON Key file. Ensure that the JSON Key file is encoded correctly before assigning it to this variable.
  * "plain": If selected, the `user_password` variable should contain a plain text password.

  Choose the appropriate type based on your authentication method.
  EOT
  validation {
    condition     = contains(["json_key", "token", "plain"], var.password_type)
    error_message = "You must provide a valid Password Type. Allowed values are: json_key, token, or plain."
  }
}
