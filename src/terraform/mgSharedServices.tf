resource "azurerm_management_group" "mgSharedServices" {
  display_name               = "Shared Services"
  parent_management_group_id = data.azurerm_management_group.mgTenantRoot.id
  group_id                   = "sharedServices"
  subscription_ids           = []
}
