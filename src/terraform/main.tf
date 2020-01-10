terraform {
  backend "azurerm" {
    resource_group_name = "terraformState"
  }
  required_version = ">= 0.12.19"
}

variable "deploymentStage" {
  type        = string
  description = "dev, prod"
  default     = null
}

data "azurerm_client_config" "current" {
}

provider "azurerm" {
<<<<<<< HEAD
  version         = "~> 1.36.0"
  client_id       = var.client_id
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_secret   = var.client_secret
}

provider "azuread" {
  version       = "~> 0.6.0"
  client_id     = var.client_id
  tenant_id     = var.tenant_id
  client_secret = var.client_secret
=======
  version = "~> 1.40.0"
}

provider "azuread" {
  version = "~> 0.7.0"
>>>>>>> 4d33a168900f4295ad706215d9e835170f0e667a
}
