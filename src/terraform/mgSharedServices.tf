variable "mgSharedServicesSubscriptions" {
  type        = map(list(string))
  description = "The subscriptions linked to the Shared Services Management Group"
  default     = null
}

resource "azurerm_management_group" "mgSharedServices" {
  display_name               = "Shared Services"
  parent_management_group_id = data.azurerm_management_group.mgTenantRoot.id
  name                       = "sharedServices"
  subscription_ids           = var.mgSharedServicesSubscriptions[var.deploymentStage]
}
