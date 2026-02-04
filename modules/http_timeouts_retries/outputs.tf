output "service_timeout_retry_definitions" {
  description = "Map containing all the timeout and retry definitions, grouped by service"
  value       = local.encoded_map
}
