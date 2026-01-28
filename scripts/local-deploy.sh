#!/bin/bash
set -e

echo "🚀 Starting Local Deployment..."

# 1. Build Images
echo "📦 Building Docker Images..."
# Assuming we are running this from git/fiap/fast-food-infra
# We need to jump to sibling directories

cd ../fast-food-catalog
docker build -t fast-food-catalog:local .
cd ../fast-food-order
docker build -t fast-food-order:local .
cd ../fast-food-payment
docker build -t fast-food-payment:local .

cd ../fast-food-infra

# 2. Infra
echo "🏗️ Applying Infrastructure..."
kubectl apply -f k8s/local/secrets.yaml
kubectl apply -f k8s/local/mongodb.yaml
kubectl apply -f k8s/local/postgres.yaml

echo "⏳ Waiting for databases to be ready..."
kubectl wait --for=condition=available --timeout=60s deployment/fast-food-mongodb
kubectl wait --for=condition=available --timeout=60s deployment/fast-food-postgres

echo "✅ Local Infrastructure Ready!"

# 3. Apps
echo "🚀 Deploying Apps..."
kubectl apply -f k8s/local/catalog.yaml
kubectl apply -f k8s/local/order.yaml
kubectl apply -f k8s/local/payment.yaml

echo "⏳ Waiting for apps to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/fast-food-catalog
kubectl wait --for=condition=available --timeout=120s deployment/fast-food-order
kubectl wait --for=condition=available --timeout=120s deployment/fast-food-payment

echo "🎉 All Systems Go!"
echo "Catalog: http://localhost:30000"
echo "Order:   http://localhost:30002"
echo "Payment: http://localhost:30004"
