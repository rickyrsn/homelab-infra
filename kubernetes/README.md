# Kubernetes GitOps

This directory contains the Argo CD bootstrap and cluster add-ons for the K3s cluster.

## Layout

- `argocd/root-app.yaml`: bootstrap this once after Argo CD is installed
- `argocd/apps/`: child Argo CD Applications managed by the root app
- `infrastructure/`: Kustomize roots for cluster add-ons

Installed add-ons:

- **Metrics Server** (v0.8.0)
- **Kong Ingress** (v0.22.0): Installed from the official Helm chart (`kong/ingress`). The proxy service is configured as `LoadBalancer`, so it will receive an IP after MetalLB is configured and synced.
- **Cert-Manager** (v1.19.2)
- **MetalLB** (v0.15.2)

Argo CD handles the automated bootstrap and sync of these applications following the App of Apps pattern.

## Bootstrap

Install Argo CD first:

```bash
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Then apply the root app:

```bash
kubectl apply -f /Users/ricky/Documents/personal/homelab-infra/kubernetes/argocd/root-app.yaml
```

## MetalLB

Before syncing the MetalLB application, edit:

- `infrastructure/metallb/ipaddresspool.yaml`

Replace the example address range with a safe free range on your LAN.
