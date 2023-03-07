function Setup-Enviroment
(
    [ValidateSet("PROD","OnPrem")]
    [string] $Environment = $script:DefaultEnvironment,
    [string] $SandboxName = $script:DefaultSandboxName,
    [pscredential] $Credential,
    [pscredential] $Token,
    [string] $ClientId
)
{
    switch ($Environment)
    {
        "PROD" 
        {           
            $authority = "https://login.microsoftonline.com/"
            $resource = "https://api.businesscentral.dynamics.com"
            
            $global:AadTokenProvider = [AadTokenProvider]::new($authority,$resource,$ClientId,$Credential,$Token,$aadActiveDirectoryPath)
            $script:discoveryUrl = "https://businesscentral.dynamics.com/$($global:AadTokenProvider.tenantDomain)/$SandboxName/deployment/url" #Sandbox
            $script:automationApiBaseUrl = "https://api.businesscentral.dynamics.com/v1.0/api/microsoft/automation/v1.0/companies"
        }
    }
}

function Get-SaaSServiceURL()
{
     $status = ''

     $provisioningTimeout = new-timespan -Minutes 15
     $stopWatch = [diagnostics.stopwatch]::StartNew()
     while ($stopWatch.elapsed -lt $provisioningTimeout)
     {
        $response = Invoke-RestMethod -Method Get -Uri $script:discoveryUrl
        if($response.status -eq 'Ready')
        {
            $clusterUrl = $response.data
            return $clusterUrl
        }
        else
        {
            Write-Host "Could not get Service url status - $($response.status)"
        }

        sleep -Seconds 10
     }
}

function Run-BCPTTestsInternal
(
    [ValidateSet("PROD","OnPrem")]
    [string] $Environment,
    [ValidateSet('Windows','NavUserPassword','AAD')]
    [string] $AuthorizationType,
    [pscredential] $Credential,
    [pscredential] $Token,
    [string] $SandboxName,
    [int] $TestRunnerPage,
    [switch] $DisableSSLVerification,
    [string] $ServiceUrl,
    [string] $SuiteCode,
    [int] $SessionTimeoutInMins,
    [string] $ClientId,
    [switch] $SingleRun
)
{
    <#
        .SYNOPSIS
        Runs the Application Beanchmark Tool(BCPT) tests.

        .DESCRIPTION
        Runs BCPT tests in different environment.

        .PARAMETER Environment
        Specifies the environment the tests will be run in. The supported values are 'PROD', 'TIE' and 'OnPrem'. Default is 'PROD'.

        .PARAMETER AuthorizationType
        Specifies the authorizatin type needed to authorize to the service. The supported values are 'Windows','NavUserPassword' and 'AAD'.

        .PARAMETER Credential
        Specifies the credential object that needs to be used to authenticate. Both 'NavUserPassword' and 'AAD' needs a valid credential objects to eb passed in.
        
        .PARAMETER Token
        Specifies the AAD token credential object that needs to be used to authenticate. The credential object should contain username and token.

        .PARAMETER SandboxName
        Specifies the sandbox name. This is necessary only when the environment is either 'PROD' or 'TIE'. Default is 'sandbox'.
        
        .PARAMETER TestRunnerPage
        Specifies the page id that is used to start the tests. Defualt is 150010.
        
        .PARAMETER DisableSSLVerification
        Specifies if the SSL verification should be disabled or not.
        
        .PARAMETER ServiceUrl
        Specifies the base url of the service. This parameter is used only in 'OnPrem' environment.
        
        .PARAMETER SuiteCode
        Specifies the code that will be used to select the test suite to be run.
        
        .PARAMETER SessionTimeoutInMins
        Specifies the timeout for the client session. This will be same the length you expect the test suite to run.

        .PARAMETER ClientId
        Specifies the guid that the BC is registered with in AAD.

        .PARAMETER SingleRun
        Specifies if it is a full run or a single iteration run.

        .INPUTS
        None. You cannot pipe objects to Add-Extension.

        .EXAMPLE
        C:\PS> Run-BCPTTestsInternal -DisableSSLVerification -Environment OnPrem -AuthorizationType Windows -ServiceUrl 'htto://localhost:48900' -TestRunnerPage 150002 -SuiteCode DEMO -SessionTimeoutInMins 20
        File.txt

        .EXAMPLE
        C:\PS> Run-BCPTTestsInternal -DisableSSLVerification -Environment PROD -AuthorizationType AAD -Credential $Credential -TestRunnerPage 150002 -SuiteCode DEMO -SessionTimeoutInMins 20 -ClientId 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
    #>

    Run-NextTest -DisableSSLVerification -Environment $Environment -AuthorizationType $AuthorizationType -Credential $Credential -Token $Token -SandboxName $SandboxName -ServiceUrl $ServiceUrl -TestRunnerPage $TestRunnerPage -SuiteCode $SuiteCode -SessionTimeout $SessionTimeoutInMins -ClientId $ClientId -SingleRun:$SingleRun
}

