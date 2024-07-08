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
    [Parameter(Mandatory = $false)]
    [ValidateSet('Cloud','Crane')]
    [String]$BcType = 'Cloud',

    [Parameter(Mandatory = $true)]
    [string]$Username,

    [Parameter(Mandatory = $true)]
    [string]$Password,

    [Parameter(Mandatory = $false)]
    [Object[]]$SuiteCodes = @('POS1S1'),

    [Parameter(Mandatory = $false)]
    [string]$CompanyName = "CRONUS Danmark A/S",

    [Parameter(Mandatory = $false)]
    [string]$TenantId = "c068e6f9-9a49-4b37-b118-09c8e5b97ab0", # Only for BcType=Cloud

    [Parameter(Mandatory = $false)]
    [string]$SandboxName = "NPRetailBCPT-Sandbox-5", # Only for BcType=Cloud

    [Parameter(Mandatory = $false)]
    [string]$ClientId = "e7aed49c-17a3-49ae-9385-bfa901e61e48",  # Only for BcType=Cloud

    [Parameter(Mandatory = $false)]
    [int]$TestPageId = 149002,

    [Parameter(Mandatory = $false)]
    [bool]$SingleRun = $false,

    [Parameter(Mandatory = $false)]
    [bool]$SkipDelayBeforeStart = $true
)

Clear-Host

# Add UI.Client
$uiclientPath = (Join-Path $PSScriptRoot "TestRunner\Microsoft.Dynamics.Framework.UI.Client.dll")
Add-type -Path $uiclientPath

# Add ActiveDirectory client
$aadActiveDirectoryPath = (Join-Path $PSScriptRoot "TestRunner\Microsoft.IdentityModel.Clients.ActiveDirectory.dll")
Add-type -Path $aadActiveDirectoryPath

# Add AadTokenProvider
$aadTokenProviderScriptPath = Join-Path $PSScriptRoot "TestRunner\AadTokenProvider.ps1"
. "$aadTokenProviderScriptPath" -Force

# Add ClientContext
$cctxScriptPath = Join-Path $PSScriptRoot "TestRunner\ClientContext.ps1"
. "$cctxScriptPath" -Force

# Import AL Test Runner functions
#Import-Module (Join-Path $PSScriptRoot "TestRunner\ALTestRunner.psm1") -Force

# Include NpBcptMgmt
$npBcptMgmt = Join-Path $PSScriptRoot "NpBcptMgmt.ps1"
. "$npBcptMgmt" -Force

$bcptMgmt = [NpBcptMgmt]::new($BcType, $Username, $Password, $TenantId, $SandboxName, $CompanyName, $ClientId, $aadActiveDirectoryPath)

$apiAuthParams = $bcptMgmt.ApiAuthParams()

# Wait for environment, in case it's not ready
Write-Host "Check environment status" -ForegroundColor Green
$bcptMgmt.WaitForEnvironment()
Write-Host ""

$internalServiceUrl = $bcptMgmt.GetInternalServiceUrl()
Write-Host "Using internal Service Url:" -ForegroundColor Green
Write-Host "$($internalServiceUrl) `r`n"

# Get companies
$companies = @(Invoke-BcSaaS @apiAuthParams `
    -BaseServiceUrl $bcptMgmt.GetApiBaseUrl() `
    -Path 'companies')

# Select company
$company = $companies | Where-Object { $_.name -eq $CompanyName } | Select-Object -First 1
Write-Host "Using company:" -ForegroundColor Green
Write-Host ($company | Out-String)

# Get Installed apps
Write-Host "Get Installed Apps:" -ForegroundColor Green
try {
    $apps = @(Invoke-BcSaaS @apiAuthParams `
        -BaseServiceUrl $bcptMgmt.GetApiBaseUrl() `
        -CompanyId $($company.id) `
        -APIPublisher "navipartner" `
        -APIGroup "bcpt" `
        -Path "installedApps")
    
    if (-not $apps) {
        throw "Make sure all required apps are installed!"
    }
    Write-Host ($apps | Out-String)
    Write-Host "`r`n"
}
catch {
    Write-Host $($_.Exception.Message)
    throw "Unable to fetch installed apps"
}

# Get BCPT suites
Write-Host "Available BCPT suite codes:" -ForegroundColor Green
$suites = @(Invoke-BcSaaS @apiAuthParams `
    -BaseServiceUrl $bcptMgmt.GetApiBaseUrl() `
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

# Wait for BCPT
$bcptMgmt.WaitForBcpt(10, 1800)

$runStarted = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

try {
    # RUN BCPT
    Write-Host "Running BCPT:" -ForegroundColor Green
    Write-Host ""

    $selectedSuites | ForEach-Object {
        $suiteCode = $_

        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        Write-Host "Running BCPT for '$($suiteCode)'..." -ForegroundColor Green

        try {
            Invoke-Command -ScriptBlock { Param($bcType, $location, [HashTable] $params, $suiteCode, $internalServiceUrl, $testPage, $sandboxName, $clientId)
                
                # Crane
                if ($bcType -eq "Crane") {
                    $params += @{
                        Environment = 'OnPrem'
                    }
                }
                # Cloud
                else {
                    $params = @{
                        Environment = 'PROD'
                        SandboxName = "$($sandboxName)"
                        ClientId = "$($clientId)"
                        Credential = $bcptMgmt.GetCredentials()
                        AuthorizationType = "AAD"
                    }
                }

                Set-Location $location

                .\RunBCPTTests.ps1 @params `
                    -BCPTTestRunnerInternalFolderPath $location `
                    -SuiteCode "$($suiteCode)" `
                    -ServiceUrl "$internalServiceUrl" `
                    -TestRunnerPage ([int]$testPage) `
                    -SingleRun:$($SingleRun) `
                    -SkipDelayBeforeStart:$($SkipDelayBeforeStart)
                
            } -ArgumentList $BcType, (Join-Path -Path $PSScriptRoot -ChildPath "TestRunner"), $apiAuthParams, $suiteCode, $internalServiceUrl, $TestPageId, $SandboxName, $ClientId
        }
        catch {
            $_
        }

        Write-Host "---> '$($suiteCode)' completed after $([math]::Round($stopwatch.Elapsed.TotalSeconds, 0)) seconds." -ForegroundColor Green
        Write-Host ""
        $stopwatch.Stop()

        Start-Sleep -Seconds 3

        # Wait for bcpt
        $bcptMgmt.WaitForBcpt(10, 1800)
    }

    Write-Host "BCPT runner completed" -ForegroundColor Green
    Write-Host "`r`n"

}
catch {
    Write-Host ($_ | Out-String)
    throw "`r`nBCPT FAILED`r`n"
} finally {
    # Display Telemetry KQL sample:
    Write-Host "Telemetry KQL for debugging this run:"
    Write-Host "------------------------------------------------"
    Write-Host "traces"
    Write-Host "| where timestamp > todatetime('$($runStarted)')"
    Write-Host "| where timestamp <= todatetime('$((Get-Date).AddMinutes(2).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))')"
    if ($BcType -eq 'Cloud') {
        Write-Host "| where customDimensions.environmentName == '$($SandboxName)'"
    }
    Write-Host "| order by timestamp asc"
    Write-Host "------------------------------------------------"
}
