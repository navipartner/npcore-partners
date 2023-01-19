# Add to launch.json:
#{
#    "name": "PowerShell BCPT SaaS",
#    "type": "PowerShell",
#    "request": "launch",
#    "script": ".\\scripts\\RunBcptSaaS.ps1",
#    "args": [],
#    "cwd": "${workspaceRoot}"
#}

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$Username,

    [Parameter(Mandatory = $true)]
    [string]$Password,

    [Parameter(Mandatory = $false)]
    [Object[]]$SuiteCodes = @('POS5S1', 'POS5S1', 'POS7S1', 'POS1S1'), # empty array => run all tests; duplicates allowed; ordered

    [Parameter(Mandatory = $false)]
    [string]$TenantId = "c068e6f9-9a49-4b37-b118-09c8e5b97ab0",

    [Parameter(Mandatory = $false)]
    [string]$SandboxName = "NPRetailBCPT-Sandbox",

    [Parameter(Mandatory = $false)]
    [string]$CompanyName = "CRONUS Danmark A/S",

    [Parameter(Mandatory = $false)]
    [string]$ClientId = "e7aed49c-17a3-49ae-9385-bfa901e61e48", # AAD app registration

    [Parameter(Mandatory = $false)]
    [int]$TestPageId = 149002
)

Clear-Host

# Invoke SaaS API script
$invokeSaasApi = Join-Path $PSScriptRoot "Invoke-SaaSApi.ps1"

# Add ActiveDirectory client
$aadActiveDirectoryPath = (Join-Path $PSScriptRoot "TestRunner\Microsoft.IdentityModel.Clients.ActiveDirectory.dll")
Add-type -Path $aadActiveDirectoryPath

# Add AadTokenProvider
$aadTokenProviderScriptPath = Join-Path $PSScriptRoot "TestRunner\AadTokenProvider.ps1"
. "$aadTokenProviderScriptPath"

# Import AL Test Runner functions
#Import-Module (Join-Path $PSScriptRoot "TestRunner\ALTestRunner.psm1") -Force

# Create credential
$credential = New-Object System.Management.Automation.PSCredential "$($Username)", (ConvertTo-SecureString -String "$($Password)" -AsPlainText -Force)

# Request token
$authority = "https://login.microsoftonline.com/"
$resource = "https://api.businesscentral.dynamics.com"
$aadTokenProvider = [AadTokenProvider]::new($authority, $resource, $ClientId, $credential, $aadActiveDirectoryPath)
$token = $aadTokenProvider.GetToken($credential)

$internalServiceUrl = "https://businesscentral.dynamics.com/$($TenantId)/$($SandboxName)?company=$([Uri]::EscapeDataString($CompanyName))"
Write-Host "Using internal Service Url:" -ForegroundColor Green
Write-Host "$($internalServiceUrl) `r`n"

# Get Api base url
$apiBaseUrl = [Uri]"https://api.businesscentral.dynamics.com/v2.0/$($TenantId)/$($SandboxName)"

# Get companies
$companies = @(. "$invokeSaasApi" `
    -AuthorizationType "AAD" `
    -BearerToken $token `
    -BaseServiceUrl $apiBaseUrl `
    -Path 'companies')

# Select company
$company = $companies | Where-Object { $_.name -eq $CompanyName } | Select-Object -First 1
Write-Host "Using company:" -ForegroundColor Green
Write-Host ($company | Out-String)

# Check if any BCPT is running and wait
$isBcptInProgress = $false
Do
{
    $checkBcptUrl = "https://api.businesscentral.dynamics.com/v2.0/$($TenantId)/$($SandboxName)/ODataV4/BCPTTestSuite_IsAnyTestRunInProgress?company=$([Uri]::EscapeDataString($CompanyName))"
    $checkRunning = @(. "$invokeSaasApi" ` `
        -AuthorizationType "AAD" `
        -BearerToken $token `
        -BaseServiceUrl $checkBcptUrl `
        -Method "POST" `
        -NotApi)
        $isBcptInProgress = ($checkRunning[0] -eq $true)
        
        if ($isBcptInProgress -eq $true) {
            Write-Host "BCPT is currently in progress - Waiting..."
            Start-Sleep -Seconds 10
        }

} While ($isBcptInProgress -eq $true)

