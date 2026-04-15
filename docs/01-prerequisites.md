# Prerequisites

## Hardware

- A machine capable of running Proxmox VE (modern x86_64 system recommended)
- Sufficient resources to run a multi-node cluster:
  - Control plane node: ≥ 2 vCPU, ≥ 4 GB RAM, ≥ 32 GB storage
  - Worker nodes (each): ≥ 2 vCPU, ≥ 4 GB RAM, ≥ 32 GB storage
  - Cluster minimum (3 nodes):
    - ≥ 6 vCPU
    - ≥ 12 GB RAM
    - ≥ 100 GB total storage (allow buffer beyond bare minimum)

> Scale resources proportionally if adding more worker nodes or running workloads beyond testing.

---

## Software

- Proxmox VE installed and accessible via its web interface
- A NixOS minimal ISO (x86_64) available in Proxmox storage
  - Download from the official NixOS website
  - Upload via: Proxmox → Node → Storage → ISO Images → Upload

    

---

## Networking

- All virtual machines connected to the same Proxmox bridge (e.g. `vmbr0` or equivalent)
- A functioning network with:
  - DHCP or static IP assignment capability
  - A known gateway address
- Reserved or available IP addresses for:
  - 1 control plane node
  - At least 2 worker nodes

> Use IPs appropriate for your subnet (e.g. `192.168.x.x`, `10.x.x.x`, etc.)

Example structure (adjust to your environment):

    <control-plane-ip>
    <worker-1-ip>
    <worker-2-ip>
    <gateway-ip>

---

## External Access

- A domain managed via a DNS provider (e.g. Cloudflare or equivalent)
- A secure ingress method, such as:
  - A tunnel client (e.g. cloudflared) running inside your network, or
  - Direct exposure via public IP, load balancer, or reverse proxy

> If your network supports inbound connections (public IP + port forwarding), a tunnel is not required.

---

## Local Machine

- SSH key pair generated:

    ssh-keygen -t ed25519

- SSH access to your Proxmox host and/or provisioned VMs

---

## Notes

- Replace all placeholder values with environment-specific details during implementation.
- Ensure IP allocations do not conflict with existing devices.
- Consider reserving IPs via DHCP or using static leases for consistency.
