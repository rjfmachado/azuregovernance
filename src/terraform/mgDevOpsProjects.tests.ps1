Describe "DevOpsProjects" {
    Context "Subscription to Assign" {
        It "exists" {
            $subscriptionList = Get-Content ./mgDevOpsProjects.subscriptions.auto.tfvars.json | ConvertFrom-Json
            $subscriptionList.mgDevOpsSubscriptions.prod | ForEach-Object { Get-AzSubscription -SubscriptionId $_ }
            Assertion
        }
    }
}