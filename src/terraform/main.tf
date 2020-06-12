terraform {
  backend "azurerm" {
    resource_group_name = "terraformState"
  }
  required_version = "~> 0.12.26"
}

variable "deploymentStage" {
  type        = string
  description = "dev, prod"
  default     = null
}

data "azurerm_client_config" "current" {
}

provider "azurerm" {
  version = "~> 2.14"
  features {}
}

provider "azuread" {
  version = "~> 0.10.0"
}
