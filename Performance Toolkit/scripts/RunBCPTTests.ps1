<#
.SYNOPSIS
    This script runs the Applicaiton Beanchmark Tests in different environment.
.DESCRIPTION
    This script chooses an appropriate defaults for most of the parameters if not provided.
.NOTES
    File Name      : RunBCPTTests.ps1
    Copyright 2020 - Microsof Corporation
.EXAMPLE
    RunBCPTTests.ps1  -Environment PROD -AuthorizationType AAD -Credential $Credential -SandboxName sandbox -TestRunnerPage 50010 -SuiteCode ONE -BCPTTestRunnerInternalFolderPath .\ALTestRunner\Internal
.EXAMPLE
    RunBCPTTests.ps1 -Environment OnPrem -AuthorizationType Windows -TestRunnerPage 50010 -SuiteCode THREE -BCPTTestRunnerInternalFolderPath .\ALTestRunner\Internal
#>
param
(
    [ValidateSet("PROD","OnPrem")]
    [string] $Environment,
    [ValidateSet("AAD","Windows","NavUserPassword")]
    [string] $AuthorizationType,
    [pscredential] $Credential,
    [pscredential] $Token,
    [string] $SandboxName,
    [string] $ServiceUrl,
    [int] $TestRunnerPage,
    [Parameter(Mandatory=$true)]
    [string] $SuiteCode,
    [string] $BCPTTestRunnerInternalFolderPath,
    [string] $ClientId,
    [switch] $SingleRun,
    [switch] $SkipDelayBeforeStart
)

