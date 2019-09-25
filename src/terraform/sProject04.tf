provider "azurerm" {
  alias           = "Project04"
  subscription_id = var.sProject04id[var.deploymentStage]
  client_id       = var.client_id
  tenant_id       = var.tenant_id
  client_secret   = var.client_secret
}

variable "sProject04id" {
  description = "The subscription ids for Project 04 Subscription"
  default     = null
}

data "azurerm_subscription" "sProject04" {
  subscription_id = var.sProject04id[var.deploymentStage]
}

module "subscriptionManagedProject04" {
  providers = {
    azurerm = "azurerm.Project04"
  }
  source                    = "github.com/rjfmachado/azuresubscription/modules/azuresubscription-managed"
  subscriptionId            = data.azurerm_subscription.sProject04.id
  subscriptionName          = "Project 04"
  subscriptionObjectPreffix = "project04"
}
