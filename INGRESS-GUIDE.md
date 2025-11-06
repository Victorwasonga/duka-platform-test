# 🌐 DukQa Platform Ingress Guide

This guide explains the ingress configuration for DukQa Platform microservices and ArgoCD access.

## 📁 Ingress Files Overview

### **1. ArgoCD Ingress**
**File:** `cluster-global-components/argocd/argocd-ingress.yaml`
- **Purpose:** Production ArgoCD UI access with SSL
- **Domain:** `argocd.duka-platform.com`
- **SSL:** ACM Certificate
- **Target:** ArgoCD Server service

### **2. DukQa Platform Main Ingress**
**File:** `cluster-global-components/duka-platform-ingress.yaml`
- **Purpose:** All DukQa Platform microservices routing
- **Domains:** 
  - `api.duka-platform.com` (API services)
  - `app.duka-platform.com` (Frontend)
- **SSL:** ACM Certificate
- **Target:** Multiple microservices

## 🎯 DukQa Platform Microservices Routing

### **API Services** (`api.duka-platform.com`)

| Path | Service Name | Compute Type | Function |
|------|-------------|--------------|----------|
| `/api` | `api-gateway` | EC2 | Main API gateway and routing |
| `/auth` | `auth-service` | Fargate | User authentication & authorization |
| `/payments` | `payments-service` | EC2 | Payment processing (PCI compliance) |
| `/notifications` | `notifications-service` | Fargate | Push notifications & messaging |
| `/support` | `customer-support-service` | Fargate | Customer support ticketing |
| `/delivery` | `delivery-service` | EC2 | Delivery tracking & logistics |
| `/insurance` | `insurance-service` | Fargate | Insurance quotes & policies |
| `/cargo` | `kq-flight-cargo-service` | EC2 | KQ flight cargo management |
| `/kra` | `kra-integration-service` | EC2 | KRA tax compliance integration |
| `/shipments` | `shipment-service` | Fargate | Shipment tracking & management |
| `/documents` | `document-upload-service` | EC2 | Document upload & processing |

### **Frontend Application** (`app.duka-platform.com`)

| Path | Service Name | Compute Type | Function |
|------|-------------|--------------|----------|
| `/` | `frontend-service` | Fargate | Main web application UI |

## 🏗️ Service Placement Strategy

### **EC2 Workers** (Performance & Compliance)
- **`api-gateway`** - Central routing, high performance
- **`payments-service`** - PCI compliance, dedicated resources
- **`delivery-service`** - Real-time tracking, consistent performance
- **`kq-flight-cargo-service`** - Heavy processing workloads
- **`kra-integration-service`** - Government compliance requirements
- **`document-upload-service`** - File processing, CPU intensive

### **Fargate** (Auto-scaling & Cost Optimization)
- **`auth-service`** - Variable authentication load
- **`notifications-service`** - Event-driven, burst scaling
- **`customer-support-service`** - Variable support requests
- **`insurance-service`** - Lightweight processing
- **`shipment-service`** - Auto-scaling based on demand
- **`frontend-service`** - Static content serving

## 🔧 Prerequisites

### **1. AWS Load Balancer Controller**
```bash
kubectl apply -f cluster-global-components/ingress/aws-load-balancer-controller.yaml
```

### **2. ACM SSL Certificates**
- Certificate for `*.duka-platform.com`
- Update ARN in both ingress files

### **3. DNS Configuration**
- Point domains to ALB endpoints
- Route53 or external DNS provider

## 📋 Deployment Order

```bash
# 1. Deploy AWS Load Balancer Controller
kubectl apply -f cluster-global-components/ingress/

# 2. Deploy ArgoCD Ingress (after ArgoCD is running)
kubectl apply -f cluster-global-components/argocd/argocd-ingress.yaml

# 3. Deploy Platform Ingress (after microservices are deployed)
kubectl apply -f cluster-global-components/duka-platform-ingress.yaml
```

## 🔍 Verification Commands

### **Check Ingress Resources**
```bash
# List all ingresses
kubectl get ingress --all-namespaces

# Check ArgoCD ingress
kubectl describe ingress argocd-server-ingress -n argocd

# Check Platform ingress
kubectl describe ingress duka-platform-main-ingress -n ingress
```

### **Check ALB Creation**
```bash
# Check ALB controller logs
kubectl logs -n kube-system deployment/aws-load-balancer-controller

# Verify ALB in AWS Console
# EC2 → Load Balancers → Application Load Balancers
```

### **Test Endpoints**
```bash
# Test ArgoCD access
curl -k https://argocd.duka-platform.com/healthz

# Test API endpoints
curl -k https://api.duka-platform.com/auth/health
curl -k https://api.duka-platform.com/payments/health

# Test Frontend
curl -k https://app.duka-platform.com/
```

## 💰 Cost Breakdown

| Component | Monthly Cost | Notes |
|-----------|-------------|-------|
| ArgoCD ALB | ~$16 | Dedicated ALB for ArgoCD |
| Platform ALB | ~$16 | Single ALB for all microservices |
| ACM Certificates | FREE | AWS managed SSL certificates |
| Route53 (optional) | ~$0.50 | Per hosted zone |
| **Total** | **~$32.50** | For complete ingress setup |

## 🔒 Security Features

- **SSL Termination** at ALB level
- **ACM Certificate** auto-renewal
- **WAF Integration** ready
- **Security Groups** control access
- **Private Subnet** protection for services

## 🚨 Important Notes

1. **Update Certificate ARNs** before deployment
2. **Configure DNS** to point to ALB endpoints  
3. **Services must be ClusterIP** type (not LoadBalancer)
4. **Health checks** configured for each service
5. **SSL redirect** enforced (HTTP → HTTPS)

## 🔧 Customization

### **Add New Microservice**
```yaml
# Add to duka-platform-ingress.yaml
- path: /new-service
  pathType: Prefix
  backend:
    service:
      name: new-service-name
      port:
        number: 80
```

### **Change Domains**
Update both ingress files:
- Replace `duka-platform.com` with your domain
- Update certificate ARN for new domain

This setup provides production-ready ingress with SSL, proper routing, and cost optimization!