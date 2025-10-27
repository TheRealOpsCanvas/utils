# ZombieScan - Azure Installation Guide

## Prerequisites
- Azure subscription with: 
   - Access to register the following providers, and install ARM templates
   - Resources to scan (see below)
- Required Resource Providers registered

### Register/Verify Required Resource Providers

New Azure subscriptions require registration for most of the below resource providers below (except Authorization and Resources).

Existing subscriptions often have them already registered, except CostManagementExports.

#### Register via Azure Portal

1. **Go to**: [Azure Portal → Subscriptions](https://portal.azure.com/#view/Microsoft_Azure_Billing/SubscriptionsBlade)
2. **Select** your subscription
3. **Navigate to**: Settings → **Resource providers** (left menu)
4. **Search and register** each of these providers below by clicking **Register**
5. **Wait** until all show status **"Registered"** (usually 1-2 minutes per provider)

   - `Microsoft.App`
   - `Microsoft.Authorization` (registered in new subscriptions)
   - `Microsoft.ManagedIdentity`
   - `Microsoft.Storage`
   - `Microsoft.Insights`
   - `Microsoft.OperationalInsights`
   - `Microsoft.EventGrid`
   - `Microsoft.CostManagementExports`
   - `Microsoft.Web`
   - `Microsoft.AlertsManagement`
   - `Microsoft.Resources` (registered in new subscriptions)

_Use our [register-providers.sh](register-providers.sh) and [check-providers.sh](check-providers.sh) scripts to register and verify via the CLI_

---

## Azure Resources Scanned

ZombieScan analyzes the following Azure resource types to identify zombies:

### Compute Resources
- **Virtual Machines** (`Microsoft.Compute/virtualMachines`)
- **Disks** (`Microsoft.Compute/disks`)
- **Virtual Machine Scale Sets** (`Microsoft.Compute/virtualMachineScaleSets`)

### Network Resources
- **Network Interfaces** (`Microsoft.Network/networkInterfaces`)
- **Public IP Addresses** (`Microsoft.Network/publicIPAddresses`)
- **Network Security Groups** (`Microsoft.Network/networkSecurityGroups`)
- **Load Balancers** (`Microsoft.Network/loadBalancers`)
- **Application Gateways** (`Microsoft.Network/applicationGateways`)

### Storage & Databases
- **Storage Accounts** (`Microsoft.Storage/storageAccounts`)
- **SQL Servers** (`Microsoft.Sql/servers`)
- **SQL Databases** (`Microsoft.Sql/servers/databases`)
- **PostgreSQL Servers** (`Microsoft.DBforPostgreSQL/servers`)
- **Redis Caches** (`Microsoft.Cache/Redis`)
- **Cosmos DB Accounts** (`Microsoft.DocumentDB/databaseAccounts`)

### Application Services
- **App Service Plans** (`Microsoft.Web/serverfarms`)
- **Web Apps** (`Microsoft.Web/sites`)
- **AKS Clusters** (`Microsoft.ContainerService/managedClusters`)
- **Key Vaults** (`Microsoft.KeyVault/vaults`)


## Installed Resource Cost

The following resources and prices are required for ZombieScan functionality

### Installation Components – One-Time

| Component                     | Purpose                                  | Est. Total Cost (USD) | Notes                               |
|------------------------------|------------------------------------------|------------------------|--------------------------------------|
| `trust-config-job`           | Runs once during install                 | ~$0.002               | Lightweight container job            |
| `deployment-complete-job`    | Runs once after config is done           | ~$0.002               | Lightweight container job            |
| `trust-config-script`        | Starts and polls the trust-config job    | ~$0.01                | Temporary script container           |
| `deployment-complete-script` | Starts and polls the complete job        | ~$0.01                | Temporary script container           |
| Event Grid                   | Detects when the resource group is deleted | $0.00               | One-time event trigger               |
| Function App                 | Calls backend on deletion                | $0.00                 | Runs once after install              |
| **Total**                    |                                          |  ~$0.03 - $0.04       | Negligible cost overall              |

### Recurring + Storage Components – Daily Usage

| Component               | Purpose                                   | Est. Monthly Cost (USD) | Notes                                         |
|------------------------|-------------------------------------------|--------------------------|-----------------------------------------------|
| `report-generator`     | Daily reporting container job             | ~$0.06                   | Runs for ~1 minute per day                    |
| Container App Env      | Shared environment for container jobs     | $0.00                    | No charge without advanced features           |
| `cost-storage`         | Stores daily cost files (auto-deletes)    | ~$0.0002                 | Deletes after 90 days                         |
| `report-storage`       | Stores daily reports (grows slowly)       | ~$0.0001 (month 1)       | Remains under $0.01 even after 5 years        |
| **Total**              |                                           |  ~$0.06 - $0.07          | Mostly compute, storage is minimal            |


