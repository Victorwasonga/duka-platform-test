# GitOps Automation for DukQa Platform

This directory contains GitOps workflows and automation for managing the DukQa platform deployment lifecycle. It implements a complete GitOps strategy using ArgoCD and Kubernetes-native workflows.

## 🏗️ GitOps Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Developer     │    │   GitHub Actions │    │   ArgoCD        │
│   Git Push      │───▶│   CI Pipeline    │───▶│   GitOps Engine │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │                          │
                              ▼                          ▼
                       ┌──────────────────┐    ┌─────────────────┐
                       │   ECR Registry   │    │   Kubernetes    │
                       │   Docker Images  │    │   Cluster       │
                       └──────────────────┘    └─────────────────┘
```

## 📁 Directory Structure

```
gitops/
├── workflows/                          # GitOps automation workflows
│   ├── argocd-app-of-apps.yaml       # App of Apps pattern implementation
│   ├── argocd-sync.yaml               # Sync and rollback scripts
│   ├── deploy-services.yaml           # Initial deployment automation
│   ├── image-build-push.yaml          # Container image management
│   ├── monitor-sync.yaml              # Application health monitoring
│   ├── terraform-plan-apply.yaml      # Infrastructure as Code workflows
│   ├── service-accounts.yaml          # IRSA service accounts
│   └── README.md                      # Workflow documentation
└── README.md                          # This documentation
```

## 🔄 GitOps Workflow Components

### 1. App of Apps Pattern (`argocd-app-of-apps.yaml`)
**Purpose**: Centralized management of all DukQa applications through a single root application

#### How It Works:
- **Single Entry Point**: One ArgoCD application manages all others
- **Hierarchical Structure**: Parent app deploys child applications
- **Consistent Configuration**: Standardized sync policies across all apps
- **Simplified Management**: Deploy entire platform with one application

#### Benefits:
- **Operational Simplicity**: Manage 20+ microservices as one unit
- **Consistency**: Same deployment patterns across all services
- **Dependency Management**: Control deployment order through app hierarchy
- **Rollback Capability**: Rollback entire platform or individual components

### 2. Sync Automation (`argocd-sync.yaml`)
**Purpose**: Automated synchronization and health monitoring of all applications

#### Scripts Provided:
- **`sync-all.sh`**: Synchronizes all DukQa applications in correct order
- **`rollback.sh`**: Rollback individual applications to previous versions

#### Features:
- **Ordered Deployment**: Infrastructure → Core Services → Applications → Monitoring
- **Health Validation**: Waits for each application to become healthy
- **Error Handling**: Stops deployment on first failure
- **Status Reporting**: Clear success/failure feedback

### 3. Service Deployment (`deploy-services.yaml`)
**Purpose**: Initial deployment and bootstrapping of the DukQa platform

#### Deployment Sequence:
1. **Global Resources**: Cluster-wide components (RBAC, network policies)
2. **Infrastructure**: Databases, message queues, storage
3. **Microservices**: Business logic applications
4. **Ingress**: Load balancers and routing
5. **Monitoring**: Observability stack

#### Security Features:
- **Non-Root Execution**: All containers run as non-privileged users
- **IRSA Integration**: Uses IAM roles instead of hardcoded credentials
- **Read-Only Filesystem**: Prevents runtime modifications
- **Capability Dropping**: Removes unnecessary Linux capabilities

### 4. Image Management (`image-build-push.yaml`)
**Purpose**: Automated container image building and ECR management

#### Capabilities:
- **Individual Builds**: Build single microservice images
- **Batch Builds**: Build all services simultaneously
- **ECR Integration**: Automatic authentication and push to ECR
- **Tagging Strategy**: Git commit SHA + latest tags

#### Security Implementations:
- **IRSA Authentication**: No hardcoded AWS credentials
- **Image Scanning**: Automatic vulnerability scanning in ECR
- **Immutable Tags**: Prevents tag overwriting for security
- **Multi-Architecture**: Support for ARM64 and AMD64 builds

### 5. Health Monitoring (`monitor-sync.yaml`)
**Purpose**: Continuous monitoring of application health and sync status

#### Monitoring Features:
- **Real-Time Status**: Live application health and sync monitoring
- **Automated Alerts**: Notifications for failed deployments
- **Health Checks**: Comprehensive application health validation
- **Performance Metrics**: Deployment time and success rate tracking

#### Integration Points:
- **Prometheus Metrics**: Exports GitOps metrics for monitoring
- **Slack/Teams Alerts**: Notifications for deployment events
- **Dashboard Integration**: Grafana dashboards for GitOps visibility
- **Audit Logging**: Complete deployment history and changes

### 6. Infrastructure Automation (`terraform-plan-apply.yaml`)
**Purpose**: Infrastructure as Code management within GitOps workflow

#### Features:
- **Terraform Integration**: Run Terraform from within Kubernetes
- **State Management**: S3 backend for Terraform state
- **Plan Validation**: Review changes before applying
- **IRSA Security**: No hardcoded AWS credentials

## 🔐 Security Architecture

### GitOps Security Model
**Principle**: Pull-based deployment with zero cluster credentials in CI/CD

#### Security Benefits:
- **No Push Access**: CI/CD cannot directly access cluster
- **Git as Audit Trail**: All changes tracked in version control
- **Encrypted Communication**: TLS for all ArgoCD communication
- **RBAC Integration**: Kubernetes-native access control

### Service Account Security
**Implementation**: IAM Roles for Service Accounts (IRSA)

#### Service Accounts:
- **`terraform-runner`**: Infrastructure management permissions
- **`image-builder`**: ECR push/pull permissions
- **`argocd-server`**: Application deployment permissions

#### Security Controls:
- **Least Privilege**: Minimal required permissions per service account
- **Temporary Credentials**: AWS STS tokens with automatic rotation
- **Audit Trail**: AWS CloudTrail logs all service account actions
- **Network Policies**: Restrict communication between components

## 🚀 Deployment Strategy

### Initial Platform Setup
```bash
# 1. Deploy ArgoCD
kubectl apply -f ../argocd/

