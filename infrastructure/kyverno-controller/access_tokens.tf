# Pull Secrets for the Kyverno images
module "pull_secrets" {
  source        = "../../modules/pull_secret"
  for_each      = { for pull_creds in var.docker_pull_secrets : pull_creds.name => pull_creds }
  namespace     = module.namespace.name
  name          = each.value.name
  registry      = each.value.registry
  user_email    = each.value.user_email
  user_name     = each.value.user_name
  user_password = each.value.password_type == "token" ? var.google_cloud_access_token : each.value.user_password
  password_type = each.value.password_type
}
