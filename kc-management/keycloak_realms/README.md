# demis

Module responsible for configuring and deploying keycloak setup

It performs the following operations:

- creates Users (Test-environment) 
- creates clients (partial) 
- creates groups
- creates IDP-Configuration 
- creates roles
- connect different resources with eachother (roles -> groups e.g.)
- maintains Keycloak-Configuration (Token-lifespan, urls, certificats etc.) 


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >= 3.0.0 |
| <a name="requirement_keycloak"></a> [keycloak](#requirement\_keycloak) | >= 5.0.0, < 6.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [keycloak_authentication_bindings.bind_direct_grant_to_demis_test_password_grant](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/authentication_bindings) | resource |
| [keycloak_authentication_execution.executions](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/authentication_execution) | resource |
| [keycloak_authentication_execution_config.execution_configs](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/authentication_execution_config) | resource |
| [keycloak_authentication_flow.flows](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/authentication_flow) | resource |
| [keycloak_custom_identity_provider_mapper.idp_mappers](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/custom_identity_provider_mapper) | resource |
| [keycloak_default_groups.default_groups](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/default_groups) | resource |
| [keycloak_default_roles.default_roles](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/default_roles) | resource |
| [keycloak_generic_protocol_mapper.protocol_mappers](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/generic_protocol_mapper) | resource |
| [keycloak_group.level1](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/group) | resource |
| [keycloak_group.level2](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/group) | resource |
| [keycloak_group.root](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/group) | resource |
| [keycloak_group_roles.level1_group_roles](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/group_roles) | resource |
| [keycloak_group_roles.level2_group_roles](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/group_roles) | resource |
| [keycloak_group_roles.root_group_roles](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/group_roles) | resource |
| [keycloak_oidc_identity_provider.oidc_idps](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/oidc_identity_provider) | resource |
| [keycloak_openid_client.clients](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/openid_client) | resource |
| [keycloak_openid_client_authorization_permission.gematik_idp_token_exchange](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/openid_client_authorization_permission) | resource |
| [keycloak_openid_client_authorization_resource.gematik_idp](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/openid_client_authorization_resource) | resource |
| [keycloak_openid_client_authorization_scope.token_exchange_scope](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/openid_client_authorization_scope) | resource |
| [keycloak_openid_client_client_policy.token_exchange](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/openid_client_client_policy) | resource |
| [keycloak_openid_client_default_scopes.default_scopes](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/openid_client_default_scopes) | resource |
| [keycloak_openid_client_optional_scopes.optional_scopes](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/openid_client_optional_scopes) | resource |
| [keycloak_openid_client_service_account_role.service_account_roles](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/openid_client_service_account_role) | resource |
| [keycloak_realm.realm](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/realm) | resource |
| [keycloak_realm_events.realm_events](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/realm_events) | resource |
| [keycloak_realm_keystore_rsa.certs](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/realm_keystore_rsa) | resource |
| [keycloak_realm_user_profile.userprofile](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/realm_user_profile) | resource |
| [keycloak_realm_user_profile.userprofile_surveillance_programs](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/realm_user_profile) | resource |
| [keycloak_role.client_roles](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/role) | resource |
| [keycloak_role.roles](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/role) | resource |
| [keycloak_saml_identity_provider.saml_idps](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/saml_identity_provider) | resource |
| [keycloak_user.user](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/user) | resource |
| [keycloak_user.users_surveillance_programs](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/user) | resource |
| [keycloak_user_groups.user_groups](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/user_groups) | resource |
| [keycloak_user_roles.roles](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/user_roles) | resource |
| [terraform_data.prune_undeclared_client_mappers](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.prune_undeclared_client_roles](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.prune_undeclared_groups](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.prune_undeclared_realm_roles](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.prune_undeclared_service_account_roles](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_auth_flow_configs"></a> [auth\_flow\_configs](#input\_auth\_flow\_configs) | Authentication flow definitions with their executions, keyed by flow alias. | `any` | n/a | yes |
| <a name="input_auth_flows"></a> [auth\_flows](#input\_auth\_flows) | List of authentication flows to create in the realm | `list(string)` | n/a | yes |
| <a name="input_certs"></a> [certs](#input\_certs) | A list of Keycloak certificates | <pre>list(object({<br/>    name        = string<br/>    cert        = string<br/>    private_key = string<br/>    algorithm   = string<br/>    priority    = number<br/>    provider_id = string<br/>  }))</pre> | `[]` | no |
| <a name="input_client_mapper_configs"></a> [client\_mapper\_configs](#input\_client\_mapper\_configs) | Protocol mapper definitions available to clients, keyed by mapper name. | `any` | n/a | yes |
| <a name="input_client_uuids"></a> [client\_uuids](#input\_client\_uuids) | clientId => UUID for the clients that already exist in this realm, resolved by the caller at plan time. | `map(string)` | `{}` | no |
| <a name="input_clients"></a> [clients](#input\_clients) | List of clients in the realm | <pre>list(map(object({<br/>    mappers               = optional(list(string), []),<br/>    roles                 = optional(list(string), []),<br/>    service_account_roles = optional(list(string), []) # only client roles allowed; realm roles are not implemented<br/>  })))</pre> | `[]` | no |
| <a name="input_default_groups"></a> [default\_groups](#input\_default\_groups) | List of default groups to register in the realm | `list(string)` | `[]` | no |
| <a name="input_disabled_clients"></a> [disabled\_clients](#input\_disabled\_clients) | List of disabled clients in the realm | `list(string)` | `[]` | no |
| <a name="input_event_listener"></a> [event\_listener](#input\_event\_listener) | List of event listeners to register in the realm | `list(string)` | <pre>[<br/>  "jboss-logging"<br/>]</pre> | no |
| <a name="input_expanded_groups_per_realm"></a> [expanded\_groups\_per\_realm](#input\_expanded\_groups\_per\_realm) | A map of expanded group sets per realm, including all groups and their ancestors | `map(set(string))` | n/a | yes |
| <a name="input_idp_configs"></a> [idp\_configs](#input\_idp\_configs) | Identity provider definitions, keyed by IdP alias. | `any` | n/a | yes |
| <a name="input_idp_mapper_configs"></a> [idp\_mapper\_configs](#input\_idp\_mapper\_configs) | Identity provider mapper definitions, keyed by mapper name. | `any` | n/a | yes |
| <a name="input_idps"></a> [idps](#input\_idps) | List of identity providers in the realm | `list(map(list(string)))` | `[]` | no |
| <a name="input_insecure_connection"></a> [insecure\_connection](#input\_insecure\_connection) | Whether to skip TLS verification for plan-time client existence checks. | `bool` | `false` | no |
| <a name="input_keycloak_admin_token"></a> [keycloak\_admin\_token](#input\_keycloak\_admin\_token) | Admin access token used for plan-time client existence checks against the Keycloak admin API. | `string` | n/a | yes |
| <a name="input_keycloak_connection_url"></a> [keycloak\_connection\_url](#input\_keycloak\_connection\_url) | Base URL of the Keycloak instance, used for plan-time client existence checks. | `string` | n/a | yes |
| <a name="input_keycloak_default_user_pwd"></a> [keycloak\_default\_user\_pwd](#input\_keycloak\_default\_user\_pwd) | The default password for Keycloak users | `string` | n/a | yes |
| <a name="input_keycloak_level1_groups"></a> [keycloak\_level1\_groups](#input\_keycloak\_level1\_groups) | A map of Keycloak level 1 groups (groups with root group as parent) | <pre>map(object({<br/>    name   = string<br/>    parent = string<br/>    roles  = optional(list(string), [])<br/>    client_roles = optional(list(object({<br/>      client = string<br/>      name   = string<br/>    })), [])<br/>    attributes = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_keycloak_level2_groups"></a> [keycloak\_level2\_groups](#input\_keycloak\_level2\_groups) | A map of Keycloak level 2 groups (groups with level 1 group as parent) | <pre>map(object({<br/>    name   = string<br/>    parent = string<br/>    roles  = optional(list(string), [])<br/>    client_roles = optional(list(object({<br/>      client = string<br/>      name   = string<br/>    })), [])<br/>    attributes = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_keycloak_root_groups"></a> [keycloak\_root\_groups](#input\_keycloak\_root\_groups) | A map of Keycloak root groups (groups without parent) | <pre>map(object({<br/>    name  = string<br/>    roles = optional(list(string), [])<br/>    client_roles = optional(list(object({<br/>      client = string<br/>      name   = string<br/>    })), [])<br/>    attributes = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_keycloak_themes"></a> [keycloak\_themes](#input\_keycloak\_themes) | Themes to be used for the Keycloak realm (login, account, admin, email). | `map(string)` | n/a | yes |
| <a name="input_managed_realms"></a> [managed\_realms](#input\_managed\_realms) | List of Keycloak realms to be managed by Terraform | `list(string)` | `[]` | no |
| <a name="input_openid_clients"></a> [openid\_clients](#input\_openid\_clients) | Configuration for the OpenID clients in the realm | `any` | n/a | yes |
| <a name="input_password_users"></a> [password\_users](#input\_password\_users) | A map of users with different passwords than default, where the key is the username and the value is the password | `map(string)` | n/a | yes |
| <a name="input_realm_config"></a> [realm\_config](#input\_realm\_config) | A map of realm specific configurations | <pre>object({<br/>    // Login parameter<br/>    edit_username_allowed          = bool<br/>    login_with_email_allowed       = bool<br/>    duplicate_emails_allowed       = bool<br/>    registration_email_as_username = bool<br/>    registration_allowed           = bool<br/>    reset_password_allowed         = bool<br/>    remember_me                    = bool<br/>    verify_email                   = bool<br/><br/>    // Session parameter<br/>    sso_session_idle_timeout             = string<br/>    sso_session_max_lifespan             = string<br/>    access_code_lifespan_login           = string<br/>    access_code_lifespan_user_action     = string<br/>    client_session_idle_timeout          = string<br/>    client_session_max_lifespan          = string<br/>    offline_session_idle_timeout         = string<br/>    offline_session_max_lifespan_enabled = bool<br/><br/>    // Token parameter<br/>    oauth2_device_code_lifespan              = string<br/>    polling_interval                         = string<br/>    access_token_lifespan                    = string<br/>    access_code_lifespan                     = string<br/>    access_token_lifespan_for_implicit_flow  = string<br/>    action_token_generated_by_user_lifespan  = string<br/>    action_token_generated_by_admin_lifespan = string<br/>    default_signature_algorithm              = string<br/>    revoke_refresh_token                     = bool<br/>  })</pre> | n/a | yes |
| <a name="input_realm_name"></a> [realm\_name](#input\_realm\_name) | The name of the Keycloak realm | `string` | n/a | yes |
| <a name="input_roles"></a> [roles](#input\_roles) | List of roles in the realm | `list(string)` | `[]` | no |
| <a name="input_roles_config"></a> [roles\_config](#input\_roles\_config) | Realm and client role definitions, keyed by role name. | `any` | n/a | yes |
| <a name="input_users"></a> [users](#input\_users) | A map of user lists for different realms | <pre>list(object({<br/>    id            = optional(string)<br/>    username      = string<br/>    email         = string<br/>    emailVerified = bool<br/>    firstName     = string<br/>    lastName      = string<br/>    enabled       = bool<br/>    groups        = list(string)<br/>    realmRoles    = list(string)<br/>    clientRoles   = optional(map(list(string)), {})<br/>    attributes    = map(string)<br/>    password      = bool<br/>    federatedIdentities = list(object({<br/>      identityProvider = string<br/>      userId           = string<br/>      userName         = string<br/>    }))<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->