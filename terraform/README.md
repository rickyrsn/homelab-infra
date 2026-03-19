# Terraform

Split Terraform into:

- `modules/`
  Reusable components like VM creation and cluster composition.
- `live/lab/`
  The actual homelab environment and state boundaries.

Suggested state split:

- `bootstrap/`
  Foundation pieces needed before the rest of the stack.
- `network/`
  DNS, VLAN, firewall, or IPAM-adjacent pieces.
- `proxmox/`
  VM definitions.
- `k3s/`
  Cluster node orchestration and outputs.
- `services/`
  Non-cluster infra services that still belong in Terraform.
