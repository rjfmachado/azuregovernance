Describe "Tenant Root Management Group" {
    Context "Subscriptions are assigned" {
        It "exists" {
            $subscriptionList = Get-Content ../src/terraform/mgDevOpsProjects.subscriptions.auto.tfvars.json | ConvertFrom-Json
            $subscriptionList.mgDevOpsSubscriptions.$ENV | ForEach-Object { Get-AzSubscription -SubscriptionId $_ }
            $true | Should -Be $true
        }
    }
}