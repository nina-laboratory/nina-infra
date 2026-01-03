# Azure AD Application for GitHub Actions OIDC
resource "azuread_application" "github_oidc" {
  display_name = "nina-infra-github-actions"
}

# Service Principal for the Application
resource "azuread_service_principal" "github_oidc" {
  client_id = azuread_application.github_oidc.client_id
}

# Federated Credential trusting the GitHub Repo
resource "azuread_application_federated_identity_credential" "github_oidc" {
  application_id = azuread_application.github_oidc.id
  display_name   = "nina-infra-main-branch"
  description    = "Trusts GitHub Action on main branch of nina-laboratory/nina-infra"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:nina-laboratory/nina-infra:ref:refs/heads/main"
}

# Assign AcrPush role to the Service Principal
resource "azurerm_role_assignment" "acr_push" {
  principal_id                     = azuread_service_principal.github_oidc.object_id
  role_definition_name             = "AcrPush"
  scope                            = azurerm_container_registry.main.id
  skip_service_principal_aad_check = true
}
