#############################################################################
# Level 0: Root Groups (no parent)
#############################################################################
resource "keycloak_group" "root" {
  for_each = { for k, v in var.keycloak_root_groups : k => v if contains(var.expanded_groups_per_realm[var.realm_name], k) }

  realm_id   = keycloak_realm.realm.id
  name       = each.value.name
  attributes = each.value.attributes
}

#############################################################################
# Level 1: Groups with root parent
#############################################################################
resource "keycloak_group" "level1" {
  for_each = { for k, v in var.keycloak_level1_groups : k => v if contains(var.expanded_groups_per_realm[var.realm_name], k) }

  realm_id   = keycloak_realm.realm.id
  name       = each.value.name
  parent_id  = keycloak_group.root[each.value.parent].id
  attributes = each.value.attributes
}

#############################################################################
# Level 2: Groups with level 1 parent
#############################################################################
resource "keycloak_group" "level2" {
  for_each = { for k, v in var.keycloak_level2_groups : k => v if contains(var.expanded_groups_per_realm[var.realm_name], k) }

  realm_id   = keycloak_realm.realm.id
  name       = each.value.name
  parent_id  = keycloak_group.level1[each.value.parent].id
  attributes = each.value.attributes
}

# ============================================================================
# === Pruning: groups created outside of Terraform ===========================
# ============================================================================
locals {
  # Groups are compared by id instead of name, so renaming a managed group is never mistaken for an undeclared one.
  managed_group_ids = concat(
    [for group in values(keycloak_group.root) : group.id],
    [for group in values(keycloak_group.level1) : group.id],
    [for group in values(keycloak_group.level2) : group.id]
  )

  # Every managed group is checked for undeclared subgroups; deleting a group also deletes everything below it.
  group_parents = merge(
    { for key, group in keycloak_group.root : "root/${key}" => group.id },
    { for key, group in keycloak_group.level1 : "level1/${key}" => group.id },
    { for key, group in keycloak_group.level2 : "level2/${key}" => group.id }
  )

  # A 404 (e.g. realm or group not present yet on an initial setup) means there is nothing to prune.
  actual_groups = merge(
    { "realm" = [for group in try(jsondecode(data.http.actual_root_groups.response_body), []) : group if data.http.actual_root_groups.status_code == 200] },
    {
      for parent, response in data.http.actual_subgroups :
      parent => [for group in try(jsondecode(response.response_body), []) : group if response.status_code == 200]
    }
  )

  # The group id is part of the trigger, so a manually re-created group is pruned again.
  undeclared_groups = merge([
    for parent, groups in local.actual_groups : {
      for group in groups : "${parent}/${group.name}" => {
        id      = group.id
        request = "${var.keycloak_connection_url}/admin/realms/${var.realm_name}/groups/${group.id}"
      } if !contains(local.managed_group_ids, group.id)
    }
  ]...)
}

data "http" "actual_root_groups" {
  url      = "${var.keycloak_connection_url}/admin/realms/${var.realm_name}/groups?first=0&max=1000&briefRepresentation=true"
  method   = "GET"
  insecure = var.insecure_connection

  request_headers = {
    Authorization = "Bearer ${var.keycloak_admin_token}"
    Content-Type  = "application/json"
  }

  retry {
    attempts     = 10
    max_delay_ms = 5000
    min_delay_ms = 1000
  }

  lifecycle {
    postcondition {
      condition     = self.status_code == 404 || (self.status_code == 200 && try(jsondecode(self.response_body), false) != false)
      error_message = "(Realm: ${var.realm_name}) Failed to fetch root groups"
    }
  }
}

data "http" "actual_subgroups" {
  for_each = local.group_parents

  url      = "${var.keycloak_connection_url}/admin/realms/${var.realm_name}/groups/${each.value}/children?first=0&max=1000&briefRepresentation=true"
  method   = "GET"
  insecure = var.insecure_connection

  request_headers = {
    Authorization = "Bearer ${var.keycloak_admin_token}"
    Content-Type  = "application/json"
  }

  retry {
    attempts     = 10
    max_delay_ms = 5000
    min_delay_ms = 1000
  }

  lifecycle {
    postcondition {
      condition     = self.status_code == 404 || (self.status_code == 200 && try(jsondecode(self.response_body), false) != false)
      error_message = "(Realm: ${var.realm_name}) Failed to fetch subgroups for group: '${each.key}'"
    }
  }
}

resource "terraform_data" "prune_undeclared_groups" {
  triggers_replace = sort([for key, item in local.undeclared_groups : "${key}#${item.id}"])

  provisioner "local-exec" {
    environment = {
      KEYCLOAK_TOKEN  = var.keycloak_admin_token
      INSECURE        = tostring(var.insecure_connection)
      DELETE_REQUESTS = join("\n", [for item in values(local.undeclared_groups) : item.request])
    }
    command = "bash ${path.module}/.scripts/delete-keycloak-resources.sh"
  }

  depends_on = [keycloak_group.root, keycloak_group.level1, keycloak_group.level2]
}
