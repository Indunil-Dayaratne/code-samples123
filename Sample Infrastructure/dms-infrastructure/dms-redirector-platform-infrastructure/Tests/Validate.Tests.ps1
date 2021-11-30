[CmdletBinding()]
param (
    [Parameter()]
    [String]
    [ValidateSet("dev","uat","prd")]
    $Environment = "dev"
)

terraform init -backend=false | Out-Null
terraform validate | Out-Null

if ($LASTEXITCODE -ne 0) {
    $syntaxValid = $false
} else {
    $syntaxValid = $true
}

if ($Environment -eq "prd") {
    $backend = ".\backend-config\partial_config-prod.tf"
} else {
    $backend = ".\backend-config\partial_config-nonprod.tf"
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

Describe "Terraform" {
    It "has valid syntax" {
        $syntaxValid | Should Be $true
    }
    It "creates a valid plan for $Environment environment" {
        $planValid | Should Be $true
    }
}
