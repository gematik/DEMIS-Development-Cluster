output "service_timeout_retry_definitions" {
  description = "Map containing all the timeout and retry definitions, grouped by service"
  value       = local.encoded_map

  precondition {
    condition     = length(local.invalid_services) == 0
    error_message = "Invalid timeout configuration for service(s): ${join(", ", keys(local.invalid_services))}. The timeout must be >= perTryTimeout * attempts."
  }
}
