#!/bin/bash
set -e

APP_NAME="FastFoodGitHubActions"
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

echo "🚀 Setting up GitHub Secrets for Azure..."
echo "Subscription ID: $SUBSCRIPTION_ID"

# 1. Create Service Principal
echo "🔑 Creating Service Principal '$APP_NAME'..."
# Using --sdk-auth to get the JSON format needed for AZURE_CREDENTIALS
CREDS_JSON=$(az ad sp create-for-rbac --name "$APP_NAME" --role contributor --scopes /subscriptions/$SUBSCRIPTION_ID --sdk-auth)

CLIENT_ID=$(echo $CREDS_JSON | jq -r .clientId)
CLIENT_SECRET=$(echo $CREDS_JSON | jq -r .clientSecret)
TENANT_ID=$(echo $CREDS_JSON | jq -r .tenantId)

echo "✅ Service Principal created."

# 2. Set Secrets
REPOS=("fast-food-infra" "fast-food-catalog" "fast-food-order" "fast-food-payment")

for REPO in "${REPOS[@]}"; do
  REPO_DIR="../$REPO"
  
  if [ -d "$REPO_DIR" ]; then
    echo "📂 Configuring secrets for $REPO..."
    pushd "$REPO_DIR" > /dev/null
    
    # AZURE_CREDENTIALS (Used by azure/login@v1)
    echo "$CREDS_JSON" | gh secret set AZURE_CREDENTIALS --app actions
    
    # For Infra repo, we also need individual vars for Terraform
    # (Note: Terraform can also use AZURE_CREDENTIALS if configured via environment vars, 
    # but our workflow infra-deploy.yml uses these specific secrets)
    if [ "$REPO" == "fast-food-infra" ]; then
      echo "   - Setting DB_PASSWORD (placeholder)"
      # Generate a random password for DB if not exists
      echo "SecureP@ssw0rd123!" | gh secret set DB_PASSWORD --app actions
      
      echo "   - Setting Terraform ARM_ vars"
      echo "$CLIENT_ID" | gh secret set AZURE_CLIENT_ID --app actions
      echo "$CLIENT_SECRET" | gh secret set AZURE_CLIENT_SECRET --app actions
      echo "$SUBSCRIPTION_ID" | gh secret set AZURE_SUBSCRIPTION_ID --app actions
      echo "$TENANT_ID" | gh secret set AZURE_TENANT_ID --app actions
    fi
    
    popd > /dev/null
  else
    echo "⚠️ Directory $REPO_DIR not found, skipping..."
  fi
done

echo "🎉 All secrets configured successfully!"
echo "You can now push to main to trigger deployments."
