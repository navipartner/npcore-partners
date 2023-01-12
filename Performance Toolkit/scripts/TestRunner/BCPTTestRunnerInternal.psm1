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
# MIInqgYJKoZIhvcNAQcCoIInmzCCJ5cCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCS0M+mCACp0V96
# zikm71mJIISdNPjLvNd2T3k1c999kaCCDYEwggX/MIID56ADAgECAhMzAAACzI61
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
# RcBCyZt2WwqASGv9eZ/BvW1taslScxMNelDNMYIZfzCCGXsCAQEwgZUwfjELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWljcm9z
# b2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMQITMwAAAsyOtZamvdHJTgAAAAACzDAN
# BglghkgBZQMEAgEFAKCBrDAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg7veVhClF
# gw2qvtC18QoC/oBPsF7FM7q4fFC8fcndYjowQAYKKwYBBAGCNwIBDDEyMDCgEoAQ
# AE0AbwBjAGsAVABlAHMAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJ
# KoZIhvcNAQEBBQAEggEAGVgF/Va3OD+N2LwHi6WWRhXpWpTbHVl3NAeLRGGPn3t/
# 5bR8VMbNVzhZ7K13on/RR0NxIJcEm3B6CLyr1tGSALaDF4ypszfFbN4ReiHZGpbb
# ghp88u2bBvx11W2gdWSAooZ6/oQvcrFtWQVcKPPFYaw/1kZFEaK0KIZxy1HHIXtl
# yCchdPs30Yp1u9W+Spf6FE5RWD2/VH5ZP9Sm0S7301eRp0Ayf/oIhxqaPI9dp0uL
# zbRtIpDQ9+G5fpYzT951ePWFlta1KznzOxEu3UYn5NwCKyld9cvzbyRJcAUiMRBW
# mzHRm6/0Gn9JynUGcAx/D8DCS2OjCZBtQFiCKP0bW6GCFwswghcHBgorBgEEAYI3
# AwMBMYIW9zCCFvMGCSqGSIb3DQEHAqCCFuQwghbgAgEDMQ8wDQYJYIZIAWUDBAIB
# BQAwggFVBgsqhkiG9w0BCRABBKCCAUQEggFAMIIBPAIBAQYKKwYBBAGEWQoDATAx
# MA0GCWCGSAFlAwQCAQUABCCyQttuWd8tyYNY+JmznWHmv9EIoTAR+bkVk1Hyuzsa
# VgIGYvuZzgSWGBMyMDIyMDgxODA2MDk1My42OTNaMASAAgH0oIHUpIHRMIHOMQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSkwJwYDVQQLEyBNaWNy
# b3NvZnQgT3BlcmF0aW9ucyBQdWVydG8gUmljbzEmMCQGA1UECxMdVGhhbGVzIFRT
# UyBFU046RjdBNi1FMjUxLTE1MEExJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0
# YW1wIFNlcnZpY2WgghFeMIIHEDCCBPigAwIBAgITMwAAAaUA3gjEQAdxTgABAAAB
# pTANBgkqhkiG9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
# Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
# cmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAe
# Fw0yMjAzMDIxODUxMTlaFw0yMzA1MTExODUxMTlaMIHOMQswCQYDVQQGEwJVUzET
# MBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMV
# TWljcm9zb2Z0IENvcnBvcmF0aW9uMSkwJwYDVQQLEyBNaWNyb3NvZnQgT3BlcmF0
# aW9ucyBQdWVydG8gUmljbzEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046RjdBNi1F
# MjUxLTE1MEExJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Uw
# ggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC6sYboIGpIvMLqDjDHe67B
# EJ5gIbVfIlNWNIrbB6t9E3QlyQ5r2Y2mfMrzh2BVYU8g9W+SRibcGY1s9X4JQqrM
# eagcT9VsdQmZ7ENbYkbEVkHNdlZBE5pGPMeOjIB7BsgJoTz6bIEZ5JRmoux6kBQd
# 9cf0I5Me62wJa+j25QeLTpmkdZysZeFSILLQ8H53imqBBMOIjf8U3c7WY8MhomOY
# Taem3nrZHIs4CRTt/8kR2IdILZPm0RIa5iIG2q664G8+zLJwO7ZSrxnDvYh3Ovtr
# MpqwFctws0OCDDTxXE08fME2fpKb+pRbNXhvMZX7LtjQ1irIazJSh9iaWM1gFtXw
# jg+Yq17BOCzr4sWUL253kBOvohnyEMGm4/n0XaLgFNgIhPomjbCA2qXSmm/Fi8c+
# lT0WxC/jOjBZHLKIrihx6LIQqeyYZmfYjNMqxMdl3mzoWv10N+NirERrNodNoKV+
# sAcsk/Hg9zCVSMUkZuDCyIpb1nKXfTd66KGsGy1OoHZO4KClkuvfsNo7aLlwhGLe
# iD32avJXYtC/wsGG7b+5mx5iGfTnNCRCXOm/YHFQ36D4npjCnM9eQS3qcse56UNj
# IgyiLHDqioV7mSPj2XqzTh4Yv77MtvxY/ZQepCazGEn1dBdn67wUgVzAe8Y7/KYK
# l+UF1HvJ08W+FHydHAwLwQIDAQABo4IBNjCCATIwHQYDVR0OBBYEFF+mjwMAl66u
# rXDu+9xZF0toqRrfMB8GA1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8G
# A1UdHwRYMFYwVKBSoFCGTmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMv
# Y3JsL01pY3Jvc29mdCUyMFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBs
# BggrBgEFBQcBAQRgMF4wXAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0
# LmNvbS9wa2lvcHMvY2VydHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUy
# MDIwMTAoMSkuY3J0MAwGA1UdEwEB/wQCMAAwEwYDVR0lBAwwCgYIKwYBBQUHAwgw
# DQYJKoZIhvcNAQELBQADggIBAJabCxflMDCihEdqdFiZ6OBuhhhp34N6ow3Wh3Ob
# r12LRuiph66gH/2Kh5JjaLUq+mRBJ5RgiWEe1t7ifuW6b49N8Bahnn70LCiEdvqu
# k686M7z+DbKHVk0+UlafwukxAxriwvZjkCgOLci+NB01u7cW9HAHX4J8hxaCPwbG
# aPxWl3s0PITuMVI4Q6cjTXielmL1+TQvh7/Z5k8s46shIPy9nFwDpsRFr3zwENZX
# 8b67VMBu+YxnlGnsJIcLc2pwpz95emI8CRSgep+/017a34pNcWNZIHr9ScEOWlHT
# 8cEnQ5hhOF0zdrOqTzovCDtffTn+gBL4eNXg8Uc/tdVVHKbhp+7SVHkk1Eh7L80P
# BAjo+cO+zL+efxfIVrtO3oJxvEq1o+fkxcTTwqcfwBTb88/qHU0U2XeC1rqJnDB1
# JixYlBjgHXrRekqHxxuRHBZ9A0w9WqQWcwj/MbBkHGYMFaqO6L9t/7iCZTAiwMk2
# GVfSEwj9PXIlCWygVQkDaxhJ0P1yxTvZsrMsg0a7x4VObhj3V8+Cbdv2TeyUGEbl
# TUrgqTcKCtCa9bOnIg7xxHi8onM8aCHvRh90sn2x8er/6YSPohNw1qNUwiu+RC+q
# bepOYt+v5J9rklV3Ux+OGVZId/4oVd7xMLO/Lhpb7IjHKygYKaNx3XIwx4h6FrFH
# +BiMMIIHcTCCBVmgAwIBAgITMwAAABXF52ueAptJmQAAAAAAFTANBgkqhkiG9w0B
# AQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNV
# BAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAG
# A1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5IDIwMTAw
# HhcNMjEwOTMwMTgyMjI1WhcNMzAwOTMwMTgzMjI1WjB8MQswCQYDVQQGEwJVUzET
# MBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMV
# TWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1T
# dGFtcCBQQ0EgMjAxMDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAOTh
# pkzntHIhC3miy9ckeb0O1YLT/e6cBwfSqWxOdcjKNVf2AX9sSuDivbk+F2Az/1xP
# x2b3lVNxWuJ+Slr+uDZnhUYjDLWNE893MsAQGOhgfWpSg0S3po5GawcU88V29YZQ
# 3MFEyHFcUTE3oAo4bo3t1w/YJlN8OWECesSq/XJprx2rrPY2vjUmZNqYO7oaezOt
# gFt+jBAcnVL+tuhiJdxqD89d9P6OU8/W7IVWTe/dvI2k45GPsjksUZzpcGkNyjYt
# cI4xyDUoveO0hyTD4MmPfrVUj9z6BVWYbWg7mka97aSueik3rMvrg0XnRm7KMtXA
# hjBcTyziYrLNueKNiOSWrAFKu75xqRdbZ2De+JKRHh09/SDPc31BmkZ1zcRfNN0S
# idb9pSB9fvzZnkXftnIv231fgLrbqn427DZM9ituqBJR6L8FA6PRc6ZNN3SUHDSC
# D/AQ8rdHGO2n6Jl8P0zbr17C89XYcz1DTsEzOUyOArxCaC4Q6oRRRuLRvWoYWmEB
# c8pnol7XKHYC4jMYctenIPDC+hIK12NvDMk2ZItboKaDIV1fMHSRlJTYuVD5C4lh
# 8zYGNRiER9vcG9H9stQcxWv2XFJRXRLbJbqvUAV6bMURHXLvjflSxIUXk8A8Fdsa
# N8cIFRg/eKtFtvUeh17aj54WcmnGrnu3tz5q4i6tAgMBAAGjggHdMIIB2TASBgkr
# BgEEAYI3FQEEBQIDAQABMCMGCSsGAQQBgjcVAgQWBBQqp1L+ZMSavoKRPEY1Kc8Q
# /y8E7jAdBgNVHQ4EFgQUn6cVXQBeYl2D9OXSZacbUzUZ6XIwXAYDVR0gBFUwUzBR
# BgwrBgEEAYI3TIN9AQEwQTA/BggrBgEFBQcCARYzaHR0cDovL3d3dy5taWNyb3Nv
# ZnQuY29tL3BraW9wcy9Eb2NzL1JlcG9zaXRvcnkuaHRtMBMGA1UdJQQMMAoGCCsG
# AQUFBwMIMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1UdDwQEAwIBhjAP
# BgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFNX2VsuP6KJcYmjRPZSQW9fOmhjE
# MFYGA1UdHwRPME0wS6BJoEeGRWh0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kv
# Y3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNybDBaBggrBgEF
# BQcBAQROMEwwSgYIKwYBBQUHMAKGPmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9w
# a2kvY2VydHMvTWljUm9vQ2VyQXV0XzIwMTAtMDYtMjMuY3J0MA0GCSqGSIb3DQEB
# CwUAA4ICAQCdVX38Kq3hLB9nATEkW+Geckv8qW/qXBS2Pk5HZHixBpOXPTEztTnX
# wnE2P9pkbHzQdTltuw8x5MKP+2zRoZQYIu7pZmc6U03dmLq2HnjYNi6cqYJWAAOw
# Bb6J6Gngugnue99qb74py27YP0h1AdkY3m2CDPVtI1TkeFN1JFe53Z/zjj3G82jf
# ZfakVqr3lbYoVSfQJL1AoL8ZthISEV09J+BAljis9/kpicO8F7BUhUKz/AyeixmJ
# 5/ALaoHCgRlCGVJ1ijbCHcNhcy4sa3tuPywJeBTpkbKpW99Jo3QMvOyRgNI95ko+
# ZjtPu4b6MhrZlvSP9pEB9s7GdP32THJvEKt1MMU0sHrYUP4KWN1APMdUbZ1jdEgs
# sU5HLcEUBHG/ZPkkvnNtyo4JvbMBV0lUZNlz138eW0QBjloZkWsNn6Qo3GcZKCS6
# OEuabvshVGtqRRFHqfG3rsjoiV5PndLQTHa1V1QJsWkBRH58oWFsc/4Ku+xBZj1p
# /cvBQUl+fpO+y/g75LcVv7TOPqUxUYS8vwLBgqJ7Fx0ViY1w/ue10CgaiQuPNtq6
# TPmb/wrpNPgkNWcr4A245oyZ1uEi6vAnQj0llOZ0dFtq0Z4+7X6gMTN9vMvpe784
# cETRkPHIqzqKOghif9lwY1NNje6CbaUFEMFxBmoQtB1VM1izoXBm8qGCAtEwggI6
# AgEBMIH8oYHUpIHRMIHOMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3Rv
# bjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
# aW9uMSkwJwYDVQQLEyBNaWNyb3NvZnQgT3BlcmF0aW9ucyBQdWVydG8gUmljbzEm
# MCQGA1UECxMdVGhhbGVzIFRTUyBFU046RjdBNi1FMjUxLTE1MEExJTAjBgNVBAMT
# HE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2WiIwoBATAHBgUrDgMCGgMVALPJ
# cNtFs5sQyojdS4Ye5mVl7rSooIGDMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAg
# UENBIDIwMTAwDQYJKoZIhvcNAQEFBQACBQDmqBKGMCIYDzIwMjIwODE4MDUyMTEw
# WhgPMjAyMjA4MTkwNTIxMTBaMHYwPAYKKwYBBAGEWQoEATEuMCwwCgIFAOaoEoYC
# AQAwCQIBAAIBfwIB/zAHAgEAAgIRXTAKAgUA5qlkBgIBADA2BgorBgEEAYRZCgQC
# MSgwJjAMBgorBgEEAYRZCgMCoAowCAIBAAIDB6EgoQowCAIBAAIDAYagMA0GCSqG
# SIb3DQEBBQUAA4GBAAkGwlkZb70SinK0J5Rnos5Xc9ZsoVLjfvkTZSBJWP+ss2T0
# bicasKp+pt/ovBfGgiyxW68lybxJr5tRXczeLsb7LUwEzGXW/Ppmsie32q6Yr9HI
# cQbs7gxsyO8Ta+/n7+xm28nvODQvdH/L2mizrM5s72cxz/qd3TRMXtExnvA+MYIE
# DTCCBAkCAQEwgZMwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAGl
# AN4IxEAHcU4AAQAAAaUwDQYJYIZIAWUDBAIBBQCgggFKMBoGCSqGSIb3DQEJAzEN
# BgsqhkiG9w0BCRABBDAvBgkqhkiG9w0BCQQxIgQgjBrI+QQdKsUjEgkzXA+daP3i
# JcBSW2UPOiN80DnXGp8wgfoGCyqGSIb3DQEJEAIvMYHqMIHnMIHkMIG9BCC4Cjhx
# fmYEsaCt2AU83Khh+6JHlyk3B70vfMHMlBLcXDCBmDCBgKR+MHwxCzAJBgNVBAYT
# AlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBU
# aW1lLVN0YW1wIFBDQSAyMDEwAhMzAAABpQDeCMRAB3FOAAEAAAGlMCIEIBFFVjcT
# Ww2Q/tAu3dNRsSlMiaeg8Wj3uHWpDWxadYBzMA0GCSqGSIb3DQEBCwUABIICAEfb
# d8gyk0U1unSg1weJV+M+Rk4Hh8UQVpIJEKDp/6WSG1xothlKMwrWEvgPwyfRO64/
# Wmi7GpxB9/9qS8SNYxlbyX66eJ6p2EzCKTz12lm9nCxlwd5LCQ6zzT78xZY8p1cZ
# hqrlJv/kPW4eVphT2QcjMjsxkbJ4+622eaT6WebFV86XMo5JrHiq/udY/mfPKSVm
# z5CAmjq9eN8pezq72hY6ohNESp7kjw0YtlmRjrVdNT4ZCyxEmCv0cU6mL0y85TbS
# /JZ9KkxeKGCltFEcep1CpdTmaYJUogwpaAjf79X1eEkAfocQhaNAf0i9kziSsEMy
# tpPxEB8yhucu76HUyxFThacCSzMpyyouH632N6qeY1U5KKQqhLCWdCkjxulw7tk1
# +0cVdXiWadb/55fTvwMLAliYXmTc1y+HOh8Pq1i3TvDRSdoasc9Ad1qdTQetcDrQ
# 8b8FL2CQqSUTQmf3P33C2Jtui8Lp542t1y3P2gLkK4OBLk56I0xj6WzJL+6I2GNP
# cVzhwaK1/EEYroZsZYDvICyXCYV7du62wa78ZMGaQohVBNTeZOxLygW7BkfhRH7P
# mhLf6YGnac7RtBJdMenRYL8QKXK/R+aMfcFrSwo3q6bRlioH8DVlwefSfHMnEubI
# MiuILBldDd/znQ8ssTIOng+slP82MqiYVF/nqKIv
# SIG # End signature block
