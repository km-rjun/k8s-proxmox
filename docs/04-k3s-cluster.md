# k3s Cluster Setup

k3s is declared entirely in `configuration.nix` — there are no manual install steps. Once NixOS is installed and booted, k3s starts automatically.

## Control plane

After the control plane boots, verify k3s is running:

```bash
ssh kube@<ip-address>
systemctl status k3s
```

Check the node is ready:

```bash
kubectl get nodes
```

## Get the join token

Workers need this token to authenticate and join the cluster:

```bash
sudo cat /var/lib/rancher/k3s/server/node-token
```

Copy this token — you will paste it into the worker `configuration.nix` before installing.

> Keep this token private. Anyone with this token can join nodes to your cluster.

## Workers

Install NixOS on each worker VM following [03-nixos-install.md](03-nixos-install.md), using the worker `configuration.nix` with:
- The correct hostname (`k8s-worker-1` or `k8s-worker-2`)
- The correct IP
- The join token from the control plane

After each worker boots, verify it joined from the control plane:

```bash
kubectl get nodes
```

Expected output after both workers are up:
```
NAME           STATUS   ROLES           AGE   VERSION
k8s-master     Ready    control-plane   Xh    v1.34.x+k3s1
k8s-worker-1   Ready    <none>          Xm    v1.34.x+k3s1
k8s-worker-2   Ready    <none>          Xm    v1.34.x+k3s1
```

## Verify system pods

```bash
kubectl get pods --all-namespaces
```

All pods should show `Running`. The k3s embedded components (CoreDNS, local-path-provisioner, metrics-server) start automatically.

## kubectl without sudo

The kubeconfig is at `/etc/rancher/k3s/k3s.yaml`. We declare it as a permanent environment variable in `configuration.nix`:

```nix
environment.sessionVariables = {
  KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
};
```

This means `kubectl` works without `sudo` or any manual exports in every shell session.
