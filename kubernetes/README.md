# Kubernetes GitOps

This directory contains the Argo CD bootstrap and cluster add-ons for the K3s cluster.

## Layout

- `argocd/root-app.yaml`: bootstrap this once after Argo CD is installed
- `argocd/apps/`: child Argo CD Applications managed by the root app
- `infrastructure/`: Kustomize roots for cluster add-ons

Installed add-ons:

- **Local Path Provisioner** (v0.0.35): Default `StorageClass` for the cluster, configured to use `/var/local-path-provisioner` on nodes.
- **Metrics Server** (v0.8.0)
- **Kong Ingress** (v0.22.0): Installed from the official Helm chart (`kong/ingress`). The proxy service is configured as `LoadBalancer`, so it will receive an IP after MetalLB is configured and synced.
- **Cert-Manager** (v1.19.2)
- **MetalLB** (v0.15.2)
- **Cluster Issuers**: Includes a Cloudflare-backed Let's Encrypt production issuer for wildcard certificates. Update the placeholder domain, email, and Cloudflare token secret before syncing.
- **VictoriaMetrics + Grafana**: Core metrics stack for the homelab, configured for `local-path` storage.
- **Loki**: Single-binary log aggregation with filesystem-backed storage on `local-path`.
- **Tempo**: Distributed tracing with persistent storage on `local-path`.
- **Vault**: Standalone Vault deployment with UI and injector enabled.
- **External Secrets**: Sync secrets from Vault into Kubernetes Secrets where applications need native `Secret` resources.

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

## Storage

The repo bootstraps `local-path-provisioner` first so workloads that request PVCs can bind successfully.

Current default path:

- `/var/local-path-provisioner`

If your Talos nodes should store PVC data somewhere else, update:

- `infrastructure/local-path-provisioner/patch-configmap.yaml`

## Cloudflare Wildcard Certificates

Before syncing `cluster-issuers`, update:

- `infrastructure/cluster-issuers/letsencrypt-cloudflare-production.yaml`

Replace the placeholder email address and DNS zone with your real values.

Then create the Cloudflare API token secret in `cert-manager`:

```bash
kubectl -n cert-manager create secret generic cloudflare-api-token-secret \
  --from-literal=api-token='YOUR_CLOUDFLARE_API_TOKEN'
```

The intended issuer name is `letsencrypt-cloudflare-production`.

## Vault and External Secrets

Before syncing Vault-backed secrets, update:

- `infrastructure/external-secrets/clustersecretstore-vault.yaml`

Review the Vault address, KV mount path, auth mount path, and the Vault role bound to the `external-secrets` service account.
