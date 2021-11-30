[CmdletBinding()]
param(
    [Parameter()]
    [ValidateScript({Test-Path $_ -PathType Container})]
    [string]
    $ModulePath = ".\Modules",

    [Parameter()]
    [ValidateScript({Test-Path $_ -PathType Container})]
    [string]
    $TestPath = ".\Tests"
)

$modules = Get-ChildItem $ModulePath -Directory

$results = @()
$results += . "$TestPath\ValidateModules.ps1" -ModulePath $ModulePath -TestPath $TestPath

foreach ($module in $modules) {
    Describe "$($module.Name)" {
        It "has valid syntax" {
            $results[$results.Module.IndexOf($module.Name)].Validated | Should Be $true
        }
    }
}
