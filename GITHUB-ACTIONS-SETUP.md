# GitHub Actions EKS Authentication Setup

This guide explains how to configure GitHub Actions to authenticate with your EKS cluster and avoid common authentication errors.

## Problem
GitHub Actions workflows fail with authentication errors when trying to access EKS cluster:
```
error: You must be logged in to the server (the server has asked for the client to provide credentials)
```

## Root Cause
The GitHub Actions IAM role is not authorized to access the EKS cluster. EKS uses RBAC (Role-Based Access Control) and the `aws-auth` ConfigMap to control access.

## Solution

### 1. Verify GitHub Secrets
Ensure these secrets are configured in your GitHub repository settings:
- `AWS_ACCOUNT_ID` = `746387399274`
- `AWS_REGION` = `us-east-1`

### 2. Add GitHub Actions Role to EKS aws-auth ConfigMap

**Step 1: Connect to your EKS cluster locally**
```bash
aws eks update-kubeconfig --region us-east-1 --name duka-eks-cluster
```

**Step 2: Edit the aws-auth ConfigMap**
```bash
kubectl edit configmap aws-auth -n kube-system
```

**Step 3: Add the GitHub Actions role to the mapRoles section**
```yaml
apiVersion: v1
data:
  mapRoles: |
    - rolearn: arn:aws:iam::746387399274:role/duka-eks-cluster-node-group-role
      groups:
      - system:bootstrappers
      - system:nodes
      username: system:node:{{EC2PrivateDNSName}}
    - rolearn: arn:aws:iam::746387399274:role/duka-eks-cluster-fargate-profile-role
      groups:
      - system:bootstrappers
      - system:nodes
      - system:node-proxier
      username: system:node:{{SessionName}}
    - rolearn: arn:aws:iam::746387399274:role/github-actions-dukqa-role
      username: github-actions
      groups:
      - system:masters
kind: ConfigMap
metadata:
  creationTimestamp: "2025-11-05T08:00:04Z"
  name: aws-auth
  namespace: kube-system
  resourceVersion: "1099"
  uid: 1b037f88-e04d-414c-ae70-314699b69d8b
```

**Key addition:**
```yaml
    - rolearn: arn:aws:iam::746387399274:role/github-actions-dukqa-role
      username: github-actions
      groups:
      - system:masters
```

### 3. Verify the Configuration
```bash
# Check the updated ConfigMap
kubectl get configmap aws-auth -n kube-system -o yaml

# Test cluster access
kubectl cluster-info
kubectl get nodes
```

## Alternative: One-liner Command
Instead of editing manually, you can use this command:
```bash
kubectl patch configmap aws-auth -n kube-system --patch '
data:
  mapRoles: |
    - rolearn: arn:aws:iam::746387399274:role/duka-eks-cluster-node-group-role
      groups:
      - system:bootstrappers
      - system:nodes
      username: system:node:{{EC2PrivateDNSName}}
    - rolearn: arn:aws:iam::746387399274:role/duka-eks-cluster-fargate-profile-role
      groups:
      - system:bootstrappers
      - system:nodes
      - system:node-proxier
      username: system:node:{{SessionName}}
    - rolearn: arn:aws:iam::746387399274:role/github-actions-dukqa-role
      username: github-actions
      groups:
      - system:masters
'
```

## Verification
After adding the role to aws-auth, GitHub Actions workflows should successfully:
-  Connect to EKS cluster
-  Run kubectl commands
-  Deploy cluster components

## Important Notes
- The GitHub Actions role gets `system:masters` permissions (full cluster admin)
- This configuration persists across cluster updates
- If you recreate the cluster, you'll need to repeat this process
- Always verify the role ARN matches your actual GitHub Actions role

## Troubleshooting
If authentication still fails:
1. Verify GitHub secrets are correctly set
2. Check IAM role trust policy allows the repository
3. Ensure the role ARN in aws-auth matches exactly
4. Confirm the cluster name and region are correct