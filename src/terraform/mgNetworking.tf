variable "mgNetworkingSubscriptions" {
  description = "The subscriptions linked to Networking Management Group"
  default     = null
}

resource "azurerm_management_group" "mgNetworking" {
  display_name               = "Networking II"
  parent_management_group_id = data.azurerm_management_group.mgTenantRoot.id
  group_id                   = "Networking"
  subscription_ids           = var.mgNetworkingSubscriptions[var.deploymentStage]
}
