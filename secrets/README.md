# Secrets

Do not commit raw secrets here.

Recommended patterns:

- SOPS + Age for encrypted YAML, env, or Terraform variable files
- External Secrets Operator for runtime Kubernetes secret delivery
- 1Password, Vault, or similar as the source of truth

If you use SOPS, keep encrypted files here and private keys outside this repository.
