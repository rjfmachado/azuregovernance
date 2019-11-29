terraform {
  backend "azurerm" {
    resource_group_name = "terraformState"
  }
  required_version = ">= 0.12.16"
}

variable "client_secret" {
  type        = string
  description = "The service principal client secred for the azurerm/ad client context."
  default     = null
}
variable "client_id" {
  type        = string
  description = "The service principal client id for the azurerm/ad client context."
  default     = null
}
variable "tenant_id" {
  type        = string
  description = "The default tenant for the azurerm client/ad context."
  default     = null
}
variable "subscription_id" {
  type        = string
  description = "The default subscription for the azurerm client context."
  default     = null
}
variable "deploymentStage" {
  type        = string
  description = "dev, qa, prod"
  default     = null
}

data "azurerm_client_config" "current" {
}

provider "azurerm" {
  version         = "~> 1.37.0"
  client_id       = var.client_id
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_secret   = var.client_secret
}

provider "azuread" {
  version       = "~> 0.7.0"
  client_id     = var.client_id
  tenant_id     = var.tenant_id
  client_secret = var.client_secret
}
