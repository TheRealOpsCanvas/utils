# ZombieScan Azure Deployment Guide

### Prerequisites
- ✅ Azure subscription with **Owner** access
- ✅ Azure CLI installed ([Install Guide](https://docs.microsoft.com/cli/azure/install-azure-cli))
- ✅ **Required Resource Providers registered** (see below)

### Step 1: Register Required Resource Providers

**⚠️ IMPORTANT:** New Azure subscriptions require resource provider registration before deployment.

#### Option A: Register via Azure Portal (Recommended)

1. **Go to**: [Azure Portal → Subscriptions](https://portal.azure.com/#view/Microsoft_Azure_Billing/SubscriptionsBlade)
2. **Select** your subscription
3. **Navigate to**: Settings → **Resource providers** (left menu)
4. **Search and register** each of these providers by clicking **Register**:
   - `Microsoft.App`
   - `Microsoft.Authorization`
   - `Microsoft.ManagedIdentity`
   - `Microsoft.Storage`
   - `Microsoft.Insights`
   - `Microsoft.OperationalInsights`
   - `Microsoft.EventGrid`
   - `Microsoft.CostManagementExports`
   - `Microsoft.Web`
   - `Microsoft.AlertsManagement`
   - `Microsoft.Resources`
5. **Wait** until all show status **"Registered"** (usually 1-2 minutes per provider)

_Use our [register-providers.sh](register-providers.sh) and [check-providers.sh](check-providers.sh) scripts to register and verify the CLI_


---

## 📊 Azure Resources Scanned

ZombieScan analyzes the following Azure resource types to identify zombies:

### Compute Resources
- 💻 **Virtual Machines** (`Microsoft.Compute/virtualMachines`)
- 💾 **Disks** (`Microsoft.Compute/disks`)
- 📦 **Virtual Machine Scale Sets** (`Microsoft.Compute/virtualMachineScaleSets`)

### Network Resources
- 🔌 **Network Interfaces** (`Microsoft.Network/networkInterfaces`)
- 🌐 **Public IP Addresses** (`Microsoft.Network/publicIPAddresses`)
- 🛡️ **Network Security Groups** (`Microsoft.Network/networkSecurityGroups`)
- ⚖️ **Load Balancers** (`Microsoft.Network/loadBalancers`)
- 🚪 **Application Gateways** (`Microsoft.Network/applicationGateways`)

### Storage & Databases
- 🗄️ **Storage Accounts** (`Microsoft.Storage/storageAccounts`)
- 🗃️ **SQL Servers** (`Microsoft.Sql/servers`)
- 📊 **SQL Databases** (`Microsoft.Sql/servers/databases`)
- 🐘 **PostgreSQL Servers** (`Microsoft.DBforPostgreSQL/servers`)
- 📈 **Redis Caches** (`Microsoft.Cache/Redis`)
- 🌍 **Cosmos DB Accounts** (`Microsoft.DocumentDB/databaseAccounts`)

### Application Services
- 🏗️ **App Service Plans** (`Microsoft.Web/serverfarms`)
- 🌐 **Web Apps** (`Microsoft.Web/sites`)
- ☸️ **AKS Clusters** (`Microsoft.ContainerService/managedClusters`)
- 🔑 **Key Vaults** (`Microsoft.KeyVault/vaults`)

**Total:** 18 resource types monitored for zombie detection.
