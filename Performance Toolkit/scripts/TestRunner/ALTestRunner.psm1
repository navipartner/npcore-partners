function Run-AlTests
(
    [string] $TestSuite = $script:DefaultTestSuite,
    [string] $TestCodeunitsRange = "",
    [string] $TestProcedureRange = "",
    [string] $ExtensionId = "",
    [ValidateSet("Disabled", "Codeunit")]
    [string] $TestIsolation = "Codeunit",
    [ValidateSet('Windows','NavUserPassword','AAD')]
    [string] $AutorizationType = $script:DefaultAuthorizationType,
    [string] $TestPage = $global:DefaultTestPage,
    [switch] $DisableSSLVerification,
    [Parameter(Mandatory=$true)]
    [string] $ServiceUrl,
    [Parameter(Mandatory=$false)]
    [pscredential] $Credential,
    [array] $DisabledTests = @(),
    [bool] $Detailed = $true,
    [ValidateSet('no','error','warning')]
    [string] $AzureDevOps = 'no',
    [bool] $SaveResultFile = $true,
    [string] $ResultsFilePath = "$PSScriptRoot\TestResults.xml",
    [ValidateSet('Disabled', 'PerRun', 'PerCodeunit', 'PerTest')]
    [string] $CodeCoverageTrackingType = 'Disabled',
    [string] $CodeCoverageOutputPath = "$PSScriptRoot\CodeCoverage",
    [string] $CodeCoverageExporterId,
    [switch] $CodeCoverageTrackAllSessions,
    [string] $CodeCoverageFilePrefix = ("TestCoverageMap_" + (get-date -Format 'yyyymmdd')),
    [bool] $StabilityRun
)
{
    $testRunArguments = @{
        TestSuite = $TestSuite
        TestCodeunitsRange = $TestCodeunitsRange
        TestProcedureRange = $TestProcedureRange
        ExtensionId = $ExtensionId
        TestRunnerId = (Get-TestRunnerId -TestIsolation $TestIsolation)
        CodeCoverageTrackingType = $CodeCoverageTrackingType
        CodeCoverageOutputPath = $CodeCoverageOutputPath
        CodeCoverageFilePrefix = $CodeCoverageFilePrefix
        CodeCoverageExporterId = $CodeCoverageExporterId
        AutorizationType = $AutorizationType
        TestPage = $TestPage
        DisableSSLVerification = $DisableSSLVerification
        ServiceUrl = $ServiceUrl
        Credential = $Credential
        DisabledTests = $DisabledTests
        Detailed = $Detailed
        StabilityRun = $StabilityRun
    }
    
    [array]$testRunResult = Run-AlTestsInternal @testRunArguments

    if($SaveResultFile)
    {
        Save-ResultsAsXUnitFile -TestRunResultObject $testRunResult -ResultsFilePath $ResultsFilePath
    }

    if($AzureDevOps  -ne 'no')
    {
        Report-ErrorsInAzureDevOps -AzureDevOps $AzureDevOps -TestRunResultObject $TestRunResultObject
    }
}

