variable "namespace" {
  description = "Namespace where to install Falco"
  type        = string
  default     = "security"
}

variable "helm_repository" {
  description = "The Helm Chart Repository for Falco"
  type        = string
  default     = "https://falcosecurity.github.io/charts"
}

variable "chart_version" {
  description = "The Helm Chart Version for Falco"
  type        = string
  default     = "4.17.2"
}

variable "kubernetes_meta_collector" {
  description = "enables the k8s metacollector plugin"
  type        = bool
  default     = true
}

variable "falcosidekick_enabled" {
  description = "enables falcosidekick"
  type        = bool
  default     = false
}

variable "falcosidekick_ui_enabled" {
  description = "enables falcosidekick"
  type        = bool
  default     = false
}

variable "driver_kind" {
  description = "sets the specfifc driver kind of the probe inside the nodes. Default of Falco is auto. The options are: kmod, ebpf, modern_ebpf, We can enforce that if needed."
  type        = string
  default     = "auto"
}