<#
This funciton verifies the passed parameters and sets the defaults for the missing ones. The parameters are saved as global variables for further use
#>
function VerifyAndSetup-Parameters(
    [string] $Environment,
    [string] $AuthorizationType,
    [pscredential] $Credential,
    [pscredential] $Token,
    [string] $SandboxName,
    [string] $ServiceUrl,
    [int] $TestRunnerPage = $script:DefaultTestRunnerPage,
    [string] $SuiteCode,
    [string] $BCPTTestRunnerInternalFolderPath,
    [string] $ClientId
)
{
    # If -Environment is not specified then pick the default
    if ($Environment -eq '')
    {
        Write-Host "-Environment parameter is not provided. Defaulting to $script:DefaultEnvironment"

        $global:Environment = $script:DefaultEnvironment
    }
    else
    {
        $global:Environment = $Environment
    }

    # Depending on the Environment make sure necessary parameters are also specified
    switch ($global:Environment)
    {
        # PROD works only with AAD authorizatin type and OnPrem works on all 3 Authorization types
        'PROD'
        {
            if ($AuthorizationType -ne 'AAD')
            {
                throw "Only Authorization type 'AAD' can work in -Environment $Environment."
            }
            else
            {
                if ($AuthorizationType -eq '')
                {
                    Write-Host "-AuthorizationType parameter is not provided. Defaulting to $script:DefaultAuthorizationType"
                    $global:AuthorizationType = $script:DefaultAuthorizationType
                }
                else
                {
                    $global:AuthorizationType = $AuthorizationType
                }
            }

            if ($SandboxName -eq '')
            {
                Write-Host "-SandboxName parameter is not provided. Defaulting to $script:DefaultSandboxName"
                $global:SandboxName = $script:DefaultSandboxName
            }
            else
            {
                $global:SandboxName = $SandboxName
            }

            if ($ClientId -eq '')
            {
                Write-Error -Category InvalidArgument -Message 'ClientId is mandatory in the PROD environment'
            }
            else
            {
                $global:ClientId = $ClientId
            }
        }
        'OnPrem'
        {
            if ($AuthorizationType -eq '')
            {
                Write-Host "-AuthorizationType parameter is not provided. Defaulting to $script:DefaultAuthorizationType"
                $global:AuthorizationType = $script:DefaultAuthorizationType
            }
            else
            {
                $global:AuthorizationType = $AuthorizationType
            }

            # OnPrem, -ServiceUrl should be provided else default is selected. On other environments, the Service Urls are built
            if ($ServiceUrl -eq '')
            {
                Write-Host "Valid ServiceUrl is not provided. Defaulting to $script:DefaultServiceUrl"
                $global:ServiceUrl = $script:DefaultServiceUrl
            }
            else
            {
                $global:ServiceUrl = $ServiceUrl
            }
        }
    }

    switch ($global:AuthorizationType)
    {
        # -Credential or -Token should be specified if authorization type is AAD.
        "AAD"
        {
            if ($Credential -eq $null -and $Token -eq $null)
            {
                throw "Parameter -Credential or -Token should be defined when selecting 'AAD' authorization type."
            }
            if ($Credential -ne $null -and $Token -ne $null)
            {
                throw "Specify only one parameter -Credential or -Token when selecting 'AAD' authorization type."
            }
        }
        # -Credential should be specified if authorization type is NavUserPassword.
        "NavUserPassword"
        {
            if ($Credential -eq $null)
            {
                throw "Parameter -Credential should be defined when selecting 'NavUserPassword' authorization type."
            }
        }
        "Windows"
        {
            if ($Credential -ne $null)
            {
                throw "Parameter -Credential should not be defined when selecting 'Windows' authorization type."
            }
        }
    }

    # Make sure all necessary scripts and assemblies are in the specified folder
    if ($BCPTTestRunnerInternalFolderPath -eq '')
    {
        Write-Host "Valid BCPTTestRunnerInternalFolderPath is not provided. Defaulting to $script:BCPTTestRunnerInternalFolderPath"
        $global:BCPTTestRunnerInternalFolderPath = $script:DefaultBCPTTestRunnerInternalFolderPath
    }
    else
    {
        $global:BCPTTestRunnerInternalFolderPath = $BCPTTestRunnerInternalFolderPath
    }

    if ([System.IO.Path]::IsPathRooted($global:BCPTTestRunnerInternalFolderPath) -eq $false)
    {
        Write-Host "The passed path for -BCPTTestRunnerInternalFolderPath seem to be relative path, converting to absolute."
        $global:BCPTTestRunnerInternalFolderPath = Convert-Path -Path $global:BCPTTestRunnerInternalFolderPath
        Write-Host "Absolute path is $global:BCPTTestRunnerInternalFolderPath"
    }

    if ((Test-Path -Path (Join-Path $global:BCPTTestRunnerInternalFolderPath $script:BCPTTestRunnerInternalScriptName)) -eq $false)
    {
         throw "Cannot find $script:BCPTTestRunnerInternalScriptName in location $global:BCPTTestRunnerInternalFolderPath"
    }

    if ((Test-Path -Path (Join-Path $global:BCPTTestRunnerInternalFolderPath $script:ClientAssembly1)) -eq $false)
    {
         throw "Cannot find $script:ClientAssembly1 in location $global:BCPTTestRunnerInternalFolderPath"
    }

    if ((Test-Path -Path (Join-Path $global:BCPTTestRunnerInternalFolderPath $script:ClientAssembly2)) -eq $false)
    {
         throw "Cannot find $script:ClientAssembly2 in location $global:BCPTTestRunnerInternalFolderPath"
    }

    if($AuthorizationType -eq "AAD")
    {
        if ((Test-Path -Path (Join-Path $global:BCPTTestRunnerInternalFolderPath $script:ClientAssembly3)) -eq $false)
        {
            throw "Cannot find $script:ClientAssembly2 in location $global:BCPTTestRunnerInternalFolderPath"
        }
    }

    if ($TestRunnerPage -eq 0)
    {
        Write-Host "Valid TestRunnerPage is not provided. Defaulting to $script:DefaultTestRunnerPage"
        $global:TestRunnerPage = $script:DefaultTestRunnerPage
    }
    else
    {
        $global:TestRunnerPage = $TestRunnerPage
    }
}

$ErrorActionPreference = "Stop"

$global:Environment = ''
$global:AuthorizationType = ''
$global:SandboxName = ''
$global:ClientId = ''
$global:ServiceUrl = ''
$global:TestRunnerPage = 0
$global:BCPTTestRunnerInternalFolderPath = ''

$script:DefaultEnvironment = "OnPrem"
$script:DefaultAuthorizationType = 'Windows'
$script:DefaultSandboxName = "sandbox"
$script:DefaultServiceUrl = 'http://localhost:48900'
$script:DefaultTestRunnerPage = '150002'
$script:DefaultBCPTTestRunnerInternalFolderPath = $PSScriptRoot

$script:BCPTTestRunnerInternalScriptName = "BCPTTestRunnerInternal.psm1"
$script:ClientAssembly1 = "Microsoft.Dynamics.Framework.UI.Client.dll"
$script:ClientAssembly2 = "NewtonSoft.Json.dll"
$script:ClientAssembly3 = "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"

VerifyAndSetup-Parameters -Environment $Environment -AuthorizationType $AuthorizationType -Credential $Credential -Token $Token -SandboxName $SandboxName -ServiceUrl $ServiceUrl -TestRunnerPage $TestRunnerPage -SuiteCode $SuiteCode -BCPTTestRunnerInternalFolderPath $BCPTTestRunnerInternalFolderPath -ClientId $ClientId

