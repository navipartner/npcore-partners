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
# MIIn0gYJKoZIhvcNAQcCoIInwzCCJ78CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDULo9y6X5LzsKJ
# AkZGrL+saKrvTQyHizN8jHTdevUOKqCCDYUwggYDMIID66ADAgECAhMzAAACzfNk
# v/jUTF1RAAAAAALNMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjIwNTEyMjA0NjAyWhcNMjMwNTExMjA0NjAyWjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDrIzsY62MmKrzergm7Ucnu+DuSHdgzRZVCIGi9CalFrhwtiK+3FIDzlOYbs/zz
# HwuLC3hir55wVgHoaC4liQwQ60wVyR17EZPa4BQ28C5ARlxqftdp3H8RrXWbVyvQ
# aUnBQVZM73XDyGV1oUPZGHGWtgdqtBUd60VjnFPICSf8pnFiit6hvSxH5IVWI0iO
# nfqdXYoPWUtVUMmVqW1yBX0NtbQlSHIU6hlPvo9/uqKvkjFUFA2LbC9AWQbJmH+1
# uM0l4nDSKfCqccvdI5l3zjEk9yUSUmh1IQhDFn+5SL2JmnCF0jZEZ4f5HE7ykDP+
# oiA3Q+fhKCseg+0aEHi+DRPZAgMBAAGjggGCMIIBfjAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQU0WymH4CP7s1+yQktEwbcLQuR9Zww
# VAYDVR0RBE0wS6RJMEcxLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJh
# dGlvbnMgTGltaXRlZDEWMBQGA1UEBRMNMjMwMDEyKzQ3MDUzMDAfBgNVHSMEGDAW
# gBRIbmTlUAXTgqoXNzcitW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8v
# d3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIw
# MTEtMDctMDguY3JsMGEGCCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDEx
# XzIwMTEtMDctMDguY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIB
# AE7LSuuNObCBWYuttxJAgilXJ92GpyV/fTiyXHZ/9LbzXs/MfKnPwRydlmA2ak0r
# GWLDFh89zAWHFI8t9JLwpd/VRoVE3+WyzTIskdbBnHbf1yjo/+0tpHlnroFJdcDS
# MIsH+T7z3ClY+6WnjSTetpg1Y/pLOLXZpZjYeXQiFwo9G5lzUcSd8YVQNPQAGICl
# 2JRSaCNlzAdIFCF5PNKoXbJtEqDcPZ8oDrM9KdO7TqUE5VqeBe6DggY1sZYnQD+/
# LWlz5D0wCriNgGQ/TWWexMwwnEqlIwfkIcNFxo0QND/6Ya9DTAUykk2SKGSPt0kL
# tHxNEn2GJvcNtfohVY/b0tuyF05eXE3cdtYZbeGoU1xQixPZAlTdtLmeFNly82uB
# VbybAZ4Ut18F//UrugVQ9UUdK1uYmc+2SdRQQCccKwXGOuYgZ1ULW2u5PyfWxzo4
# BR++53OB/tZXQpz4OkgBZeqs9YaYLFfKRlQHVtmQghFHzB5v/WFonxDVlvPxy2go
# a0u9Z+ZlIpvooZRvm6OtXxdAjMBcWBAsnBRr/Oj5s356EDdf2l/sLwLFYE61t+ME
# iNYdy0pXL6gN3DxTVf2qjJxXFkFfjjTisndudHsguEMk8mEtnvwo9fOSKT6oRHhM
# 9sZ4HTg/TTMjUljmN3mBYWAWI5ExdC1inuog0xrKmOWVMIIHejCCBWKgAwIBAgIK
# YQ6Q0gAAAAAAAzANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlm
# aWNhdGUgQXV0aG9yaXR5IDIwMTEwHhcNMTEwNzA4MjA1OTA5WhcNMjYwNzA4MjEw
# OTA5WjB+MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYD
# VQQDEx9NaWNyb3NvZnQgQ29kZSBTaWduaW5nIFBDQSAyMDExMIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAq/D6chAcLq3YbqqCEE00uvK2WCGfQhsqa+la
# UKq4BjgaBEm6f8MMHt03a8YS2AvwOMKZBrDIOdUBFDFC04kNeWSHfpRgJGyvnkmc
# 6Whe0t+bU7IKLMOv2akrrnoJr9eWWcpgGgXpZnboMlImEi/nqwhQz7NEt13YxC4D
# dato88tt8zpcoRb0RrrgOGSsbmQ1eKagYw8t00CT+OPeBw3VXHmlSSnnDb6gE3e+
# lD3v++MrWhAfTVYoonpy4BI6t0le2O3tQ5GD2Xuye4Yb2T6xjF3oiU+EGvKhL1nk
# kDstrjNYxbc+/jLTswM9sbKvkjh+0p2ALPVOVpEhNSXDOW5kf1O6nA+tGSOEy/S6
# A4aN91/w0FK/jJSHvMAhdCVfGCi2zCcoOCWYOUo2z3yxkq4cI6epZuxhH2rhKEmd
# X4jiJV3TIUs+UsS1Vz8kA/DRelsv1SPjcF0PUUZ3s/gA4bysAoJf28AVs70b1FVL
# 5zmhD+kjSbwYuER8ReTBw3J64HLnJN+/RpnF78IcV9uDjexNSTCnq47f7Fufr/zd
# sGbiwZeBe+3W7UvnSSmnEyimp31ngOaKYnhfsi+E11ecXL93KCjx7W3DKI8sj0A3
# T8HhhUSJxAlMxdSlQy90lfdu+HggWCwTXWCVmj5PM4TasIgX3p5O9JawvEagbJjS
# 4NaIjAsCAwEAAaOCAe0wggHpMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRI
# bmTlUAXTgqoXNzcitW2oynUClTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTAL
# BgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBRyLToCMZBD
# uRQFTuHqp8cx0SOJNDBaBgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsLm1pY3Jv
# c29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFf
# MDNfMjIuY3JsMF4GCCsGAQUFBwEBBFIwUDBOBggrBgEFBQcwAoZCaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFf
# MDNfMjIuY3J0MIGfBgNVHSAEgZcwgZQwgZEGCSsGAQQBgjcuAzCBgzA/BggrBgEF
# BQcCARYzaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9kb2NzL3ByaW1h
# cnljcHMuaHRtMEAGCCsGAQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAHAAbwBsAGkA
# YwB5AF8AcwB0AGEAdABlAG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQBn
# 8oalmOBUeRou09h0ZyKbC5YR4WOSmUKWfdJ5DJDBZV8uLD74w3LRbYP+vj/oCso7
# v0epo/Np22O/IjWll11lhJB9i0ZQVdgMknzSGksc8zxCi1LQsP1r4z4HLimb5j0b
# pdS1HXeUOeLpZMlEPXh6I/MTfaaQdION9MsmAkYqwooQu6SpBQyb7Wj6aC6VoCo/
# KmtYSWMfCWluWpiW5IP0wI/zRive/DvQvTXvbiWu5a8n7dDd8w6vmSiXmE0OPQvy
# CInWH8MyGOLwxS3OW560STkKxgrCxq2u5bLZ2xWIUUVYODJxJxp/sfQn+N4sOiBp
# mLJZiWhub6e3dMNABQamASooPoI/E01mC8CzTfXhj38cbxV9Rad25UAqZaPDXVJi
# hsMdYzaXht/a8/jyFqGaJ+HNpZfQ7l1jQeNbB5yHPgZ3BtEGsXUfFL5hYbXw3MYb
# BL7fQccOKO7eZS/sl/ahXJbYANahRr1Z85elCUtIEJmAH9AAKcWxm6U/RXceNcbS
# oqKfenoi+kiVH6v7RyOA9Z74v2u3S5fi63V4GuzqN5l5GEv/1rMjaHXmr/r8i+sL
# gOppO6/8MO0ETI7f33VtY5E90Z1WTk+/gFcioXgRMiF670EKsT/7qMykXcGhiJtX
# cVZOSEXAQsmbdlsKgEhr/Xmfwb1tbWrJUnMTDXpQzTGCGaMwghmfAgEBMIGVMH4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01p
# Y3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTECEzMAAALN82S/+NRMXVEAAAAA
# As0wDQYJYIZIAWUDBAIBBQCggd4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIBZi
# vwq0hx1eqqHKKunMSEJzdPRpAAEu7FuB6ksOQ2MNMHIGCisGAQQBgjcCAQwxZDBi
# oESAQgBNAGkAYwByAG8AcwBvAGYAdABfAFAAZQByAGYAbwByAG0AYQBuAGMAZQAg
# AFQAbwBvAGwAawBpAHQALgBhAHAAcKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAh8JJxeFishaW3V+wZPfH4BjqKjWXKnb6msOV
# ONlt/UEgHPA6jfnHtdx1RjuDoEHFC6JL7Ni2qRK8AoFqPioXrttzruAO8xC4zuyx
# BTJHrwwESnATvKoEiLAe9MO+vpAOfTI1q/Rn4+cunu7mM3SgMhQ2s7YkUMV0jmqt
# LLQJrNW00uugT6o7G9iIIwtiG7fEXdFnOBUlN0OfBmYXEUOMRqXKZkZF18UKXrtw
# 7cWV8udIDuQ8CKGeboFYJq+s2a6y0YoK+isyk3d5YEV+D7DI2m6sw8PCgcGtgso6
# fPV3zHvfjam37VEmTw9W/okLgFS3rNRQfPIZMGDLubYm1EBo3KGCFv0wghb5Bgor
# BgEEAYI3AwMBMYIW6TCCFuUGCSqGSIb3DQEHAqCCFtYwghbSAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFRBgsqhkiG9w0BCRABBKCCAUAEggE8MIIBOAIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCDOC7+aEeKHsaXzuufVfvtEwhWtuYyV56ri
# rUhmMXB7dgIGY+5izsVRGBMyMDIzMDIyMzExMTc0Mi43MDZaMASAAgH0oIHQpIHN
# MIHKMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQL
# ExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25zMSYwJAYDVQQLEx1UaGFsZXMg
# VFNTIEVTTjpFNUE2LUUyN0MtNTkyRTElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUt
# U3RhbXAgU2VydmljZaCCEVQwggcMMIIE9KADAgECAhMzAAABvvQgou6W1iDWAAEA
# AAG+MA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
# aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
# cG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEw
# MB4XDTIyMTEwNDE5MDEyMloXDTI0MDIwMjE5MDEyMlowgcoxCzAJBgNVBAYTAlVT
# MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJTAjBgNVBAsTHE1pY3Jvc29mdCBBbWVy
# aWNhIE9wZXJhdGlvbnMxJjAkBgNVBAsTHVRoYWxlcyBUU1MgRVNOOkU1QTYtRTI3
# Qy01OTJFMSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNlMIIC
# IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEApV/y2z7Da7nMu0tykLY8olh7
# Z03EqFNz3iFlMp9gOfVmZABmheCc87RuPdQ2P+OHUJiqCQAWNuNSoI/Q1ixEw9AA
# 657ldD8Z3/EktpmxKHHavOhwQSFPcpTGFVXIxKCwoO824giyHPG84dfhdi6WU7f7
# D+85LaPB0dOsPHKKMGlC9p66Lv9yQzvAhZGFmFhlusCy/egrz6JX/OHOT9qCwugh
# rL0IPf47ULe1pQSEEihy438JwS+rZU4AVyvQczlMC26XsTuDPgEQKlzx9ru7EvNV
# 99l/KCU9bbFf5SnkN1moUgKUq09NWlKxzLGEvhke2QNMopn86Jh1fl/PVevN/xrZ
# SpV23rM4lB7lh7XSsCPeFslTYojKN2ioOC6p3By7kEmvZCh6rAsPKsARJISdzKQC
# Mq+mqDuiP6mr/LvuWKinP+2ZGmK/C1/skvlTjtIehu50yoXNDlh1CN9B3QLglQY+
# UCBEqJog/BxAn3pWdR01o/66XIacgXI/d0wG2/x0OtbjEGAkacfQlmw0bDc02dhQ
# Fki/1Q9Vbwh4kC7VgAiJA8bC5zEIYWHNU7C+He69B4/2dZpRjgd5pEpHbF9OYiAf
# 7s5MnYEnHN/5o/bGO0ajAb7VI4f9av62sC6xvhKTB5R4lhxEMWF0z4v7BQ5CHyMN
# kL+oTnzJLqnLVdXnuM0CAwEAAaOCATYwggEyMB0GA1UdDgQWBBTrKiAWoYRBoPGt
# bwvbhhX6a2+iqjAfBgNVHSMEGDAWgBSfpxVdAF5iXYP05dJlpxtTNRnpcjBfBgNV
# HR8EWDBWMFSgUqBQhk5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2Ny
# bC9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcmwwbAYI
# KwYBBQUHAQEEYDBeMFwGCCsGAQUFBzAChlBodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFRpbWUtU3RhbXAlMjBQQ0ElMjAy
# MDEwKDEpLmNydDAMBgNVHRMBAf8EAjAAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMA0G
# CSqGSIb3DQEBCwUAA4ICAQDHlfu9c0ImhdBis1yj56bBvOSyGpC/rSSty+1F49Tf
# 6fmFEeqxhwTTHVHOeIRNd8gcDLSz0d79mXCqq8ynq6gJgy2u4LyyAr2LmwzFVuux
# oGVR8YuUnRtvsDH5J+unye/nMkwHiC+G82h3uQ8fcGj+2H0nKPmUpUtfQruMUXvz
# LjV5NyRjDiCL5c/f5ecmz01dnpnCvE6kIz/FTpkvOeVJk22I2akFZhPz24D6OT6K
# kTtwBRpSEHDYqCQ4cZ+7SXx7jzzd7b+0p9vDboqCy7SwWgKpGQG+wVbKrTm4hKkZ
# DzcdAEgYqehXz78G00mYILiDTyUikwQpoZ7am9pA6BdTPY+o1v6CRzcneIOnJYan
# HWz0R+KER/ZRFtLCyBMvLzSHEn0sR0+0kLklncKjGdA1YA42zOb611UeIGytZ9Vh
# Nwn4ws5GJ6n6PJmMPO+yPEkOy2f8OBiuhaqlipiWhzGtt5UsC0geG0sW9qwa4QAW
# 1sQWIrhSl24MOOVwNl/Am9/ZqvLRWr1x4nupeR8G7+DNyn4MTg28yFZRU1ktSvyB
# MUSvN2K99BO6p1gSx/wvSsR45dG33PDG5fKqHOgDxctjBU5bX49eJqjNL7S/UndL
# F7S0OWL9mdk/jPVHP2I6XtN0K4VjdRwvIgr3jNib3GZyGJnORp/ZMbY2Dv1mKcx7
# dTCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZIhvcNAQEL
# BQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
# EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNV
# BAMTKU1pY3Jvc29mdCBSb290IENlcnRpZmljYXRlIEF1dGhvcml0eSAyMDEwMB4X
# DTIxMDkzMDE4MjIyNVoXDTMwMDkzMDE4MzIyNVowfDELMAkGA1UEBhMCVVMxEzAR
# BgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1p
# Y3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3Rh
# bXAgUENBIDIwMTAwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDk4aZM
# 57RyIQt5osvXJHm9DtWC0/3unAcH0qlsTnXIyjVX9gF/bErg4r25PhdgM/9cT8dm
# 95VTcVrifkpa/rg2Z4VGIwy1jRPPdzLAEBjoYH1qUoNEt6aORmsHFPPFdvWGUNzB
# RMhxXFExN6AKOG6N7dcP2CZTfDlhAnrEqv1yaa8dq6z2Nr41JmTamDu6GnszrYBb
# fowQHJ1S/rboYiXcag/PXfT+jlPP1uyFVk3v3byNpOORj7I5LFGc6XBpDco2LXCO
# Mcg1KL3jtIckw+DJj361VI/c+gVVmG1oO5pGve2krnopN6zL64NF50ZuyjLVwIYw
# XE8s4mKyzbnijYjklqwBSru+cakXW2dg3viSkR4dPf0gz3N9QZpGdc3EXzTdEonW
# /aUgfX782Z5F37ZyL9t9X4C626p+Nuw2TPYrbqgSUei/BQOj0XOmTTd0lBw0gg/w
# EPK3Rxjtp+iZfD9M269ewvPV2HM9Q07BMzlMjgK8QmguEOqEUUbi0b1qGFphAXPK
# Z6Je1yh2AuIzGHLXpyDwwvoSCtdjbwzJNmSLW6CmgyFdXzB0kZSU2LlQ+QuJYfM2
# BjUYhEfb3BvR/bLUHMVr9lxSUV0S2yW6r1AFemzFER1y7435UsSFF5PAPBXbGjfH
# CBUYP3irRbb1Hode2o+eFnJpxq57t7c+auIurQIDAQABo4IB3TCCAdkwEgYJKwYB
# BAGCNxUBBAUCAwEAATAjBgkrBgEEAYI3FQIEFgQUKqdS/mTEmr6CkTxGNSnPEP8v
# BO4wHQYDVR0OBBYEFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMFwGA1UdIARVMFMwUQYM
# KwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUHAgEWM2h0dHA6Ly93d3cubWljcm9zb2Z0
# LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5Lmh0bTATBgNVHSUEDDAKBggrBgEF
# BQcDCDAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYD
# VR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTV9lbLj+iiXGJo0T2UkFvXzpoYxDBW
# BgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2Ny
# bC9wcm9kdWN0cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcmwwWgYIKwYBBQUH
# AQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtp
# L2NlcnRzL01pY1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNydDANBgkqhkiG9w0BAQsF
# AAOCAgEAnVV9/Cqt4SwfZwExJFvhnnJL/Klv6lwUtj5OR2R4sQaTlz0xM7U518Jx
# Nj/aZGx80HU5bbsPMeTCj/ts0aGUGCLu6WZnOlNN3Zi6th542DYunKmCVgADsAW+
# iehp4LoJ7nvfam++Kctu2D9IdQHZGN5tggz1bSNU5HhTdSRXud2f8449xvNo32X2
# pFaq95W2KFUn0CS9QKC/GbYSEhFdPSfgQJY4rPf5KYnDvBewVIVCs/wMnosZiefw
# C2qBwoEZQhlSdYo2wh3DYXMuLGt7bj8sCXgU6ZGyqVvfSaN0DLzskYDSPeZKPmY7
# T7uG+jIa2Zb0j/aRAfbOxnT99kxybxCrdTDFNLB62FD+CljdQDzHVG2dY3RILLFO
# Ry3BFARxv2T5JL5zbcqOCb2zAVdJVGTZc9d/HltEAY5aGZFrDZ+kKNxnGSgkujhL
# mm77IVRrakURR6nxt67I6IleT53S0Ex2tVdUCbFpAUR+fKFhbHP+CrvsQWY9af3L
# wUFJfn6Tvsv4O+S3Fb+0zj6lMVGEvL8CwYKiexcdFYmNcP7ntdAoGokLjzbaukz5
# m/8K6TT4JDVnK+ANuOaMmdbhIurwJ0I9JZTmdHRbatGePu1+oDEzfbzL6Xu/OHBE
# 0ZDxyKs6ijoIYn/ZcGNTTY3ugm2lBRDBcQZqELQdVTNYs6FwZvKhggLLMIICNAIB
# ATCB+KGB0KSBzTCByjELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEmMCQGA1UE
# CxMdVGhhbGVzIFRTUyBFU046RTVBNi1FMjdDLTU5MkUxJTAjBgNVBAMTHE1pY3Jv
# c29mdCBUaW1lLVN0YW1wIFNlcnZpY2WiIwoBATAHBgUrDgMCGgMVAGitWlL3vPu8
# ENOAe+i2+4wfTMB7oIGDMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
# c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIw
# MTAwDQYJKoZIhvcNAQEFBQACBQDnoXKTMCIYDzIwMjMwMjIzMTMwNTIzWhgPMjAy
# MzAyMjQxMzA1MjNaMHQwOgYKKwYBBAGEWQoEATEsMCowCgIFAOehcpMCAQAwBwIB
# AAICGdgwBwIBAAICEUYwCgIFAOeixBMCAQAwNgYKKwYBBAGEWQoEAjEoMCYwDAYK
# KwYBBAGEWQoDAqAKMAgCAQACAwehIKEKMAgCAQACAwGGoDANBgkqhkiG9w0BAQUF
# AAOBgQAcuOc1UpSp4uGTTxTOOPW5Fj0CnAxtBvc107Z+YTd724sjB7qW3HvDHj4O
# 2jsFGPx5BQcJeBhNaNJw4IdnoorT/c3Phg+vUmnmS5mC+Rlhw6Nr+y7+aBwz9jKA
# hsPXX5PfWbXdD5vuT2ieqj7PkYKV8QKfr7AyBShxCNNeAlKBcDGCBA0wggQJAgEB
# MIGTMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
# EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNV
# BAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAABvvQgou6W1iDW
# AAEAAAG+MA0GCWCGSAFlAwQCAQUAoIIBSjAaBgkqhkiG9w0BCQMxDQYLKoZIhvcN
# AQkQAQQwLwYJKoZIhvcNAQkEMSIEIFMyoOPuYTCDVHA36tnwMpVCLD2pJ64/9q1a
# r2RbaDtxMIH6BgsqhkiG9w0BCRACLzGB6jCB5zCB5DCBvQQglO6Kr632/Oy9ZbXP
# rhEPidNAg/Fef7K3SZg+DxjhDC8wgZgwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEG
# A1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWlj
# cm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFt
# cCBQQ0EgMjAxMAITMwAAAb70IKLultYg1gABAAABvjAiBCBAcqudhA7Whrqr8T0x
# 65KCHS52K1v7WVC2w/BHoFEirzANBgkqhkiG9w0BAQsFAASCAgAgV8xIyAkhxSTo
# rGwPsiSabuHh+FHvn1RtDR+eGQQNsqLMA8qfosRgwi9GNLrDM/6xO5Cj3JBo9XH4
# VD5FTaPqJYu0n59rS+NJsHslIxZjT+Ra3vdFIDcubIyk+T/s9eMaVZyjG0Fhv2TF
# 4qBaBN8iRSUNeGUjXh62ekbx9LYaTkBY5WY9M6Q7b7emdn5klfnnCFf8+pjihq0w
# 2okHTSGGWxvUUvXF7g53zEDb0Y3b2fKsyh2xHahKSyFcu4HJWR/2l+9f+8UvpNR6
# NuNa7iWGjD/I+I4Mwh5WF47GnFB8idF5RiDo9aFvIF92nYb/YXAg2Se8yZzbk+Jg
# 7SwlfNz3J/tobnqIv5Kz6WxspAyxtMvjNgZbPTEuE47EKZbpP5kh3+VDQJUQXM8R
# MEAcerUBZ/0tOz92Rj7VVMKtU/PV86RSdD2l9FLf9Q6eZTXNFpVUmzcmxR9t6FeN
# Opz/P4Nsh8L+6+aKmuJMLV2bi/KH3eFAC+WzKRMlbIsZiehzK0RbLJmObA4g9Ep+
# IebGbnRVOmU9xvQFHK9B81peWLq3U5uRIcr8qvSmJy0ctIdWLb/gQ0GGIPVLtsJi
# GM8a9rfFPpOn14+2UBtxy6KUCJxXijTd1xqsjTYMCjDkGH1zCITmwpKYHmIwEZ9t
# 5tjU2bpGkmy54SHibPDOU2Z9FNFU3g==
# SIG # End signature block
