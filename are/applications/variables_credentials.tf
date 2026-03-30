################################
# ARE Application Credentials
################################

# Redis CUS Credentials for Notification Processing Service
variable "redis_cus_reader_user" {
  type        = string
  sensitive   = true
  description = "The Redis CUS User (Reader)"
}

variable "redis_cus_reader_password" {
  type        = string
  sensitive   = true
  description = "The Redis CUS Password (Reader)"
}