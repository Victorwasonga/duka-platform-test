# ArgoCD GitOps Deployment

## What is ArgoCD?

ArgoCD is a **declarative GitOps continuous delivery tool** for Kubernetes. It automatically syncs your cluster state with Git repositories, ensuring your applications match what's defined in Git.

## Why ArgoCD for DukQa Platform?

### GitOps Benefits:
- **Git as Single Source of Truth** - All changes tracked in version control
- **Automated Deployments** - Push to Git → Automatic deployment to cluster
- **Rollback Capability** - Easy rollback to any previous Git commit
- **Security** - No direct cluster access needed for deployments
- **Audit Trail** - Complete history of all changes and deployments

### Operational Benefits:
- **Self-Healing** - Automatically fixes configuration drift
- **Multi-Environment** - Manage dev, test, prod from same Git repo
- **Visual UI** - See application status and sync state
- **RBAC Integration** - Role-based access control for teams

## Deployment Order (CRITICAL)

ArgoCD components must be deployed in the correct order:

### 1. Install ArgoCD Core Components
```bash
# Install ArgoCD CRDs and core components
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 2. Wait for ArgoCD to be Ready
```bash
# Wait for ArgoCD server to be available
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
```

### 3. Deploy Custom Configurations
```bash
# Deploy in this specific order:
kubectl apply -f argocd-project.yaml      # Create project first
kubectl apply -f argocd-apps.yaml         # Then applications
kubectl apply -f argocd-image-updater.yaml # Finally image updater
```

## File Structure

### `argocd-project.yaml` - Project Configuration
- **Purpose**: Defines the `dukqa-platform` project with permissions
- **Contains**: Repository access, namespace permissions, RBAC rules
- **Why First**: Applications reference this project

### `argocd-apps.yaml` - Application Definitions
- **Purpose**: Defines all DukQa applications managed by ArgoCD
- **Applications**:
  - `dukqa-microservices` → `dukqa-apps` namespace
  - `dukqa-ingress` → `ingress` namespace  
  - `dukqa-global` → cluster-wide resources
  - `dukqa-infra` → infrastructure components
  - `dukqa-monitoring` → `monitoring` namespace

### `argocd-image-updater.yaml` - Automated Image Updates
- **Purpose**: Automatically updates container images when new versions are available
- **Benefit**: Keeps applications up-to-date without manual intervention

### `argocd-install.yaml` - Helm-based Installation (Alternative)
- **Purpose**: Alternative installation method using Helm chart
- **Features**: Custom configuration, ingress, OIDC integration
- **Use Case**: When you need advanced ArgoCD configuration

## Configuration Details

### Repository Configuration
```yaml
source:
  repoURL: https://github.com/dukqa-org/dukqa-platform
  targetRevision: HEAD
  path: production-cluster/cluster-manifests/apps
```

### Sync Policy
```yaml
syncPolicy:
  automated:
    prune: true      # Remove resources not in Git
    selfHeal: true   # Fix configuration drift
```

### Namespace Mapping
- **dukqa-apps**: Main microservices (auth, payments, etc.)
- **ingress**: Load balancer and ingress controllers
- **monitoring**: Observability stack (Prometheus, Grafana)
- **argocd**: ArgoCD itself

## Access ArgoCD UI

### 1. Get Admin Password
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 2. Port Forward to Access UI
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### 3. Access UI
- **URL**: https://localhost:8080
- **Username**: admin
- **Password**: (from step 1)

## Application Sync States

### 🟢 Synced
- Application matches Git repository
- All resources deployed successfully

### 🟡 OutOfSync  
- Git repository has changes not yet applied
- Click "Sync" to apply changes

### 🔴 Failed
- Deployment failed due to errors
- Check application details for error messages

### ⚪ Unknown
- ArgoCD cannot determine sync state
- Usually indicates connectivity issues

## Troubleshooting

### Applications Show "Repository not accessible"
**Cause**: GitHub repository doesn't exist or is private
**Solution**: 
1. Create the GitHub repository
2. Update `repoURL` in YAML files
3. Add SSH keys if repository is private

### Applications Stuck in "Progressing"
**Cause**: Resources cannot be created (permissions, quotas)
**Solution**:
1. Check application events in ArgoCD UI
2. Verify namespace permissions
3. Check resource quotas

### ArgoCD Server Not Starting
**Cause**: Resource constraints or configuration issues
**Solution**:
```bash
# Check pod logs
kubectl logs -n argocd deployment/argocd-server

# Check resource usage
kubectl top pods -n argocd
```

## Security Features

### RBAC Integration
- **Project-level permissions** control who can deploy what
- **Namespace isolation** prevents cross-contamination
- **Git-based access control** - permissions follow Git repository access

### Secret Management
- **No secrets in Git** - Uses Kubernetes secrets and external secret management
- **IRSA integration** - Uses IAM roles for AWS service access
- **Encrypted communication** - TLS for all ArgoCD components

## GitOps Workflow

### 1. Developer Workflow
```bash
# 1. Make changes to application manifests
git add production-cluster/cluster-manifests/apps/auth-service/
git commit -m "Update auth service to v1.2.3"
git push origin main

# 2. ArgoCD automatically detects changes and syncs
# 3. Application is updated in cluster
```

### 2. Infrastructure Changes
```bash
# 1. Update infrastructure manifests
git add production-cluster/cluster-manifests/infra/
git commit -m "Add Redis cluster"
git push origin main

# 2. ArgoCD syncs infrastructure changes
# 3. New infrastructure components deployed
```

## Integration with DukQa Platform

### Terraform → ArgoCD Flow
1. **Terraform** creates EKS cluster and AWS resources
2. **Global Components** deploy foundational Kubernetes resources
3. **ArgoCD** manages application deployments from Git
4. **Applications** use IRSA roles created by Terraform

### Monitoring Integration
- **ArgoCD metrics** exported to Prometheus
- **Application health** monitored and alerted
- **Deployment events** tracked in observability stack

## Best Practices

### ✅ Do:
- **Keep manifests in Git** - Never apply directly with kubectl
- **Use branches** for testing changes before merging to main
- **Monitor sync status** - Set up alerts for failed syncs
- **Regular backups** - Backup ArgoCD configuration

### ❌ Don't:
- **Manual kubectl apply** - Breaks GitOps workflow
- **Secrets in Git** - Use external secret management
- **Direct cluster access** - Use ArgoCD for all deployments
- **Skip testing** - Always test changes in dev environment first

ArgoCD provides **automated, secure, and auditable** deployments for the entire DukQa platform, ensuring consistency between environments and enabling rapid, reliable releases.