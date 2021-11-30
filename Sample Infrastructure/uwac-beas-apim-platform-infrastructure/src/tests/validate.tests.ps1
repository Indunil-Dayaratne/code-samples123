[CmdletBinding()]
param (
    [Parameter()]
    [String]
    [ValidateSet("dev","tst", "uat", "stg", "prd")]
    $Environment = "dev"
)

BeforeAll {
    if ($Environment -eq "prd") {
        $backend = ".\backend-config\partial_config_prod.tf"
    } else {
        $backend = ".\backend-config\partial_config_nonprod.tf"
    }

    terraform init -backend-config="$backend"

    if (terraform workspace list | Select-String $Environment) {
        terraform workspace select $Environment
    } else {
        terraform workspace new $Environment
    }
    
    terraform plan -refresh=true -input=false -var-file="./terraform-vars/$Environment.terraform.tfvars" -out=plan

    if (Test-Path plan) {
        $planValid = $true
    } else {
        $planValid = $false
    }
}

Describe "Terraform" {
    It "creates a valid plan for <Environment> environment" {
        $planValid | Should -Be $true
    }
}
