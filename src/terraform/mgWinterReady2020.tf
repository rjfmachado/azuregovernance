variable "mgWinterReady2020Subscriptions" {
  type        = map(list(string))
  description = "The subscriptions linked to the Shared Services Management Group"
  default     = null
}

resource "azurerm_management_group" "mgWinterReady2020" {
  display_name               = "Winter Ready 2020"
  parent_management_group_id = data.azurerm_management_group.mgTenantRoot.id
  #group_id                   = "winterready"
  #subscription_ids           = var.mgWinterReady2020Subscriptions[var.deploymentStage]
}
