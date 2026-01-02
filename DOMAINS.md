# Custom Domains Configuration

This document outlines the setup for matching `*.ninalabs.de` domains to Azure Container Apps (`nina-fit`, `nina-journal`, `nina-quick`).

## 1. DNS Configuration (Squarespace)

Before applying Terraform, you must verify domain ownership.

**Records Required:**

| Host | Type | Purpose | Value |
|------|------|---------|-------|
| `asuid.fit` | TXT | Verification | `<CUSTOM_DOMAIN_VERIFICATION_ID>` |
| `fit` | CNAME | Routing | `fit-app-<...>.azurecontainerapps.io` |
| `asuid.journal` | TXT | Verification | `<CUSTOM_DOMAIN_VERIFICATION_ID>` |
| `journal` | CNAME | Routing | `journal-app-<...>.azurecontainerapps.io` |
| `asuid.quick` | TXT | Verification | `<CUSTOM_DOMAIN_VERIFICATION_ID>` |
| `quick` | CNAME | Routing | `quick-app-<...>.azurecontainerapps.io` |

**How to get the Verification ID:**
```bash
terraform output custom_domain_verification_id
```

## 2. Terraform Configuration

We use `azurerm_container_app_custom_domain` to bind the domains.

**Critical Settings:**
- `certificate_binding_type = "Auto"`: This enables Azure Managed Certificates. (Old value "Managed" is deprecated/buggy).
- `allow_insecure_connections = true`: Enabled on the Container App ingress to prevent redirect loops or failures while the certificate is being issued.

## 3. Troubleshooting & Manual Steps

### Issue: "Resource already exists" (Stuck State)
If Terraform fails saying the custom domain resource already exists (even after a destroy), the binding might be stuck in Azure.

**Fix:** Delete the hostname manually using Azure CLI.
```bash
az containerapp hostname delete --name <APP_NAME> --resource-group nina-labs --hostname <DOMAIN> --yes
# Example:
# az containerapp hostname delete --name fit-app --resource-group nina-labs --hostname fit.ninalabs.de --yes
```

### Issue: Certificate not issuing / HTTPS failing
If Terraform applies but the certificate stays pending or HTTPS doesn't work, you can force the binding manually.

**Fix:** Use `az containerapp hostname bind` with validation.
```bash
az containerapp hostname bind -n <APP_NAME> -g nina-labs --hostname <DOMAIN> --environment nina-infra-env --validation-method CNAME
# Example:
# az containerapp hostname bind -n journal-app -g nina-labs --hostname journal.ninalabs.de --environment nina-infra-env --validation-method CNAME
```

### Verification Commands

**Check DNS Propagation:**
```bash
dig txt asuid.fit.ninalabs.de
dig cname fit.ninalabs.de
```

**Check Connectivity:**
```bash
curl -I http://fit.ninalabs.de
curl -I https://fit.ninalabs.de
```

**Check Certificate Status:**
```bash
az containerapp hostname list --name fit-app --resource-group nina-labs
```
