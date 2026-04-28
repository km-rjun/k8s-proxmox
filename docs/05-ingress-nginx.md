# NGINX Ingress Controller

The ingress controller is the front door of the cluster. All external traffic enters through NGINX, which routes it to the correct service based on hostname and path rules.

## Why NGINX and not Traefik?

k3s ships with Traefik by default. We disable it (`--disable=traefik`) and use NGINX instead because:
- NGINX has wider community adoption and more documentation
- Annotation-based configuration is more explicit and easier to debug
- Better compatibility with cert-manager

## Install

We use the baremetal deploy manifest — not the cloud provider version. The cloud version expects a LoadBalancer to be automatically provisioned by AWS/GCP/Azure. On baremetal/homelab that never happens and the service stays in `Pending` forever.

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.1/deploy/static/provider/baremetal/deploy.yaml
```

## Verify

```bash
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
```

Expected pods:
- `ingress-nginx-admission-create` — `Completed` (one-time setup job)
- `ingress-nginx-admission-patch` — `Completed` (one-time setup job)
- `ingress-nginx-controller` — `Running`

Expected service:
```
NAME                       TYPE       CLUSTER-IP     EXTERNAL-IP    PORT(S)
ingress-nginx-controller   NodePort   10.43.x.x      10.0.0.131,10.0.0.132   80:xxxxx/TCP,443:xxxxx/TCP
```

## Expose on standard ports via externalIPs

By default the baremetal install uses random high NodePorts (e.g. `80:31913`). We patch the service to also listen on the standard ports 80 and 443 via `externalIPs`:

```bash
kubectl patch svc ingress-nginx-controller -n ingress-nginx \
  --type='json' \
  -p='[
    {"op":"replace","path":"/spec/type","value":"NodePort"},
    {"op":"add","path":"/spec/externalIPs","value":["10.0.0.131","10.0.0.132"]}
  ]'
```

> We set externalIPs to the worker node IPs, not the control plane. Workers are where workloads run and where traffic should enter.

## Test

From any machine on your network:

```bash
curl -v http://10.0.0.131
```

## Writing an Ingress rule

Every service you want to expose needs an `Ingress` object:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app
  namespace: default
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: myapp.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-app
            port:
              number: 80
```
