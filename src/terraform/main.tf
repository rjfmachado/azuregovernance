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
  version = "~> 1.4.0"
}

provider "azuread" {
  version = "~> 0.7.0"
}
