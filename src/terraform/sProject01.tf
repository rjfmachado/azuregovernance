provider "azurerm" {
  alias           = "Project01"
  subscription_id = var.sProject01id[var.deploymentStage]
  client_id       = var.client_id
  tenant_id       = var.tenant_id
  client_secret   = var.client_secret
}

variable "sProject01id" {
  description = "The subscription id for Project 01 Subscription"
  default     = null
}

data "azurerm_subscription" "sProject01" {
  subscription_id = var.sProject01id[var.deploymentStage]
}

resource "azuread_group" "gProject01Support" {
  name = "Project 01 Support"
}

resource "azuread_group" "gProject01VMOperators" {
  name = "Project 01 VMOperators"
}

resource "azuread_group" "gProject01Auditors" {
  name = "Project 01 Auditors"
}

resource "azuread_group" "gProject01DeploymentAuditors" {
  name = "Project 01 Deployment Auditors"
}

# Assignment of a Management Group scoped role to a subscription
resource "azurerm_role_assignment" "assProject01CustomSupport" {
  provider           = "azurerm.Project01"
  scope              = data.azurerm_subscription.sProject01.id
  role_definition_id = azurerm_role_definition.roleCustomSupport.id
  principal_id       = azuread_group.gProject01Support.id
}

# Assignment of a Child Management Group scoped role to a subscription
resource "azurerm_role_assignment" "assProject01DeploymentAuditor" {
  provider           = "azurerm.Project01"
  scope              = data.azurerm_subscription.sProject01.id
  role_definition_id = azurerm_role_definition.roleDeploymentManagerAuditor.id
  principal_id       = azuread_group.gProject01DeploymentAuditors.id
}

# Assignment of a subscription scoped Role scoped to a subscription
resource "azurerm_role_assignment" "assProject01VMRestarter" {
  provider           = "azurerm.Project01"
  scope              = data.azurerm_subscription.sProject01.id
  role_definition_id = azurerm_role_definition.roleVMRestarter.id
  principal_id       = azuread_group.gProject01VMOperators.id
}

# Assignment of a built in role to a subscription
resource "azurerm_role_assignment" "assProject01Auditors" {
  provider             = "azurerm.Project01"
  scope                = data.azurerm_subscription.sProject01.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.gProject01Auditors.id
}

# Role Definition scoped to subscription
resource "azurerm_role_definition" "roleVMRestarter" {
  provider    = "azurerm.Project01"
  name        = "VM Restart"
  scope       = data.azurerm_subscription.sProject01.id
  description = "Members can restart Virtual Machines."

  permissions {
    actions = [
      "Microsoft.Compute/virtualMachines/start/action",
      "Microsoft.Compute/virtualMachines/powerOff/action",
      "Microsoft.Compute/virtualMachines/restart/action",
      "*/read"
    ]
    not_actions = []
  }

  //Assignable to all Management Groups & Subscriptions
  assignable_scopes = [
    data.azurerm_subscription.sProject01.id
  ]
}

resource "azurerm_resource_group" "rgTestRBACAssignment" {
  provider = "azurerm.Project01"
  name     = "testrbacassignment"
  location = "West Europe"
}

# Assignment of a Management Group scoped role to a Resource Group
resource "azurerm_role_assignment" "assTestCustomSupport" {
  provider           = "azurerm.Project01"
  scope              = azurerm_resource_group.rgTestRBACAssignment.id
  role_definition_id = azurerm_role_definition.roleCustomSupport.id
  principal_id       = azuread_group.gProject01Support.id
}

# Assignment of a Subscription scoped role to a Resource Group
resource "azurerm_role_assignment" "assTestVMRestarter" {
  provider           = "azurerm.Project01"
  scope              = azurerm_resource_group.rgTestRBACAssignment.id
  role_definition_id = azurerm_role_definition.roleVMRestarter.id
  principal_id       = azuread_group.gProject01VMOperators.id
}

# Assignment of a built-in role to a resource group
resource "azurerm_role_assignment" "assTest01Auditors" {
  provider             = "azurerm.Project01"
  scope                = azurerm_resource_group.rgTestRBACAssignment.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.gProject01Auditors.id
}