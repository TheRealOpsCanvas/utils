#!/bin/bash
# register-providers.sh
# Registers all required Azure Resource Providers for ZombieScan deployment

set -e

echo "🔧 Registering Azure Resource Providers for ZombieScan..."
echo ""

REQUIRED_PROVIDERS=(
  "Microsoft.App"
  "Microsoft.Authorization"
  "Microsoft.ManagedIdentity"
  "Microsoft.Storage"
  "Microsoft.Insights"
  "Microsoft.OperationalInsights"
  "Microsoft.EventGrid"
  "Microsoft.CostManagementExports"
  "Microsoft.Web"
  "Microsoft.AlertManagement"
  "Microsoft.Resources"
)

# Check if logged in to Azure
if ! az account show &>/dev/null; then
  echo "❌ Not logged in to Azure. Please run: az login"
  exit 1
fi

SUBSCRIPTION_ID=$(az account show --query id -o tsv)
SUBSCRIPTION_NAME=$(az account show --query name -o tsv)

echo "📍 Subscription: $SUBSCRIPTION_NAME"
echo "🆔 ID: $SUBSCRIPTION_ID"
echo ""

# Register all providers
for provider in "${REQUIRED_PROVIDERS[@]}"; do
  echo "📦 Registering $provider..."
  az provider register --namespace "$provider" --wait &
done

# Wait for all background registrations
wait

echo ""
echo "⏳ Verifying registration status..."
echo ""

ALL_REGISTERED=true

for provider in "${REQUIRED_PROVIDERS[@]}"; do
  status=$(az provider show -n "$provider" --query "registrationState" -o tsv)
  
  if [ "$status" == "Registered" ]; then
    echo "✅ $provider: Registered"
  elif [ "$status" == "Registering" ]; then
    echo "⏳ $provider: Registering (may take 1-2 minutes)"
    ALL_REGISTERED=false
  else
    echo "❌ $provider: $status"
    ALL_REGISTERED=false
  fi
done

echo ""

if [ "$ALL_REGISTERED" = false ]; then
  echo "⚠️  Some providers are still registering. You can:"
  echo "   1. Wait a few minutes and run: ./scripts/check-providers.sh"
  echo "   2. Proceed with deployment (it will wait automatically)"
  echo ""
  echo "💡 Registration typically completes in 1-2 minutes."
else
  echo "✅ All providers registered successfully!"
  echo "🚀 Ready to deploy ZombieScan!"
fi
