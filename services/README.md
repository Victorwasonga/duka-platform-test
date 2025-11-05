# DukQa Platform Services

This directory contains the source code for all DukQa microservices.

## Services

### Core Services
- **auth-service** - Authentication and authorization
- **api-gateway** - Main API gateway and routing
- **frontend-service** - Web portals (B2C, B2B, Admin)
- **payments-service** - Payment processing (Mpesa, Cards)

### Business Services
- **shipment-service** - Shipment management
- **delivery-service** - Last mile delivery
- **insurance-service** - Insurance processing
- **customer-support-service** - Customer support
- **document-upload-service** - Document management
- **kq-flight-cargo-service** - KQ flight cargo integration
- **kra-integration-service** - KRA tax integration
- **notifications-service** - Email/SMS notifications

## Structure

Each service directory contains:
```
service-name/
├── Dockerfile          # Container build instructions
├── package.json        # Dependencies and scripts
├── src/               # Source code
│   └── index.js       # Main application file
└── README.md          # Service-specific documentation
```

## Development

### Local Development
```bash
cd services/<service-name>
npm install
npm run dev
```

### Docker Build
```bash
cd services/<service-name>
docker build -t <service-name> .
```

## CI/CD Integration

Changes to any service in this directory will trigger:
1. **Docker image build**
2. **Push to ECR**
3. **Update deployment manifest**
4. **ArgoCD sync and deployment**

## Monitoring

GitHub Actions workflows monitor changes in:
- `services/<service-name>/**`

When changes are detected, only the affected services are built and deployed.