function Run-NextTest
(
    [switch] $DisableSSLVerification,
    [ValidateSet("PROD","OnPrem")]
    [string] $Environment,
    [ValidateSet('Windows','NavUserPassword','AAD')]
    [string] $AuthorizationType,
    [pscredential] $Credential,
    [pscredential] $Token,
    [string] $SandboxName,
    [string] $ServiceUrl,
    [int] $TestRunnerPage,
    [string] $SuiteCode,
    [int] $SessionTimeout,
    [string] $ClientId,
    [switch] $SingleRun
)
{
    $aadActiveDirectoryPath = (Join-Path $PSScriptRoot "Microsoft.IdentityModel.Clients.ActiveDirectory.dll")
    [System.Reflection.Assembly]::LoadFrom($aadActiveDirectoryPath) | Out-Null
    Setup-Enviroment -Environment $Environment -SandboxName $SandboxName -Credential $Credential -Token $Token -ClientId $ClientId
    if ($Environment -ne 'OnPrem')
    {
        $ServiceUrl = Get-SaaSServiceURL
    }
    
    try
    {
        $clientContext = Open-ClientSessionWithWait -DisableSSLVerification:$DisableSSLVerification -AuthorizationType $AuthorizationType -Credential $Credential -ServiceUrl $ServiceUrl -ClientSessionTimeout $SessionTimeout
        $form = Open-TestForm -TestPage $TestRunnerPage -DisableSSLVerification:$DisableSSLVerification -AuthorizationType $AuthorizationType -ClientContext $clientContext

        $SelectSuiteControl = $clientContext.GetControlByName($form, "Select Code")
        $clientContext.SaveValue($SelectSuiteControl, $SuiteCode);

        if ($SingleRun.IsPresent)
        {
            $StartNextAction = $clientContext.GetActionByName($form, "StartNextPRT")
        }
        else
        {
            $StartNextAction = $clientContext.GetActionByName($form, "StartNext")
        }

        $clientContext.InvokeAction($StartNextAction)
        
        $clientContext.CloseForm($form)
    }
    finally
    {
        if($clientContext)
        {
            $clientContext.Dispose()
        }
    } 
}

