# Create the Managed Subscriptions Management Group
resource "azurerm_management_group" "mgDevOps" {
  display_name               = "DevOps Projects"
  parent_management_group_id = data.azurerm_management_group.mgTenantRoot.id
  group_id                   = "DevOps"
  subscription_ids           = []
}
