# Cluster Global Components Deployment Guide

This guide provides the correct order to manually deploy all cluster global components on EC2 worker nodes.

## Prerequisites
- EKS cluster running with at least one EC2 worker node
- kubectl configured to access the cluster
- All components configured with EC2 nodeSelectors

## Deployment Order

### 1. **Namespaces** (Foundation)
```bash
kubectl apply -f cluster-global-components/namespaces.yaml
```
**Creates:** All application and system namespaces (argocd, monitoring, ingress, b2b, b2c, backoffice)

### 2. **RBAC** (Security)
```bash
kubectl apply -f cluster-global-components/rbac/
```
**Creates:** 
- dukqa-admin (cluster-admin access)
- dukqa-developer (namespace-scoped access)  
- dukqa-readonly (read-only access)

### 3. **Storage** (Secrets Management)
```bash
kubectl apply -f cluster-global-components/storage/
```
**Creates:**
- Secrets Store CSI Driver
- AWS Secrets Manager Provider
- SecretProviderClass for AWS integration

### 4. **Monitoring** (Metrics & Observability)
```bash
kubectl apply -f cluster-global-components/monitoring/
```
**Creates:**
- Metrics Server (for `kubectl top nodes/pods`)
- Configured to run on EC2 worker nodes only

### 5. **ArgoCD** (GitOps Controller)
```bash
kubectl apply -f cluster-global-components/argocd/
```
**Creates:**
- ArgoCD installation with EC2 nodeSelectors
- NodePort service (ports 30080/30443) for UI access
- All ArgoCD components (server, repo-server, controller, redis, dex)

### 6. **Production LoadBalancer** (Optional - for external app access)
```bash
kubectl apply -f cluster-global-components/production-loadbalancer.yaml
```
**Creates:** NLB LoadBalancer service for production applications (~$16/month)

## Verification Commands

### Check All Components
```bash
# Verify namespaces
kubectl get namespaces

# Verify RBAC
kubectl get clusterroles | grep dukqa
kubectl get clusterrolebindings | grep dukqa

# Verify Storage
kubectl get pods -n kube-system | grep secrets-store
kubectl get secretproviderclass --all-namespaces

# Verify Monitoring
kubectl get pods -n kube-system | grep metrics-server
kubectl top nodes  # Should work after metrics-server is ready

# Verify ArgoCD
kubectl get pods -n argocd
kubectl get svc -n argocd
```

### Check EC2 Node Placement
```bash
# Verify components are running on EC2 nodes (not Fargate)
kubectl get pods -n argocd -o wide
kubectl get pods -n kube-system -l k8s-app=metrics-server -o wide
```

## Access ArgoCD

### Option 1: Port Forward (Recommended)
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
**Access:** https://localhost:8080

### Option 2: NodePort (if EC2 node has public IP)
**Access:** https://EC2-NODE-IP:30443

### Get ArgoCD Credentials
```bash
# Username: admin
# Password:
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## Component Status

| Component | Namespace | Node Type | Purpose |
|-----------|-----------|-----------|---------|
| Namespaces | - | - | Foundation structure |
| RBAC | - | - | Security & permissions |
| Storage | kube-system | EC2 | AWS Secrets Manager |
| Metrics Server | kube-system | EC2 | Resource monitoring |
| ArgoCD | argocd | EC2 | GitOps deployment |
| LoadBalancer | - | - | External app access |

## Troubleshooting

### Metrics Server Issues
```bash
kubectl logs -n kube-system -l k8s-app=metrics-server
```

### ArgoCD Issues
```bash
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server
```

### Check Node Selectors
```bash
kubectl get deployment argocd-server -n argocd -o yaml | grep -A 3 nodeSelector
kubectl get deployment metrics-server -n kube-system -o yaml | grep -A 3 nodeSelector
```

## Success Criteria

- All namespaces created
- RBAC roles and bindings active
- Storage CSI driver running
- Metrics server responding (`kubectl top nodes` works)
- ArgoCD UI accessible
- All components running on EC2 worker nodes
- No pods stuck in Pending state

## Next Steps

After successful deployment:
1. Configure ArgoCD repositories
2. Deploy App-of-Apps pattern
3. Set up monitoring dashboards
4. Configure ingress controllers