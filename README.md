# Azure Governance with Terraform

[![Build Status](https://dev.azure.com/rjfmachado/azuredemos/_apis/build/status/governance/release/azure.governance.envrelease?branchName=release%2Fr8)](https://dev.azure.com/rjfmachado/azuredemos/_build/latest?definitionId=60&branchName=release%2Fr8)

This repo contains samples for using Terraform 0.13 to deploy and manage Azure Governance related resources using GitHub/Azure Devops and is configured to:

* [x] Support multiple Azure AD Tenants in a multistage pipeline - Currently dev and prod, but designed to support easy addition of more stages.
* [x] Azure Pipelines YAML templates for common tasks.
* [x] Use of containers to support required tooling version pinning.
  * [ ] Extend usage of container for dev scenarios with Visual Studio Code
* [ ] Implement Azure Governance Resources
  * [x] Subscription assignment to Management Groups
  * [x] Support for external management of Subscription Assignment via lifecycle/ignore_changes
  * [x] Custom Role Based Access Control definitons scoped to Management Groups, Subscriptions and Resource Groups [#4847](https://github.com/terraform-providers/terraform-provider-azurerm/issues/4847).
  * [x] Role Based Access Control assignments with builtin and custom roles to Management Groups, Subscriptions and Resource Groups.
  * [ ] Azure Policy definitions scoped to Management Groups
  * [ ] Azure Policy assignments to Management Groups [#3762](https://github.com/terraform-providers/terraform-provider-azurerm/issues/3762)
  * [ ] Add a scenario with Tags
  * [ ] Add a scenario for DeployIfNotExists and Managed Service Identities.
  * [ ] Add Blueprints definitions/assignments
* [ ] Add Azure DevOps custom dashboard with relevant visuals
* [ ] Add azure dashboard [azurerm_dashboard](https://www.terraform.io/docs/providers/azurerm/r/dashboard.html)
* [ ] Improve deployment safety
  * [x] Added Scheduled plan pipeline
  * [ ] Notify on pipeline failure
  * [x] Add pull request pipeline
  * [ ] Add tflint, investigate terratest
  * [ ] Add tests to pull request pipeline
  * [ ] Add Environments, approvals and checks
  * [ ] Monitor secret age and alert.
* [ ] Add Security Center configuration
* [ ] Cost Management
  * [ ] [Budgets](https://github.com/terraform-providers/terraform-provider-azurerm/issues/2677)
* [ ] Documentation
  * [ ] Improve [setup guidance](docs/setup.md) & automation
* [ ] Add Azure AD custom roles
* [ ] Custom Roles for App registration
* [ ] Operations scenarios
  * [ ] Connect Activity Log to Workspace
  * [ ] Connect Azure AD Logs
  * [ ] Add Azure Monitor
  * [ ] Action Groups & Alerts
* [ ] Terraform
  * [x] Maintain Terraform state with the azurerm storage account backend.
  * [ ] Add Terraform graph and GraphViz support, review terraform-docs
  * [ ] Add a provisioners/connections scenario
  * [ ] Verify usage of *dynamic* block
* [ ] Enterprise Scale
  * [ ] Review <https://github.com/terraform-azurerm-modules/terraform-azurerm-azopsreference>

## Setup

Setup [guidance](docs/setup.md) is work in progress and most steps are capable of automation with az cli and the azure-devops extension.

> Note: the Repo contains IDs for tenants/subscriptions related to my test/demo infrastructure.
