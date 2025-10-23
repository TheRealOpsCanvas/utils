#!/usr/bin/env bash
# filepath: /Users/wyn/dev/opscanvas/gitlab/opsrunner/tools/application/environment/aws/zombiescan-arm-templates/scripts/unregister-providers.sh
set -euo pipefail

# ZombieScan Provider Cleanup Script
# Unregisters all resource providers to restore subscription to initial state
# WARNING: This will affect ALL resources using these providers in the subscription

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
  "Microsoft.Resources"
)

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

error() {
  echo "[ERROR] $*" >&2
  exit 1
}

check_prerequisites() {
  command -v az &> /dev/null || error "Azure CLI not found"
  az account show &> /dev/null || error "Not logged in to Azure. Run: az login"
}

confirm_action() {
  local subscription_name subscription_id
  subscription_name=$(az account show --query name -o tsv)
  subscription_id=$(az account show --query id -o tsv)
  
  cat <<EOF

WARNING: DESTRUCTIVE OPERATION

This will UNREGISTER the following resource providers:
$(printf "  • %s\n" "${REQUIRED_PROVIDERS[@]}")

IMPACT:
• Resources using these providers will become unmanageable
• ZombieScan and similar services will stop working
• Use only for lab/sandbox environments

Subscription: ${subscription_name} (${subscription_id})

EOF

  read -p "Type 'UNREGISTER' to confirm: " confirmation
  [[ "$confirmation" == "UNREGISTER" ]] || error "Confirmation failed"
  
  read -p "Type 'YES' to proceed: " final_confirmation
  [[ "$final_confirmation" == "YES" ]] || error "Final confirmation failed"
}

unregister_provider() {
  local provider=$1
  local status
  
  status=$(az provider show --namespace "$provider" --query registrationState -o tsv 2>/dev/null || echo "NotRegistered")
  
  case "$status" in
    "Registered")
      log "Unregistering ${provider}..."
      az provider unregister --namespace "$provider" --wait 2>/dev/null || return 1
      ;;
    "NotRegistered")
      log "${provider} - Already unregistered"
      ;;
    "Unregistering")
      log "${provider} - Already unregistering"
      ;;
    *)
      log "${provider} - Unknown state: ${status}"
      ;;
  esac
  return 0
}

verify_unregistration() {
  log "Verifying provider states..."
  
  local all_unregistered=true
  for provider in "${REQUIRED_PROVIDERS[@]}"; do
    local status
    status=$(az provider show --namespace "$provider" --query registrationState -o tsv 2>/dev/null || echo "NotRegistered")
    echo "  ${provider}: ${status}"
    [[ "$status" == "Registered" ]] && all_unregistered=false
  done
  
  if [[ "$all_unregistered" == true ]]; then
    log "All providers unregistered successfully"
    return 0
  else
    error "Some providers failed to unregister"
  fi
}

show_reregistration() {
  cat <<EOF

Provider unregistration complete.

To re-enable ZombieScan:
  1. Portal: https://portal.azure.com → Subscriptions → Resource providers
  2. CLI: ${SCRIPT_DIR}/register-providers.sh
  3. Deploy: ARM template will auto-register (5-10 min delay)

EOF
}

main() {
  log "ZombieScan Provider Cleanup Script"
  
  check_prerequisites
  confirm_action
  
  local failed=0
  for provider in "${REQUIRED_PROVIDERS[@]}"; do
    unregister_provider "$provider" || ((failed++))
  done
  
  if [[ $failed -eq 0 ]]; then
    verify_unregistration
    show_reregistration
  else
    error "$failed provider(s) failed to unregister"
  fi
}

main