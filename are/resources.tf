########################
# Retrieve the Feature Flags and Config Options for each service application
########################

module "application_resources" {
  source = "../modules/resources"
  # pass the resource definitions to the module
  resource_definitions = var.resource_definitions
}