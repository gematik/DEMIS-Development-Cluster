locals {
  # Group all the defaults by service
  timeout_retry_defaults = {
    for conf in distinct(var.timeout_retry_defaults) :
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
  # merge defaults and overrides
  merged_values = {
    for key in setunion(keys(local.timeout_retry_defaults), keys(local.timeout_retry_overrides)) :
    key => merge(try(local.timeout_retry_defaults[key], {}), try(local.timeout_retry_overrides[key], {}))
  }
  # encode configs
  encoded_map = {
    for k, v in local.merged_values :
    k => trimspace(yamlencode(v))
  }
}
