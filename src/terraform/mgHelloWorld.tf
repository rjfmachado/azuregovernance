resource "azurerm_management_group" "mgHelloWorld" {
  display_name               = "HelloWorld Projects"
  parent_management_group_id = data.azurerm_management_group.mgTenantRoot.id
  group_id                   = "HelloWorld"
  lifecycle {
    ignore_changes = [
      # Ignore changes to subscription assignments.
      subscription_ids,
    ]
  }
}
