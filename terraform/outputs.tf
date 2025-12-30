output "container_app_environment_default_domain" {
  value = azurerm_container_app_environment.main.default_domain
}

output "custom_domain_verification_id" {
  value = azurerm_container_app_environment.main.custom_domain_verification_id
}

output "acr_login_server" {
  value = azurerm_container_registry.main.login_server
}

output "app_urls" {
  value = { for k, v in azurerm_container_app.apps : k => "https://${v.latest_revision_fqdn}" }
}
