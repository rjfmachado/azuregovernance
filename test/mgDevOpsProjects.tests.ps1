Describe "DevOpsProjects" {
    Context "Subscription to Assign" {
        It "exists" {
            $subscriptionList = Get-Content ./mgDevOpsProjects.subscriptions.auto.tfvars.json | ConvertFrom-Json
            $subscriptionList.mgDevOpsSubscriptions.$ENV | ForEach-Object { Get-AzSubscription -SubscriptionId $_ }
            Assertion
        }
    }
}