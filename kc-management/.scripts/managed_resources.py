# This scripts creates an overview about managed resources in kc-management and writes it to Readme
import sys
import json
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent

terraform_state_file = SCRIPT_DIR / "../terraform.tfstate"

if not terraform_state_file.exists():
    print(f"Terraform state file not found at: {terraform_state_file}")
    sys.exit(0)

with terraform_state_file.open(encoding="utf-8") as file:
    state = json.load(file)

managed_resources = {}

instance_values = {
    "keycloak_user": ["username", "first_name", "last_name"],
    "keycloak_group": ["name"],
    "keycloak_custom_identity_provider_mapper": ["name", ("identity_provider_mapper", "attached-to-provider")],
    "keycloak_role": ["name", "description"],
    "keycloak_realm_user_profile": [],
    "keycloak_default_groups": [("group_ids", "default_groups_amount", lambda x: len(x or []))],
    "keycloak_default_roles": ["default_roles"],
    "keycloak_generic_protocol_mapper": ["name"],
    "keycloak_group_roles": [],
    "keycloak_oidc_identity_provider": [("alias", "name")],
    "keycloak_openid_client": [("client_id","name")],
    "keycloak_realm": ["display_name"],
    "keycloak_realm_events": ["events_enabled","admin_events_enabled","admin_events_details_enabled","events_listeners"],
    "keycloak_realm_keystore_rsa": ["provider_id", "algorithm"],
    "keycloak_saml_identity_provider": [("alias", "name")],
    "keycloak_authentication_bindings": ["direct_grant_flow"],
    "keycloak_authentication_execution": [("authenticator","name"),("parent_flow_alias","attached_flow")],
    "keycloak_authentication_execution_config": ["alias"],
    "keycloak_authentication_flow": ["alias"],
    "keycloak_openid_client_default_scopes": ["default_scopes"],
    "keycloak_openid_client_optional_scopes": [],
    "keycloak_openid_client_authorization_permission": ["name",("policies", "amount_policies", lambda x: len(x or []))],
    "keycloak_openid_client_authorization_resource": ["name",("scopes", "amount_scopes", lambda x: len(x or []))],
    "keycloak_openid_client_authorization_scope": ["name", "display_name"],
    "keycloak_openid_client_client_policy": ["name", ("clients", "amount_clients", lambda x: len(x or []))]

}

resouces_not_to_display = ["null_resource","keycloak_user_roles","keycloak_user_groups"]

def fill_mr(mr, resource):
    mr["type"] = resource.get("type")
    mr["realm"] = resource.get("module").split('"')[1]

def fill_instances(instances, resource_type, resource):
    keys_to_keep = instance_values.get(resource_type, None)
    if keys_to_keep == []:
        filtered_attributes = {"name": resource.get("name"), "amount": len(resource.get("instances", []))}
        instances.append(filtered_attributes)
        return

    if keys_to_keep is None or "all" in keys_to_keep:
        instances.extend(
            instance.get("attributes", {})
            for instance in resource.get("instances", [])
        )
        return

    for instance in resource.get("instances", []):
        instance_attributes = instance.get("attributes", {})
        filtered_attributes = {}
        for key in keys_to_keep:
            if isinstance(key, tuple):
                source_key, output_key, *func = key
                if source_key in instance_attributes:
                    value = instance_attributes[source_key]
                    if func:
                        value = func[0](value)
                    filtered_attributes[output_key] = value
            elif key in instance_attributes:
                filtered_attributes[key] = instance_attributes[key]
        instances.append(filtered_attributes)

for resource in state.get("resources", []):
    if not resource.get("mode") == "managed":
        continue
    if resource.get("type") in resouces_not_to_display:
        continue

    mr = dict()
    fill_mr(mr, resource)
    
    realm_resources = managed_resources.setdefault(mr["realm"], {})
    type_resources = realm_resources.setdefault(mr["type"], {"instances": []})

    fill_instances(type_resources["instances"], mr["type"], resource)

# print(json.dumps(managed_resources, indent=2, ensure_ascii=False))

def escape(value):
    return str(value).replace("|", "\\|").replace("\n", " ")


def instances_table(instances):
    if not instances:
        return ""

    keys = sorted({
        key
        for instance in instances
        if isinstance(instance, dict)
        for key in instance
    })

    header = "".join(f"<th>{escape(key)}</th>" for key in keys)

    rows = []
    for instance in instances:
        cells = "".join(
            f"<td>{escape(instance.get(key, ''))}</td>"
            for key in keys
        )
        rows.append(f"<tr>{cells}</tr>")

    return (
        "<table>"
        f"<thead><tr>{header}</tr></thead>"
        f"<tbody>{''.join(rows)}</tbody>"
        "</table>"
    )


def managed_resources_to_markdown(resources):
    markdown = []

    for realm, resource_types in resources.items():
        markdown.append("<details>")
        markdown.append(f"<summary>Realm: {realm}</summary>\n")
        markdown.append("| Resource Type | Instances |")
        markdown.append("|---|---|")

        for resource_type, resource_data in resource_types.items():
            nested_table = instances_table(
                resource_data.get("instances", [])
            )

            markdown.append(
                f"| `{resource_type}` | {nested_table} |"
            )

        markdown.append("\n</details>\n")

    return "\n".join(markdown)

markdown = managed_resources_to_markdown(managed_resources)

readme_file = SCRIPT_DIR / "../README.md"
readme = readme_file.read_text(encoding="utf-8")
begin_marker = "<!-- BEGIN_LIST_OF_MANAGED_RESOURCES-->"
end_marker = "<!-- END_LIST_OF_MANAGED_RESOURCES-->"

begin_index = readme.find(begin_marker)
end_index = readme.find(end_marker)
if begin_index == -1 or end_index == -1 or begin_index > end_index:
    raise ValueError(f"Managed resources markers not found in {readme_file}")

content_start = begin_index + len(begin_marker)
updated_readme = (
    readme[:content_start]
    + "\n"
    + markdown
    + "\n"
    + readme[end_index:]
)
readme_file.write_text(updated_readme, encoding="utf-8")