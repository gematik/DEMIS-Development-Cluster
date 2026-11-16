########################
# State moves of the infrastructure refactoring (namespaces and pull secrets in the submodules).
# Can be removed once every stage with persisted state has been applied.
########################

# Service Mesh
moved {
  from = module.istio_metadata
  to   = module.service_mesh.module.metadata
}

moved {
  from = module.istio_namespace
  to   = module.service_mesh.module.namespace
}

# Kyverno (had a count before)
moved {
  from = module.kyverno[0]
  to   = module.kyverno
}

moved {
  from = module.kyverno_namespace
  to   = module.kyverno.module.namespace
}

moved {
  from = module.pull_secrets
  to   = module.kyverno.module.pull_secrets
}

# Security
moved {
  from = module.security_metadata
  to   = module.security.module.metadata
}

moved {
  from = module.security_namespace
  to   = module.security.module.namespace
}

moved {
  from = module.trivy
  to   = module.security.module.trivy
}

moved {
  from = module.falco
  to   = module.security.module.falco
}

moved {
  from = module.kyverno_policy_reporter
  to   = module.security.module.policy_reporter
}
