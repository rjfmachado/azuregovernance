terraform {
  required_version = "~> 0.13.5"
  backend "azurerm" {
    resource_group_name = "terraformState"
  }
  required_providers {
    azurerm = "~> 2.29.0"
    azuread = "~> 1.0.0"
  }
}

provider "azurerm" {
  features {
    virtual_machine {
      delete_os_disk_on_deletion = true
    }
  }
}

variable "deploymentStage" {
  type        = string
  description = "dev, prod"
  default     = null
}

data "azurerm_client_config" "current" {
}
