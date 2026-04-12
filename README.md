# Kubernetes on NixOS with Proxmox

A step-by-step guide to building a production-ready Kubernetes cluster on NixOS VMs running on Proxmox, using k3s, NGINX ingress, and Cloudflare Tunnel.

## Cluster Layout

| Node | VM ID | IP | Role |
|---|---|---|---|
| k8s-control | 130 | 10.0.0.130 | k3s server (control plane) |
| k8s-worker-1 | 131 | 10.0.0.131 | k3s agent (worker) |
| k8s-worker-2 | 132 | 10.0.0.132 | k3s agent (worker) |

## Stack

- **Hypervisor** — Proxmox VE
- **OS** — NixOS
- **Ingress** — NGINX Ingress Controller
- **Tunnel** — Cloudflare Tunnel
- **TLS** — cert-manager

## Why this stack

- **NixOS** — Entire system config lives in one file, fully reproducible, perfect for documenting and sharing
- **k3s** — Bundles etcd, API server, scheduler into one binary, handles certs automatically
- **Cloudflare Tunnel** — Works behind CGNAT, no port forwarding needed, free DDoS protection
- **NGINX Ingress** — Gives full routing control inside the cluster, easy to extend

## Documentation

| Step | Guide |
|---|---|
| 1 | [Prerequisites](docs/01-prerequisites.md) |
| 2 | [Proxmox VM Setup](docs/02-proxmox-vm-setup.md) |
| 3 | [NixOS Installation](docs/03-nixos-install.md) |
| 4 | [k3s Cluster Setup](docs/04-k3s-cluster.md) |
| 5 | [NGINX Ingress Controller](docs/05-ingress-nginx.md) |
| 6 | [Cloudflare Tunnel](docs/06-cloudflare-tunnel.md) |

## NixOS Configs

- [Control plane configuration.nix](nixos/control-plane/configuration.nix)
- [Worker configuration.nix](nixos/worker/configuration.nix)

## Manifests

- [Test app](manifests/test-app/test-app.yaml)

## Roadmap

- [ ] Resource limits and requests
- [ ] Network policies
- [ ] Pod security standards
- [ ] Namespaces per workload
- [ ] Monitoring (Prometheus + Grafana)
- [ ] Automated backups

