# Test Endpoints
run "endpoint_test" {
  command = plan

  variables {
    domain_name                = "ingress.local"
    check_istio_gateway_exists = false
  }

  # assert that the core_hostname is correct
  assert {
    condition     = output.core_hostname == "${var.domain_name}"
    error_message = "Expected was ${var.domain_name}, got: ${output.core_hostname}"
  }

  # assert that the auth_hostname name is correct
  assert {
    condition     = output.auth_hostname == "auth.${var.domain_name}"
    error_message = "Expected was auth.${var.domain_name}, got: ${output.auth_hostname}"
  }
}

# Test Endpoints
run "endpoint_test" {
  command = plan

  variables {
    domain_name                = "ingress.local"
    auth_issuer_subdomain      = "keycloak"
    check_istio_gateway_exists = false
  }

  # assert that the auth_hostname name is correct
  assert {
    condition     = output.auth_hostname == "${var.auth_issuer_subdomain}.${var.domain_name}"
    error_message = "Expected was ${var.auth_issuer_subdomain}.${var.domain_name}, got: ${output.auth_hostname}"
  }
}

run "all_subdomains_test" {
  command = plan
  variables {
    domain_name                 = "domain"
    ti_idp_subdomain            = "ti-idp"
    bundid_idp_issuer_subdomain = "bundid-idp"
    check_istio_gateway_exists  = false
  }

  # assert that the auth_hostname name is correct
  assert {
    condition     = join(",", output.tls_hostnames) == "portal.domain,meldung.domain,bundid-idp.domain,auth.domain,ti-idp.domain,storage.domain"
    error_message = "Expected was \"portal.domain,meldung.domain,bundid-idp.domain,auth.domain,ti-idp.domain,storage.domain\", got: ${join(",", output.tls_hostnames)}"
  }
}

run "empty_subdomains_test" {
  command = plan
  variables {
    domain_name                 = "domain"
    ti_idp_subdomain            = ""
    bundid_idp_issuer_subdomain = ""
    core_subdomain              = ""
    check_istio_gateway_exists  = false
  }

  # assert that the auth_hostname name is correct
  assert {
    condition     = join(",", output.tls_hostnames) == "portal.domain,meldung.domain,auth.domain,storage.domain"
    error_message = "Expected was \"portal.domain,meldung.domain,auth.domain,storage.domain\", got: ${join(",", output.tls_hostnames)}"
  }
}
