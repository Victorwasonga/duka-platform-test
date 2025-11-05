# Storage & Secrets Management

## What is the Secrets Store CSI Driver?

The **Container Storage Interface (CSI) driver** allows Kubernetes pods to securely access secrets from **AWS Secrets Manager** by mounting them as files in the pod's filesystem.

## Why Use CSI Instead of Kubernetes Secrets?

### Security Advantages:
- **Secrets never stored in etcd** - No risk of cluster compromise exposing secrets
- **Automatic rotation** - AWS handles secret rotation, pods get updated secrets
- **Audit trail** - AWS CloudTrail tracks all secret access
- **Encryption at rest** - AWS manages encryption, not Kubernetes

### Operational Benefits:
- **Centralized management** - All secrets managed in AWS console
- **No kubectl secret commands** - Developers don't handle raw secrets
- **Integration with AWS services** - RDS, ElastiCache passwords auto-generated
- **Compliance ready** - Meets enterprise security requirements

## How It Works

```
Pod Request → CSI Driver → AWS Secrets Manager → Mount as File
```

1. **Pod starts** with SecretProviderClass reference
2. **CSI driver** authenticates using IRSA (IAM role)
3. **AWS Secrets Manager** returns the secret value
4. **Secret mounted** as file in pod's filesystem
5. **Application reads** secret from file (not environment variable)

## Components Deployed

### 1. `secrets-store-csi.yaml` - Core CSI Driver
- **DaemonSet** runs on every node
- **Handles secret mounting** requests from pods
- **Manages secret lifecycle** (mount/unmount)

### 2. `aws-provider.yaml` - AWS Integration
- **Connects CSI driver** to AWS Secrets Manager
- **Handles AWS authentication** via IRSA
- **Translates Kubernetes requests** to AWS API calls

## Real-World Usage Example

### 1. Create Secret in AWS Secrets Manager
```bash
aws secretsmanager create-secret \
  --name "dukqa/database/password" \
  --secret-string "super-secure-password"
```

### 2. Create SecretProviderClass
```yaml
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: database-secrets
spec:
  provider: aws
  parameters:
    objects: |
      - objectName: "dukqa/database/password"
        objectType: "secretsmanager"
```

### 3. Mount in Pod
```yaml
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: app-service-account  # Has IRSA role
  containers:
  - name: app
    volumeMounts:
    - name: secrets
      mountPath: "/mnt/secrets"
      readOnly: true
  volumes:
  - name: secrets
    csi:
      driver: secrets-store.csi.k8s.io
      volumeAttributes:
        secretProviderClass: "database-secrets"
```

### 4. Application Reads Secret
```bash
# Inside the pod
cat /mnt/secrets/dukqa/database/password
# Output: super-secure-password
```

## Security Benefits

### Zero-Trust Architecture:
- **No secrets in container images** - Images remain secret-free
- **No secrets in environment variables** - Harder to accidentally log
- **No secrets in Kubernetes etcd** - Cluster compromise doesn't expose secrets
- **Automatic rotation** - Secrets update without pod restart

### Compliance Features:
- **Audit logging** - Every secret access logged in CloudTrail
- **Encryption in transit** - TLS between CSI driver and AWS
- **IAM integration** - Fine-grained permissions per service account
- **Secret versioning** - AWS maintains secret history

## Integration with Our Infrastructure

### IRSA (IAM Roles for Service Accounts):
```yaml
# Service account uses IAM role created by Terraform
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-service-account
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::ACCOUNT:role/duka-eks-cluster-secrets-role
```

### Terraform-Created IAM Roles:
- **Secrets Manager permissions** - Read specific secret paths
- **KMS permissions** - Decrypt secrets if using custom KMS keys
- **Least privilege** - Each service account gets minimal required access

## Why Remove Resource Limits?

### Flexibility Benefits:
- **Burst capacity** - Handle secret mounting spikes during deployments
- **Node diversity** - Works on different instance types without tuning
- **Operational simplicity** - No resource limit troubleshooting

### When Limits Matter:
- **Production clusters** - Prevent resource starvation
- **Multi-tenant environments** - Ensure fair resource sharing
- **Cost optimization** - Control maximum resource usage

For our **test environment**, removing limits provides **operational simplicity** while maintaining security.

## Troubleshooting Common Issues

### Pod Can't Mount Secrets:
1. **Check IRSA role** - Service account has correct IAM role annotation
2. **Verify IAM permissions** - Role can access the specific secret
3. **Check SecretProviderClass** - Correct secret name and region
4. **Review CSI driver logs** - `kubectl logs -n kube-system -l app=secrets-store-csi-driver`

### Secret Not Updating:
- **CSI driver limitation** - Secrets update on pod restart, not automatically
- **Use init containers** - For applications that need fresh secrets
- **Consider external-secrets operator** - For automatic secret synchronization

The CSI driver provides **enterprise-grade secret management** while maintaining the **simplicity** developers expect from Kubernetes.