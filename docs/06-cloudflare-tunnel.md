# Cloudflare Tunnel

Cloudflare Tunnel allows you to expose services to the internet without opening any inbound ports. This is essential if you are behind CGNAT (common with most ISPs) where port forwarding is not possible.

## How it works

```
Browser → Cloudflare Edge → Cloudflare Tunnel (outbound) → NGINX Ingress → pods
```

`cloudflared` runs on a machine in your network and creates a persistent outbound connection to Cloudflare. Cloudflare routes all traffic for your domain through this tunnel — no inbound ports, no port forwarding, no public IP needed.

## Why route through NGINX and not directly to services?

Routing tunnel traffic through NGINX ingress gives you full routing control inside the cluster. You can host multiple services on different subdomains, add TLS, rate limiting, authentication, and other NGINX annotations — all from inside the cluster without touching the tunnel config.

## Prerequisites

- A Cloudflare account with your domain added
- `cloudflared` installed and running on a machine in your network
- An existing tunnel already configured

## Add your cluster to the existing tunnel

On the machine running `cloudflared`, open your tunnel config file:

```bash
# usually one of:
~/.cloudflared/config.yml
/etc/cloudflared/config.yml
```

Add a new ingress rule pointing to your NGINX ingress:

```yaml
tunnel: <your-tunnel-id>
credentials-file: /path/to/<tunnel-id>.json

ingress:
  # existing services stay here

  - hostname: myapp.yourdomain.com
    service: http://<ip-address> # Enter IP address of worker node

  # catch-all — must always be last
  - service: http_status:404
```

## Add the DNS record

```bash
cloudflared tunnel route dns <your-tunnel-name> myapp.yourdomain.com
```

This creates a CNAME record in Cloudflare DNS automatically.

## Restart cloudflared

```bash
sudo systemctl restart cloudflared
cloudflared tunnel info <your-tunnel-name>
```

## Verify end to end

Deploy the test app from [manifests/test-app/test-app.yaml](../manifests/test-app/test-app.yaml) and visit your hostname in a browser. You should see the nginx welcome page.

```bash
kubectl apply -f manifests/test-app/test-app.yaml
```

Clean up after verifying:

```bash
kubectl delete -f manifests/test-app/test-app.yaml
```

## Security notes

- Cloudflare Tunnel means zero inbound ports are open on your network
- Cloudflare provides DDoS protection and WAF (Web Application Firewall) for free at the edge
- All traffic between Cloudflare and your tunnel is encrypted
- You can add Cloudflare Access in front of any service for zero-trust authentication
