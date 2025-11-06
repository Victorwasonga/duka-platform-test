# RBAC (Role-Based Access Control)

## What is RBAC?

RBAC controls **who can do what** in your Kubernetes cluster. It defines permissions for users, service accounts, and applications to access cluster resources.

## Why Do We Need RBAC?

### Security Benefits:
- **Prevents accidental damage** - Developers can't delete the entire cluster
- **Limits blast radius** - Compromised accounts have restricted access
- **Audit compliance** - Track who accessed what resources
- **Principle of least privilege** - Users get only the permissions they need

### Operational Benefits:
- **Safe multi-tenancy** - Multiple teams can share the cluster safely
- **Self-service deployments** - Developers can deploy without admin help
- **Reduced support burden** - Fewer "can you deploy this for me?" requests

## Our RBAC Roles

### 1. `dukqa-admin` - Platform Administrators
**Who**: DevOps engineers, platform team
**Can do**: Everything (cluster-wide admin access)
```yaml
- apiGroups: ["*"]
  resources: ["*"] 
  verbs: ["*"]
```

### 2. `dukqa-developer` - Application Developers  
**Who**: Software engineers, QA engineers
**Can do**: 
- Deploy and manage applications
- View logs and debug pods
- Create services and ingresses
- **Cannot**: Delete nodes, modify cluster settings

### 3. `dukqa-readonly` - Monitoring & Support
**Who**: Support team, monitoring systems
**Can do**: 
- View all resources
- Read logs
- **Cannot**: Modify anything

## How It Works

```
User/ServiceAccount → ClusterRoleBinding → ClusterRole → Permissions
```

1. **User** authenticates (via AWS IAM)
2. **ClusterRoleBinding** maps user to role
3. **ClusterRole** defines what actions are allowed
4. **Kubernetes** enforces the permissions

## Real-World Example

```bash
# Developer tries to delete a node (DENIED)
kubectl delete node worker-1
# Error: forbidden - user "developer" cannot delete nodes

# Developer deploys app (ALLOWED)  
kubectl apply -f app-deployment.yaml
# deployment.apps/my-app created
```

## Integration with AWS

- **AWS IAM users/roles** map to Kubernetes users
- **IRSA (IAM Roles for Service Accounts)** provides AWS permissions
- **EKS cluster** handles the authentication integration

## Why These Specific Roles?

### `dukqa-admin`
- **Platform emergencies** - Fix cluster issues quickly
- **Infrastructure changes** - Update cluster components
- **Security incidents** - Full access for incident response

### `dukqa-developer`  
- **Daily development** - Deploy, test, debug applications
- **CI/CD pipelines** - Automated deployments
- **Troubleshooting** - Access logs and pod details

### `dukqa-readonly`
- **Monitoring systems** - Collect metrics without modification risk
- **Support team** - Investigate issues without breaking things
- **Compliance audits** - Read-only access for security reviews

## Security Best Practices

 **Do:**
- Use service accounts for applications
- Regularly review role bindings
- Follow principle of least privilege
- Use namespaces for additional isolation

 **Don't:**
- Give admin access to everyone
- Use the default service account
- Hardcode credentials in applications
- Skip RBAC "for simplicity"

RBAC is your **security foundation** - it prevents both accidents and attacks by ensuring everyone has just the right amount of access.