# dreamcatcher-infrastructure

Opinionated homelab infrastructure layout for:

- Proxmox as the virtualization platform
- Packer for golden images
- Terraform for VM and cluster provisioning
- Ansible for day-0/day-1 configuration
- K3s for the Kubernetes control plane
- Argo CD for GitOps delivery into the cluster

## Structure

```text
.
|-- ansible/
|   |-- inventories/
|   |   `-- lab/
|   |-- playbooks/
|   `-- roles/
|-- argocd/
|   |-- applications/
|   |-- bootstrap/
|   |-- clusters/
|   `-- projects/
|-- docs/
|-- kubernetes/
|   |-- apps/
|   |-- bootstrap/
|   `-- platform/
|-- packer/
|   |-- common/
|   `-- proxmox/
|-- proxmox/
|   `-- snippets/
|-- scripts/
|-- secrets/
|   `-- sops/
`-- terraform/
    |-- live/
    `-- modules/
```

## Recommended Flow

1. Build reusable Ubuntu images with Packer and publish them into Proxmox.
2. Use Terraform to provision Proxmox VMs for jump hosts, K3s servers, K3s agents, and support services.
3. Use Ansible to apply baseline OS hardening, packages, users, SSH policy, and K3s bootstrap tasks that do not belong in image build.
4. Bootstrap Argo CD into K3s.
5. Let Argo CD reconcile platform services and applications from `kubernetes/` and `argocd/`.

## Directory Conventions

- `terraform/modules/` contains reusable building blocks.
- `terraform/live/lab/` contains the actual deployed homelab stack.
- `packer/proxmox/` contains image templates targeted at Proxmox.
- `ansible/inventories/lab/` maps VMs and clusters to real hosts.
- `kubernetes/platform/` is for cluster services like ingress, storage, cert-manager, and monitoring.
- `kubernetes/apps/` is for workloads you personally run in the homelab.
- `argocd/bootstrap/` is the minimum needed to get GitOps online.
- `secrets/` is intentionally not for raw credentials in git; use SOPS/Age, Vault, or external secret backends.

## Next Good Steps

- Fill in Proxmox credentials and networking variables under `terraform/live/lab/`.
- Define VM classes in `terraform/modules/proxmox-vm/`.
- Create a base Ubuntu template in `packer/proxmox/ubuntu-24.04-base/`.
- Add an Ansible inventory for your Proxmox nodes, jump box, and K3s nodes.
- Bootstrap Argo CD and point it at `argocd/applications/`.
