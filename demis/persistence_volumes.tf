##################################
# Define PersistenceVolumeClaims
##################################

module "persistent_volume_claims" {
  source   = "../modules/persistence_volume_claim"
  for_each = var.volumes

  namespace = module.demis_namespace.name
  labels    = local.labels

  name             = each.key
  storage_class    = each.value.storage_class
  capacity         = each.value.capacity
  access_mode      = local.is_local_mode ? "ReadWriteOnce" : "ReadWriteMany"
  wait_until_bound = false
}