function Save-ResultsAsXUnitFile
(
    $TestRunResultObject,
    [string] $ResultsFilePath
)
{
    [xml]$XUnitDoc = New-Object System.Xml.XmlDocument
    $XUnitDoc.AppendChild($XUnitDoc.CreateXmlDeclaration("1.0","UTF-8",$null)) | Out-Null
    $XUnitAssemblies = $XUnitDoc.CreateElement("assemblies")
    $XUnitDoc.AppendChild($XUnitAssemblies) | Out-Null

    foreach($testResult in $TestRunResultObject)
    {
        $name = $testResult.name
        $startTime =  [datetime]($testResult.startTime)
        $finishTime = [datetime]($testResult.finishTime)
        $duration = $finishTime.Subtract($startTime)
        $durationSeconds = [Math]::Round($duration.TotalSeconds,3)

        $XUnitAssembly = $XUnitDoc.CreateElement("assembly")
        $XUnitAssemblies.AppendChild($XUnitAssembly) | Out-Null
        $XUnitAssembly.SetAttribute("name",$name)
        $XUnitAssembly.SetAttribute("x-code-unit",$testResult.codeUnit)
        $XUnitAssembly.SetAttribute("test-framework", "PS Test Runner")
        $XUnitAssembly.SetAttribute("run-date", $startTime.ToString("yyyy-MM-dd"))
        $XUnitAssembly.SetAttribute("run-time", $startTime.ToString("HH:mm:ss"))
        $XUnitAssembly.SetAttribute("total",0)
        $XUnitAssembly.SetAttribute("passed",0)
        $XUnitAssembly.SetAttribute("failed",0)
        $XUnitAssembly.SetAttribute("time", $durationSeconds.ToString([System.Globalization.CultureInfo]::InvariantCulture))
        $XUnitCollection = $XUnitDoc.CreateElement("collection")
        $XUnitAssembly.AppendChild($XUnitCollection) | Out-Null
        $XUnitCollection.SetAttribute("name",$name)
        $XUnitCollection.SetAttribute("total",0)
        $XUnitCollection.SetAttribute("passed",0)
        $XUnitCollection.SetAttribute("failed",0)
        $XUnitCollection.SetAttribute("skipped",0)
        $XUnitCollection.SetAttribute("time", $durationSeconds.ToString([System.Globalization.CultureInfo]::InvariantCulture))

        foreach($testMethod in $testResult.testResults)
        {
            $testMethodName = $testMethod.method
            $XUnitAssembly.SetAttribute("total",([int]$XUnitAssembly.GetAttribute("total") + 1))
            $XUnitCollection.SetAttribute("total",([int]$XUnitCollection.GetAttribute("total") + 1))
            $XUnitTest = $XUnitDoc.CreateElement("test")
            $XUnitCollection.AppendChild($XUnitTest) | Out-Null
            $XUnitTest.SetAttribute("name", $XUnitAssembly.GetAttribute("name") + ':' + $testMethodName)
            $XUnitTest.SetAttribute("method", $testMethodName)
            $startTime =  [datetime]($testMethod.startTime)
            $finishTime = [datetime]($testMethod.finishTime)
            $duration = $finishTime.Subtract($startTime)
            $durationSeconds = [Math]::Round($duration.TotalSeconds,3)
            $XUnitTest.SetAttribute("time", $durationSeconds.ToString([System.Globalization.CultureInfo]::InvariantCulture))

            switch($testMethod.result)
            {
                $script:SuccessTestResultType
                {
                    $XUnitAssembly.SetAttribute("passed",([int]$XUnitAssembly.GetAttribute("passed") + 1))
                    $XUnitCollection.SetAttribute("passed",([int]$XUnitCollection.GetAttribute("passed") + 1))
                    $XUnitTest.SetAttribute("result", "Pass")
                    break;
                }
                $script:FailureTestResultType
                {
                    $XUnitAssembly.SetAttribute("failed",([int]$XUnitAssembly.GetAttribute("failed") + 1))
                    $XUnitCollection.SetAttribute("failed",([int]$XUnitCollection.GetAttribute("failed") + 1))
                    $XUnitTest.SetAttribute("result", "Fail")
                    $XUnitFailure = $XUnitDoc.CreateElement("failure")
                    $XUnitMessage = $XUnitDoc.CreateElement("message")
                    $XUnitMessage.InnerText = $testMethod.message;
                    $XUnitFailure.AppendChild($XUnitMessage) | Out-Null
                    $XUnitStacktrace = $XUnitDoc.CreateElement("stack-trace")
                    $XUnitStacktrace.InnerText = $($testMethod.stackTrace).Replace(";","`n")
                    $XUnitFailure.AppendChild($XUnitStacktrace) | Out-Null
                    $XUnitTest.AppendChild($XUnitFailure) | Out-Null
                    break;
                }
                $script:SkippedTestResultType
                {
                    $XUnitCollection.SetAttribute("skipped",([int]$XUnitCollection.GetAttribute("skipped") + 1))
                    break;
                }
            }
        }
    }

    $XUnitDoc.Save($ResultsFilePath)
}

