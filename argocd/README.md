# Argo CD

This directory holds the GitOps entrypoints for the cluster.

- `bootstrap/`
  Minimal resources to install or register Argo CD.
- `projects/`
  Argo CD projects used to isolate platform and app scopes.
- `applications/`
  App-of-apps or per-service Application manifests.
- `clusters/`
  Cluster-specific overlays or registration manifests.
