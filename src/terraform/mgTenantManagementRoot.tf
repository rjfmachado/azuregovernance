//Get reference to the "Tenant Root Group"
data "azurerm_management_group" "mgTenantRoot" {
  group_id = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_role_definition" "roleCustomSupport" {
  name = "Custom Support Agent"
  //Store in the Management Group Root
  scope       = data.azurerm_management_group.mgTenantRoot.id
  description = "Members can create and manage Azure support tickets."

  permissions {
    actions = [
      "Microsoft.Support/*",
      "*/read"
    ]
    not_actions = []
  }

  //Assignable to all Management Groups & Subscriptions
  assignable_scopes = [
    data.azurerm_management_group.mgTenantRoot.id
  ]
}

resource "azurerm_role_assignment" "assAllCustomSupport" {
  scope              = data.azurerm_management_group.mgTenantRoot.id
  role_definition_id = azurerm_role_definition.roleCustomSupport.id
  principal_id       = azuread_group.gAllSupport.id
}

resource "azuread_group" "gAllSupport" {
  name = "All Support"
}