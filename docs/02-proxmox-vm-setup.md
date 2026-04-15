# Proxmox VM Setup

Create three VMs in Proxmox. The settings are identical for all nodes — only the role, name, and assigned IP address differ.

## VM Settings

| Setting | Value |
|---|---|
| VM ID | Unique ID per VM (e.g. `<control-id>`, `<worker-1-id>`, `<worker-2-id>`) |
| Name | `<cluster-name>-control`, `<cluster-name>-worker-1`, `<cluster-name>-worker-2` |
| ISO | NixOS minimal ISO |
| Machine | `q35` |
| BIOS | `SeaBIOS` |
| SCSI Controller | `VirtIO SCSI single` |
| Qemu Agent | enabled |
| Disk | ≥ 32GB, VirtIO Block, Discard enabled (if SSD) |
| CPU | ≥ 2 cores, type `host` |
| RAM | ≥ 4096 MB, ballooning disabled |
| Network | Bridge (e.g. `vmbr0`), VirtIO, firewall disabled |

> Set CPU type to `host` — this passes your actual CPU flags through to the VM and provides optimal performance.

> Disable memory ballooning — Kubernetes manages its own memory and does not behave well with dynamic memory allocation.

---

## Creating the VMs

- Create all required VMs before starting installation
- Install nodes sequentially:
  1. Control plane node
  2. Worker nodes

> This ensures the control plane is available before workers attempt to join the cluster.

---

## Notes

- Ensure each VM has a unique ID and hostname
- Maintain consistent naming conventions across nodes
- Keep resource allocation uniform unless intentionally tuning for workload differences
