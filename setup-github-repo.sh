#!/bin/bash

echo "🚀 Setting up GitHub repository for DukQa Platform..."

# Initialize git if not already done
if [ ! -d ".git" ]; then
    git init
    echo "✅ Git repository initialized"
fi

# Configure git user (update with your details)
git config user.name "Victor Wasonga"
git config user.email "victorwasonga@example.com"

# Add all files
git add .

# Create initial commit
git commit -m "🚀 Initial commit: DukQa Platform with automated cluster deployment

✅ Features included:
- Complete cluster global components
- Automated GitHub Actions workflows
- ArgoCD GitOps setup
- Monitoring stack (Prometheus, Grafana)
- Security and RBAC configurations
- Storage and networking components
- Microservices CI/CD pipelines

🎯 Ready for automated deployment on commit to main branch!"

echo ""
echo "✅ Repository setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Create a GitHub repository (e.g., 'dukqa-platform')"
echo "2. Add the remote origin:"
echo "   git remote add origin https://github.com/YOUR_USERNAME/dukqa-platform.git"
echo "3. Push to GitHub:"
echo "   git push -u origin main"
echo ""
echo "🎉 Once pushed, any commit to main will automatically deploy cluster components!"