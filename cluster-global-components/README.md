# Cluster Global Components

This directory contains the foundational infrastructure components that are deployed to the EKS cluster. These components provide the essential services and configurations required before deploying applications.

## 📋 What Gets Deployed

### 🏷️ **Namespaces** (`namespaces.yaml`)
Application isolation and organization:
- `b2b-fargate` & `b2b-ec2-worker` - B2B applications
- `b2c-fargate` & `b2c-ec2-worker` - B2C applications  
- `backoffice-fargate` & `backoffice-ec2-worker` - BackOffice applications
- `argocd` - GitOps platform
- `monitoring` - Observability stack
- `ingress` - Load balancing and routing

### 🔐 **RBAC Components** (`rbac/`)
Security and access control:
- **`dukqa-admin`** - Full cluster admin permissions
- **`dukqa-developer`** - Developer permissions (pods, deployments, services)
- **`dukqa-readonly`** - Read-only access for monitoring/auditing
- **Role Bindings** - Connect users/groups to roles

### 💾 **Storage Components** (`storage/`)
Secret management and storage:
- **Secrets Store CSI Driver** - AWS Secrets Manager integration
- **AWS Provider** - Enables pods to mount secrets as volumes
- **Service Account** - IRSA role for secrets access
- **DaemonSet** - Runs on all nodes for secret mounting

### 📊 **Monitoring Components** (`monitoring/`)
Observability and metrics:
- **Metrics Server** - Resource metrics (CPU, memory) for HPA
- **Service Account & RBAC** - Permissions for metrics collection
- **Deployment & Service** - Metrics API endpoint

### 🎛️ **ArgoCD Components**
GitOps platform (deployed via workflow):
- **Core ArgoCD** - GitOps controller, UI, repo server
- **LoadBalancer Service** - External AWS NLB access (`argocd-loadbalancer.yaml`)
- **Ingress** - ALB option for domain-based access (`argocd-ingress.yaml`)

## 🔄 Deployment Flow

The GitHub Actions workflow deploys components in this order:

1. **Namespaces** → Create isolated environments
2. **RBAC** → Set up security and permissions  
3. **Storage** → Enable secret management
4. **Monitoring** → Enable resource metrics
5. **ArgoCD** → Install GitOps platform
6. **ArgoCD Apps** → Deploy your applications

## 🚀 Automatic Deployment

The `Deploy Cluster Global Components` workflow automatically runs when:
- ✅ Changes are made to files in this directory (`cluster-global-components/`)
- ✅ Manual trigger via GitHub Actions "Run workflow" button

The workflow will **NOT** run for changes outside this directory, ensuring infrastructure changes are deployed only when needed.

## 🎯 Result

After deployment, you'll have a **complete production-ready Kubernetes platform** with:
- ✅ Security and RBAC configured
- ✅ Secret management enabled
- ✅ Resource monitoring active
- ✅ GitOps platform ready
- ✅ Isolated namespaces for B2B/B2C/BackOffice applications

## 📝 Usage

To deploy or update global components:

1. **Make changes** to files in this directory
2. **Commit and push** to main branch
3. **GitHub Actions** will automatically deploy the changes
4. **Monitor** the workflow in the Actions tab

## 🔧 Manual Deployment

If needed, you can also deploy manually:

```bash
# Deploy namespaces
kubectl apply -f namespaces.yaml

# Deploy RBAC
kubectl apply -f rbac/

# Deploy storage components
kubectl apply -f storage/

# Deploy monitoring
kubectl apply -f monitoring/

# Deploy ArgoCD LoadBalancer
kubectl apply -f argocd-loadbalancer.yaml
```

## 🌐 Accessing ArgoCD

After deployment, ArgoCD will be available via:

1. **LoadBalancer** (Production):
   ```bash
   kubectl get svc argocd-server-lb -n argocd
   ```

2. **Port Forward** (Development):
   ```bash
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```

3. **Get Admin Password**:
   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   ```