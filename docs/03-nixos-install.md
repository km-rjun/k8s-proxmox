# NixOS Installation

This process is the same for all three nodes. Follow it once for the control plane, then repeat for each worker with different hostname and IP.

## Boot the VM

Start the VM in Proxmox and open the Console tab. Select the default boot option and wait for the NixOS shell:

```
[nixos@nixos:~]$
```

## Verify disk and network interface names

```bash
lsblk && ip link show
```

In this guide the disk is `sda` and the interface is `ens18`. If yours differ, adjust the configuration accordingly.

## Partition the disk

Run these commands one at a time:

```bash
sudo parted /dev/sda -- mklabel gpt
sudo parted /dev/sda -- mkpart ESP fat32 1MB 512MB
sudo parted /dev/sda -- set 1 esp on
sudo parted /dev/sda -- mkpart primary ext4 512MB 100%
sudo mkfs.fat -F 32 -n boot /dev/sda1
sudo mkfs.ext4 -L nixos /dev/sda2
sudo mount /dev/disk/by-label/nixos /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/boot /mnt/boot
```

Verify mounts:

```bash
lsblk
```

You should see `sda1` mounted at `/mnt/boot` and `sda2` at `/mnt`.

## Generate hardware config

```bash
sudo nixos-generate-config --root /mnt
```

This creates two files:
- `/mnt/etc/nixos/hardware-configuration.nix` — auto-detected hardware, do not edit
- `/mnt/etc/nixos/configuration.nix` — replace this with the config below

## Apply the configuration

```bash
sudo nano /mnt/etc/nixos/configuration.nix
```

Replace the entire contents with the appropriate config:
- For the control plane: [nixos/control-plane/configuration.nix](../nixos/control-plane/configuration.nix)
- For workers: [nixos/worker/configuration.nix](../nixos/worker/configuration.nix)

Before saving, fill in:
- Your actual SSH public key (`cat ~/.ssh/id_ed25519.pub` on your local machine)
- The correct hostname and IP for each node
- For workers only: the k3s join token from the control plane

## Run the installer

```bash
sudo nixos-install
```

At the end it will prompt for a root password — set one, but you will not use it for day-to-day access (SSH key login only).

## Reboot

```bash
sudo reboot
```

Remove the ISO in Proxmox while it reboots, then SSH in:

```bash
ssh kube@<node-ip>
```
