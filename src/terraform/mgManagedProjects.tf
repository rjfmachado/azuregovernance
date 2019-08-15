resource "azurerm_management_group" "mgManaged" {
  display_name               = "Managed Projects"
  parent_management_group_id = data.azurerm_management_group.mgTenantRoot.id
  group_id                   = "Managed"
  subscription_ids           = []
}