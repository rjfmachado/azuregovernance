resource "azurerm_management_group" "mgManaged" {
  display_name               = "Managed Projects"
  parent_management_group_id = data.azurerm_management_group.mgTenantRoot.id
  group_id                   = "Managed"
  subscription_ids           = []
}

resource "azurerm_role_assignment" "assManagedProjectsCustomSupport" {
  scope              = azurerm_management_group.mgManaged.id
  role_definition_id = azurerm_role_definition.roleCustomSupport.id
  principal_id       = azuread_group.gManagedProjectsSupport.id
}

resource "azuread_group" "gManagedProjectsSupport" {
  name = "All Support"
}
