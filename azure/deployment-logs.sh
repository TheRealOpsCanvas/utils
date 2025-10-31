# Retrieves the most recent template-based deployment at the subscription level and summarizes its status.  
# If the deployment failed, it lists the specific operations and related error messages for troubleshooting.
deployment_name=$(az deployment sub list \
  --query "max_by([?contains(name, 'Microsoft.Template')], &properties.timestamp).name" \
  -o tsv)

if [ -z "$deployment_name" ]; then
  echo "No Microsoft.Template deployments found."
  exit 0
fi

echo "Most recent template deployment: $deployment_name"

# Show high-level status
az deployment sub show --name "$deployment_name" \
  --query "{status: properties.provisioningState, timestamp: properties.timestamp}" \
  -o yaml

# If failed, show detailed error logs
echo "Error details:"
az deployment operation sub list --name "$deployment_name" \
  --query "[?properties.provisioningState=='Failed'].{OperationName: properties.targetResource.resourceName, Status: properties.statusMessage}" \
  -o jsonc
