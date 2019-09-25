provider "azurerm" {
  alias           = "Project01"
  subscription_id = var.sProject01id[var.deploymentStage]
  client_id       = var.client_id
  tenant_id       = var.tenant_id
  client_secret   = var.client_secret
}

variable "sProject01id" {
  description = "The subscription ids for Project 01 Subscription"
  default     = null
}

data "azurerm_subscription" "sProject01" {
  subscription_id = var.sProject01id[var.deploymentStage]
}

# module "subscriptionManagedProject01" {
#   providers = {
#     azurerm = "azurerm.Project01"
#   }
#   source                    = "github.com/rjfmachado/azuresubscription/modules/azuresubscription-managed"
#   subscriptionId            = data.azurerm_subscription.sProject01.id
#   subscriptionName          = "Project 01"
#   subscriptionObjectPreffix = "project01"
#   depends_on = [
#     roleDeploymentManagerAuditor,
#     roleCustomSupport
#   ]
# }
