# TODO: Azure Governance with Terraform - Lessons learned

## Design

## Single tenant vs Multiple tenants

## Cloud Custodian vs Customers

## Leveraging terraform features

### lifecycle block

ignore_changes

## Deployment resiliency

No matter how much testing you do, some things really just fail when running agains the live API.
Develop processes that allow shift right deployment, strong runtime versioning for dev, test and prod.
With the Governance structure, there is no A/B, blue/green, staged rollout.

### PR builds

### Ops Builds

## Decoupling dependencies

Shared services for state, logging

## Decoupling subscription configuration

Originally in the same repo and leveraging implicit dependencies...
...but moving Subscription configuration to a module to enable scale caused failures in deployments...
as modules do not handle explicit (depends_on) or implicit dependencies. so they can fail when referencing objects that are in the code, but not created.