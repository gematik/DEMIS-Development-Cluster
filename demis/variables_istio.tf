#########################
# Istio Settings
#########################

variable "istio_enabled" {
  type        = bool
  description = "Defines if Istio Settings are enabled for the given target namespace"
  default     = true
}
