variable "mgManagedSubscriptions" {
  type        = map(list(string))
  description = "The subscriptions linked to the Managed Projects Management Group"
  default     = null
}

# Create the Managed Subscriptions Management Group
resource "azurerm_management_group" "mgManaged" {
  display_name               = "Managed Projects"
  parent_management_group_id = data.azurerm_management_group.mgTenantRoot.id
  group_id                   = "Managed"
  #subscription_ids           = var.mgManagedSubscriptions[var.deploymentStage]
}

# Assignment of a Tenant Root Management Group scoped role to a child Management Group
resource "azurerm_role_assignment" "assManagedProjectsCustomSupport" {
  scope              = azurerm_management_group.mgManaged.id
  role_definition_id = azurerm_role_definition.roleCustomSupport.id
  principal_id       = azuread_group.gManagedProjectsSupport.id
}

resource "azuread_group" "gManagedProjectsSupport" {
  name = "Managed Projects Support"
}

resource "azurerm_role_definition" "roleDeploymentManagerAuditor" {
  name        = "Deployment Manager Auditor"
  scope       = azurerm_management_group.mgManaged.id
  description = "Members can read the Deployment Manager configuration."

  permissions {
    actions = [
      "Microsoft.DeploymentManager/*/read"
    ]
    not_actions = []
  }

  //Assignable to all Management Groups & Subscriptions
  assignable_scopes = [
    azurerm_management_group.mgManaged.id
  ]
}
