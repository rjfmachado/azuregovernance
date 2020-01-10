resource "azurerm_management_group" "mgSandbox" {
  display_name               = "Sandbox Projects"
  parent_management_group_id = data.azurerm_management_group.mgTenantRoot.id
  group_id                   = "Sandbox"

  lifecycle {
    ignore_changes = [
      # Ignore changes to subscription assignments.
      subscription_ids,
    ]
  }
}
