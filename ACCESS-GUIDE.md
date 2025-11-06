# Platform Access Guide

## ️ ArgoCD Access (NodePort)

### Get Node IP:
```bash
kubectl get nodes -o wide
```

### Access ArgoCD:
- **HTTP**: `http://NODE-IP:30080`
- **HTTPS**: `https://NODE-IP:30443`

### Get Admin Password:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Login:
- **Username**: `admin`
- **Password**: (from command above)

##  Production Applications (LoadBalancer)

### Get LoadBalancer URL:
```bash
kubectl get svc dukqa-platform-lb -n ingress
```

### Access Applications:
- **HTTP**: `http://LOADBALANCER-DNS`
- **HTTPS**: `https://LOADBALANCER-DNS`

##  Verify Services:

```bash
# Check ArgoCD NodePort
kubectl get svc argocd-server-nodeport -n argocd

# Check Production LoadBalancer  
kubectl get svc dukqa-platform-lb -n ingress

# Check all services
kubectl get svc --all-namespaces
```

## 💰 Cost Summary:
- **ArgoCD NodePort**: FREE
- **Production LoadBalancer**: ~$16/month
- **Total**: ~$16/month for production traffic + FREE ArgoCD access