function Invoke-ALTestResultVerification
(
    [string] $TestResultsFolder = $(throw "Missing argument TestResultsFolder")
)
{
    $failedTestList = New-Object System.Collections.ArrayList
    $testsExecuted = $false
    [array]$testResultFiles = Get-ChildItem -Path $TestResultsFolder -Filter "*.xml" | Foreach { "$($_.FullName)" }

    if($testResultFiles.Length -eq 0)
    {
        throw "No test results were found"
    }

    foreach($resultFile in $testResultFiles)
    {
        [xml]$xmlDoc = Get-Content "$resultFile"
        [array]$failedTests = $xmlDoc.assemblies.assembly.collection.ChildNodes | Where-Object {$_.result -eq 'Fail'}
        if($failedTests)
        {
            $testsExecuted = $true
            foreach($failedTest in $failedTests)
            {
                $failedTestObject = @{
                    name = $failedTest.name;
                    method = $failedTest.method;
                    time = $failedTest.time;
                    message = $failedTest.failure.message;
                    stackTrace = $failedTest.failure.'stack-trace';
                }

                $failedTestList.Add($failedTestObject) > $null
            }
        }

         [array]$otherTests = $xmlDoc.assemblies.assembly.collection.ChildNodes | Where-Object {$_.result -ne 'Fail'}
         if($otherTests.Length -gt 0)
         {
            $testsExecuted = $true
         }
    }

    if($failedTestList.Count -gt 0) 
    {
        Write-Log "Failed tests:"
        $testsFailed = ""
        foreach($failedTest in $failedTestList)
        {
            $testsFailed += "Name: " + $failedTest.name + [environment]::NewLine
            $testsFailed += "Method: " + $failedTest.method + [environment]::NewLine
            $testsFailed += "Time: " + $failedTest.time + [environment]::NewLine
            $testsFailed += "Message: " + [environment]::NewLine + $failedTest.message + [environment]::NewLine
            $testsFailed += "StackTrace: "+ [environment]::NewLine + $failedTest.stackTrace + [environment]::NewLine  + [environment]::NewLine
        }

        Write-Log $testsFailed
        throw "Test execution failed due to the failing tests, see the list of the failed tests above."
    }

    if(-not $testsExecuted)
    {
        throw "No test codeunits were executed"
    }
}

function Report-ErrorsInAzureDevOps
(
    [ValidateSet('no','error','warning')]
    [string] $AzureDevOps = 'no',
    $TestRunResultObject
)
{
    if ($AzureDevOps -eq 'no')
    {
        return
    }

    $failedCodeunits = $TestRunResultObject | Where-Object { $_.result -eq $script:FailureTestResultType }
    $failedTests = $failedCodeunits.testResults | Where-Object { $_.result -eq $script:FailureTestResultType }

    foreach($failedTest in $failedTests)
    {
        $methodName = $failedTest.method;
        $errorMessage = $failedTests.message
        Write-Host "##vso[task.logissue type=$AzureDevOps;sourcepath=$methodName;]$errorMessage"
    }
}

function Get-DisabledAlTests
(
    [string] $DisabledTestsPath
)
{
    $DisabledTests = @()
    if(Test-Path $DisabledTestsPath)
    {
        $DisabledTests = Get-Content $DisabledTestsPath | ConvertFrom-Json
    }

    return $DisabledTests
}

function Get-TestRunnerId
(
    [ValidateSet("Disabled", "Codeunit")]
    [string] $TestIsolation = "Codeunit"
)
{
    switch($TestIsolation)
    {
        "Codeunit" 
        {
            return Get-CodeunitTestIsolationTestRunnerId
        }
        "Disabled"
        {
            return Get-DisabledTestIsolationTestRunnerId
        }
    }
}

function Get-DisabledTestIsolationTestRunnerId()
{
    return $global:TestRunnerIsolationDisabled
}

function Get-CodeunitTestIsolationTestRunnerId()
{
    return $global:TestRunnerIsolationCodeunit
}

$script:CodeunitLineType = '0'
$script:FunctionLineType = '1'

$script:FailureTestResultType = '1';
$script:SuccessTestResultType = '2';
$script:SkippedTestResultType = '3';

