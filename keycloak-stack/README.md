# keycloak-stack

A Helm chart that deploys [Keycloak](https://www.keycloak.org/) with a **self-hosted, persistent PostgreSQL** backend.

It wraps the community-maintained [`codecentric/keycloakx`](https://github.com/codecentric/helm-charts/tree/master/charts/keycloakx) chart and adds a plain, hand-written PostgreSQL `StatefulSet` for persistence — no Bitnami, no third-party database chart, no vendor lock-in. The Postgres piece is ~100 lines of plain YAML that you fully own and can audit.

## Why this exists

The codecentric Keycloak charts don't ship an opinionated, persistent database out of the box. This chart fills that gap with a minimal, transparent Postgres deployment using the official `postgres` image from Docker Hub.

## Features

- Keycloak via `codecentric/keycloakx` (official `quay.io/keycloak/keycloak` image)
- Dedicated PostgreSQL `StatefulSet` with a `PersistentVolumeClaim`
- Auto-generated, stable DB & admin credentials (stored in a `Secret`, not rotated on upgrade)
- No dependency on Bitnami or any chart that could be relicensed/pulled

## Prerequisites

- Kubernetes 1.23+
- Helm 3
- A default `StorageClass` in your cluster (or set one explicitly)

## Install

```bash
helm repo add codecentric https://codecentric.github.io/helm-charts
helm repo update

git clone https://github.com/Jouini-Mohamed-Chaker/keycloak-stack.git
cd keycloak-stack
helm dependency update

helm install keycloak . -n keycloak --create-namespace
```

## Configuration

Key values in `values.yaml`:

| Key | Description | Default |
|---|---|---|
| `postgresql.database` | Keycloak database name | `keycloak` |
| `postgresql.username` | Keycloak database user | `keycloak` |
| `postgresql.password` | DB password (auto-generated if empty) | `""` |
| `postgresql.persistence.size` | PVC size | `8Gi` |
| `postgresql.persistence.storageClassName` | StorageClass (empty = cluster default) | `""` |
| `keycloak.replicas` | Keycloak pod replicas | `1` |
| `keycloak.image.tag` | Keycloak image tag | `26.6.2` |

See `values.yaml` for the full list, and the [keycloakx README](https://github.com/codecentric/helm-charts/tree/master/charts/keycloakx) for all upstream Keycloak options (passed through under the `keycloak:` key).

## Getting the admin password

```bash
kubectl -n keycloak get secret keycloak-postgresql-credentials \
  -o jsonpath="{.data.keycloak-admin-password}" | base64 -d; echo
```

## Uninstall

```bash
helm uninstall keycloak -n keycloak
```

> Note: the PVC is not deleted automatically. Remove it manually if you want to wipe all data:
> `kubectl -n keycloak delete pvc -l app.kubernetes.io/name=keycloak-stack-postgresql`

## Limitations

- Single-instance Postgres — not HA. For production-grade HA, consider swapping in Patroni or CloudNativePG.
- No automated backups included; bring your own (e.g. `pg_dump` CronJob, Velero, etc.).

## License

MIT