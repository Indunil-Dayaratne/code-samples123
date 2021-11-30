[CmdletBinding()]
param (
    [Parameter()]
    [String]
    [ValidateSet("prd","nonprd")]
    $Environment = "nonprd"
)
BeforeAll {

    terraform init -backend-config=".\backend-config\partial_config_$Environment.tf"
    
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
    It "has valid syntax" {
        $syntaxValid | Should -Be $true
    }
    It "creates a valid plan for <Environment> environment" {
        $planValid | Should -Be $true
    }
}