# Get BCPT suites
Write-Host "Available BCPT suite codes:" -ForegroundColor Green
$suites = @(. "$invokeSaasApi" ` `
    -AuthorizationType "AAD" `
    -BearerToken $token `
    -BaseServiceUrl $apiBaseUrl `
    -CompanyId $($company.id) `
    -APIPublisher "microsoft" `
    -APIGroup "PerformancToolkit" `
    -Path "bcptSuites")
Write-Host ($suites.code -join ', ')
Write-Host "`r`n"

# Selected Suite Codes
$selectedSuites = @()
Write-Host "Selected BCPT suite codes, in order of execution:" -ForegroundColor Green
if ($SuiteCodes.Count -eq 0) {
    $selectedSuites = @($suites.code)
    Write-Host "ALL" -ForegroundColor Yellow
} else {
    $SuiteCodes | ForEach-Object {
        if (@($suites.code).Contains("$_")) {
            $selectedSuites += $_
        }
    }
    Write-Host ($selectedSuites -join ', ') -ForegroundColor Yellow
}
if ($selectedSuites.Count -eq 0) {
    throw "Please enter SuiteCodes for the run."
}
Write-Host "`r`n"

# Create BCPT credential
$bcptCredential = New-Object System.Management.Automation.PSCredential "$($Username)", (ConvertTo-SecureString -String "$($Password)" -AsPlainText -Force)

# RUN BCPT
Write-Host "Running BCPT:" -ForegroundColor Green
$selectedSuites | ForEach-Object {
    $suiteCode = $_

    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    Write-Host "Running BCPT for '$($suiteCode)'..."

    $params = @{
        Credential = $bcptCredential
        AuthorizationType = "AAD"
    }
    
    $Job = Start-Job -ScriptBlock { Param( $location, [HashTable] $params, $suiteCode, $internalServiceUrl, $testPage, $sandboxName, $clientId)
        Write-Host "Running test for '$($suiteCode)'..."
        
        Set-Location $location

        .\RunBCPTTests.ps1 @params `
            -BCPTTestRunnerInternalFolderPath $location `
            -SuiteCode "$($suiteCode)" `
            -ServiceUrl "$internalServiceUrl" `
            -Environment PROD `
            -SandboxName "$($sandboxName)" `
            -ClientId "$($clientId)" `
            -TestRunnerPage ([int]$testPage)
        
        Write-Host "Running test for '$($suiteCode)'..."
    } -ArgumentList (Join-Path -Path $PSScriptRoot -ChildPath "TestRunner"), $params, $suiteCode, $internalServiceUrl, $TestPageId, $SandboxName, $ClientId | Wait-Job
    
    if ($job.State -ne "Completed") {
        Write-Host "Running performance test failed" -ForegroundColor Red
    }
    
    $job | Receive-Job -Keep

    $job | Remove-Job | Out-Null

    Write-Host "---> '$($suiteCode)' completed after $([math]::Round($stopwatch.Elapsed.TotalSeconds, 0)) seconds."
    $stopwatch.Stop()
}

#$bcptLogEntries = @(. "$invokeSaasApi" ` `
#    -AuthorizationType "AAD" `
#    -BearerToken $token `
#    -BaseServiceUrl $apiBaseUrl `
#    -CompanyId $($company.id) `
#    -APIPublisher "microsoft" `
#    -APIGroup "PerformancToolkit" `
#    -Path "bcptLogEntries")
#Write-Host ($bcptLogEntries | Out-String)
#
#Save-ResultsAsXUnitFile -TestRunResultObject $bcptLogEntries -ResultsFilePath (Join-Path $PSScriptRoot "logs\Results.xml")

Write-Host "BCPT runner completed" -ForegroundColor Green