$BCPTRTestRunnerInternalScriptPath = (Join-Path $global:BCPTTestRunnerInternalFolderPath $script:BCPTTestRunnerInternalScriptName)
Write-Host "Importing AL Test Runner from $BCPTRTestRunnerInternalScriptPath"
Import-Module $BCPTRTestRunnerInternalScriptPath -WarningAction SilentlyContinue -Force

# Fetch no. of tasks, tasks life time and no. of tests from the client
$NoOfTasks,$TaskLifeInMins,$NoOfTests = Get-NoOfIterations -DisableSSLVerification -Environment $global:Environment -AuthorizationType $global:AuthorizationType -Credential $Credential -Token $Token -SandboxName $global:SandboxName -ServiceUrl $global:ServiceUrl -TestRunnerPage $global:TestRunnerPage -SuiteCode $SuiteCode -ClientId $global:ClientId

$TaskLifeInMins += 10;

# Run-BCPTTestsInternal -DisableSSLVerification -Environment $global:Environment -AuthorizationType $global:AuthorizationType -Credential $Credential -Token $Token -SandboxName $global:SandboxName -ServiceUrl $global:ServiceUrl -TestRunnerPage $global:TestRunnerPage -SuiteCode $SuiteCode -SessionTimeoutInMins $TaskLifeInMins -ClientId $global:ClientId

$task = {
    param(
        [string] $Environment,
        [string] $AuthorizationType,
        [pscredential] $Credential,
        [pscredential] $Token,
        [string] $SandboxName,
        [string] $ServiceUrl,
        [int] $TestRunnerPage,
        [string] $SuiteCode,
        [string] $PathToRunnerScript,
        [int] $SessionTimeoutInMins,
        [string] $ClientId,
        [switch] $SingleRun
    )
        
    Write-Host "Importing AL Test Runner from $PathToRunnerScript"
    Import-Module $PathToRunnerScript -WarningAction SilentlyContinue -Force

    Run-BCPTTestsInternal -DisableSSLVerification -Environment $Environment -AuthorizationType $AuthorizationType -Credential $Credential -Token $Token -SandboxName $SandboxName -ServiceUrl $ServiceUrl -TestRunnerPage $TestRunnerPage -SuiteCode $SuiteCode -SessionTimeoutInMins $SessionTimeoutInMins -ClientId $ClientId -SingleRun:$SingleRun
}

# Determine how many sessions to spawn based on single run mode
if ($SingleRun.IsPresent)
{
    $NoOfSessions = $NoOfTests
}
else
{
    $NoOfSessions = $NoOfTasks
}
    
# Spawn sessions
for ($i = 0; $i -lt $NoOfSessions; $i++)
{
    Start-Job -ScriptBlock $task -ArgumentList $global:Environment,$global:AuthorizationType,$Credential,$Token,$global:SandboxName,$global:ServiceUrl,$global:TestRunnerPage,$SuiteCode,$BCPTRTestRunnerInternalScriptPath,$TaskLifeInMins, $global:ClientId, $SingleRun

    if ($SkipDelayBeforeStart -eq $false)
    {sleep -Seconds 2}
}

While (@(Get-Job | Where { $_.State -eq "Running" -and $_.PSJobTypeName -eq "BackgroundJob"}).Count -ne 0) {
    Write-Verbose "Waiting for background jobs..."
    Start-Sleep -Seconds 3
}

$Data = ForEach ($Job in (Get-Job | Where { $_.PSJobTypeName -eq "BackgroundJob"}))
{  
    try {
        Receive-Job $Job
    }
    catch { 
        Write-Host $_ -ForegroundColor Red
    }
    finally {
        Remove-Job $Job
    }
}

