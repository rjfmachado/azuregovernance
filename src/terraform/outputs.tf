output "outSubscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}

output "outTenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}
