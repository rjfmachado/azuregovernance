resource "azurerm_management_group" "mgManaged" {
  display_name               = "Managed Projects"
  parent_management_group_id = data.azurerm_management_group.mgTenantRoot.id
  group_id                   = "Managed"
  subscription_ids           = []
}

# Assignment of a tenant root scoped role to a child management group
resource "azurerm_role_assignment" "assManagedProjectsCustomSupport" {
  scope              = azurerm_management_group.mgManaged.id
  role_definition_id = azurerm_role_definition.roleCustomSupport.id
  principal_id       = azuread_group.gManagedProjectsSupport.id
}

resource "azuread_group" "gManagedProjectsSupport" {
  name = "Managed Projects Support"
}

resource "azurerm_role_definition" "roleDeploymentManagerAuditor" {
  name = "Deployment Manager Auditor"
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