variable "mgSandboxSubscriptions" {
  type        = map(list(string))
  description = "The subscriptions linked to the Sandbox Management Group"
  default     = null
}

resource "azurerm_management_group" "mgSandbox" {
  display_name               = "Sandbox Projects"
  parent_management_group_id = data.azurerm_management_group.mgTenantRoot.id
  name                       = "Sandbox"
  subscription_ids           = var.mgSandboxSubscriptions[var.deploymentStage]

  # lifecycle {
  #   ignore_changes = [
  #     # Ignore changes to subscription assignments.
  #     subscription_ids,
  #   ]
  # }
}
