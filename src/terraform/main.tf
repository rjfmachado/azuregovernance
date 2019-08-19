terraform {
  backend "azurerm" {
    resource_group_name = "terraformState"
  }
  required_version = ">= 0.12"
}

variable "client_secret" {}
variable "client_id" {}
variable "tenant_id" {}
variable "subscription_id" {}
variable "deploymentStage" {
  type        = string
  description = "dev, qa, prod"
  default     = null
}

data "azurerm_client_config" "current" {
}

provider "azurerm" {
  version         = "=1.32.1"
  subscription_id = var.subscription_id
  client_id       = var.client_id
  tenant_id       = var.tenant_id
  client_secret   = var.client_secret
  #skip_provider_registration = true
}

provider "azuread" {
  version       = "=0.5.1"
  client_id     = var.client_id
  tenant_id     = var.tenant_id
  client_secret = var.client_secret
}
