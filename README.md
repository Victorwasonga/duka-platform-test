# DukQa Platform EKS Project

## Overview

This project contains the complete Kubernetes infrastructure and application manifests for the DukQa Platform, deployed on Amazon EKS with a hybrid compute model using both EC2 worker nodes and AWS Fargate.

## Architecture

### Compute Strategy
- **EC2 Worker Nodes**: Performance-critical and compliance-required services
- **AWS Fargate**: Auto-scaling and cost-optimized services

### Infrastructure Components
- **EKS Cluster**: Kubernetes 1.32 with mixed compute types
- **VPC**: Multi-AZ setup with public and private subnets
- **Security**: RBAC, AWS Secrets Manager integration
- **Monitoring**: Metrics Server for resource monitoring
- **GitOps**: ArgoCD for application deployment

## Project Structure

```
DukQa-EKS-Project/
├── cluster-global-components/     # Core cluster infrastructure
│   ├── namespaces.yaml           # Application and system namespaces
│   ├── rbac/                     # Role-based access control
│   ├── storage/                  # Secrets Store CSI driver
│   ├── monitoring/               # Metrics server
│   ├── argocd/                   # ArgoCD installation
│   ├── duka-platform-ingress.yaml # Main application ingress
│   └── production-loadbalancer.yaml # Production load balancer
├── production-cluster/           # Application manifests
│   └── cluster-manifests/        # Kubernetes manifests
│       ├── apps/                 # Microservices
│       ├── argocd/              # ArgoCD applications
│       ├── infra/               # Infrastructure services
│       └── monitoring/          # Application monitoring
├── services/                     # Service definitions
├── CLUSTER-DEPLOYMENT-GUIDE.md   # Manual deployment guide
└── INGRESS-GUIDE.md              # Ingress configuration guide
```

## Deployment

### Prerequisites
- EKS cluster with EC2 worker nodes and Fargate profiles
- kubectl configured for cluster access
- AWS Load Balancer Controller installed

### Manual Deployment Order

1. **Namespaces**
   ```bash
   kubectl apply -f cluster-global-components/namespaces.yaml
   ```

2. **RBAC**
   ```bash
   kubectl apply -f cluster-global-components/rbac/
   ```

3. **Storage**
   ```bash
   kubectl apply -f cluster-global-components/storage/
   ```

4. **Monitoring**
   ```bash
   kubectl apply -f cluster-global-components/monitoring/
   ```

5. **ArgoCD**
   ```bash
   kubectl apply -f cluster-global-components/argocd/
   ```

6. **Ingress (Optional)**
   ```bash
   kubectl apply -f cluster-global-components/duka-platform-ingress.yaml
   ```

## Services

### EC2 Worker Services
- API Gateway
- Payments Service (PCI compliance)
- Delivery Service
- KQ Flight Cargo Service
- KRA Integration Service
- Document Upload Service

### Fargate Services
- Auth Service
- Notifications Service
- Customer Support Service
- Insurance Service
- Shipment Service
- Frontend Service

## Access

### ArgoCD Access
- **Port Forward**: `kubectl port-forward svc/argocd-server -n argocd 8080:443`
- **URL**: https://localhost:8080
- **Credentials**: 
  - Username: admin
  - Password: `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`

### Application Access
- **API**: api.duka-platform.com (via ALB)
- **Frontend**: app.duka-platform.com (via ALB)

## Documentation

- **CLUSTER-DEPLOYMENT-GUIDE.md**: Complete deployment instructions
- **INGRESS-GUIDE.md**: Ingress configuration and routing details
- **cluster-global-components/README.md**: Core components overview
- **services/README.md**: Service definitions and configurations

## Security

- RBAC with three role levels (admin, developer, readonly)
- AWS Secrets Manager integration
- SSL termination at ALB level
- Private subnet deployment for worker nodes
- Security groups and network policies

## Monitoring

- Metrics Server for resource monitoring
- kubectl top nodes/pods functionality
- Application-level monitoring via ArgoCD
- AWS CloudWatch integration

## Cost Optimization

- Fargate for variable workloads
- EC2 for consistent performance requirements
- Single ALB for multiple services
- Spot instances support (configurable)

## Support

For deployment issues, refer to the troubleshooting sections in:
- CLUSTER-DEPLOYMENT-GUIDE.md
- INGRESS-GUIDE.md

For service-specific issues, check the individual service documentation in the services/ directory.