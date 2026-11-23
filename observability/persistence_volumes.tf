##################################
# Define PersistenceVolumeClaims
##################################

module "persistent_volume_claims" {
  source   = "../modules/persistence_volume_claim"
  for_each = var.volumes

  namespace = local.namespace

  name             = each.key
  storage_class    = each.value.storage_class
  capacity         = each.value.capacity
  access_mode      = "ReadWriteOnce"
  wait_until_bound = false
}
