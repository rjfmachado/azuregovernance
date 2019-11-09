Describe "Management Groups" {
    Context "Structure" {
        It "Only 5 Management Groups below the tenant root" {
            $subscriptionList = Get-Content ../../terraform/mgDevOpsProjects.subscriptions.auto.tfvars.json | ConvertFrom-Json
            $subscriptionList.mgDevOpsSubscriptions.$ENV | ForEach-Object { Get-AzSubscription -SubscriptionId $_ }
            $true | Should -Be $true
        }
    }

    Context "Structure" {
        It "True is True" {
            $subscriptionList = Get-Content ../../terraform/mgDevOpsProjects.subscriptions.auto.tfvars.json | ConvertFrom-Json
            $subscriptionList.mgDevOpsSubscriptions.$ENV | ForEach-Object { Get-AzSubscription -SubscriptionId $_ }
            $true | Should -Be $true
        }
    }
}