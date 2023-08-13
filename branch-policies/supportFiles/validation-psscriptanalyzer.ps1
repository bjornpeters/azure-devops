[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$ScriptDirectory
)

Set-StrictMode -Version 'Latest'
$ErrorActionPreference = 'Stop'

# Import PSSCriptAnalyzer module and internal module
try {
    $module = 'PSScriptAnalyzer'
    Write-Output '##[group]Import required modules'
    if (Get-Module -Name $module) {
        Write-Output '##[command]PSScriptAnalyzer module already imported'
    }
    elseif (Get-Module -ListAvailable | Where-Object {$_.Name -eq $module}) {
        Write-Output '##[command]PSScriptAnalyzer found, importing module'
        Import-Module -Name $module -Force
    }
    else {
        Write-Output '##[command]PSScriptAnalyzer not found, installing module'
        Install-Module -Name $module -Force
        Import-Module -Name $module
    }
    Write-Output '##[command]Import internal module'    
    Import-Module "$env:BUILD_REPOSITORY_LOCALPATH/branch-policies/supportFiles/validation-module.psm1" -Force
    Write-Output '##[endgroup]'
}
catch {
    Write-Error $_
    Write-Error $_.Exception.Message
}

# Start analysis with PSScriptAnalyzer
try {
    Write-Output '##[group]Analyse scripts with PSScriptAnalyzer'
    $analysis = New-PowerShellAnalysis -ScriptDirectory $ScriptDirectory

    foreach ($item in $analysis) {
        Write-Output "##[command]Add comment to pull request for file ($($item.ScriptName) - Line $($item.Line))"
        New-PullRequestComment -Line $item.Line -Message $item.Message -ScriptPath $item.ScriptPath | Out-Null
    }
    Write-Output '##[endgroup]'
}
catch {
    Write-Error $_
    Write-Error $_.Exception.Message
}
