variable "mgManagedProject01Subscriptions" {
  type        = map(list(string))
  description = "The subscriptions linked to the Project 01 Management Group"
  default     = null
}

resource "azurerm_management_group" "mgManagedProject01" {
  display_name               = "My Managed Application Project 01"
  parent_management_group_id = azurerm_management_group.mgManaged.id
  group_id                   = "mgProject01"
  subscription_ids           = var.mgManagedProject01Subscriptions[var.deploymentStage]
}
