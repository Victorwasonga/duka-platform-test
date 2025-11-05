# Cluster Global Components

This directory contains essential Kubernetes-native components that provide foundational services for the entire DukQa platform. These components are deployed once per cluster and support all microservices.

## 🏗️ Architecture Overview

These components bridge the gap between AWS infrastructure (managed by Terraform) and application workloads, providing:
- **Security Foundation** - RBAC, network policies, and secret management
- **Observability** - Metrics collection for autoscaling and monitoring
- **Operational Excellence** - Standardized access patterns and security policies

## 📁 Directory Structure

```
cluster-global-components/
├── rbac/                    # Role-Based Access Control
│   ├── cluster-roles.yaml           # Admin, Developer, ReadOnly roles
│   └── cluster-role-bindings.yaml   # User/group permissions
├── monitoring/              # Cluster Observability
│   └── metrics-server.yaml          # Resource metrics for HPA/VPA
├── security/               # Security Policies
│   ├── network-policies.yaml        # Network segmentation rules
│   └── namespaces.yaml              # Namespace security labels
└── storage/                # Secret Management
    ├── secrets-store-csi.yaml       # CSI driver for AWS Secrets Manager
    └── aws-provider.yaml            # AWS Secrets Manager provider
```

## 🔐 Security Components

### RBAC (Role-Based Access Control)
**Purpose**: Implement least-privilege access control across the cluster

#### Cluster Roles:
- **`dukqa-admin`** - Full cluster access for platform administrators
- **`dukqa-developer`** - Application deployment and debugging permissions
- **`dukqa-readonly`** - Read-only access for monitoring and troubleshooting

#### Why These Roles:
- **Security**: Prevents accidental cluster-wide changes
- **Compliance**: Audit trail of who can access what
- **Operational Safety**: Developers can't break cluster-level components

### Network Policies
**Purpose**: Implement zero-trust networking at the Kubernetes level

#### Policies Implemented:
- **`default-deny-all`** - Blocks all traffic by default (security-first approach)
- **`allow-dns-and-system`** - Permits essential DNS and HTTPS communication
- **`allow-microservices-communication`** - Enables inter-service communication for DukQa services

#### Why Network Policies:
- **Defense in Depth**: Complements AWS Security Groups
- **Microsegmentation**: Isolates compromised workloads
- **Compliance**: Meets security requirements for financial platforms

### Namespace Security
**Purpose**: Apply Pod Security Standards to enforce security baselines

- **`kube-system`**: Privileged (for system components)
- **`default`**: Baseline (for application workloads)

## 📊 Monitoring Components

### Metrics Server
**Purpose**: Collect resource usage metrics for autoscaling and capacity planning

#### What It Provides:
- **CPU/Memory metrics** for Horizontal Pod Autoscaler (HPA)
- **Node resource usage** for Cluster Autoscaler decisions
- **kubectl top** functionality for debugging

#### Why Essential:
- **Autoscaling**: HPA requires metrics to scale pods
- **Cost Optimization**: Right-sizing based on actual usage
- **Performance**: Identify resource bottlenecks

## 🔒 Storage & Secrets

### Secrets Store CSI Driver
**Purpose**: Securely inject AWS Secrets Manager secrets into pods as mounted volumes

#### Components:
- **CSI Driver**: Kubernetes interface for secret mounting
- **AWS Provider**: Connects to AWS Secrets Manager
- **IRSA Integration**: Uses IAM roles (no hardcoded credentials)

#### Why CSI over Kubernetes Secrets:
- **Security**: Secrets never stored in etcd
- **Rotation**: Automatic secret rotation from AWS
- **Audit**: AWS CloudTrail tracks secret access
- **Compliance**: Meets enterprise security requirements

## 🚀 Deployment Strategy

### Deployment Order (Critical):
```bash
# 1. Security Foundation
kubectl apply -f security/namespaces.yaml
kubectl apply -f rbac/

# 2. Network Security
kubectl apply -f security/network-policies.yaml

# 3. Secret Management
kubectl apply -f storage/

# 4. Observability
kubectl apply -f monitoring/
```

### Why This Order:
1. **Namespaces first** - Establishes security boundaries
2. **RBAC second** - Prevents unauthorized access during deployment
3. **Network policies third** - Secures communication channels
4. **Storage fourth** - Enables secure secret access
5. **Monitoring last** - Observes the secured environment

## 🔗 Integration Points

### With Terraform Infrastructure:
- **IRSA Roles**: Service accounts use IAM roles created by Terraform
- **Network Security**: Kubernetes policies complement AWS Security Groups
- **Secret Access**: CSI driver uses Terraform-created IAM roles
- **Cluster Integration**: Components reference EKS cluster created by Terraform

### With Application Workloads:
- **RBAC**: Applications deploy using developer role permissions
- **Secrets**: Applications mount secrets via CSI volumes
- **Networking**: Applications communicate through allowed network policies
- **Metrics**: Applications expose metrics consumed by metrics server

## 🛡️ Security Benefits

### Zero-Trust Architecture:
- **Default Deny**: Nothing communicates unless explicitly allowed
- **Least Privilege**: Users and services get minimum required permissions
- **Secret Isolation**: Secrets never touch Kubernetes storage

### Compliance Ready:
- **Audit Trails**: All access logged via AWS CloudTrail and Kubernetes audit logs
- **Encryption**: Secrets encrypted in transit and at rest
- **Access Control**: Role-based permissions with group integration

## 🔧 Operational Benefits

### Developer Experience:
- **Self-Service**: Developers can deploy without cluster admin access
- **Debugging**: Metrics and logs accessible via kubectl
- **Security**: Guardrails prevent accidental security issues

### Platform Operations:
- **Scalability**: Metrics enable automatic scaling decisions
- **Security**: Network policies prevent lateral movement
- **Reliability**: RBAC prevents accidental cluster modifications

## 📋 Prerequisites

Before deploying these components:
1. **EKS Cluster** - Must be provisioned via Terraform
2. **IRSA Setup** - OIDC provider and IAM roles must exist
3. **kubectl Access** - Cluster admin permissions required for initial setup
4. **AWS Secrets** - Secrets must exist in AWS Secrets Manager

## 🚨 Important Notes

- **Network Policies**: Require a CNI that supports NetworkPolicy (AWS VPC CNI does)
- **Secrets Store CSI**: Requires IRSA roles with Secrets Manager permissions
- **Metrics Server**: Required for HPA and VPA functionality
- **RBAC**: Changes require cluster admin permissions

These components form the security and operational foundation for the DukQa microservices platform, ensuring secure, scalable, and compliant operations.