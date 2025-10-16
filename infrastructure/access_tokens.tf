module "pull_secrets" {
  source        = "../modules/pull_secret"
  for_each      = { for pull_creds in var.docker_pull_secrets : pull_creds.name => pull_creds }
  namespace     = var.kyverno_namespace
  name          = each.value.name
  registry      = each.value.registry
  user_email    = each.value.user_email
  user_name     = each.value.user_name
  user_password = each.value.password_type == "token" ? var.google_cloud_access_token : each.value.user_password
  password_type = each.value.password_type
  depends_on    = [module.kyverno_namespace.name]
}