function Get-NoOfIterations
(
    [ValidateSet("PROD","OnPrem")]
    [string] $Environment,
    [ValidateSet('Windows','NavUserPassword','AAD')]
    [string] $AuthorizationType,
    [pscredential] $Credential,
    [pscredential] $Token,
    [string] $SandboxName,
    [int] $TestRunnerPage,
    [switch] $DisableSSLVerification,
    [string] $ServiceUrl,
    [string] $SuiteCode,
    [String] $ClientId
)
{
    <#
        .SYNOPSIS
        Opens the Application Beanchmark Tool(BCPT) test runner page and reads the number of sessions that needs to be created.

        .DESCRIPTION
        Opens the Application Beanchmark Tool(BCPT) test runner page and reads the number of sessions that needs to be created.

        .PARAMETER Environment
        Specifies the environment the tests will be run in. The supported values are 'PROD', 'TIE' and 'OnPrem'.

        .PARAMETER AuthorizationType
        Specifies the authorizatin type needed to authorize to the service. The supported values are 'Windows','NavUserPassword' and 'AAD'.

        .PARAMETER Credential
        Specifies the credential object that needs to be used to authenticate. Both 'NavUserPassword' and 'AAD' needs a valid credential objects to eb passed in.
        
        .PARAMETER Token
        Specifies the AAD token credential object that needs to be used to authenticate. The credential object should contain username and token.

        .PARAMETER SandboxName
        Specifies the sandbox name. This is necessary only when the environment is either 'PROD' or 'TIE'. Default is 'sandbox'.
        
        .PARAMETER TestRunnerPage
        Specifies the page id that is used to start the tests.
        
        .PARAMETER DisableSSLVerification
        Specifies if the SSL verification should be disabled or not.
        
        .PARAMETER ServiceUrl
        Specifies the base url of the service. This parameter is used only in 'OnPrem' environment.
        
        .PARAMETER SuiteCode
        Specifies the code that will be used to select the test suite to be run.
        
        .PARAMETER ClientId
        Specifies the guid that the BC is registered with in AAD.

        .INPUTS
        None. You cannot pipe objects to Add-Extension.

        .EXAMPLE
        C:\PS> $NoOfTasks,$TaskLifeInMins,$NoOfTests = Get-NoOfIterations -DisableSSLVerification -Environment OnPrem -AuthorizationType Windows -ServiceUrl 'htto://localhost:48900' -TestRunnerPage 150010 -SuiteCode DEMO
        File.txt

        .EXAMPLE
        C:\PS> $NoOfTasks,$TaskLifeInMins,$NoOfTests = Get-NoOfIterations -DisableSSLVerification -Environment PROD -AuthorizationType AAD -Credential $Credential -TestRunnerPage 50010 -SuiteCode DEMO -ClientId 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'

    #>

    $aadActiveDirectoryPath = (Join-Path $PSScriptRoot "Microsoft.IdentityModel.Clients.ActiveDirectory.dll")
    [System.Reflection.Assembly]::LoadFrom($aadActiveDirectoryPath) | Out-Null
    Setup-Enviroment -Environment $Environment -SandboxName $SandboxName -Credential $Credential -Token $Token -ClientId $ClientId
    if ($Environment -ne 'OnPrem')
    {
        $ServiceUrl = Get-SaaSServiceURL
    }
    
    try
    {
        $clientContext = Open-ClientSessionWithWait -DisableSSLVerification:$DisableSSLVerification -AuthorizationType $AuthorizationType -Credential $Credential -ServiceUrl $ServiceUrl
        $form = Open-TestForm -TestPage $TestRunnerPage -DisableSSLVerification:$DisableSSLVerification -AuthorizationType $AuthorizationType -ClientContext $clientContext
        $SelectSuiteControl = $clientContext.GetControlByName($form, "Select Code")
        $clientContext.SaveValue($SelectSuiteControl, $SuiteCode);

        $testResultControl = $clientContext.GetControlByName($form, "No. of Instances")
        $NoOfInstances = [int]$testResultControl.StringValue

        $testResultControl = $clientContext.GetControlByName($form, "Duration (minutes)")
        $DurationInMins = [int]$testResultControl.StringValue

        $testResultControl = $clientContext.GetControlByName($form, "No. of Tests")
        $NoOfTests = [int]$testResultControl.StringValue
        
        $clientContext.CloseForm($form)
        return $NoOfInstances,$DurationInMins,$NoOfTests
    }
    finally
    {
        if($clientContext)
        {
            $clientContext.Dispose()
        }
    } 
}

$ErrorActionPreference = "Stop"

if(!$script:TypesLoaded)
{
    Add-type -Path "$PSScriptRoot\Microsoft.Dynamics.Framework.UI.Client.dll"
    Add-type -Path "$PSScriptRoot\NewtonSoft.Json.dll"
    Add-type -Path "$PSScriptRoot\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"

    $alTestRunnerInternalPath = Join-Path $PSScriptRoot "ALTestRunnerInternal.psm1"
    Import-Module "$alTestRunnerInternalPath"

    $clientContextScriptPath = Join-Path $PSScriptRoot "ClientContext.ps1"
    . "$clientContextScriptPath"
    
    $aadTokenProviderScriptPath = Join-Path $PSScriptRoot "AadTokenProvider.ps1"
    . "$aadTokenProviderScriptPath"
}

