//Get reference to the "Tenant Root Management Group"
data "azurerm_management_group" "mgTenantRoot" {
  name = data.azurerm_client_config.current.tenant_id
}

//Custom role definition scoped to tenant root management group
resource "azurerm_role_definition" "roleCustomSupport" {
  name        = "Custom Support Agent"
  scope       = data.azurerm_management_group.mgTenantRoot.id
  description = "Members can create and manage Azure support tickets."

  permissions {
    actions = [
      "Microsoft.Support/*",
      "*/read",
      "Microsoft.Resources/*"
    ]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_management_group.mgTenantRoot.id
  ]
}

data "azuread_domains" "aad_domains" {
  only_default = true
}

data "azuread_user" "example" {
  user_principal_name = "ricardo@${data.azuread_domains.aad_domains.domains[0].domain_name}"
}

//Group to target with role assigment
resource "azuread_group" "gAllSupport" {
  name = "All Support"
  members = [
    data.azuread_user.example.object_id
  ]
}

//Custom Role assignment to Tenant Root Management Group
resource "azurerm_role_assignment" "assAllCustomSupport" {
  scope              = data.azurerm_management_group.mgTenantRoot.id
  role_definition_id = azurerm_role_definition.roleCustomSupport.id
  principal_id       = azuread_group.gAllSupport.id
}

//Get a built-in policy definition
data "azurerm_policy_definition" "polAllowedLocations" {
  display_name = "Allowed locations"
}

//Assign builtin policy "Allowed locations" to Root Management Group
resource "azurerm_policy_assignment" "polassAllowedLocations" {
  name                 = "polassP0165"
  display_name         = "P0165 - Data Residency - Allowed Regions"
  scope                = data.azurerm_management_group.mgTenantRoot.id
  policy_definition_id = data.azurerm_policy_definition.polAllowedLocations.id
  parameters           = <<PARAMETERS
{
  "listOfAllowedLocations": {
    "value": [
      "West Europe",
      "North Europe"
     ]
  }
}
PARAMETERS
}

//Get a built-in policy definition
data "azurerm_policy_definition" "polAuditStorageAccountSSL" {
  display_name = "Secure transfer to storage accounts should be enabled"
}

//Assign builtin policy "Allowed locations" to Root Management Group
resource "azurerm_policy_assignment" "polassAuditStorageAccountSSL" {
  name                 = "polassP0001"
  display_name         = "P0001 - Audit Storage Account encryption in transit"
  scope                = data.azurerm_management_group.mgTenantRoot.id
  policy_definition_id = data.azurerm_policy_definition.polAuditStorageAccountSSL.id
  parameters           = <<PARAMETERS
{
  "effect": {
    "value": "Audit"
  }
}
PARAMETERS
}
