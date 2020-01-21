variable "mgDevOpsSubscriptions" {
  type        = map(list(string))
  description = "The subscriptions linked to the DevOps Management Group"
  default     = null
}

# Create the DevOps Subscriptions Management Group
resource "azurerm_management_group" "mgDevOps" {
  display_name               = "DevOps Projects"
  parent_management_group_id = data.azurerm_management_group.mgTenantRoot.id
  group_id                   = "DevOps"
  subscription_ids           = var.mgDevOpsSubscriptions[var.deploymentStage]
}
