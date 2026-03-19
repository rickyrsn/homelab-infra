# Packer

Use Packer to create repeatable Proxmox VM templates.

- `common/`
  Shared scripts and cloud-init fragments.
- `proxmox/ubuntu-24.04-base/`
  Generic Ubuntu base template.
- `proxmox/ubuntu-24.04-k3s-node/`
  Optional K3s-optimized image if you want a separate node profile.
