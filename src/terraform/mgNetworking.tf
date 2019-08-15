variable "mgNetworkingSubscriptions" {
  description = "The subscription lists for each deployment stage"
  default     = null
}

resource "azurerm_management_group" "mgNetworking" {
  display_name               = "Networking"
  parent_management_group_id = data.azurerm_management_group.mgTenantRoot.id
  group_id                   = "Networking"
  subscription_ids           = var.mgNetworkingSubscriptions[var.deploymentStage]
}

# TODO: https://github.com/terraform-providers/terraform-provider-azurerm/issues/3762
# data "azurerm_policy_definition" "test" {
#   display_name        = "test"
#   management_group_id = azurerm_management_group.mgNetworking.id
# }
