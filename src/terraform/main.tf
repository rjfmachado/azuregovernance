terraform {
  required_version = "~> 0.12.26"
  backend "azurerm" {
    resource_group_name = "terraformState"
  }
  required_providers {
    azurerm = "~> 2.14"
    azuread = "~> 0.10"
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
