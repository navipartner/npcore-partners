[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [ValidateSet('Cloud','Crane')]
    [String]$BcType = 'Cloud',

    [Parameter(Mandatory = $true)]
    [string]$Username,

    [Parameter(Mandatory = $true)]
    [string]$Password,

    [Parameter(Mandatory = $false)]
    [Object[]]$SuiteCodes = @(),

    [Parameter(Mandatory = $false)]
    [string]$CompanyName = "CRONUS Danmark A/S",

    [Parameter(Mandatory = $false)]
    [string]$TenantId = "c068e6f9-9a49-4b37-b118-09c8e5b97ab0", # Only for BcType=Cloud
    
    [Parameter(Mandatory = $false)]
    [string]$SandboxName = "NPRetailBCPT-Sandbox-5", # Only for BcType=Cloud

    [Parameter(Mandatory = $false)]
    [string]$ClientId = "e7aed49c-17a3-49ae-9385-bfa901e61e48" # Only for BcType=Cloud
)

Clear-Host

# Add ActiveDirectory client
$aadActiveDirectoryPath = (Join-Path $PSScriptRoot "TestRunner\Microsoft.IdentityModel.Clients.ActiveDirectory.dll")
Add-type -Path $aadActiveDirectoryPath

# Add AadTokenProvider
$aadTokenProviderScriptPath = Join-Path $PSScriptRoot "TestRunner\AadTokenProvider.ps1"
. "$aadTokenProviderScriptPath"

# Import AL Test Runner functions
#Import-Module (Join-Path $PSScriptRoot "TestRunner\ALTestRunner.psm1") -Force

# Include NpBcptMgmt
$npBcptMgmt = Join-Path $PSScriptRoot "NpBcptMgmt.ps1"
. "$npBcptMgmt"

$bcptMgmt = [NpBcptMgmt]::new($BcType, $Username, $Password, $TenantId, $SandboxName, $CompanyName, $ClientId, $aadActiveDirectoryPath)

$apiAuthParams = $bcptMgmt.ApiAuthParams()

# Get companies
$companies = @(Invoke-BcSaaS @apiAuthParams `
    -BaseServiceUrl $bcptMgmt.GetApiBaseUrl() `
    -Path 'companies')

# Select company
$company = $companies | Where-Object { $_.name -eq $CompanyName } | Select-Object -First 1

if ($SuiteCodes.Count -eq 0) {
    throw "Please specify Suite Codes"
}

$errors = @()

$SuiteCodes | ForEach-Object {
    $suiteCode = $_

    # Get last version
    $versionCode = @(Invoke-BcSaaS @apiAuthParams `
        -BaseServiceUrl $bcptMgmt.GetApiBaseUrl() `
        -CompanyId $($company.id) `
        -APIPublisher "microsoft" `
        -APIGroup "PerformancToolkit" `
        -Path "bcptLogEntries" `
        -Query "`$filter=bcptCode eq '$($suiteCode)'&`$orderby=startTime%20desc&`$top=1&`$select=version")

    $lastVersion = ($versionCode.version)
    Write-Host "Last version for $($suiteCode) is $($lastVersion), get log entries:"

    $bcptLogEntries = @(Invoke-BcSaaS @apiAuthParams `
        -BaseServiceUrl $bcptMgmt.GetApiBaseUrl() `
        -CompanyId $($company.id) `
        -APIPublisher "microsoft" `
        -APIGroup "PerformancToolkit" `
        -Path "bcptLogEntries" `
        -Query "`$filter=bcptCode eq '$($suiteCode)' and version eq $($lastVersion)")
    
    Write-Host "Show log:"
    Write-Host ($bcptLogEntries | Out-String)

    $bcptLogEntries | ForEach-Object {
        if ($_.status -ne 'Success') {
            $errors += "$($_.status) - $($_.message)"
        }
    }
}

if ($errors.Count -gt 0) {
    Write-Host "ERRORS:"
    Write-Host ($errors | Out-String)
}

#$bcptLogEntries = @(Invoke-BcSaaS `
#    -AuthorizationType "AAD" `
#    -BearerToken $bcptMgmt.GetToken() `
#    -BaseServiceUrl $bcptMgmt.GetApiBaseUrl() `
#    -CompanyId $($company.id) `
#    -APIPublisher "microsoft" `
#    -APIGroup "PerformancToolkit" `
#    -Path "bcptLogEntries")
#Write-Host ($bcptLogEntries | Out-String)
#
#Write-Host "Show errors:"
#$bcptLogEntries | ForEach-Object {
#    if ($_.status -ne "Success") {
#        Write-Host "$($_.status) - $($_.bcptCode) - $($_.message)"
#    }
#}