Get-Content -Path ./temp.plan.json | ConvertFrom-Json
$tfPlan = Get-Content -Path ./temp.plan.json | ConvertFrom-Json
$tfPlan.resource_changes
$tfPlan.resource_changes[3].change.after.subscription_ids
