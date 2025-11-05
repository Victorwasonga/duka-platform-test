# DukQa Platform CI/CD Workflows

This directory contains GitHub Actions workflows for automated building, testing, and deployment of DukQa microservices.

## Workflows Overview

### 1. `dukqa-microservices-ci-cd.yaml`
**Core Services Pipeline**
- `auth-service`
- `payments-service`
- `api-gateway`
- `frontend-service`

### 2. `dukqa-additional-services.yaml`
**Additional Services Pipeline**
- `shipment-service`
- `delivery-service`
- `insurance-service`
- `customer-support-service`
- `document-upload-service`
- `kq-flight-cargo-service`
- `kra-integration-service`
- `notifications-service`

## How It Works

### Trigger
Workflows trigger on push to `main` branch when changes are detected in:
```
services/<service-name>/**
```

### Process
1. **Change Detection** - Uses path filters to detect which services changed
2. **Build Docker Image** - Builds only changed services
3. **Push to ECR** - Tags with commit SHA and latest
4. **Update Manifests** - Updates deployment.yaml with new image tag
5. **ArgoCD Sync** - Triggers deployment to Kubernetes

### Image Tagging
- **Commit Tag**: `<service-name>-<commit-sha>`
- **Latest Tag**: `<service-name>-latest`

## Required GitHub Secrets

```bash
AWS_ACCESS_KEY_ID          # AWS access key for ECR
AWS_SECRET_ACCESS_KEY      # AWS secret key for ECR
ARGOCD_SERVER             # ArgoCD server URL
ARGOCD_USERNAME           # ArgoCD username
ARGOCD_PASSWORD           # ArgoCD password
```

## Directory Structure Expected

```
DukQa-EKS-Project/
├── services/
│   ├── auth-service/
│   │   └── Dockerfile
│   ├── payments-service/
│   │   └── Dockerfile
│   └── ...
└── production-cluster/
    └── cluster-manifests/
        └── apps/
            ├── auth-service/
            │   └── deployment.yaml
            └── ...
```

## Workflow Features

- ✅ **Independent Builds** - Only changed services are built
- ✅ **Parallel Execution** - Multiple services build simultaneously
- ✅ **GitOps Integration** - Automatic manifest updates
- ✅ **ECR Integration** - Direct push to Amazon ECR
- ✅ **ArgoCD Sync** - Automated deployment

## Usage

1. **Make changes** to any service in `services/` directory
2. **Commit and push** to main branch
3. **GitHub Actions** automatically:
   - Detects changed services
   - Builds Docker images
   - Pushes to ECR
   - Updates deployment manifests
   - Syncs ArgoCD for deployment

## Monitoring

Check workflow status in GitHub Actions tab:
- Green ✅ = Successful deployment
- Red ❌ = Failed (check logs)
- Yellow 🟡 = In progress

## Troubleshooting

### Common Issues
1. **ECR Login Failed** - Check AWS credentials
2. **ArgoCD Sync Failed** - Verify ArgoCD server and credentials
3. **Docker Build Failed** - Check Dockerfile in service directory
4. **Git Push Failed** - Ensure GitHub token has write permissions

### Debug Steps
1. Check GitHub Actions logs
2. Verify ECR repository exists
3. Confirm ArgoCD application is healthy
4. Check service directory structure