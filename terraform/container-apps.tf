resource "azurerm_log_analytics_workspace" "main" {
  name                = "nina-infra-logs"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "main" {
  name                       = "nina-infra-env"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
}

resource "azurerm_user_assigned_identity" "app_identity" {
  location            = azurerm_resource_group.main.location
  name                = "nina-infra-app-identity"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_container_app" "apps" {
  for_each = var.apps

  name                         = "${each.key}-app"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app_identity.id]
  }

  ingress {
    external_enabled           = true
    target_port                = 80
    transport                  = "auto"
    allow_insecure_connections = true

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  registry {
    server   = azurerm_container_registry.main.login_server
    identity = azurerm_user_assigned_identity.app_identity.id
  }

  secret {
    name                = "google-client-id"
    key_vault_secret_id = azurerm_key_vault_secret.google_client_id.id
    identity            = azurerm_user_assigned_identity.app_identity.id
  }
  secret {
    name                = "google-client-secret"
    key_vault_secret_id = azurerm_key_vault_secret.google_client_secret.id
    identity            = azurerm_user_assigned_identity.app_identity.id
  }
  secret {
    name                = "nextauth-url"
    key_vault_secret_id = azurerm_key_vault_secret.nextauth_url.id
    identity            = azurerm_user_assigned_identity.app_identity.id
  }
  secret {
    name                = "nextauth-secret"
    key_vault_secret_id = azurerm_key_vault_secret.nextauth_secret.id
    identity            = azurerm_user_assigned_identity.app_identity.id
  }

  template {
    container {
      name   = "${each.key}-container"
      image  = "${azurerm_container_registry.main.login_server}/nina-${each.key}:${lookup(var.image_tags, each.key, "latest")}"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name        = "GOOGLE_CLIENT_ID"
        secret_name = "google-client-id"
      }
      env {
        name        = "GOOGLE_CLIENT_SECRET"
        secret_name = "google-client-secret"
      }
      env {
        name        = "NEXTAUTH_URL"
        secret_name = "nextauth-url"
      }
      env {
        name        = "NEXTAUTH_SECRET"
        secret_name = "nextauth-secret"
      }
    }
  }

}

resource "azurerm_container_app_custom_domain" "domains" {
  for_each = var.apps

  name                     = "${each.key}.${var.domain_name}"
  container_app_id         = azurerm_container_app.apps[each.key].id
  certificate_binding_type = "SniEnabled"
}

