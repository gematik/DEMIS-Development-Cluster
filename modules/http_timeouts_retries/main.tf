locals {
  # Built-in standard configurations, no longer defined outside of this module
  common_timeout_retry_value = { timeout = "5s", retries = { attempts = 1, perTryTimeout = "5s" } }
  no_retries                 = { retries = { attempts = 0 } }

  # Group all the explicit defaults by service
  custom_timeout_retry = {
    for conf in distinct(var.custom_timeout_retry) :
    conf.service => merge(
      conf.timeout != null ? { timeout = conf.timeout } : {},
      conf.retries != null ? { retries = merge(
        conf.retries.attempts != null ? { attempts = conf.retries.attempts } : {},
        conf.retries.retryOn != null ? { retryOn = conf.retries.retryOn } : {},
        conf.retries.perTryTimeout != null ? { perTryTimeout = conf.retries.perTryTimeout } : {}
    ) } : {})
  }
  # Group all the overrides by service
  timeout_retry_overrides = {
    for conf in distinct(var.timeout_retry_overrides) :
    conf.service => merge(
      conf.timeout != null ? { timeout = conf.timeout } : {},
      conf.retries != null ? { retries = merge(
        conf.retries.attempts != null ? { attempts = conf.retries.attempts } : {},
        conf.retries.retryOn != null ? { retryOn = conf.retries.retryOn } : {},
        conf.retries.perTryTimeout != null ? { perTryTimeout = conf.retries.perTryTimeout } : {}
    ) } : {})
  }

  # Built-in no-retries defaults derived from the plain service-name list
  no_retries_defaults = { for service in distinct(var.no_retries_services) : service => local.no_retries }

  # Services that already have an explicit configuration (no-retries or explicit defaults)
  # and therefore must NOT receive the common default. Overrides are layered on top and do
  # not disable the common base.
  configured_services = setunion(keys(local.no_retries_defaults), keys(local.custom_timeout_retry))

  # Every service without an explicit configuration receives the built-in common default
  common_defaults = {
    for service in distinct(var.service_names) : service => local.common_timeout_retry_value
    if !contains(local.configured_services, service)
  }

  # Combine the built-in defaults (common + no-retries).
  builtin_defaults = merge(local.common_defaults, local.no_retries_defaults)

  # Merge built-in defaults, explicit defaults and overrides (increasing precedence)
  merged_values = {
    for key in setunion(keys(local.builtin_defaults), keys(local.custom_timeout_retry), keys(local.timeout_retry_overrides)) :
    key => merge(
      try(local.builtin_defaults[key], {}),
      try(local.custom_timeout_retry[key], {}),
      try(local.timeout_retry_overrides[key], {})
    )
  }
  # encode configs
  encoded_map = {
    for k, v in local.merged_values :
    k => trimspace(yamlencode(v))
  }

  # Multipliers to convert Istio durations (ms, s, m, h) to milliseconds
  duration_units = { ms = 1, s = 1000, m = 60000, h = 3600000 }

  # Services that can ever produce an invalid timeout configuration: only those with an
  # explicit timeout/retry definition (defaults or overrides). Pure common-default services
  # (5s timeout, 1 attempt, 5s perTryTimeout) are always valid and no-retries services
  # (0 attempts) are skipped. This set is derived solely from the known input lists and is
  # therefore independent of var.service_names, which keeps the validation condition known at
  # plan time even when service_names contains values that are unknown until apply.
  validated_services = setsubtract(
    setunion(keys(local.custom_timeout_retry), keys(local.timeout_retry_overrides)),
    keys(local.no_retries_defaults)
  )

  # Override-only services (validated, but without an explicit default) receive the common
  # default as their base, mirroring their runtime configuration.
  validation_common_base = {
    for svc in setsubtract(local.validated_services, local.configured_services) :
    svc => local.common_timeout_retry_value
  }

  # Effective configuration used exclusively for validation. It mirrors merged_values for the
  # validated services but is built without referencing service_names.
  validation_merged = {
    for svc in local.validated_services : svc => merge(
      try(local.validation_common_base[svc], {}),
      try(local.custom_timeout_retry[svc], {}),
      try(local.timeout_retry_overrides[svc], {})
    )
  }

  # Compute the effective timeout and the minimum required timeout (perTryTimeout * attempts)
  # in milliseconds per service. Values are null when the corresponding fields are unset,
  # so validation is skipped for those services.
  timeout_validation = {
    for k, v in local.validation_merged : k => {
      timeout_ms = try(
        tonumber(regex("^([0-9]+)(ms|s|m|h)$", v.timeout)[0]) * local.duration_units[regex("^([0-9]+)(ms|s|m|h)$", v.timeout)[1]],
        null
      )
      min_timeout_ms = try(
        tonumber(regex("^([0-9]+)(ms|s|m|h)$", v.retries.perTryTimeout)[0]) * local.duration_units[regex("^([0-9]+)(ms|s|m|h)$", v.retries.perTryTimeout)[1]] * v.retries.attempts,
        null
      )
    }
  }

  # Services whose configured timeout is smaller than perTryTimeout * attempts.
  # Only evaluated when both a timeout and retries (attempts > 0 and perTryTimeout) are set.
  invalid_services = {
    for k, val in local.timeout_validation : k => val
    if val.timeout_ms != null && val.min_timeout_ms != null && val.timeout_ms < val.min_timeout_ms
  }
}
