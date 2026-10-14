locals {
  client_mapper_configs = {
    "Account-Is-Test-Protocol-Mapper" = {
      "config" = {
        "introspection.token.claim" : "true",
        "aggregate.attrs" : "false",
        "userinfo.token.claim" : "true",
        "user.attribute" : "accountIsTest",
        "id.token.claim" : "true",
        "access.token.claim" : "true",
        "claim.name" : "accountIsTest",
        "lightweight.claim" : "false",
        "jsonType.label" : "boolean"
      }
    },
    "IK-Number-Protocol-Mapper" = {
      "protocol_mapper" = "ik-number-mapper",
      "config" = {
        "id.token.claim" : "true",
        "lightweight.claim" : "false",
        "access.token.claim" : "true",
        "claim.name" : "ik",
        "userinfo.token.claim" : "true",
        "introspection.token.claim" : "true"
      }
    },
    "Profession-OID-Protocol-Mapper" = {
      "config" = {
        "introspection.token.claim" : "true",
        "aggregate.attrs" : "false",
        "userinfo.token.claim" : "true",
        "multivalued" : "false",
        "user.attribute" : "professionOid",
        "id.token.claim" : "true",
        "access.token.claim" : "true",
        "claim.name" : "professionOid",
        "jsonType.label" : "String",
        "lightweight.claim" : "false"
      }
    },
    "testuser-Recipient-attribute-mapper" = {
      "config" = {
        "introspection.token.claim" : "true",
        "userinfo.token.claim" : "true",
        "user.attribute" : "testuserRecipient",
        "id.token.claim" : "true",
        "access.token.claim" : "true",
        "claim.name" : "testuserRecipient",
        "jsonType.label" : "String"
      }
    },
    "ik-mapper" = {
      "config" = {
        "introspection.token.claim" = "true",
        "user.attribute" : "ik",
        "id.token.claim" : "true",
        "access.token.claim" : "true",
        "claim.name" : "ik",
        "jsonType.label" : "String",
        "userinfo.token.claim" : "true"
      }
    },
    "Account-Type-Protocol-Mapper" = {
      "config" = {
        "introspection.token.claim" : "true",
        "user.attribute" : "accountType",
        "id.token.claim" : "true",
        "access.token.claim" : "true",
        "claim.name" : "accountType",
        "jsonType.label" : "String",
        "userinfo.token.claim" : "true"
      }
    },
    "Username-Protocol-Mapper" = {
      "protocol_mapper" = "oidc-usermodel-property-mapper",
      "config" = {
        "introspection.token.claim" : "true",
        "user.attribute" : "username",
        "id.token.claim" : "true",
        "access.token.claim" : "true",
        "claim.name" : "username",
        "lightweight.claim" : "false",
        "jsonType.label" : "String",
        "userinfo.token.claim" : "true",
      }
    },
    "Organization-Name-Protocol-Mapper" = {
      "config" = {
        "introspection.token.claim" : "true",
        "lightweight.claim" : "false",
        "userinfo.token.claim" : "true",
        "jsonType.label" : "String",
        "user.attribute" : "organizationName",
        "id.token.claim" : "true",
        "access.token.claim" : "true",
        "claim.name" : "organizationName"
      }
    },
    "Level-Of-Assurance-Protocol-Mapper" = {
      "config" = {
        "introspection.token.claim" : "true",
        "user.attribute" : "levelOfAssurance",
        "lightweight.claim" : "false",
        "id.token.claim" : "true",
        "access.token.claim" : "true",
        "claim.name" : "levelOfAssurance",
        "jsonType.label" : "String",
        "userinfo.token.claim" : "true"
      }
    },
    "Account-Source-Protocol-Mapper" = {
      "config" = {
        "introspection.token.claim" : "true",
        "user.attribute" : "accountSource",
        "id.token.claim" : "true",
        "access.token.claim" : "true",
        "claim.name" : "accountSource",
        "jsonType.label" : "String",
        "userinfo.token.claim" : "true"
      }
    },
    "Account-Identifier-Protocol-Mapper" = {
      "protocol_mapper" = "account-identifier-mapper",
      "config" = {
        "id.token.claim" : "true",
        "lightweight.claim" : "false",
        "access.token.claim" : "true",
        "claim.name" : "accountIdentifier",
        "userinfo.token.claim" : "true",
        "introspection.token.claim" : "true"
      }
    },
    "Account-Is-Temporary-Protocol-Mapper" = {
      "config" = {
        "introspection.token.claim" = "true",
        "userinfo.token.claim" : "true",
        "user.attribute" : "accountIsTemporary",
        "id.token.claim" : "true",
        "lightweight.claim" : "false",
        "access.token.claim" : "true",
        "claim.name" : "accountIsTemporary",
        "jsonType.label" : "boolean"
      }
    }
    "SP-User-ID-Mapper" = {
      config = {
        "introspection.token.claim" : "true",
        "userinfo.token.claim" : "true",
        "user.attribute" : "SP-User-ID",
        "id.token.claim" : "true",
        "lightweight.claim" : "false",
        "access.token.claim" : "true",
        "claim.name" : "SP-User-ID",
        "jsonType.label" : "String"
      }
    }
    "preferred_username-mapper" = {
      "config" = {
        "introspection.token.claim" = "true",
        "user.attribute" : "preferred_username",
        "id.token.claim" : "true",
        "access.token.claim" : "true",
        "claim.name" : "preferred_username",
        "jsonType.label" : "String",
        "userinfo.token.claim" : "true"
      }
    }
  }
  idp_mapper_configs = {
    "Admin Role" = {
      should_create = !var.local_cluster
      mapper        = "oidc-advanced-role-idp-mapper"
      extra_config = {
        syncMode = "FORCE"
        claims = jsonencode(
          [{
            key = "roles", value = "StageAdmin"
          }]
        )
        role = "admin"
      }
    }
    Account-Source-Mapper = {
      mapper = "hardcoded-attribute-idp-mapper"
      extra_config = {
        syncMode          = "FORCE"
        "attribute.value" = "gematik"
        attribute         = "accountSource"
      }
      bundid-idp = {
        extra_config = {
          "attribute.value" = "bundid"
        }
      }
      muk = {
        extra_config = {
          "attribute.value" = "muk"
        }
      }
    },
    Account-Is-Temporary-Mapper = {
      mapper = "hardcoded-attribute-idp-mapper"
      extra_config = {
        syncMode          = "IMPORT"
        "attribute.value" = "true"
        attribute         = "accountIsTemporary"
      }
    },
    Profession-OID-Mapper = {
      mapper = "gematik-smcb-user-attribute-mapper"
      extra_config = {
        syncMode       = "IMPORT"
        userAttribute  = "professionOid"
        claimAttribute = "PROFESSION_OID"
      }
      gematik-authenticator = {
        mapper = "gematik-idp-smcb-user-mapper"
      }
    },
    Organization-Name-Mapper = {
      mapper = "gematik-smcb-user-attribute-mapper"
      extra_config = {
        syncMode       = "FORCE"
        userAttribute  = "organizationName"
        claimAttribute = "ORGANIZATION_NAME"
      }
      gematik-authenticator = {
        mapper = "gematik-idp-smcb-user-mapper"
      }
    },
    Level-Of-Assurance-Mapper = {
      mapper = "hardcoded-attribute-idp-mapper"
      extra_config = {
        syncMode          = "FORCE"
        "attribute.value" = "STORK-QAA-Level-3"
        attribute         = "levelOfAssurance"
      }
      bundid-idp = {
        mapper = "saml-user-attribute-idp-mapper"
        extra_config = {
          "attribute.friendly.name" = "EID-CITIZEN-QAA-LEVEL"
          "attribute.name.format"   = "ATTRIBUTE_FORMAT_BASIC"
          "user.attribute"          = "levelOfAssurance"
        }
      }
    },
    Account-Type-Mapper = {
      mapper = "hardcoded-attribute-idp-mapper"
      extra_config = {
        syncMode          = "FORCE"
        "attribute.value" = "organization"
        attribute         = "accountType"
      }
      bundid-idp = {
        extra_config = {
          "attribute.value" = "person"
        }
      }
    },
    Username-Protocol-Mapper = {
      mapper = "saml-user-attribute-idp-mapper"
      extra_config = {
        syncMode                = "IMPORT",
        "user.attribute"        = "username",
        "attribute.name.format" = "ATTRIBUTE_FORMAT_BASIC",
        "attribute.name"        = "DatenuebermittlerPseudonymId"
      }
    },
  }
  auth_flow_configs = {
    for realm in keys(local.keycloak_realms) : realm => {
      "Direct Grant Mutual TLS" = {
        execution = [
          {
            requirement   = "REQUIRED"
            authenticator = "direct-grant-validate-username"
            priority      = 5
            alias         = "Direct Grant Validate Username"
          },
          {
            requirement   = "REQUIRED"
            authenticator = "direct-grant-auth-x509-username"
            priority      = 10
            alias         = "x509-exec-config"
            config = {
              "x509-cert-auth.canonical-dn-enabled" : "true"
              "x509-cert-auth.serialnumber-hex-enabled" : "false"
              "x509-cert-auth.ocsp-fail-open" : try(var.stage_specific_keycloak_config.realm_specifics[realm].x509_cert_auth_ocsp_fail_open, false)
              "x509-cert-auth.regular-expression" : try(var.stage_specific_keycloak_config.realm_specifics[realm].x509_cert_auth_regular_expression, null)
              "x509-cert-auth-crl-abort-if-non-updated" : "true"
              "x509-cert-auth.mapper-selection" : "Username or Email"
              "x509-cert-auth.crl-relative-path" : "crl.pem"
              "x509-cert-auth.certificate-policy-mode" : "All"
              "x509-cert-auth.crldp-checking-enabled" : "false"
              "x509-cert-auth.mapping-source-selection" : "Match SubjectDN using regular expression"
              "x509-cert-auth.timestamp-validation-enabled" : try(var.stage_specific_keycloak_config.realm_specifics[realm].x509_cert_timestamp_validation_enabled, null)
              "x509-cert-auth.ocsp-checking-enabled" : try(var.stage_specific_keycloak_config.realm_specifics[realm].x509_ocsp_checking_enabled, true)
            }
          }
        ]
      }
    }
  }
  idp_configs = {
    for realm in keys(local.keycloak_realms) : realm => {
      "gematik-idp" = {
        type              = "oidc"
        authorization_url = var.stage_specific_keycloak_config.oidc_idp_configs.gematik-idp.authorizationUrl
        client_id         = var.stage_specific_keycloak_config.oidc_idp_configs.gematik-idp.clientId
        token_url         = var.stage_specific_keycloak_config.oidc_idp_configs.gematik-idp.tokenUrl
        issuer            = var.stage_specific_keycloak_config.oidc_idp_configs.gematik-idp.issuer
        display_name      = "gematik IDP"
        client_secret     = var.keycloak_gematik_idp_client_secret
      }
      "entra-id" = {
        type               = "oidc"
        authorization_url  = var.stage_specific_keycloak_config.oidc_idp_configs.entra-id.authorizationUrl
        client_id          = var.stage_specific_keycloak_config.oidc_idp_configs.entra-id.clientId
        token_url          = var.stage_specific_keycloak_config.oidc_idp_configs.entra-id.tokenUrl
        issuer             = var.stage_specific_keycloak_config.oidc_idp_configs.entra-id.issuer
        display_name       = "EntraID"
        client_secret      = var.keycloak_entra_id_client_secret
        user_info_url      = "https://graph.microsoft.com/oidc/userinfo"
        logout_url         = "https://login.microsoftonline.com/30092c62-4dbf-43bf-a33f-10d21b5b660a/oauth2/v2.0/logout"
        validate_signature = true
        jwks_url           = "https://login.microsoftonline.com/30092c62-4dbf-43bf-a33f-10d21b5b660a/discovery/v2.0/keys"
        enabled            = !var.local_cluster
      }
      "gematik-authenticator" = {
        type                          = "oidc"
        provider_id                   = "gematik-idp"
        display_name                  = "gematik Authenticator"
        client_id                     = var.stage_specific_keycloak_config.authenticator_configs.client_id
        gui_order                     = 0,
        sync_mode                     = "IMPORT",
        default_scopes                = var.stage_specific_keycloak_config.authenticator_configs.default_scope
        trust_email                   = true
        first_broker_login_flow_alias = "first broker login"
        extra_config = {
          authenticatorUrl                       = "authenticator://",
          idpUserAgent                           = var.stage_specific_keycloak_config.authenticator_configs.user_agent,
          authenticationFlow                     = "SMCB",
          idpTimeoutMs                           = "10000",
          openidConfigUrl                        = var.stage_specific_keycloak_config.authenticator_configs.openid_config_url,
          timeoutMs                              = "60000",
          newAuthenticationFlow                  = "true",
          validateOpenIDConfigSigningCertificate = "false"
        }
      }
      "bundid-idp" = {
        type = "saml"

        client_id    = "bund-idp-client"
        display_name = "BundID IDP"
        gui_order    = 1

        entity_id                              = "${var.stage_specific_keycloak_config.demis_keycloak_url}/realms/${realm}"
        single_sign_on_service_url             = var.stage_specific_keycloak_config.saml_idp_configs["bundid-idp"].service_url
        single_logout_service_url              = var.stage_specific_keycloak_config.saml_idp_configs["bundid-idp"].service_url
        post_binding_response                  = true
        post_binding_logout                    = true
        post_binding_authn_request             = true
        want_assertions_signed                 = var.stage_specific_keycloak_config.saml_idp_configs["bundid-idp"].want_assertions_signed
        signature_algorithm                    = "RSA_SHA256_MGF1"
        name_id_policy_format                  = var.stage_specific_keycloak_config.saml_idp_configs["bundid-idp"].name_id_policy_format
        signing_certificate                    = var.saml_signing_certs["bundid-idp"]
        validate_signature                     = true
        sync_mode                              = "IMPORT"
        xml_sign_key_info_key_name_transformer = "KEY_ID"

        extra_config = {
          "idpEntityId" : var.stage_specific_keycloak_config.saml_idp_configs["bundid-idp"].entity_id,
          "useMetadataDescriptorUrl" : "false",
          "allowCreate" : "true",
          "enabledFromMetadata" : "true",
          "allowedClockSkew" : "0",
          "signSpMetadata" : "false",
          "sendClientIdOnLogout" : "false",
          "sendIdTokenOnLogout" : "true",
          "attributeConsumingServiceIndex" : "0",
          "addExtensionsElementWithKeyInfo" : "false",
        }
      }
      "muk" = {
        type = "saml"

        client_id    = "muk"
        display_name = "MUK"
        gui_order    = 2

        entity_id                              = "${var.stage_specific_keycloak_config.demis_keycloak_url}/realms/${realm}"
        single_sign_on_service_url             = var.stage_specific_keycloak_config.saml_idp_configs["muk"].service_url
        single_logout_service_url              = var.stage_specific_keycloak_config.saml_idp_configs["muk"].service_url
        post_binding_response                  = true
        post_binding_logout                    = true
        post_binding_authn_request             = true
        want_assertions_signed                 = var.stage_specific_keycloak_config.saml_idp_configs["muk"].want_assertions_signed
        signature_algorithm                    = "RSA_SHA256_MGF1"
        name_id_policy_format                  = var.stage_specific_keycloak_config.saml_idp_configs["muk"].name_id_policy_format
        signing_certificate                    = var.saml_signing_certs["muk"]
        validate_signature                     = true
        force_authn                            = true
        sync_mode                              = "IMPORT"
        xml_sign_key_info_key_name_transformer = "KEY_ID"

        extra_config = {
          "idpEntityId" : var.stage_specific_keycloak_config.saml_idp_configs["muk"].entity_id,
          "useMetadataDescriptorUrl" : "false",
          "allowCreate" : "true",
          "enabledFromMetadata" : "true",
          "allowedClockSkew" : "0",
          "signSpMetadata" : "false",
          "sendClientIdOnLogout" : "false",
          "sendIdTokenOnLogout" : "true",
          "attributeConsumingServiceIndex" : "0",
          "addExtensionsElementWithKeyInfo" : "false",
        }
      }
    }
  }
  roles_config = {
    "are-notification-sender" = {
      desc = "ARE Sendungen übermitteln"
    }
    "ars-data-sender" = {
      desc = "ARS-Sendungen senden"
    }
    "bed-occupancy-sender" = {
      desc = "Bettenbelegung senden"
    }
    "disease-notification-nonnominal-sender" = {
      desc = "Nicht namentliche Erkrankungsmeldung nach §7.3 senden"
    }
    "disease-notification-sender" = {
      desc = "Erkrankungsmeldung nach §6.1 senden"
    }
    "igs-notification-data-sender" = {
      desc = "Meldungsdaten senden"
    }
    "igs-sequence-data-sender" = {
      desc = "Sequenzdaten senden"
    }
    "igs-sequence-data-sender-fasta-only" = {
      desc = "Nur FastA Sequenzdaten senden und erweiterte Prüfung"
    }
    "pathogen-notification-anonymous-sender" = {
      desc = "Anonyme Erregernachweis-Meldung nach §7.3 senden"
    }
    "pathogen-notification-nonnominal-sender" = {
      desc = "Nicht namentliche Erregernachweis-Meldung nach §7.3 senden"
    }
    "pathogen-notification-negative-sender" = {
      desc = "Negative Erregernachweis-Meldung nach §7.4 senden"
    }
    "pathogen-notification-sender" = {
      desc = "Erregernachweis-Meldung nach §7.1 senden"
    }
    "vaccine-injury-sender" = {
      desc = "Impfschäden senden"
    }
    ## OEGD Roles
    "are-notification-fetcher" = {
      desc = "ARE Sendungen abholen"
    }
    "ars-data-fetcher" = {
      desc = "ARS-Sendungen abholen"
    }
    "bed-occupancy-fetcher" = {
      desc = "Bettenbelegung abrufen"
    }
    "disease-notification-fetcher" = {
      desc = "Erkrankungsmeldungen abrufen"
    }
    "disease-notification-nonnominal-fetcher" = {
      desc = "Nicht namentliche Erkrankungsmeldungen nach §7.3 abrufen"
    }
    "igs-notification-data-fetcher" = {
      desc = "IGS Meldungsdaten abrufen"
    }
    "igs-sequence-data-fetcher" = {
      desc = "Sequenzdaten abrufen"
    }
    "pathogen-notification-anonymous-fetcher" = {
      desc = "Abrufen von anonymen Erregernachweis-Meldungen nach §7.3"
    }
    "pathogen-notification-fetcher" = {
      desc = "Abrufen von Erregernachweis-Meldungen nach §7.1"
    }
    "pathogen-notification-negative-fetcher" = {
      desc = "Abrufen von negativen Erregernachweis-Meldungen nach §7.4"
    }
    "pathogen-notification-nonnominal-fetcher" = {
      desc = "Abrufen von nicht namentlichen Erregernachweis-Meldungen nach §7.3"
    }
    "proof-of-disease-notification-excerpt-fetcher" = {
      desc = "Abrufen (Auszüge) von Krankheitsmeldungen nach §6.1"
    }
    "proof-of-pathogen-notification-excerpt-fetcher" = {
      desc = "Abrufen (Auszüge) von Erregernachweis-Meldungen nach §7.1"
    }
    "vaccine-injury-fetcher" = {
      desc = "Impfschäden abrufen"
    }
    ## Client Roles
    "lab-notification-sender" = {
      desc = "Rolle, die das Versenden von Labormeldungen erlaubt"
    }
    "lab-notification-receiver" = {
      desc = "Rolle, die das Abrufen von Labormeldungen erlaubt"
    }
  }
  openid_clients = {
    for realm in keys(local.keycloak_realms) : realm => {
      "testsuite-client" = {
        name                             = "Testsuite"
        access_type                      = "CONFIDENTIAL"
        client_secret                    = var.keycloak_testsuite_client_secret
        access_token_lifespan            = 600
        frontchannel_logout_enabled      = true
        frontend_logout_session_required = true
        service_accounts_enabled         = true
      }
      "token-exchange-client" = {
        access_type                     = "CONFIDENTIAL"
        client_secret                   = var.keycloak_default_client_secrets
        standard_flow_enabled           = true
        direct_access_grants_enabled    = true
        frontchannel_logout_enabled     = true
        valid_redirect_uris             = ["/*"]
        valid_post_logout_redirect_uris = ["+"]
        web_origins                     = ["/*"]
      }
      "demis-adapter" = {
        name                         = "Service Provider demis-adapter"
        access_type                  = "CONFIDENTIAL"
        client_secret                = var.keycloak_default_client_secrets
        standard_flow_enabled        = true
        direct_access_grants_enabled = true
        valid_redirect_uris = [
          "de.fraunhofer.fokus.ehealth.movi.kaa://oauth/callback",
          "de.fraunhofer.fokus.ehealth.ask.keycloakauthenticatortest://oauth/callback"
        ]
        valid_post_logout_redirect_uris = ["+"]
      }
      "demis-gateway" = {
        access_type                     = "CONFIDENTIAL"
        standard_flow_enabled           = true
        direct_access_grants_enabled    = true
        valid_redirect_uris             = ["http://www.example.de/*"]
        valid_post_logout_redirect_uris = ["+"]
        access_token_lifespan           = 600
      }
      "demis-test-password-grant" = {
        access_type                  = "PUBLIC"
        client_secret                = var.keycloak_default_client_secrets
        standard_flow_enabled        = false
        direct_access_grants_enabled = true
        frontchannel_logout_enabled  = true
        authentication_flow_binding_overrides = {
          direct_grant : "direct grant"
        }
      }
      "demis-test" = {
        name                            = "Service Provider demis-test"
        access_type                     = "CONFIDENTIAL"
        client_secret                   = var.keycloak_default_client_secrets
        valid_redirect_uris             = ["/*"]
        valid_post_logout_redirect_uris = ["+"]
        standard_flow_enabled           = true
        direct_access_grants_enabled    = true
        access_token_lifespan           = 600
        default_scopes                  = ["basic", "profile", "roles"]
        optional_scopes                 = []
      }
      "notification-gateway" = {
        name                  = "Notification Gateway Ressource"
        access_type           = "BEARER-ONLY"
        access_token_lifespan = 540
      }
      "notification-api" = {
        name        = "REST Service: notification-api"
        access_type = "BEARER-ONLY"
      }
      "notification-entry-service" = {
        name                  = "REST Service: notification-entry-service"
        access_type           = "BEARER-ONLY"
        access_token_lifespan = 600
      }
      ### PORTAL Clients
      "meldeportal" = {
        access_type                         = "PUBLIC"
        standard_flow_enabled               = true
        direct_access_grants_enabled        = true
        backchannel_logout_session_required = true
        base_url                            = var.stage_specific_keycloak_config.portal_specifics.demis_home_url
        admin_url                           = "${var.stage_specific_keycloak_config.portal_specifics.demis_home_url}/"
        valid_redirect_uris                 = var.stage_specific_keycloak_config.portal_specifics.meldeportal_redirect_url
        valid_post_logout_redirect_uris     = ["+"]
        web_origins                         = var.stage_specific_keycloak_config.portal_specifics.meldeportal_web_origin
      }
      "meldeportal-internet" = {
        access_type                         = "PUBLIC"
        standard_flow_enabled               = true
        direct_access_grants_enabled        = true
        backchannel_logout_session_required = true
        base_url                            = var.stage_specific_keycloak_config.portal_specifics.demis_home_url
        admin_url                           = "${var.stage_specific_keycloak_config.portal_specifics.demis_home_url}/"
        valid_redirect_uris                 = var.stage_specific_keycloak_config.portal_specifics.meldeportal_internet_redirect_url
        valid_post_logout_redirect_uris     = ["+"]
        web_origins                         = var.stage_specific_keycloak_config.portal_specifics.meldeportal_internet_web_origin
      }
      ### OEGD Clients
      "demis-analyzer" = {
        name        = "Service Provider demis-analyzer"
        access_type = "CONFIDENTIAL"
        valid_redirect_uris = [
          "de.fraunhofer.fokus.ehealth.demis2.bachelorarbeitmarkus://oauth/callback",
          "de.fraunhofer.fokus.ehealth.ask.keycloakauthenticatortest://oauth/callback"
        ]
        valid_post_logout_redirect_uris = ["+"]
        standard_flow_enabled           = true
        direct_access_grants_enabled    = true
        client_secret                   = var.keycloak_default_client_secrets
        full_scope_allowed              = true
        access_token_lifespan           = 600
      }
      "demis-importer" = {
        name        = "Service Provider demis-importer"
        access_type = "CONFIDENTIAL"
        valid_redirect_uris = [
          "de.fraunhofer.fokus.ehealth.movi.kaa://oauth/callback",
          "de.fraunhofer.fokus.ehealth.ask.keycloakauthenticatortest://oauth/callback"
        ]
        valid_post_logout_redirect_uris = ["+"]
        standard_flow_enabled           = true
        direct_access_grants_enabled    = true
        client_secret                   = var.keycloak_default_client_secrets
        full_scope_allowed              = true
        access_token_lifespan           = 600
      }
      "aeskulab21" = {
        name        = "Service Provider aeskulab21"
        access_type = "CONFIDENTIAL"
        valid_redirect_uris = [
          "https://unisoft.de/",
          "de.fraunhofer.fokus.ehealth.ask.keycloakauthenticatortest://oauth/callback"
        ]
        standard_flow_enabled           = true
        direct_access_grants_enabled    = true
        client_secret                   = var.keycloak_default_client_secrets
        valid_post_logout_redirect_uris = ["+"]
        access_token_lifespan           = 600
      }
      "cus-cli" = {
        name                             = "Certificate Update Service"
        access_type                      = "CONFIDENTIAL"
        client_secret                    = var.keycloak_cus_client_secret
        access_token_lifespan            = 600
        frontchannel_logout_enabled      = true
        frontend_logout_session_required = true
        service_accounts_enabled         = true
      }
      "devagency" = {
        name        = "Service Provider devagency"
        access_type = "CONFIDENTIAL"
        valid_redirect_uris = [
          "https://devagency.de/",
          "de.fraunhofer.fokus.ehealth.ask.keycloakauthenticatortest://oauth/callback"
        ]
        valid_post_logout_redirect_uris = ["+"]
        standard_flow_enabled           = true
        direct_access_grants_enabled    = true
        client_secret                   = var.keycloak_default_client_secrets
        access_token_lifespan           = 600
      }
      "duplicate-detection-engine" = {
        name                  = "REST Service: duplicate-detection-engine"
        access_type           = "BEARER-ONLY"
        access_token_lifespan = 600
      }
      "gumax" = {
        name        = "Service Provider gumax"
        access_type = "CONFIDENTIAL"
        valid_redirect_uris = [
          "de.fraunhofer.fokus.ehealth.ask.keycloakauthenticatortest://oauth/callback",
          "https://www.software-house.de/"
        ]
        standard_flow_enabled           = true
        direct_access_grants_enabled    = true
        client_secret                   = var.keycloak_default_client_secrets
        valid_post_logout_redirect_uris = ["+"]
        access_token_lifespan           = 600
      }
      "isga" = {
        name        = "Service Provider isga"
        access_type = "CONFIDENTIAL"
        valid_redirect_uris = [
          "de.fraunhofer.fokus.ehealth.ask.keycloakauthenticatortest://oauth/callback",
          "http://www.computerzentrum.de/"
        ]
        standard_flow_enabled           = true
        direct_access_grants_enabled    = true
        client_secret                   = var.keycloak_default_client_secrets
        valid_post_logout_redirect_uris = ["+"]
        access_token_lifespan           = 600
      }
      "mikropro" = {
        name        = "Service Provider mikropro"
        access_type = "CONFIDENTIAL"
        valid_redirect_uris = [
          "de.fraunhofer.fokus.ehealth.ask.keycloakauthenticatortest://oauth/callback",
          "http://www.computerzentrum.de/"
        ]
        standard_flow_enabled           = true
        direct_access_grants_enabled    = true
        client_secret                   = var.keycloak_default_client_secrets
        valid_post_logout_redirect_uris = ["+"]
        access_token_lifespan           = 600
      }
      "notification-clearing-api" = {
        name                  = "REST Service: notification-clearing-api"
        access_type           = "BEARER-ONLY"
        access_token_lifespan = 600
      }
      "octoware" = {
        name        = "Service Provider octoware"
        access_type = "CONFIDENTIAL"
        valid_redirect_uris = [
          "http://easy-soft.de/unternehmen/",
          "de.fraunhofer.fokus.ehealth.ask.keycloakauthenticatortest://oauth/callback",
        ]
        standard_flow_enabled           = true
        direct_access_grants_enabled    = true
        client_secret                   = var.keycloak_default_client_secrets
        valid_post_logout_redirect_uris = ["+"]
        access_token_lifespan           = 600
      }
      "profile-loader" = {
        name        = "Service Provider profile-loader"
        access_type = "CONFIDENTIAL"
        valid_redirect_uris = [
          "www.example.de"
        ]
        standard_flow_enabled           = true
        direct_access_grants_enabled    = true
        client_secret                   = var.keycloak_default_client_secrets
        valid_post_logout_redirect_uris = ["+"]
        access_token_lifespan           = 600
      }
      "profile-server" = {
        name                  = "REST Service: profile-server"
        access_type           = "BEARER-ONLY"
        access_token_lifespan = 600
      }
      "survnet" = {
        name        = "Service Provider survnet"
        access_type = "CONFIDENTIAL"
        valid_redirect_uris = [
          "de.fraunhofer.fokus.ehealth.ask.keycloakauthenticatortest://oauth/callback",
          "http://www.computerzentrum.de/"
        ]
        standard_flow_enabled           = true
        direct_access_grants_enabled    = true
        client_secret                   = var.keycloak_default_client_secrets
        valid_post_logout_redirect_uris = ["+"]
        access_token_lifespan           = 600
      }
      # Default clients that are created by Keycloak and should be imported into Terraform state if not excluded
      "account" = {
        name                  = "$${client_account}"
        access_type           = "CONFIDENTIAL"
        standard_flow_enabled = true
        valid_redirect_uris   = ["/realms/${realm}/account/*"]
        defaultClient         = true
        full_scope_allowed    = false
        "SURVEILLANCE-PROGRAMS" = {
          access_type = "PUBLIC"
        }
      }
      "account-console" = {
        name                       = "$${client_account-console}"
        access_type                = "PUBLIC"
        standard_flow_enabled      = true
        pkce_code_challenge_method = "S256"
        valid_redirect_uris        = ["/realms/${realm}/account/*"]
        defaultClient              = true
        full_scope_allowed         = false
      }
      "admin-cli" = {
        name                         = "$${client_admin-cli}"
        access_type                  = "PUBLIC"
        defaultClient                = true
        direct_access_grants_enabled = true
        "PORTAL" = {
          client_secret = var.keycloak_portal_admin_cli_client_secret
        }
      }
      "broker" = {
        name               = "$${client_broker}"
        access_type        = "BEARER-ONLY"
        defaultClient      = true
        full_scope_allowed = false
        "LAB" = {
          access_type           = "CONFIDENTIAL"
          valid_redirect_uris   = ["+"]
          standard_flow_enabled = true
        }
        "HOSPITAL" = {
          access_type           = "CONFIDENTIAL"
          valid_redirect_uris   = ["+"]
          standard_flow_enabled = true
        }
      }
      "realm-management" = {
        name          = "$${client_realm-management}"
        access_type   = "BEARER-ONLY"
        defaultClient = true
        "INSTITUTIONS-TI" = {
          access_type                      = "CONFIDENTIAL"
          client_secret                    = var.keycloak_institutions_ti_realm_management_client_secret
          standard_flow_enabled            = true
          implicit_flow_enabled            = false
          direct_access_grants_enabled     = false
          service_accounts_enabled         = true
          full_scope_allowed               = false
          frontchannel_logout_enabled      = false
          allow_remote_resource_management = false
          valid_redirect_uris              = ["+"]
          valid_post_logout_redirect_uris  = ["+"]
          web_origins                      = []
          authorization = {
            policy_enforcement_mode          = "ENFORCING"
            decision_strategy                = "UNANIMOUS"
            allow_remote_resource_management = false
            keep_defaults                    = false
          }
        }
        "master" = {
          defaultClient = false
        }
      }
      "security-admin-console" = {
        name                       = "$${client_security-admin-console}"
        access_type                = "PUBLIC"
        standard_flow_enabled      = true
        pkce_code_challenge_method = "S256"
        valid_redirect_uris        = ["/admin/${realm}/console/*"]
        defaultClient              = true
        post_logout_redirect_uris  = ["+"]
      }
    }
  }
  root_groups = {
    "Anmeldeverfahren"           = { name = "Anmeldeverfahren" }
    "Organisationstypen"         = { name = "Organisationstypen" }
    "SurveillanceProgramme"      = { name = "SurveillanceProgramme" }
    "Testusers"                  = { name = "Testusers", attributes = { "testuserRecipient" = "$sender", "accountIsTest" = true } }
    "Weitere Organisationstypen" = { name = "Weitere Organisationstypen" }
    "RKI.admin" = { name = "RKI.admin", client_roles = [
      { client = "SURVEILLANCE-PROGRAMS-realm", name = "manage-users" },
      { client = "SURVEILLANCE-PROGRAMS-realm", name = "view-users" }
    ] }
  }
  level1_groups = {
    "GematikIdp"                              = { name = "GematikIdp", parent = "Anmeldeverfahren" }
    "ErregerdiagnostischeUntersuchungsstelle" = { name = "ErregerdiagnostischeUntersuchungsstelle", parent = "Organisationstypen", roles = ["disease-notification-nonnominal-sender", "pathogen-notification-sender", "disease-notification-sender", "pathogen-notification-negative-sender", "pathogen-notification-nonnominal-sender", "	disease-notification-nonnominal-sender"] }
    "MedizinischeEinrichtung"                 = { name = "MedizinischeEinrichtung", parent = "Organisationstypen", roles = ["pathogen-notification-nonnominal-sender", "pathogen-notification-sender", "disease-notification-sender", "disease-notification-nonnominal-sender"] }
    "OZG"                                     = { name = "OZG", parent = "Anmeldeverfahren", roles = ["pathogen-notification-nonnominal-sender", "disease-notification-nonnominal-sender", "pathogen-notification-sender", "disease-notification-sender"] }
    "Zertifikat"                              = { name = "Zertifikat", parent = "Anmeldeverfahren" }
    "OEGD"                                    = { name = "OEGD", parent = "Organisationstypen" }
    "ARS"                                     = { name = "ARS", parent = "SurveillanceProgramme", roles = ["ars-data-sender"] }
    "ARE"                                     = { name = "ARE", parent = "SurveillanceProgramme", roles = ["are-notification-sender"] }
    "IGS"                                     = { name = "IGS", parent = "SurveillanceProgramme", roles = ["igs-sequence-data-sender", "igs-notification-data-sender"] }
    "IgsFastAOnly"                            = { name = "IgsFastAOnly", parent = "SurveillanceProgramme", roles = ["igs-sequence-data-sender-fasta-only", "igs-notification-data-sender"] }
    "EinrichtungenFürAnonymeMeldungen"        = { name = "Einrichtungen für Anonyme Meldungen", parent = "Weitere Organisationstypen", roles = ["pathogen-notification-anonymous-sender"] }
  }
  level2_groups = {
    "PathologischAnatomischeEinrichtung" = { name = "PathologischAnatomischeEinrichtung", parent = "ErregerdiagnostischeUntersuchungsstelle", roles = ["vaccine-injury-sender"] }
    "Apotheke"                           = { name = "Apotheke", parent = "MedizinischeEinrichtung", roles = ["vaccine-injury-sender"] }
    "Arztpraxis"                         = { name = "Arztpraxis", parent = "MedizinischeEinrichtung", roles = ["vaccine-injury-sender"] }
    "Geburtshilfe"                       = { name = "Geburtshilfe", parent = "MedizinischeEinrichtung", roles = ["vaccine-injury-sender"] }
    "InstitutionOEGD"                    = { name = "InstitutionOEGD", parent = "MedizinischeEinrichtung" }
    "Krankenhaus"                        = { name = "Krankenhaus", parent = "MedizinischeEinrichtung", roles = ["vaccine-injury-sender", "bed-occupancy-sender"] }
    "SonstigeMedizinischeEinrichtung"    = { name = "SonstigeMedizinischeEinrichtung", parent = "MedizinischeEinrichtung", roles = ["vaccine-injury-sender"] }
    "Tierarzt"                           = { name = "Tierarzt", parent = "MedizinischeEinrichtung" }
    "VorsorgeReha"                       = { name = "VorsorgeReha", parent = "MedizinischeEinrichtung", roles = ["vaccine-injury-sender"] }
    "WeitereGesundheitsberufe"           = { name = "WeitereGesundheitsberufe", parent = "MedizinischeEinrichtung" }
    "Zahnarztpraxis"                     = { name = "Zahnarztpraxis", parent = "MedizinischeEinrichtung" }
    "GesundheitsamtHauptstelle"          = { name = "GesundheitsamtHauptstelle", parent = "OEGD", roles = ["vaccine-injury-fetcher", "pathogen-notification-fetcher", "disease-notification-fetcher"] }
    "GesundheitsamtNebenstelle"          = { name = "GesundheitsamtNebenstelle", parent = "OEGD", roles = ["pathogen-notification-fetcher", "disease-notification-fetcher"] }
    "RKI"                                = { name = "RKI", parent = "OEGD", roles = ["ars-data-fetcher", "are-notification-fetcher", "igs-sequence-data-fetcher", "proof-of-pathogen-notification-excerpt-fetcher", "disease-notification-nonnominal-fetcher", "pathogen-notification-negative-fetcher", "igs-notification-data-fetcher", "bed-occupancy-fetcher", "pathogen-notification-nonnominal-fetcher", "pathogen-notification-anonymous-fetcher", "proof-of-disease-notification-excerpt-fetcher"] }
  }
}
