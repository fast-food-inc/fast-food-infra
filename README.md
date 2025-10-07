# Fast Food Infrastructure as Code

## 🏗️ Overview

This repository contains **Infrastructure as Code (IAC)** for the Fast Food application, providing AWS infrastructure components using Terraform.

## 🎯 Purpose

- **Infrastructure provisioning only** - No application deployment
- **AWS resources** - EKS, Cognito, Lambda, API Gateway, IAM, Secrets Manager
- **Modular design** - Reusable Terraform modules
- **CI/CD ready** - GitHub Actions for automated deployment

## 📁 Structure

```
fast-food-infra/
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── modules/                   # Reusable Terraform modules
│   ├── cognito/              # Cognito User Pool + Client
│   ├── lambda/                # Lambda function infrastructure
│   ├── api_gateway/          # HTTP API Gateway
│   ├── iam/                  # IAM roles and policies
│   ├── secrets/              # AWS Secrets Manager
│   └── eks/                  # EKS cluster + node groups
└── .github/workflows/        # CI/CD pipelines
```

## 🚀 Usage

### Prerequisites
- AWS CLI configured
- Terraform >= 1.6.0
- AWS credentials with appropriate permissions

### Deployment

1. **Configure variables** in `terraform.tfvars`:
```hcl
aws_region = "us-east-1"
cognito_user_pool_name = "fast-food-auth-user-pool"
lambda_package_path = "path/to/lambda.zip"  # Provided by CI/CD
```

2. **Deploy infrastructure**:
```bash
terraform init
terraform plan
terraform apply
```

### CI/CD Pipeline

The repository includes GitHub Actions workflow that:
- ✅ Validates Terraform configuration
- 📋 Creates execution plans
- 🚀 Deploys infrastructure (on main branch)
- 🔒 Uses environment protection

## 🏗️ Infrastructure Components

- **Amazon EKS** - Kubernetes cluster for containerized applications
- **AWS Cognito** - User authentication and management
- **AWS Lambda** - Serverless functions (infrastructure only)
- **API Gateway** - HTTP API endpoints
- **IAM** - Roles and policies for secure access
- **Secrets Manager** - Secure storage for sensitive data

## 🔒 Security

- **Least privilege** IAM policies
- **Secrets management** via AWS Secrets Manager
- **Environment separation** (dev/staging/prod)
- **Local state management** for development

## 📦 State Management

### **Development (Current)**
- Uses **local state** for simplicity
- State file stored locally in `terraform.tfstate`

### **Production (Recommended)**
- **Remote state** with S3 backend
- **DynamoDB locking** to prevent conflicts
- **State encryption** enabled
- **Team collaboration** supported

### **Setting Up Remote State**

1. **Create S3 bucket** for state storage:
```bash
aws s3 mb s3://your-terraform-state-bucket
```

2. **Create DynamoDB table** for locking:
```bash
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

3. **Configure backend** in `main.tf`:
```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "fast-food-infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

4. **Migrate state**:
```bash
terraform init -migrate-state
```

## 📝 Notes

- **Application deployment** is handled by separate repositories
- **Lambda packages** must be provided by external CI/CD pipelines
- **Kubernetes applications** are deployed separately to the EKS cluster
