output "outTenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "outRoleDeploymentManagerAuditor" {
  value = azurerm_role_definition.roleDeploymentManagerAuditor.id
}

output "outRoleCustomSupport" {
  value = azurerm_role_definition.roleCustomSupport.id
}

output "outRoleVMRestarter" {
  value = azurerm_role_definition.roleVMRestarter.id
}