# 2. Deploy GitOps service accounts
kubectl apply -f workflows/service-accounts.yaml

# 3. Bootstrap with App of Apps
kubectl apply -f workflows/argocd-app-of-apps.yaml

# 4. Run initial deployment
kubectl apply -f workflows/deploy-services.yaml
```

### Ongoing Operations
```bash
# Sync all applications
kubectl exec -n argocd deployment/argocd-server -- /scripts/sync-all.sh

# Monitor application health
kubectl exec -n argocd deployment/argocd-server -- /scripts/monitor.sh

# Build and push new images
kubectl exec -n argocd deployment/argocd-server -- /scripts/build-all-services.sh
```

## 🔗 Integration Points

### With CI/CD Pipeline:
1. **Code Push** → GitHub Actions builds and tests
2. **Image Build** → Push to ECR with new tags
3. **Manifest Update** → Update Kubernetes manifests in Git
4. **ArgoCD Sync** → Automatic deployment to cluster
5. **Health Check** → Validate deployment success

### With Infrastructure:
- **Terraform State**: Shared S3 backend for infrastructure state
- **IRSA Roles**: IAM roles created by Terraform infrastructure
- **ECR Repositories**: Container registries provisioned by Terraform
- **Secrets Manager**: Application secrets managed by Terraform

### With Monitoring:
- **Prometheus Metrics**: GitOps deployment metrics
- **Grafana Dashboards**: Visual deployment status and history
- **Alert Manager**: Notifications for deployment failures
- **Jaeger Tracing**: Distributed tracing for deployment workflows

## 🛡️ Compliance & Governance

### Audit Requirements
- **Change Tracking**: All changes tracked in Git with author and timestamp
- **Approval Process**: Pull request reviews for production changes
- **Rollback Capability**: Complete audit trail of rollbacks and reasons
- **Access Control**: RBAC controls who can deploy what and where

### Security Compliance
- **Secrets Management**: No secrets in Git repositories
- **Image Scanning**: Vulnerability scanning for all container images
- **Network Segmentation**: Network policies isolate application traffic
- **Encryption**: All data encrypted in transit and at rest

## 📊 Operational Benefits

### Developer Experience
- **Self-Service**: Developers deploy by committing to Git
- **Fast Feedback**: Immediate deployment status and health information
- **Easy Rollbacks**: Simple Git revert for rollback operations
- **Environment Parity**: Same deployment process for all environments

### Platform Operations
- **Declarative Management**: Infrastructure and applications as code
- **Disaster Recovery**: Complete platform rebuild from Git repositories
- **Scalability**: Handles hundreds of microservices efficiently
- **Cost Optimization**: Automated scaling based on actual usage

### Business Value
- **Faster Time to Market**: Automated deployment reduces release cycles
- **Reduced Risk**: Consistent, tested deployment processes
- **Improved Reliability**: Automated health checks and rollbacks
- **Compliance Ready**: Built-in audit trails and governance

## 🚨 Important Considerations

### Prerequisites
- **ArgoCD Installed**: Must be deployed and configured first
- **IRSA Setup**: IAM roles must exist in AWS
- **ECR Repositories**: Container registries must be created
- **Git Repository**: Source code and manifests must be accessible
- **Network Connectivity**: Cluster must reach GitHub and ECR

### Operational Notes
- **Deployment Order**: Follow the prescribed deployment sequence
- **Resource Limits**: Set appropriate resource limits for all workflows
- **Monitoring**: Continuously monitor application health and performance
- **Backup Strategy**: Regular backups of ArgoCD configuration and Git repositories

This GitOps implementation provides a production-ready, secure, and scalable deployment platform for the DukQa microservices ecosystem.