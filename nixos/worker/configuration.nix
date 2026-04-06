{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  networking.hostName = "k8s-control";
  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_IN.UTF-8";

  networking = {
    useDHCP = false;
    interfaces.eth0 = {
      ipv4.addresses = [{
        address = "IP_ADDRESS";
        prefixLength = 24;
      }];
    };
    defaultGateway = "";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 6443 10250 ];
    allowedUDPPorts = [ 8472 51820 ];
  };
# 6443 = Kubernetes API
# 10250 = kubelet API
# 8472 = Flannel VXLAN
# 51820 = WireGuard

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  users.users.master = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "SSH_KEY"
    ];
  };
  # security.sudo.wheelNeedsPassword = true;

  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    htop
    kubectl
  ];

  services.k3s = {
    enable = true;
    role = "server";

    extraFlags = toString [
      "--node-ip=IP_ADDRESS"
      "--advertise-address=IP_ADDRESS"
      "--tls-san=IP_ADDRESS"
      "--disable=traefik"
      "--flannel-iface=eth0"
      "--write-kubeconfig-mode=644"
    ];
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.bridge.bridge-nf-call-iptables" = 1;
    "net.bridge.bridge-nf-call-ip6tables" = 1;
  };
  boot.kernelModules = [ "br_netfilter" "overlay" ];

  environment.sessionVariables = {
    KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
  };

  system.stateVersion = "24.11";
}
