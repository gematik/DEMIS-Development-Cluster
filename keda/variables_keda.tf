#########################
# KEDA Settings
#########################

variable "keda_priority_class_name" {
  type        = string
  default     = "system-cluster-critical"
  nullable    = false
  description = "The PriorityClass for all KEDA components, so KEDA keeps running in the DEGRADED/EMERGENCY modes. Built-in classes (system-*) are allowed by a dedicated ResourceQuota. Empty disables the PriorityClass."
}
