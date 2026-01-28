#!/bin/bash
set -e

echo "🚀 Getting Terraform Outputs..."
cd ../azure
# Ensure we have the outputs
terraform refresh > /dev/null

RG_NAME=$(terraform output -raw resource_group_name 2>/dev/null || echo "fast-food-rg")
AKS_NAME=$(terraform output -raw aks_cluster_name 2>/dev/null || echo "fast-food-aks")
COSMOS_CONN=$(terraform output -raw cosmos_connection_string)
POSTGRES_FQDN=$(terraform output -raw postgres_fqdn)
DB_PASS=$(grep "Using DB Pass:" apply.log | tail -n 1 | awk '{print $4}')

# Fallback for DB Pass if not found in log (should have been exported in apply.sh)
if [ -z "$DB_PASS" ]; then
  echo "⚠️ Could not find DB Password in apply.log. Please enter it:"
  read -s DB_PASS
fi

echo "✅ connection details retrieved."

echo "🔑 Getting AKS Credentials..."
az aks get-credentials --resource-group $RG_NAME --name $AKS_NAME --overwrite-existing

echo "📦 Creating Kubernetes Secret 'db-secrets-azure'..."

# Construct connection strings
MONGO_URI="$COSMOS_CONN"
# Postgres URL format: postgresql://USER:PASSWORD@HOST:5432/DB_NAME?sslmode=require
# Note: Azure Postgres username often requires @servername suffix in some SKUs, but Flexible Server usually just uses username.
# Checking Terraform variable for admin user
ADMIN_USER="azureuser"

ORDER_DB_URL="postgresql://$ADMIN_USER:$DB_PASS@$POSTGRES_FQDN:5432/fast_food_production?sslmode=require"
PAYMENT_DB_URL="postgresql://$ADMIN_USER:$DB_PASS@$POSTGRES_FQDN:5432/fast_food_payment?sslmode=require"

kubectl create secret generic db-secrets-azure \
  --from-literal=mongo-uri="$MONGO_URI" \
  --from-literal=order-db-url="$ORDER_DB_URL" \
  --from-literal=payment-db-url="$PAYMENT_DB_URL" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "🎉 Secret 'db-secrets-azure' created successfully!"
kubectl get secret db-secrets-azure