# SIG # Begin signature block
# MIInmwYJKoZIhvcNAQcCoIInjDCCJ4gCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDULo9y6X5LzsKJ
# AkZGrL+saKrvTQyHizN8jHTdevUOKqCCDYEwggX/MIID56ADAgECAhMzAAACzI61
# lqa90clOAAAAAALMMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjIwNTEyMjA0NjAxWhcNMjMwNTExMjA0NjAxWjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQCiTbHs68bADvNud97NzcdP0zh0mRr4VpDv68KobjQFybVAuVgiINf9aG2zQtWK
# No6+2X2Ix65KGcBXuZyEi0oBUAAGnIe5O5q/Y0Ij0WwDyMWaVad2Te4r1Eic3HWH
# UfiiNjF0ETHKg3qa7DCyUqwsR9q5SaXuHlYCwM+m59Nl3jKnYnKLLfzhl13wImV9
# DF8N76ANkRyK6BYoc9I6hHF2MCTQYWbQ4fXgzKhgzj4zeabWgfu+ZJCiFLkogvc0
# RVb0x3DtyxMbl/3e45Eu+sn/x6EVwbJZVvtQYcmdGF1yAYht+JnNmWwAxL8MgHMz
# xEcoY1Q1JtstiY3+u3ulGMvhAgMBAAGjggF+MIIBejAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUiLhHjTKWzIqVIp+sM2rOHH11rfQw
# UAYDVR0RBEkwR6RFMEMxKTAnBgNVBAsTIE1pY3Jvc29mdCBPcGVyYXRpb25zIFB1
# ZXJ0byBSaWNvMRYwFAYDVQQFEw0yMzAwMTIrNDcwNTI5MB8GA1UdIwQYMBaAFEhu
# ZOVQBdOCqhc3NyK1bajKdQKVMFQGA1UdHwRNMEswSaBHoEWGQ2h0dHA6Ly93d3cu
# bWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY0NvZFNpZ1BDQTIwMTFfMjAxMS0w
# Ny0wOC5jcmwwYQYIKwYBBQUHAQEEVTBTMFEGCCsGAQUFBzAChkVodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY0NvZFNpZ1BDQTIwMTFfMjAx
# MS0wNy0wOC5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAgEAeA8D
# sOAHS53MTIHYu8bbXrO6yQtRD6JfyMWeXaLu3Nc8PDnFc1efYq/F3MGx/aiwNbcs
# J2MU7BKNWTP5JQVBA2GNIeR3mScXqnOsv1XqXPvZeISDVWLaBQzceItdIwgo6B13
# vxlkkSYMvB0Dr3Yw7/W9U4Wk5K/RDOnIGvmKqKi3AwyxlV1mpefy729FKaWT7edB
# d3I4+hldMY8sdfDPjWRtJzjMjXZs41OUOwtHccPazjjC7KndzvZHx/0VWL8n0NT/
# 404vftnXKifMZkS4p2sB3oK+6kCcsyWsgS/3eYGw1Fe4MOnin1RhgrW1rHPODJTG
# AUOmW4wc3Q6KKr2zve7sMDZe9tfylonPwhk971rX8qGw6LkrGFv31IJeJSe/aUbG
# dUDPkbrABbVvPElgoj5eP3REqx5jdfkQw7tOdWkhn0jDUh2uQen9Atj3RkJyHuR0
# GUsJVMWFJdkIO/gFwzoOGlHNsmxvpANV86/1qgb1oZXdrURpzJp53MsDaBY/pxOc
# J0Cvg6uWs3kQWgKk5aBzvsX95BzdItHTpVMtVPW4q41XEvbFmUP1n6oL5rdNdrTM
# j/HXMRk1KCksax1Vxo3qv+13cCsZAaQNaIAvt5LvkshZkDZIP//0Hnq7NnWeYR3z
# 4oFiw9N2n3bb9baQWuWPswG0Dq9YT9kb+Cs4qIIwggd6MIIFYqADAgECAgphDpDS
# AAAAAAADMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0
# ZSBBdXRob3JpdHkgMjAxMTAeFw0xMTA3MDgyMDU5MDlaFw0yNjA3MDgyMTA5MDla
# MH4xCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
# ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMT
# H01pY3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTEwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQCr8PpyEBwurdhuqoIQTTS68rZYIZ9CGypr6VpQqrgG
# OBoESbp/wwwe3TdrxhLYC/A4wpkGsMg51QEUMULTiQ15ZId+lGAkbK+eSZzpaF7S
# 35tTsgosw6/ZqSuuegmv15ZZymAaBelmdugyUiYSL+erCFDPs0S3XdjELgN1q2jz
# y23zOlyhFvRGuuA4ZKxuZDV4pqBjDy3TQJP4494HDdVceaVJKecNvqATd76UPe/7
# 4ytaEB9NViiienLgEjq3SV7Y7e1DkYPZe7J7hhvZPrGMXeiJT4Qa8qEvWeSQOy2u
# M1jFtz7+MtOzAz2xsq+SOH7SnYAs9U5WkSE1JcM5bmR/U7qcD60ZI4TL9LoDho33
# X/DQUr+MlIe8wCF0JV8YKLbMJyg4JZg5SjbPfLGSrhwjp6lm7GEfauEoSZ1fiOIl
# XdMhSz5SxLVXPyQD8NF6Wy/VI+NwXQ9RRnez+ADhvKwCgl/bwBWzvRvUVUvnOaEP
# 6SNJvBi4RHxF5MHDcnrgcuck379GmcXvwhxX24ON7E1JMKerjt/sW5+v/N2wZuLB
# l4F77dbtS+dJKacTKKanfWeA5opieF+yL4TXV5xcv3coKPHtbcMojyyPQDdPweGF
# RInECUzF1KVDL3SV9274eCBYLBNdYJWaPk8zhNqwiBfenk70lrC8RqBsmNLg1oiM
# CwIDAQABo4IB7TCCAekwEAYJKwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFEhuZOVQ
# BdOCqhc3NyK1bajKdQKVMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1Ud
# DwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFHItOgIxkEO5FAVO
# 4eqnxzHRI4k0MFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwubWljcm9zb2Z0
# LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcmwwXgYIKwYBBQUHAQEEUjBQME4GCCsGAQUFBzAChkJodHRwOi8vd3d3Lm1p
# Y3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcnQwgZ8GA1UdIASBlzCBlDCBkQYJKwYBBAGCNy4DMIGDMD8GCCsGAQUFBwIB
# FjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2RvY3MvcHJpbWFyeWNw
# cy5odG0wQAYIKwYBBQUHAgIwNB4yIB0ATABlAGcAYQBsAF8AcABvAGwAaQBjAHkA
# XwBzAHQAYQB0AGUAbQBlAG4AdAAuIB0wDQYJKoZIhvcNAQELBQADggIBAGfyhqWY
# 4FR5Gi7T2HRnIpsLlhHhY5KZQpZ90nkMkMFlXy4sPvjDctFtg/6+P+gKyju/R6mj
# 82nbY78iNaWXXWWEkH2LRlBV2AySfNIaSxzzPEKLUtCw/WvjPgcuKZvmPRul1LUd
# d5Q54ulkyUQ9eHoj8xN9ppB0g430yyYCRirCihC7pKkFDJvtaPpoLpWgKj8qa1hJ
# Yx8JaW5amJbkg/TAj/NGK978O9C9Ne9uJa7lryft0N3zDq+ZKJeYTQ49C/IIidYf
# wzIY4vDFLc5bnrRJOQrGCsLGra7lstnbFYhRRVg4MnEnGn+x9Cf43iw6IGmYslmJ
# aG5vp7d0w0AFBqYBKig+gj8TTWYLwLNN9eGPfxxvFX1Fp3blQCplo8NdUmKGwx1j
# NpeG39rz+PIWoZon4c2ll9DuXWNB41sHnIc+BncG0QaxdR8UvmFhtfDcxhsEvt9B
# xw4o7t5lL+yX9qFcltgA1qFGvVnzl6UJS0gQmYAf0AApxbGbpT9Fdx41xtKiop96
# eiL6SJUfq/tHI4D1nvi/a7dLl+LrdXga7Oo3mXkYS//WsyNodeav+vyL6wuA6mk7
# r/ww7QRMjt/fdW1jkT3RnVZOT7+AVyKheBEyIXrvQQqxP/uozKRdwaGIm1dxVk5I
# RcBCyZt2WwqASGv9eZ/BvW1taslScxMNelDNMYIZcDCCGWwCAQEwgZUwfjELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWljcm9z
# b2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMQITMwAAAsyOtZamvdHJTgAAAAACzDAN
# BglghkgBZQMEAgEFAKCBrDAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQgFmK/CrSH
# HV6qocoq6cxIQnN09GkAAS7sW4HqSw5DYw0wQAYKKwYBBAGCNwIBDDEyMDCgEoAQ
# AE0AbwBjAGsAVABlAHMAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJ
# KoZIhvcNAQEBBQAEggEAoTAQcgpt8XJz3tGOR2sTCuABeL91BaXgKHSssUStplQW
# 1s4EvmJupj3Awabq6MrWHa2VUcwifMam5TDKPt9Q45DmXwtzk8ZBADgNWo4AcGLW
# th40hwJPlfvEMsTYM6gTACzFMDPyWpYBh3UXCnyK7rwzI3eRp4SqW8mOFv9q8lgy
# 8aSwksQhIufrdf+CYvL1YJRMITV8BIn0ZOguwV0D4nt4RSrwR/up7HrlyYEVXVnZ
# TBRbZsKeeIRY2tVlu/+8Nvma0DYEPshQLB31srReRuAJvxN2rWypvhb2VoNxPFPU
# MpLgg/+ECpuRM3c1XFQvVHyVuXOG6AwZGDxxfy+AH6GCFvwwghb4BgorBgEEAYI3
# AwMBMYIW6DCCFuQGCSqGSIb3DQEHAqCCFtUwghbRAgEDMQ8wDQYJYIZIAWUDBAIB
# BQAwggFRBgsqhkiG9w0BCRABBKCCAUAEggE8MIIBOAIBAQYKKwYBBAGEWQoDATAx
# MA0GCWCGSAFlAwQCAQUABCBipPrTrHA2Mhb1GzQWb0rWzBHlEM2+z91yO7j1bn1w
# BAIGYv11lPsOGBMyMDIyMDgxODA2MTAzNi44NDlaMASAAgH0oIHQpIHNMIHKMQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNy
# b3NvZnQgQW1lcmljYSBPcGVyYXRpb25zMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVT
# Tjo0OUJDLUUzN0EtMjMzQzElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAg
# U2VydmljZaCCEVMwggcMMIIE9KADAgECAhMzAAABlwPPWZxriXg/AAEAAAGXMA0G
# CSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
# MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMB4XDTIx
# MTIwMjE5MDUxNFoXDTIzMDIyODE5MDUxNFowgcoxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJTAjBgNVBAsTHE1pY3Jvc29mdCBBbWVyaWNhIE9w
# ZXJhdGlvbnMxJjAkBgNVBAsTHVRoYWxlcyBUU1MgRVNOOjQ5QkMtRTM3QS0yMzND
# MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNlMIICIjANBgkq
# hkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA7QBK6kpBTfPwnv3LKx1VnL9YkozUwKzy
# hDKij1E6WCV/EwWZfPCza6cOGxKT4pjvhLXJYuUQaGRInqPks2FJ29PpyhFmhGIL
# m4Kfh0xWYg/OS5Xe5pNl4PdSjAxNsjHjiB9gx6U7J+adC39Ag5XzxORzsKT+f77F
# MTXg1jFus7ErilOvWi+znMpN+lTMgioxzTC+u1ZmTCQTu219b2FUoTr0KmVJMQqQ
# kd7M5sR09PbOp4cC3jQs+5zJ1OzxIjRlcUmLvldBE6aRaSu0x3BmADGt0mGY0MRs
# gznOydtJBLnerc+QK0kcxuO6rHA3z2Kr9fmpHsfNcN/eRPtZHOLrpH59AnirQA7p
# uz6ka20TA+8MhZ19hb8msrRo9LmirjFxSbGfsH3ZNEbLj3lh7Vc+DEQhMH2K9XPi
# U5Jkt5/6bx6/2/Od3aNvC6Dx3s5N3UsW54kKI1twU2CS5q1Hov5+ARyuZk0/DbsR
# us6D97fB1ZoQlv/4trBcMVRz7MkOrHa8bP4WqbD0ebLYtiExvx4HuEnh+0p3veNj
# h3gP0+7DkiVwIYcfVclIhFFGsfnSiFexruu646uUla+VTUuG3bjqS7FhI3hh6THo
# v/98XfHcWeNhvxA5K+fi+1BcSLgQKvq/HYj/w/Mkf3bu73OERisNaacaaOCR/TJ2
# H3fs1A7lIHECAwEAAaOCATYwggEyMB0GA1UdDgQWBBRtzwHPKOswbpZVC9Gxvt1+
# vRUAYDAfBgNVHSMEGDAWgBSfpxVdAF5iXYP05dJlpxtTNRnpcjBfBgNVHR8EWDBW
# MFSgUqBQhk5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNy
# b3NvZnQlMjBUaW1lLVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcmwwbAYIKwYBBQUH
# AQEEYDBeMFwGCCsGAQUFBzAChlBodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtp
# b3BzL2NlcnRzL01pY3Jvc29mdCUyMFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEp
# LmNydDAMBgNVHRMBAf8EAjAAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMA0GCSqGSIb3
# DQEBCwUAA4ICAQAESNhh0iTtMx57IXLfh4LuHbD1NG9MlLA1wYQHQBnR9U/rg3qt
# 3Nx6e7+QuEKMEhKqdLf3g5RR4R/oZL5vEJVWUfISH/oSWdzqrShqcmT4Oxzc2CBs
# 0UtnyopVDm4W2Cumo3quykYPpBoGdeirvDdd153AwsJkIMgm/8sxJKbIBeT82tnr
# UngNmNo8u7l1uE0hsMAq1bivQ63fQInr+VqYJvYT0W/0PW7pA3qh4ocNjiX6Z8d9
# kjx8L7uBPI/HsxifCj/8mFRvpVBYOyqP7Y5di5ZAnjTDSHMZNUFPHt+nhFXUcHjX
# PRRHCMqqJg4D63X6b0V0R87Q93ipwGIXBMzOMQNItJORekHtHlLi3bg6Lnpjs0aC
# o5/RlHCjNkSDg+xV7qYea37L/OKTNjqmH3pNAa3BvP/rDQiGEYvgAbVHEIQz7WMW
# SYsWeUPFZI36mCjgUY6V538CkQtDwM8BDiAcy+quO8epykiP0H32yqwDh852BeWm
# 1etF+Pkw/t8XO3Q+diFu7Ggiqjdemj4VfpRsm2tTN9HnAewrrb0XwY8QE2tp0hRd
# N2b0UiSxMmB4hNyKKXVaDLOFCdiLnsfpD0rjOH8jbECZObaWWLn9eEvDr+QNQPvS
# 4r47L9Aa8Lr1Hr47VwJ5E2gCEnvYwIRDzpJhMRi0KijYN43yT6XSGR4N9jCCB3Ew
# ggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZIhvcNAQELBQAwgYgx
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1p
# Y3Jvc29mdCBSb290IENlcnRpZmljYXRlIEF1dGhvcml0eSAyMDEwMB4XDTIxMDkz
# MDE4MjIyNVoXDTMwMDkzMDE4MzIyNVowfDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENB
# IDIwMTAwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDk4aZM57RyIQt5
# osvXJHm9DtWC0/3unAcH0qlsTnXIyjVX9gF/bErg4r25PhdgM/9cT8dm95VTcVri
# fkpa/rg2Z4VGIwy1jRPPdzLAEBjoYH1qUoNEt6aORmsHFPPFdvWGUNzBRMhxXFEx
# N6AKOG6N7dcP2CZTfDlhAnrEqv1yaa8dq6z2Nr41JmTamDu6GnszrYBbfowQHJ1S
# /rboYiXcag/PXfT+jlPP1uyFVk3v3byNpOORj7I5LFGc6XBpDco2LXCOMcg1KL3j
# tIckw+DJj361VI/c+gVVmG1oO5pGve2krnopN6zL64NF50ZuyjLVwIYwXE8s4mKy
# zbnijYjklqwBSru+cakXW2dg3viSkR4dPf0gz3N9QZpGdc3EXzTdEonW/aUgfX78
# 2Z5F37ZyL9t9X4C626p+Nuw2TPYrbqgSUei/BQOj0XOmTTd0lBw0gg/wEPK3Rxjt
# p+iZfD9M269ewvPV2HM9Q07BMzlMjgK8QmguEOqEUUbi0b1qGFphAXPKZ6Je1yh2
# AuIzGHLXpyDwwvoSCtdjbwzJNmSLW6CmgyFdXzB0kZSU2LlQ+QuJYfM2BjUYhEfb
# 3BvR/bLUHMVr9lxSUV0S2yW6r1AFemzFER1y7435UsSFF5PAPBXbGjfHCBUYP3ir
# Rbb1Hode2o+eFnJpxq57t7c+auIurQIDAQABo4IB3TCCAdkwEgYJKwYBBAGCNxUB
# BAUCAwEAATAjBgkrBgEEAYI3FQIEFgQUKqdS/mTEmr6CkTxGNSnPEP8vBO4wHQYD
# VR0OBBYEFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMFwGA1UdIARVMFMwUQYMKwYBBAGC
# N0yDfQEBMEEwPwYIKwYBBQUHAgEWM2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9w
# a2lvcHMvRG9jcy9SZXBvc2l0b3J5Lmh0bTATBgNVHSUEDDAKBggrBgEFBQcDCDAZ
# BgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/
# BAUwAwEB/zAfBgNVHSMEGDAWgBTV9lbLj+iiXGJo0T2UkFvXzpoYxDBWBgNVHR8E
# TzBNMEugSaBHhkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9k
# dWN0cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcmwwWgYIKwYBBQUHAQEETjBM
# MEoGCCsGAQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRz
# L01pY1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNydDANBgkqhkiG9w0BAQsFAAOCAgEA
# nVV9/Cqt4SwfZwExJFvhnnJL/Klv6lwUtj5OR2R4sQaTlz0xM7U518JxNj/aZGx8
# 0HU5bbsPMeTCj/ts0aGUGCLu6WZnOlNN3Zi6th542DYunKmCVgADsAW+iehp4LoJ
# 7nvfam++Kctu2D9IdQHZGN5tggz1bSNU5HhTdSRXud2f8449xvNo32X2pFaq95W2
# KFUn0CS9QKC/GbYSEhFdPSfgQJY4rPf5KYnDvBewVIVCs/wMnosZiefwC2qBwoEZ
# QhlSdYo2wh3DYXMuLGt7bj8sCXgU6ZGyqVvfSaN0DLzskYDSPeZKPmY7T7uG+jIa
# 2Zb0j/aRAfbOxnT99kxybxCrdTDFNLB62FD+CljdQDzHVG2dY3RILLFORy3BFARx
# v2T5JL5zbcqOCb2zAVdJVGTZc9d/HltEAY5aGZFrDZ+kKNxnGSgkujhLmm77IVRr
# akURR6nxt67I6IleT53S0Ex2tVdUCbFpAUR+fKFhbHP+CrvsQWY9af3LwUFJfn6T
# vsv4O+S3Fb+0zj6lMVGEvL8CwYKiexcdFYmNcP7ntdAoGokLjzbaukz5m/8K6TT4
# JDVnK+ANuOaMmdbhIurwJ0I9JZTmdHRbatGePu1+oDEzfbzL6Xu/OHBE0ZDxyKs6
# ijoIYn/ZcGNTTY3ugm2lBRDBcQZqELQdVTNYs6FwZvKhggLKMIICMwIBATCB+KGB
# 0KSBzTCByjELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNV
# BAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjElMCMG
# A1UECxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEmMCQGA1UECxMdVGhh
# bGVzIFRTUyBFU046NDlCQy1FMzdBLTIzM0MxJTAjBgNVBAMTHE1pY3Jvc29mdCBU
# aW1lLVN0YW1wIFNlcnZpY2WiIwoBATAHBgUrDgMCGgMVAGFA0rCNmEk0zU12DYNG
# MU3B1mPRoIGDMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0
# b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3Jh
# dGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwDQYJ
# KoZIhvcNAQEFBQACBQDmp/QRMCIYDzIwMjIwODE4MDcxMTEzWhgPMjAyMjA4MTkw
# NzExMTNaMHMwOQYKKwYBBAGEWQoEATErMCkwCgIFAOan9BECAQAwBgIBAAIBADAH
# AgEAAgIRrDAKAgUA5qlFkQIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgorBgEEAYRZ
# CgMCoAowCAIBAAIDB6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEBBQUAA4GBAIyX
# 6IdHQpksNinatyszaqZ4YIrcAY9d0BBbrCHrq8O6oEU83rngvzxVZc5sUltRT5hn
# SdineNVMd/lPLIl0Y5N/xt0EdjnRkJt16ILz1lLXn0wY5lKM5gCVCiSko+d2oVYu
# rapiPAiaqHcpbAnUfzDohnNGTFp+55Tma99WyagZMYIEDTCCBAkCAQEwgZMwfDEL
# MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
# bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWlj
# cm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAGXA89ZnGuJeD8AAQAAAZcw
# DQYJYIZIAWUDBAIBBQCgggFKMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAv
# BgkqhkiG9w0BCQQxIgQgtgJDCmU8LdL0xox1qz6ugDT0epbizJBghVPfcIXhAQgw
# gfoGCyqGSIb3DQEJEAIvMYHqMIHnMIHkMIG9BCBbe9obEJV6OP4EDMVJ8zF8dD5v
# HGSoLDwuQxj9BnimvzCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpX
# YXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg
# Q29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAy
# MDEwAhMzAAABlwPPWZxriXg/AAEAAAGXMCIEIAoTHc7zafNjiAWlPzvecIf7FWn6
# kqJG48DQtuMnKnqcMA0GCSqGSIb3DQEBCwUABIICAD/vS3nT2R4/leWhQWBGXxDL
# AzkH8NndB3zO2s9WfA55ugqlT0ijRRdx4FaVz3/bDRmwhauyNE6i63SnQBdcw4ac
# 9xHfgTKrmSo7oybtXDL5Isgfo8pcYYzm4wi+FMsO4StI547RMk5hE903fQibX1rF
# /8xhHXe+jcCCnvksjE4dOP5fUIFyBJjtnaZy3MR6u2u016SiutbouSKfagMZdYG/
# hXhwFOZSeg8+1Q26szH3uaUhws8UfVYTVPAUUUJeS63LrBT62XUlVDPpyrWUZQPE
# w9YMNTOvgc8c4/3MVsOOLDn5mOK3UNM0qir1rcaBfmOmE20oG/HRpgpiPVafU7cn
# qrgrMQdVSdJvzJBFHGBPta4gl+DUP3beKgzQ3kVkezT/EjacVtIyxw9+Pqjsh397
# gKBo0aYKHmdH9mM1AhvaBjOYJAPUt8tuQPFWKSkmByUIgVaXjtrzsz/L2i7HeSzI
# cNDW0NYzlBXv7NL1IHWuLxTvqzgjh3BAsFGAGrVcmHJ6h5Fd7rBiwmjiSlCFn+gj
# qZABYX3+doJfwgAE9k/LOjMeFeXEgA+1qPFdJRvOYN0yNxPhU2jHHTWRjhtkTKW5
# h0geRNKDeymkq1p+WiA29qwjG8E/pITCjavuT2YuzS0XE9thrGfzqxsp8cb4VDkH
# 33gX91YRdZ8DCDCAtcJX
# SIG # End signature block
