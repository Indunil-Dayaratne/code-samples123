param (
    [Parameter()]
    [String]
    [ValidateSet("dev","tst", "uat", "stg", "prd")]
    $Environment = "dev"
)

BeforeAll   {
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
    
    terraform plan -refresh=true -input=false -var-file="./terraform-vars/$Environment.terraform.tfvars" -out="plan.tfplan"
    
    $planData = terraform show -json plan.tfplan | ConvertFrom-Json
    
    $changes = $planData.resource_changes.Where({$_.change.actions -ne "no-op"}).count
}  

Describe "Infrastructure Configuration" {        
    It "<Environment> environment has not been updated in the portal. Changes: <changes>" {
        $changes | Should -Be 0
    }    
}
