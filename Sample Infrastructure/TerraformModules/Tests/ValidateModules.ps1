[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [ValidateScript({Test-Path $_ -PathType Container})]
    [string]
    $ModulePath,

    [Parameter(Mandatory)]
    [ValidateScript({Test-Path $_ -PathType Container})]
    [string]
    $TestPath
)

function Test-Module {
    [Cmdletbinding()]
    param (
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [alias("Module")]
        [string[]]
        $Name,

        [Parameter(Mandatory)]
        [ValidateScript({Test-Path $_ -PathType Container})]
        [string]
        $ModulePath,

        [Parameter(Mandatory)]
        [ValidateScript({Test-Path $_ -PathType Container})]
        [string]
        $TestPath
    )

    begin {
        if (Test-Path temp -PathType Container) {
            Get-childItem temp | Remove-Item -Recurse
        } else {
            New-Item temp -ItemType Directory | Out-Null
        }
    }

    process {
        foreach ($module in $Name) {
            Get-ChildItem "$ModulePath\$module" | Copy-Item -Destination temp
            Copy-Item "$TestPath\$module\main.tf" -Destination temp

            $tempFiles = Get-ChildItem temp
            foreach ($file in $tempFiles) {
                $content = Get-Content $file.FullName
                $content = $content.Replace("path.module","path.root")
                Set-Content $file.FullName -Value $content
            }

            Push-Location temp
            terraform init | Out-Null
            terraform validate | Out-Null
            Pop-Location
            Get-ChildItem temp | Remove-Item -Recurse

            if ($LASTEXITCODE -ne 0) {
                $validated = $false
            } else {
                $validated = $true
            }

            Write-Output ([PSCustomObject]@{
                Module = $module
                Validated = $validated
            })
        }
    }

    end {
        Remove-Item temp -Recurse
    }
}

$modules = Get-ChildItem $ModulePath -Directory
$results = @()

$results += Test-Module -Name $modules.Name -ModulePath $ModulePath -TestPath $TestPath

Write-Output $results
