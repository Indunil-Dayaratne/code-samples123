[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $Path = "."
)

terraform init -backend=false | out-null
terraform validate | out-null

if ($LASTEXITCODE -ne 0) {
    $validated = $false
} else {
    $validated = $true
}

Describe "Terraform" {
    It "has valid syntax" {
        $validated | Should Be $true
    }
}
