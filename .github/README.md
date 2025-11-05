# GitHub Actions with AWS OIDC Integration

## Overview

This directory contains GitHub Actions workflows that use **OpenID Connect (OIDC)** to securely authenticate with AWS without storing long-lived access keys. This follows AWS security best practices and provides temporary, scoped credentials for CI/CD operations.

## 🔐 Security Benefits of OIDC

### Why OIDC Instead of Access Keys?

| **Access Keys** | **OIDC with IAM Roles** |
|-----------------|-------------------------|
| ❌ Long-lived credentials | ✅ Temporary credentials (1 hour) |
| ❌ Stored in GitHub secrets | ✅ No credentials stored |
| ❌ Manual rotation required | ✅ Automatic rotation |
| ❌ Broad permissions | ✅ Scoped to specific repository |
| ❌ Risk if compromised | ✅ Limited blast radius |

### Security Features:
- **Repository-specific**: Only `dukqa-org/dukqa-platform` can assume the role
- **Branch-specific**: Can be limited to specific branches (main, develop)
- **Time-limited**: Tokens expire automatically after 1 hour
- **Audit trail**: All actions logged in AWS CloudTrail
- **No secrets**: No long-lived credentials stored in GitHub

## 🏗️ Architecture

```
GitHub Actions → GitHub OIDC Provider → AWS STS → Temporary Credentials → AWS Services
```

1. **GitHub Actions** requests a token from GitHub's OIDC provider
2. **AWS STS** validates the token and issues temporary credentials
3. **Temporary credentials** are used to access AWS services
4. **Credentials expire** automatically after the session

## 📁 Workflow Files

### `deploy-global-components.yml`
- **Purpose**: Automatically deploy cluster global components
- **Trigger**: Push to `cluster-global-components/` directory
- **Features**: YAML validation, ordered deployment, testing

### `complete-platform-deployment-iam.yml`
- **Purpose**: Complete platform deployment with IAM roles
- **Trigger**: Manual workflow dispatch
- **Features**: Infrastructure, global components, ArgoCD deployment

## 🚀 Setup Instructions

### Step 1: Deploy OIDC Infrastructure

The OIDC provider and IAM role are defined in `DUKA-IAC-TERRAFORM/github-oidc.tf`:

```bash
cd DUKA-IAC-TERRAFORM
terraform plan -var-file=environments/test.tfvars
terraform apply -var-file=environments/test.tfvars
```

### Step 2: Get the Role ARN

```bash
terraform output github_actions_role_arn
```

**Example output:**
```
arn:aws:iam::746387399274:role/github-actions-dukqa-role
```

### Step 3: Configure GitHub Repository

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add the secret:
   - **Name**: `AWS_GITHUB_ROLE_ARN`
   - **Value**: `arn:aws:iam::746387399274:role/github-actions-dukqa-role`

### Step 4: Update Repository URL (If Different)

If your repository is not `dukqa-org/dukqa-platform`, update the trust policy in `github-oidc.tf`:

```hcl
StringLike = {
  "token.actions.githubusercontent.com:sub" = "repo:YOUR-ORG/YOUR-REPO:*"
}
```

## 🔧 IAM Role Permissions

The GitHub Actions role has the following permissions:

### EKS Cluster Management
- Describe and list EKS clusters and node groups
- Update kubeconfig for cluster access

### Infrastructure Management
- Full EC2, IAM, S3, ECR, and CloudWatch Logs access
- Required for Terraform infrastructure deployment

### Terraform State Management
- S3 bucket access for Terraform state files
- DynamoDB access for state locking

### Security Scope
- **Repository**: Only `dukqa-org/dukqa-platform`
- **Resources**: Scoped to DukQa-specific resources where possible
- **Time**: Temporary credentials (1 hour expiration)

## 🚦 Workflow Usage

### Automatic Deployment
Push changes to trigger automatic deployment:

```bash
# Make changes to global components
git add cluster-global-components/
git commit -m "Update RBAC permissions"
git push origin main

# GitHub Actions automatically deploys changes
```

### Manual Deployment
Use the GitHub Actions UI:

1. Go to **Actions** tab in your repository
2. Select **"Complete Platform Deployment (IAM Role)"**
3. Click **"Run workflow"**
4. Choose options:
   - Environment: `test` or `prod`
   - Deploy infrastructure: `true/false`
   - Deploy global components: `true/false`
   - Deploy ArgoCD: `true/false`

## 🔍 Monitoring and Troubleshooting

### Check Workflow Status
- **GitHub Actions tab**: View real-time workflow execution
- **Workflow logs**: Detailed step-by-step execution logs
- **AWS CloudTrail**: Audit trail of all AWS API calls

### Common Issues

#### ❌ "Error: Could not assume role"
**Cause**: OIDC provider not configured or wrong repository
**Solution**: 
1. Verify OIDC provider exists: `aws iam list-open-id-connect-providers`
2. Check repository name in trust policy
3. Ensure secret `AWS_GITHUB_ROLE_ARN` is set correctly

#### ❌ "Error: Access denied"
**Cause**: IAM role lacks required permissions
**Solution**: 
1. Check IAM role permissions in AWS console
2. Verify resource ARNs in policy statements
3. Test permissions with AWS CLI

#### ❌ "Error: Repository not allowed"
**Cause**: Repository name doesn't match trust policy
**Solution**: Update trust policy condition in `github-oidc.tf`

### Debugging Commands

```bash
# Test role assumption locally
aws sts assume-role \
  --role-arn arn:aws:iam::ACCOUNT:role/github-actions-dukqa-role \
  --role-session-name test-session

# Check OIDC provider
aws iam get-open-id-connect-provider \
  --open-id-connect-provider-arn arn:aws:iam::ACCOUNT:oidc-provider/token.actions.githubusercontent.com

# Verify role permissions
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::ACCOUNT:role/github-actions-dukqa-role \
  --action-names eks:DescribeCluster \
  --resource-arns "*"
```

## 🔄 Workflow Permissions

Each workflow job requires specific permissions:

```yaml
permissions:
  id-token: write    # Required for OIDC token request
  contents: read     # Required to checkout repository code
```

## 🛡️ Security Best Practices

### ✅ Implemented
- **Least privilege**: Role has minimal required permissions
- **Repository scoping**: Only specific repository can assume role
- **Temporary credentials**: Automatic expiration
- **Audit logging**: All actions logged in CloudTrail

### 🔒 Additional Recommendations
- **Branch protection**: Require PR reviews for main branch
- **Environment protection**: Require approvals for production deployments
- **Monitoring**: Set up CloudWatch alarms for unusual activity
- **Regular review**: Audit role permissions quarterly

## 📚 References

- [AWS IAM OIDC Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
- [GitHub OIDC Documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [AWS Security Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)

## 🎯 Summary

This OIDC integration provides:
- **Secure authentication** without storing credentials
- **Automated deployments** with proper validation
- **Audit trail** for compliance and security
- **Scalable CI/CD** for the DukQa platform

Your GitHub Actions workflows now use enterprise-grade security practices! 🔐