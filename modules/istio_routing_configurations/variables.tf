variable "input_mapping_path" {
  description = "Path to the traffic routes template YAML file."
  type        = string
}

variable "global_template_variables" {
  description = "Additional global variables for template substitution, provided as a map."
  type        = map(string)
  default     = {}
}

variable "python_interpreter" {
  description = "Python interpreter to pass as the first argument to the module's Python wrapper."
  type        = string
  default     = "python3"
}

variable "service_list" {
  description = "List of services to generate rules for. If empty, rules will be generated for all services in the input mapping."
  type        = list(string)
  default     = []
}
