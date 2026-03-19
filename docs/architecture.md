# Homelab Architecture

## Layers

1. `packer/`
   Builds immutable VM templates for Proxmox.
2. `terraform/`
   Creates networks, VM instances, and cluster primitives.
3. `ansible/`
   Applies host bootstrap, hardening, and operational config.
4. `kubernetes/`
   Stores cluster manifests, platform services, and apps.
5. `argocd/`
   Connects the Git repo to the running K3s cluster.

## Suggested VM Roles

- `px-jump-01`
  Administrative jump host and automation runner.
- `k3s-server-01..03`
  Control-plane or embedded-etcd server nodes.
- `k3s-agent-01..03`
  Worker nodes for workloads.
- `ops-utility-01`
  Optional services like runners, backup agents, or observability components that do not belong in the cluster.

## Security Notes

- Prefer template-based provisioning over snowflake VMs.
- Keep SSH access centralized and disable password auth where possible.
- Store secrets with SOPS + Age or an external secret store.
- Separate bootstrap credentials from steady-state credentials.
- Treat Proxmox API tokens and kubeconfig files as sensitive artifacts.