$script:DefaultAuthorizationType = 'NavUserPassword'
$script:DefaultTestSuite = 'DEFAULT'
$global:TestRunnerAppId = "23de40a6-dfe8-4f80-80db-d70f83ce8caf"
Import-Module "$PSScriptRoot\Internal\ALTestRunnerInternal.psm1"
# SIG # Begin signature block
# MIInqAYJKoZIhvcNAQcCoIInmTCCJ5UCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDRzo1LPLKLkcVJ
# ePQg/C9fuObYYUndok+DJyxprmENE6CCDYEwggX/MIID56ADAgECAhMzAAACzI61
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
# RcBCyZt2WwqASGv9eZ/BvW1taslScxMNelDNMYIZfTCCGXkCAQEwgZUwfjELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWljcm9z
# b2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMQITMwAAAsyOtZamvdHJTgAAAAACzDAN
# BglghkgBZQMEAgEFAKCBrDAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQgkfF3x7ew
# jvk9Nv+hnCQgoBhTSvDcLRyZCukEkTkGCQwwQAYKKwYBBAGCNwIBDDEyMDCgEoAQ
# AE0AbwBjAGsAVABlAHMAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJ
# KoZIhvcNAQEBBQAEggEADCK0hwSJ2liX/qJh2BPFBzVKKAt/+Y8Cv6iiezelaFxW
# afS2DsloYXQeY9VyC9tmhaqgCRCo7q34ei8pDaaKfu2QaQDRfGmIdzP0wYHAdfOq
# XBZD5BP1TWkBapAxKrc5Zfe2CAjhQwf1CnQzgGCGp+utCqpn7BhqVoHm0lSY9pvk
# rnGKmOR4DSI/oL1Dz5FvYivTQCDDZ9HOUSO32NGSV573tvTLj+rA4KmuYEpZ0LxT
# DmvOFRVsaIc3Zkv8F9Q2cbOHpsFbcdgyFbjr/iC3lY1mGztfAwJzlVJ87q8imhRC
# F1gM/W/xtMg4VXrs4l4DEnQGCmVKM3bwsPUrSrp3mKGCFwkwghcFBgorBgEEAYI3
# AwMBMYIW9TCCFvEGCSqGSIb3DQEHAqCCFuIwghbeAgEDMQ8wDQYJYIZIAWUDBAIB
# BQAwggFVBgsqhkiG9w0BCRABBKCCAUQEggFAMIIBPAIBAQYKKwYBBAGEWQoDATAx
# MA0GCWCGSAFlAwQCAQUABCC6jIoxiqlyCka1Un4TjRCZI52wcIG/QYGKBak/UQt7
# 3gIGYtsQqM0GGBMyMDIyMDgxODA2MDk1NC45NTFaMASAAgH0oIHUpIHRMIHOMQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSkwJwYDVQQLEyBNaWNy
# b3NvZnQgT3BlcmF0aW9ucyBQdWVydG8gUmljbzEmMCQGA1UECxMdVGhhbGVzIFRT
# UyBFU046ODk3QS1FMzU2LTE3MDExJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0
# YW1wIFNlcnZpY2WgghFcMIIHEDCCBPigAwIBAgITMwAAAasJCe+rY9ToqQABAAAB
# qzANBgkqhkiG9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
# Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
# cmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAe
# Fw0yMjAzMDIxODUxMjhaFw0yMzA1MTExODUxMjhaMIHOMQswCQYDVQQGEwJVUzET
# MBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMV
# TWljcm9zb2Z0IENvcnBvcmF0aW9uMSkwJwYDVQQLEyBNaWNyb3NvZnQgT3BlcmF0
# aW9ucyBQdWVydG8gUmljbzEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046ODk3QS1F
# MzU2LTE3MDExJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Uw
# ggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDJnUtaOXXoQElLLHC6ssds
# Jv1oqzVH6pBgcpgyLWMxJ6CrZIa3e8DbCbOIPgbjN7gV/NVpztu9JZKwtHtZpg6k
# LeNtE5m/JcLI0CjOphGjUCH1w66J61Td2sNZcfWwH+1WRAN5BxapemADt5I0Oj37
# QOIlR19yVb/fJ7Y5G7asyniTGjVnfHQWgA90QpYjKGo0wxm8mDSk78QYViC8ifFm
# HSfzQQ6aj80JfqcZumWVUngUACDrm2Y1NL36RAsRwubyNRK66mqRvtKAYYTjfoJZ
# VZJTwFmb9or9JoIwk4+2DSl+8i9sdk767x1auRjzWuXzW6ct/beXL4omKjH9UWVW
# XHHa/trwKZOYm+WuDvEogID0lMGBqDsG2RtaJx4o9AEzy5IClH4Gj8xX3eSWUm0Z
# dl4N+O/y41kC0fiowMgAhW9Om6ls7x7UCUzQ/GNI+WNkgZ0gqldszR0lbbOPmlH5
# FIbCkvhgF0t4+V1IGAO0jDaIO+jZ7LOZdNZxF+7Bw3WMpGIc7kCha0+9F1U2Xl9u
# bUgX8t1WnM2HdSUiP/cDhqmxVOdjcq5bANaopsTobLnbOz8aPozt0Y1f5AvgBDqF
# Wlw3Zop7HNz7ZQQlYf7IGJ6PQFMpm5UkZnntYMJZ5WSdLohyiPathxYGVjNdMjxu
# YFbdKa15yRYtVsZpoPgR/wIDAQABo4IBNjCCATIwHQYDVR0OBBYEFBRbzvKNXjXE
# giEGTL6hn3TS/qaqMB8GA1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8G
# A1UdHwRYMFYwVKBSoFCGTmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMv
# Y3JsL01pY3Jvc29mdCUyMFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBs
# BggrBgEFBQcBAQRgMF4wXAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0
# LmNvbS9wa2lvcHMvY2VydHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUy
# MDIwMTAoMSkuY3J0MAwGA1UdEwEB/wQCMAAwEwYDVR0lBAwwCgYIKwYBBQUHAwgw
# DQYJKoZIhvcNAQELBQADggIBAMpLlIE3NSjLMzILB24YI4BBr/3QhxX9G8vfQuOU
# ke+9P7nQjTXqpU+tdBIc9d8RhVOh3Ivky1D1J4b1J0rs+8ZIlka7uUY2WZkqJxFb
# /J6Wt89UL3lH54LcotCXeqpUspKBFSerQ7kdSsPcVPcr7YWVoULP8psjsIfpsbdA
# vcG3iyfdnq9r3PZctdqRcWwjQyfpkO7+dtIQL63lqmdNhjiYcNEeHNYj9/YjQcxz
# qM/g7DtLGI8IWs/R672DBMzg9TCXSz1n1BbGf/4k3d48xMpJNNlo52TcyHthDX5k
# Pym5Rlx3knvCWKopkxcZeZHjHy1BC4wIdJoUNbywiWdtAcAuDuexIO8jv2LgZ6Pu
# Ea1dAg9oKeATtdChVtkkPzIb0Viux24Eugc7e9K5CHklLaO6UZBzKq54bmyE3F3X
# ZMuhrWbJsDN4b6l7krTHlNVuTTdxwPMqYzy3f26Jnxsfeh7sPDq37XEL5O7YXTbu
# CYQMilF1D+3SjAiX6znaZYNI9bRNGohPqQ00kFZj8xnswi+NrJcjyVV6buMcRNIa
# QAq9rmtCx7/ywekVeQuAjuDLP6X2pf/xdzvoSWXuYsXr8yjZF128TzmtUfkiK1v6
# x2TOkSAy0ycUxhQzNYUA8mnxrvUv2u7ppL4pYARzcWX5NCGBO0UViXBu6ImPhRnc
# dXLNMIIHcTCCBVmgAwIBAgITMwAAABXF52ueAptJmQAAAAAAFTANBgkqhkiG9w0B
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
# cETRkPHIqzqKOghif9lwY1NNje6CbaUFEMFxBmoQtB1VM1izoXBm8qGCAs8wggI4
# AgEBMIH8oYHUpIHRMIHOMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3Rv
# bjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
# aW9uMSkwJwYDVQQLEyBNaWNyb3NvZnQgT3BlcmF0aW9ucyBQdWVydG8gUmljbzEm
# MCQGA1UECxMdVGhhbGVzIFRTUyBFU046ODk3QS1FMzU2LTE3MDExJTAjBgNVBAMT
# HE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2WiIwoBATAHBgUrDgMCGgMVAFuo
# ev9uFgqO1mc+ghFQHi87XJg+oIGDMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAg
# UENBIDIwMTAwDQYJKoZIhvcNAQEFBQACBQDmp9VXMCIYDzIwMjIwODE4MDEwMDA3
# WhgPMjAyMjA4MTkwMTAwMDdaMHQwOgYKKwYBBAGEWQoEATEsMCowCgIFAOan1VcC
# AQAwBwIBAAICAMkwBwIBAAICEUYwCgIFAOapJtcCAQAwNgYKKwYBBAGEWQoEAjEo
# MCYwDAYKKwYBBAGEWQoDAqAKMAgCAQACAwehIKEKMAgCAQACAwGGoDANBgkqhkiG
# 9w0BAQUFAAOBgQCltySVLJe0pf47gqe6OHKhkRt6G16MP6NnVeXh3dFkihHaeAw3
# /cHGQkMhj//ou+Se304CcY2bMqoJbBvir8LaDiYKXE5rD2prnY5lbqVBfub3Jl0X
# m/EMVw8/Rvmwac35pEuxcGLXYkIUyw2M2LsG25c1L0CoOg7P2oBw3JjLGjGCBA0w
# ggQJAgEBMIGTMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
# DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
# JjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAABqwkJ
# 76tj1OipAAEAAAGrMA0GCWCGSAFlAwQCAQUAoIIBSjAaBgkqhkiG9w0BCQMxDQYL
# KoZIhvcNAQkQAQQwLwYJKoZIhvcNAQkEMSIEIJXmJEjYTT5IzzgJ9c39pkApN3XF
# WfbVhQrNnlM8+OdBMIH6BgsqhkiG9w0BCRACLzGB6jCB5zCB5DCBvQQgDhyv+rCF
# YBFUlQ9wK75OjskCr0cRRysq2lM2zdfwClcwgZgwgYCkfjB8MQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGlt
# ZS1TdGFtcCBQQ0EgMjAxMAITMwAAAasJCe+rY9ToqQABAAABqzAiBCCYky1Yz2ZA
# XWjEAId5UJXQxgnjVCXffS/5fBn0w+7/ZTANBgkqhkiG9w0BAQsFAASCAgCXxoVi
# oq8gf9p+xlTM50TBoyza6/ANQacl+eAvcstrPDzAI5/fgjskmqle+VPiU4MIMset
# 7WOjWRfzKsb8cWZxVX4WBcBVBnJ/vlaalxcyV2fNXG/R0jcsFMmJsLw1YVbquAcQ
# S0Wx5+ZO8W24gQ8PS35A2yxKZ9xYYJGW0Q9ebK2pyApGtQdgWthXsnCXrA9tgGeu
# GWEF9wLZ69lZ15H6d7Z+PKU1N1lL4nMM5TGMvdY3fOxBDGv5GraaHnpPrLv2Cc1B
# Mh3c9iv56l6rmatz4f6at3Rod/yztHllqkOFhykILjNIXf2uVyMWrE2IptWRrT6r
# 7Bvv3gaEihS0FE6cTX38WCA+FZS+dn/DuECjsFv9y0fTFrwcyZ2ek4PYAOx9Evqb
# /4EVRr1l7PTSCuJ7o6xrOd/dDvygQ3roFnmpdZzIYF+KN08RV5ZnV0jrCWEFNyFz
# Pt6M817vIOMwLI8rq2Xb73F/WlwaUsSRBPiwQdu8aGz4x7U1m108tgTcfR0gRMy2
# WVpRDyBws7xAVtCDT81C45mOjDUiaw10lfzcoSikfzQ1Y1NRWZZSDGTONThk132z
# raxnsWgNR5hqpHLXs2RZXB6stbDjrjzZwBqoSmalx9Ouuh59yEOiEsZGIxzjJCHV
# iuY3lfS3hgfyEw36M58IDArxPOo6fKGdBKVWEQ==
# SIG # End signature block
