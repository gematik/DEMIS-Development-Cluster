#########################
# Istio Settings
#########################

variable "istio_enabled" {
  type        = bool
  description = "Defines if Istio Settings are enabled for the given target namespace"
  default     = true
}

variable "istio_routing_chart_version" {
  type        = string
  description = "Defines the version of the Istio Routing Chart to be used"
  default     = ""
}