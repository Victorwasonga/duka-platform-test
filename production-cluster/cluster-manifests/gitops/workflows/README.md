# DukQa Platform GitOps Workflows

This directory contains GitOps workflows for managing the DukQa platform deployment and operations.

## Workflows Overview

### 1. ArgoCD App of Apps (`argocd-app-of-apps.yaml`)
- Implements the App of Apps pattern
- Manages all DukQa applications from a single root application
- Enables centralized GitOps management

### 2. ArgoCD Sync (`argocd-sync.yaml`)
- Contains scripts for syncing all applications
- Provides rollback functionality
- Automated sync and health checking

### 3. Deploy Services (`deploy-services.yaml`)
- Kubernetes Job for initial deployment
- Creates ArgoCD applications for all microservices
- Automated deployment pipeline

### 4. Image Build Push (`image-build-push.yaml`)
- Scripts for building and pushing Docker images to ECR
- Supports individual service builds or batch builds
- Integrates with AWS ECR authentication

### 5. Monitor Sync (`monitor-sync.yaml`)
- Continuous monitoring of application health
- Sync status checking
- Alerting for failed deployments

### 6. Terraform Plan Apply (`terraform-plan-apply.yaml`)
- Infrastructure as Code management
- Terraform workflow for EKS cluster
- Automated infrastructure provisioning

## Usage

### Initial Setup
```bash
# Apply ArgoCD installation
kubectl apply -f ../argocd/

# Deploy the App of Apps
kubectl apply -f argocd-app-of-apps.yaml
```

### Deploy Services
```bash
# Run deployment job
kubectl apply -f deploy-services.yaml
```

### Build and Push Images
```bash
# Build single service
kubectl exec -it <pod> -- /scripts/build-push.sh auth-service ./services/auth-service

# Build all services
kubectl exec -it <pod> -- /scripts/build-all-services.sh
```

### Monitor Applications
```bash
# Start monitoring
kubectl exec -it <pod> -- /scripts/monitor.sh

# Quick health check
kubectl exec -it <pod> -- /scripts/health-check.sh
```

### Infrastructure Management
```bash
# Plan infrastructure changes
kubectl apply -f terraform-plan-apply.yaml
```

## Prerequisites

1. **ArgoCD installed and configured**
2. **AWS credentials configured**
3. **ECR repository created**
4. **Terraform state bucket created**
5. **GitHub repository access**

## Configuration

Update the following in the workflow files:
- Repository URLs
- AWS account ID and region
- ECR registry details
- Terraform backend configuration
- Domain names and hostnames

## Security Notes

- All sensitive data should be stored in Kubernetes secrets
- Use IAM roles for service accounts (IRSA) where possible
- Regularly rotate credentials and access keys
- Monitor ArgoCD access logs and audit trails