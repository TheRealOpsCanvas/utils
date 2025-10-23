#!/bin/bash
# check-providers.sh
# Verifies all required Azure Resource Providers are registered before deployment

set -e

echo "🔍 Checking Azure Resource Provider registration..."
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

ALL_REGISTERED=true
NEED_REGISTRATION=()

for provider in "${REQUIRED_PROVIDERS[@]}"; do
  status=$(az provider show -n "$provider" --query "registrationState" -o tsv 2>/dev/null)
  
  if [ "$status" == "Registered" ]; then
    echo "✅ $provider: Registered"
  elif [ "$status" == "Registering" ]; then
    echo "⏳ $provider: Registering (in progress)"
    ALL_REGISTERED=false
  else
    echo "❌ $provider: Not registered"
    NEED_REGISTRATION+=("$provider")
    ALL_REGISTERED=false
  fi
done

echo ""

if [ "$ALL_REGISTERED" = false ]; then
  if [ ${#NEED_REGISTRATION[@]} -gt 0 ]; then
    echo "⚠️  Providers need registration. Run these commands:"
    echo ""
    for provider in "${NEED_REGISTRATION[@]}"; do
      echo "az provider register --namespace $provider"
    done
    echo ""
    echo "💡 Or run: ./scripts/register-providers.sh (registers all at once)"
  else
    echo "⏳ Some providers are still registering. Wait 1-2 minutes and try again."
  fi
  exit 1
else
  echo "✅ All required providers are registered!"
  echo "🚀 Ready to deploy ZombieScan!"
  echo ""
  echo "Next step:"
  echo "  az deployment group create --resource-group zombiescan-rg --template-file bicep/main.bicep"
fi
