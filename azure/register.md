## Appendix: Provider Registration Scripts

### Automated Registration Script

**File**: `scripts/register-providers.sh`

Registers all required resource providers automatically:

```bash
# Make executable (first time only)
chmod +x scripts/register-providers.sh

# Run registration
./scripts/register-providers.sh
```

**What it does:**
- Registers all 8 required providers with `--wait` flag
- Waits for each provider to complete registration
- Verifies final registration status
- Exits with error if any provider fails

**Example output:**
```
[2024-10-16 14:23:15] ZombieScan Provider Registration Script

Subscription:
  Name: Pay-As-You-Go
  ID:   12345678-1234-1234-1234-123456789abc

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[2024-10-16 14:23:16] Registering Microsoft.App (waiting for completion)...
[SUCCESS] Microsoft.App registered successfully
[2024-10-16 14:23:45] Registering Microsoft.ContainerRegistry (waiting for completion)...
[SUCCESS] Microsoft.ContainerRegistry registered successfully
...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Verifying all providers are registered...

  ✓ Microsoft.App: Registered
  ✓ Microsoft.ContainerRegistry: Registered
  ✓ Microsoft.ManagedIdentity: Registered
  ✓ Microsoft.OperationalInsights: Registered
  ✓ Microsoft.Storage: Registered
  ✓ Microsoft.Authorization: Registered
  ✓ Microsoft.Resources: Registered
  ✓ Microsoft.Insights: Registered

[SUCCESS] All providers registered successfully!
```

---

### Pre-Deployment Check Script

**File**: `scripts/check-providers.sh`

Verifies provider registration status before deployment:

```bash
# Make executable (first time only)
chmod +x scripts/check-providers.sh

# Run verification
./scripts/check-providers.sh

# Or chain with deployment
./scripts/check-providers.sh && az deployment group create ...
```

**What it does:**
- Checks registration status of all required providers
- Shows which providers are missing or still registering
- Exits with error code if not ready for deployment
- Safe to run multiple times

**Example output:**
```
[2024-10-16 14:25:30] Checking ZombieScan provider registration status...

Subscription:
  Name: Pay-As-You-Go
  ID:   12345678-1234-1234-1234-123456789abc

Provider Status:
  ✓ Microsoft.App: Registered
  ✓ Microsoft.ContainerRegistry: Registered
  ✓ Microsoft.ManagedIdentity: Registered
  ⏳ Microsoft.OperationalInsights: Registering (in progress)
  ✗ Microsoft.Storage: NotRegistered (action required)
  ✓ Microsoft.Authorization: Registered
  ✓ Microsoft.Resources: Registered
  ✓ Microsoft.Insights: Registered

[ERROR] 1 provider(s) not registered, 1 still registering

ACTION REQUIRED:
Run: ./scripts/register-providers.sh
Or register manually via Azure Portal
```

---

### Provider Cleanup Script (Advanced)

**File**: `scripts/unregister-providers.sh`

**⚠️ WARNING: This is a DESTRUCTIVE operation!**

Unregisters all ZombieScan resource providers to restore subscription to initial state.

```bash
# Make executable (first time only)
chmod +x scripts/unregister-providers.sh

# Run cleanup (requires confirmation)
./scripts/unregister-providers.sh
```

**Use cases:**
- Testing fresh subscription behavior in lab environments
- Cleaning up sandbox/development subscriptions
- Troubleshooting provider-related issues

**⛔ DO NOT USE in production subscriptions!**

**What it does:**
1. Shows detailed warning about impact
2. Requires double confirmation ("UNREGISTER" then "YES")
3. Unregisters all 8 providers with `--wait` flag
4. Verifies unregistration status
5. Shows re-registration instructions

**Safety features:**
- Requires explicit typed confirmations (not just Y/N)
- Shows subscription name and ID before proceeding
- Warns about impact on existing resources
- Provides clear rollback instructions

**After running:**
Your subscription will be in the same state as a new Pay-As-You-Go subscription. Any resources using these providers will become unmanageable until you re-register them.

**To restore functionality:**
```bash
# Re-register providers
./scripts/register-providers.sh

# Or use the portal method described in Step 1
```

---

### All Scripts Summary

| Script | Purpose | Safety | When to Use |
|--------|---------|--------|-------------|
| `register-providers.sh` | Register all providers | ✅ Safe | Before first deployment |
| `check-providers.sh` | Verify registration | ✅ Safe | Before each deployment (optional) |
| `unregister-providers.sh` | Remove all providers | ⚠️ Destructive | Lab/sandbox cleanup only |

**Typical workflow:**
1. **First time**: Run `register-providers.sh`
2. **Before deploy**: Run `check-providers.sh` (optional but recommended)
3. **Deploy**: Use Azure Portal or `az deployment group create`
4. **Cleanup** (lab only): Run `unregister-providers.sh` if needed