$script:TypesLoaded = $true;
$script:ActiveDirectoryDllsLoaded = $false;
$script:AadTokenProvider = $null

$script:DefaultEnvironment = "OnPrem"
$script:DefaultAuthorizationType = 'Windows'
$script:DefaultSandboxName = "sandbox"
$script:DefaultTestPage = 150002;
$script:DefaultTestSuite = 'DEFAULT'
$script:DefaultErrorActionPreference = 'Stop'

$script:DefaultTcpKeepActive = [timespan]::FromMinutes(2);
$script:DefaultTransactionTimeout = [timespan]::FromMinutes(30);
$script:DefaultCulture = "en-US";

Export-ModuleMember -Function Run-BCPTTestsInternal,Get-NoOfIterations

# SIG # Begin signature block
# MIIn1AYJKoZIhvcNAQcCoIInxTCCJ8ECAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCS0M+mCACp0V96
# zikm71mJIISdNPjLvNd2T3k1c999kaCCDYUwggYDMIID66ADAgECAhMzAAACzfNk
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
# cVZOSEXAQsmbdlsKgEhr/Xmfwb1tbWrJUnMTDXpQzTGCGaUwghmhAgEBMIGVMH4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01p
# Y3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTECEzMAAALN82S/+NRMXVEAAAAA
# As0wDQYJYIZIAWUDBAIBBQCggd4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIO73
# lYQpRYMNqr7QtfEKAv6AT7BexTO6uHxQvH3J3WI6MHIGCisGAQQBgjcCAQwxZDBi
# oESAQgBNAGkAYwByAG8AcwBvAGYAdABfAFAAZQByAGYAbwByAG0AYQBuAGMAZQAg
# AFQAbwBvAGwAawBpAHQALgBhAHAAcKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEALk6DSWwDDiWMl6vIFmG0X8iwXzm9zEzgZOyb
# iK0T+lN00iGn44aJ+Kf8EGM0hcS+tJgJ2mUECSf1iNIaIKutUTfcOknCAh8H7jk5
# Ir5CiovE+rpaELFSUnc3eb0jYaHT9BVwVAipQImKUgf9MnjayLARSR1MjMcSe+uO
# qeuv7sJHHUQt3lpP0TA7/GAxBR9/YNhqscIW4Gsgr6TAFAr2vtvmGtpdzWWURAsV
# 4iZNyiDPIlhg4KeRaKZHahXWUx3oUK1y/xbJJ+zrQw5iYD+jE26Kc/Dr+OVImFxZ
# ZMAqEngFTJP7ywfszWrHcVina6gzqGpCYgTihaK8SqUCET2Kb6GCFv8wghb7Bgor
# BgEEAYI3AwMBMYIW6zCCFucGCSqGSIb3DQEHAqCCFtgwghbUAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFRBgsqhkiG9w0BCRABBKCCAUAEggE8MIIBOAIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCDGkzLKKxgtAiUmWSeuJeKMlpIU1vAf820Q
# XeC0UQQVDQIGY+4pUKhiGBMyMDIzMDIyMzExMTc0MC44MTVaMASAAgH0oIHQpIHN
# MIHKMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQL
# ExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25zMSYwJAYDVQQLEx1UaGFsZXMg
# VFNTIEVTTjpENkJELUUzRTctMTY4NTElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUt
# U3RhbXAgU2VydmljZaCCEVYwggcMMIIE9KADAgECAhMzAAABx/sAoEpb8ifcAAEA
# AAHHMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
# aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
# cG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEw
# MB4XDTIyMTEwNDE5MDEzNVoXDTI0MDIwMjE5MDEzNVowgcoxCzAJBgNVBAYTAlVT
# MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJTAjBgNVBAsTHE1pY3Jvc29mdCBBbWVy
# aWNhIE9wZXJhdGlvbnMxJjAkBgNVBAsTHVRoYWxlcyBUU1MgRVNOOkQ2QkQtRTNF
# Ny0xNjg1MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNlMIIC
# IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAr0LcVtnatNFMBrQTtG9P8ISA
# PyyGmxNfhEzaOVlt088pBUFAIasmN/eOijE6Ucaf3c2bVnN/02ih0smSqYkm5P3Z
# wU7ZW202b6cPDJjXcrjJj0qfnuccBtE3WU0vZ8CiQD7qrKxeF8YBNcS+PVtvsqhd
# 5YW6AwhWqhjw1mYuLetF5b6aPif/3RzlyqG3SV7QPiSJends7gG435Rsy1HJ4Xnq
# ztOJR41I0j3EQ05JMF5QNRi7kT6vXTT+MHVj27FVQ7bef/U+2EAbFj2X2AOWbvgl
# YaYnM3m/I/OWDHUgGw8KIdsDh3W1eusnF2D7oenGgtahs+S1G5Uolf5ESg/9Z+38
# rhQwLgokY5k6p8k5arYWtszdJK6JiIRl843H74k7+QqlT2LbAQPq8ivQv0gdclW2
# aJun1KrW+v52R3vAHCOtbUmxvD1eNGHqGqLagtlq9UFXKXuXnqXJqruCYmfwdFMD
# 0UP6ii1lFdeKL87PdjdAwyCiVcCEoLnvDzyvjNjxtkTdz6R4yF1N/X4PSQH4Flgs
# lyBIXggaSlPtvPuxAtuac/ITj4k0IRShGiYLBM2Dw6oesLOoxe07OUPO+qXXOcJM
# VHhE0MlhhnxfN2B1JWFPWwQ6ooWiqAOQDqzcDx+79shxA1Cx0K70eOBplMog27gY
# oLpBv7nRz4tHqoTyvA0CAwEAAaOCATYwggEyMB0GA1UdDgQWBBQFUNLdHD7BAF/V
# U/X/eEHLiUSSIDAfBgNVHSMEGDAWgBSfpxVdAF5iXYP05dJlpxtTNRnpcjBfBgNV
# HR8EWDBWMFSgUqBQhk5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2Ny
# bC9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcmwwbAYI
# KwYBBQUHAQEEYDBeMFwGCCsGAQUFBzAChlBodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFRpbWUtU3RhbXAlMjBQQ0ElMjAy
# MDEwKDEpLmNydDAMBgNVHRMBAf8EAjAAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMA0G
# CSqGSIb3DQEBCwUAA4ICAQDQy5c8ogP0y8xAsLVca07wWy1mT+nqYgAFnz2972kN
# O+KJ7AE4f+SVbvOnkeeuOPq3xc+6TS8g3FuKKYEwYqvnRHxX58tjlscZsZeKnu7f
# GNUlpNT9bOQFHWALURuoXp8TLHhxj3PEq9jzFYBP2YNMLol70ojY1qpze3nMMJfp
# durdBBpaOLlJmRNTLhxd+RJGJQbY1XAcx6p/FigwqBasSDUxp+0yFPEBB9uBE3KI
# LAtq6fczGp4EMeon6YmkyCGAtXMKDFQQgdP/ITe7VghAVbPTVlP3hY1dFgc+t8YK
# 2obFSFVKslkASATDHulCMht+WrIsukclEUP9DaMmpq7S0RLODMicI6PtqqGOhdna
# RltA0d+Wf+0tPt9SUVtrPJyO7WMPKbykCRXzmHK06zr0kn1YiUYNXCsOgaHF5ImO
# 2ZwQ54UE1I55jjUdldyjy/UPJgxRm9NyXeO7adYr8K8f6Q2nPF0vWqFG7ewwaAl5
# ClKerzshfhB8zujVR0d1Ra7Z01lnXYhWuPqVZayFl7JHr6i6huhpU6BQ6/VgY0cB
# iksX4mNM+ISY81T1RYt7fWATNu/zkjINczipzbfg5S+3fCAo8gVB6+6A5L0vBg39
# dsFITv6MWJuQ8ZZy7fwlFBZE4d5IFbRudakNwKGdyLGM2otaNq7wm3ku7x41UGAm
# kDCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZIhvcNAQEL
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
# 0ZDxyKs6ijoIYn/ZcGNTTY3ugm2lBRDBcQZqELQdVTNYs6FwZvKhggLNMIICNgIB
# ATCB+KGB0KSBzTCByjELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEmMCQGA1UE
# CxMdVGhhbGVzIFRTUyBFU046RDZCRC1FM0U3LTE2ODUxJTAjBgNVBAMTHE1pY3Jv
# c29mdCBUaW1lLVN0YW1wIFNlcnZpY2WiIwoBATAHBgUrDgMCGgMVAOIASP0JSbv5
# R23wxciQivHyckYooIGDMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
# c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIw
# MTAwDQYJKoZIhvcNAQEFBQACBQDnoTkNMCIYDzIwMjMwMjIzMDg1OTU3WhgPMjAy
# MzAyMjQwODU5NTdaMHYwPAYKKwYBBAGEWQoEATEuMCwwCgIFAOehOQ0CAQAwCQIB
# AAIBUQIB/zAHAgEAAgIROTAKAgUA56KKjQIBADA2BgorBgEEAYRZCgQCMSgwJjAM
# BgorBgEEAYRZCgMCoAowCAIBAAIDB6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEB
# BQUAA4GBAIq96xHl4l9KoQdO+DkZvipR4DhxdotkAu8yCMmCZN0B0b0zAWkVPx5j
# iJXARXdH9ee5X1ok/74uGfybvzq2TfZDY+ZBlPghzFdts942Db0dBQh/30nbvJuz
# PpTb7RNnV3VVubMcw6r+bbRsOrbCDI3Y3ofj39ab/BvOS0nbpT65MYIEDTCCBAkC
# AQEwgZMwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNV
# BAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQG
# A1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAHH+wCgSlvy
# J9wAAQAAAccwDQYJYIZIAWUDBAIBBQCgggFKMBoGCSqGSIb3DQEJAzENBgsqhkiG
# 9w0BCRABBDAvBgkqhkiG9w0BCQQxIgQgKCWx/2X14Kxw+Bm0A5IAlMmRnqUTEeyg
# JxcRnaizMWEwgfoGCyqGSIb3DQEJEAIvMYHqMIHnMIHkMIG9BCBH5+Xb4lKyRQs5
# 5Vgtt4yCTsd0htESYCyPC1zLowmSyTCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0
# YW1wIFBDQSAyMDEwAhMzAAABx/sAoEpb8ifcAAEAAAHHMCIEIO5Mt4OPPCtjVYkT
# rX3358d/RSGg0Y1KadJJ2tJaRm0EMA0GCSqGSIb3DQEBCwUABIICAITnGW1mYmkl
# HsUgyajGiz8SAmMQftU96ksiXC0ZFN+3/0V+v3nVEhDbpHoePDdAf/79mvRpKPuj
# CWLfIi/I8LEtAHJkjAyKv9bn1DJ2zo5VWIYvrt5xM3o8j+dKMHIud1TYf3JZshH1
# qJWiDsfrlM50ucbahYhUFAjH6LsGemAmZgLoy7RVlKWuPznE3++oVDpC8PPdQO+l
# RBLDuHlb3EMMIxj9zMV5m4vBuQKSRD1Jip4DgnXhTlT+BdtpdSptnNZknxP6i8OI
# uKtanTGc8ec+V3P/pYCSTJbpyXUateCeqYOCfgu/KQWr3kZ9RdYKLjxA2v/gZBUp
# MZMzZY/30smhDhH1+jM/vlK5RsaFXyLoXHSa5/MTrw1KRmRbnEWkPVOcckz+IfPE
# +bFNbGfYax6NE75PvactDxB5yfzfSNLlunJw/nHJksQSFf8TKPgoPsOBmV6+aGgU
# 3TQDBSBMhUh2WnkVMHodVLojKnkHjZJ+9i9tadBZL8yjIO07NtUA/1TtwOF/C1H4
# dm3lCIdLafWh/6Z8PSx1pQgUAMdHkvoGSZE/unZ7Wak3Z+mvjEloO6hOUJX//xBs
# fXM6mz7/GmcShVf1ijrTnsmfBfRP8WpDksZh6uHnNd4FEdvZSM696KShC8k87cfX
# CT6uH8ouRpB0GlVtJ1cyD9Ojo9jk78Fz
# SIG # End signature block
