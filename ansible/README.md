# Ansible

Use Ansible for host-level configuration that should happen after the VM exists:

- baseline packages
- users and SSH
- hardening
- K3s prerequisites
- backup agents
- node labels/taints bootstrap

Keep playbooks small and role-driven.
