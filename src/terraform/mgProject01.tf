variable "mgManagedProject01Subscriptions" {
  description = "The subscription lists for each deployment stage"
  default     = null
}

resource "azurerm_management_group" "mgManagedProject01" {
  display_name               = "My Managed Application Project"
  parent_management_group_id = azurerm_management_group.mgManaged.id
  group_id                   = "mgProject01"
  subscription_ids           = var.mgManagedProject01Subscriptions[var.deploymentStage]
}
