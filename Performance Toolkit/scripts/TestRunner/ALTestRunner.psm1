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
    [ValidateSet('Disabled','PerCodeunit','PerTest')]
    [string] $ProduceCodeCoverageMap = 'Disabled',
    [string] $CodeCoverageOutputPath = "$PSScriptRoot\CodeCoverage",
    [string] $CodeCoverageExporterId = $script:DefaultCodeCoverageExporter,
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
        ProduceCodeCoverageMap = $ProduceCodeCoverageMap
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
    $failedTestList = Get-FailedTestsFromXMLFiles -TestResultsFolder $TestResultsFolder

    if($failedTestList.Count -gt 0) 
    {
        $testsExecuted = $true;
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
        [array]$testResultFiles = Get-ChildItem -Path $TestResultsFolder -Filter "*.xml" | Foreach { "$($_.FullName)" }

        foreach($resultFile in $testResultFiles)
        {
            [xml]$xmlDoc = Get-Content "$resultFile"
            [array]$otherTests = $xmlDoc.assemblies.assembly.collection.ChildNodes | Where-Object {$_.result -ne 'Fail'}
            if($otherTests.Length -gt 0)
            {
                return;
            }

        }
        throw "No test codeunits were executed"
    }
}

function Get-FailedTestsFromXMLFiles
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
                    codeunitID = [int]($failedTest.ParentNode.ParentNode.'x-code-unit');
                    codeunitName = $failedTest.name;
                    method = $failedTest.method;
                    time = $failedTest.time;
                    message = $failedTest.failure.message;
                    stackTrace = $failedTest.failure.'stack-trace';
                }

                $failedTestList.Add($failedTestObject) > $null
            }
        }
    }

    return $failedTestList
}

function Write-DisabledTestsJson
(
    $FailedTests,
    [string] $OutputFolder = $(throw "Missing argument OutputFolder"),
    [string] $FileName = 'DisabledTests.json'
)
{
    $testsToDisable = New-Object -TypeName "System.Collections.ArrayList"
    foreach($failedTest in $failedTests)
    {
        $test = @{
                    codeunitID = $failedTest.codeunitID;
                    codeunitName = $failedTest.name;
                    method = $failedTest.method;
                }

       $testsToDisable.Add($test)
    }

    $oututFile = Join-Path $OutputFolder $FileName
    if(-not (Test-Path $outputFolder))
    {
        New-Item -Path $outputFolder -ItemType Directory
    }

    Add-Content -Value (ConvertTo-Json $testsToDisable) -Path $oututFile
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
$script:DefaultCodeCoverageExporter = 130470;
Import-Module "$PSScriptRoot\Internal\ALTestRunnerInternal.psm1"
# SIG # Begin signature block
# MIIn1QYJKoZIhvcNAQcCoIInxjCCJ8ICAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBtkHNzOqEhFY7/
# uzGO0Rj3pihWcIh8T4ugEZTXYM902aCCDYUwggYDMIID66ADAgECAhMzAAACzfNk
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
# cVZOSEXAQsmbdlsKgEhr/Xmfwb1tbWrJUnMTDXpQzTGCGaYwghmiAgEBMIGVMH4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01p
# Y3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTECEzMAAALN82S/+NRMXVEAAAAA
# As0wDQYJYIZIAWUDBAIBBQCggd4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIPLG
# xNQ9mXJsmbteS6bInDLZEKP5YdMGxRVUscpNMuKpMHIGCisGAQQBgjcCAQwxZDBi
# oESAQgBNAGkAYwByAG8AcwBvAGYAdABfAFAAZQByAGYAbwByAG0AYQBuAGMAZQAg
# AFQAbwBvAGwAawBpAHQALgBhAHAAcKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAtKdcEFZGm2rD0H7v3/9QxUXQhogyWsfkFnTI
# 4i6qTyelm8jaKDJP6gfHE//QXsKOslUq+XxvZVpVhyuZzNLV1b2daUe8zz90VkEk
# ncyO1+j6MwXnp8F6Z/LMnS0Jxwz/FHjsYBXZSDqUTXiOmEt+nQdH/l0yvc/JPHUW
# HFl4Z/2t6GqMEGjNDUpG3ZV26lD4/5d1gAwCGyDvicMkGjOKEbav1yfISwv1228N
# qAoGhO8ma2a9Yd692jERBsXwaBQ0TyURcPCpQhpbnIVf5M/GLzeBh4l+hrpON6S8
# WDIV0eRRl9VVhHFU5N3ADBzmHdUyE+Sx3hZcKT1GKIr0EBqI0qGCFwAwghb8Bgor
# BgEEAYI3AwMBMYIW7DCCFugGCSqGSIb3DQEHAqCCFtkwghbVAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFRBgsqhkiG9w0BCRABBKCCAUAEggE8MIIBOAIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCB1GPEe/YQyC99FqsRhpDWJykGSJC9HQ1RN
# ync0anCH0gIGY+53lstUGBMyMDIzMDIyMzExMTc0MC43ODlaMASAAgH0oIHQpIHN
# MIHKMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQL
# ExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25zMSYwJAYDVQQLEx1UaGFsZXMg
# VFNTIEVTTjo0OUJDLUUzN0EtMjMzQzElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUt
# U3RhbXAgU2VydmljZaCCEVcwggcMMIIE9KADAgECAhMzAAABwFWkjcNkFcVLAAEA
# AAHAMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
# aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
# cG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEw
# MB4XDTIyMTEwNDE5MDEyNVoXDTI0MDIwMjE5MDEyNVowgcoxCzAJBgNVBAYTAlVT
# MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJTAjBgNVBAsTHE1pY3Jvc29mdCBBbWVy
# aWNhIE9wZXJhdGlvbnMxJjAkBgNVBAsTHVRoYWxlcyBUU1MgRVNOOjQ5QkMtRTM3
# QS0yMzNDMSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNlMIIC
# IjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAvO1g+2NhhmBQvlGlCTOMaFw3
# jbIhUdDTqkaQhRpdHVb+huU/0HNhLmoRYvrp7z5vIoL1MPAkVBFWJIkrcG7sSred
# nyZwreY207C9n8XivL9ZBOQeiUeL/TMlJ6VinrcafbhdnkNO5JDlPozC9dGySiub
# ryds5GKtu69D1wNat9DIQl6alFO6pncZK4RIzfv+KzkM7RkY3vHphV0C8EFUpF+l
# ysaGJXFf9QsUUHwj9XKWHfc9BfhLoCReXUzvgrspdFmVnA9ATYXmidSjrshf8A+E
# 0/FpTdhXPI9XXqsZDHBqr7DlYoSCU3lvrVDRu1p5pHHf7s3kM16HpK6arDtY3ai1
# soASmEpv3C2N/y5MDBApDd4SpSkLMa7+6es/daeS7zdH1qdCa2RoJPM6Eh/6YmBf
# ofhfLQofKPJl34ALlZWK5AzVtFRNOXacoj6MAG2dT8Rc5fpKCH1E3n7Zje0dK24Q
# VfSv/YOxw52ECaMLlW5PhHT3ZINNaCmRgcHCTClOKzC2FOr03YBc2zPOW6bIVdXl
# oPmBMVaE+thXqPmANBw0YsncaOkVggjDb5O5VqOp98MklHpJoJI6pk5zAlx8/OtC
# 7FutrdtYNUC6ykXzMAPFuYkWGgx/W7A0itKW8WzYzwO3bAhprwznouGZmRiw2k8p
# en80BzqzdyPvbzTxQsMCAwEAAaOCATYwggEyMB0GA1UdDgQWBBQARMZ480jwpK3P
# 6quVWUEJ0c30hTAfBgNVHSMEGDAWgBSfpxVdAF5iXYP05dJlpxtTNRnpcjBfBgNV
# HR8EWDBWMFSgUqBQhk5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2Ny
# bC9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcmwwbAYI
# KwYBBQUHAQEEYDBeMFwGCCsGAQUFBzAChlBodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFRpbWUtU3RhbXAlMjBQQ0ElMjAy
# MDEwKDEpLmNydDAMBgNVHRMBAf8EAjAAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMA0G
# CSqGSIb3DQEBCwUAA4ICAQCtTh0EQn16kKQyCeVk9Vc10m6L0EwLRo3ATRouP7Yd
# 2hWeEB2Y4ZF4CJKe9qfXWGJKzV7tMUm6DAsBKYH/nT+8ybI8uJiHGnfnVi6Sh7gF
# jnTpfh1j1T90H/uLeoFjpOn/+eoCoJmorW5Gb2ezlTlo5I0kNAubxtCxqbLizuPN
# Pob8kRAKQgv+4/CC1JmiUFG0uKINlKj9SsHcrWeBBQHX62nNgziIwT44JqHrA02I
# 6cmQAi9BZcsf57OOLpRYlzoPH3x/+ldSySXAmyLq2uSbWtQuD84I/0ZgS/B5L3ew
# qTdiE1KbKX89MW5JqCK/yI/mAIQammAlHPqU9eZZTMPOHQs0XrpCijlk+qyo2JaH
# iySww6nuPqXzU3sEj3VW00YiVSayKEu1IrRzzX3La8qe6OqLTvK/6gu5XdKq7TT8
# 52nB6IP0QM+Budtr4Fbx4/svpKHGpK9/zBuaHHDXX5AoSksh/kSDYKfefQIhIfQJ
# JzoE3X+MimMJrgrwZXltb6j1IL0HY3qCpa03Ghgi0ITzqfkw3Man3G8kB1Ql+SeN
# ciPUj73Kn2veJenGLtT8JkUM9RUi0woO0iuY4tJnYuS+SeqavXUOWqUYVY19FIr1
# PLqpmWkbrO5xKjkyOHoAmLxjNbKjOnkAwft+1G00kulKqzqPbm+Sn+47JsGQFhNG
# bTCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZIhvcNAQEL
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
# 0ZDxyKs6ijoIYn/ZcGNTTY3ugm2lBRDBcQZqELQdVTNYs6FwZvKhggLOMIICNwIB
# ATCB+KGB0KSBzTCByjELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEmMCQGA1UE
# CxMdVGhhbGVzIFRTUyBFU046NDlCQy1FMzdBLTIzM0MxJTAjBgNVBAMTHE1pY3Jv
# c29mdCBUaW1lLVN0YW1wIFNlcnZpY2WiIwoBATAHBgUrDgMCGgMVABAQ7ExF19Kk
# wVL1E3Ad8k0Peb6doIGDMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
# c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIw
# MTAwDQYJKoZIhvcNAQEFBQACBQDnoYdfMCIYDzIwMjMwMjIzMTQzNDA3WhgPMjAy
# MzAyMjQxNDM0MDdaMHcwPQYKKwYBBAGEWQoEATEvMC0wCgIFAOehh18CAQAwCgIB
# AAICHGACAf8wBwIBAAICEc8wCgIFAOei2N8CAQAwNgYKKwYBBAGEWQoEAjEoMCYw
# DAYKKwYBBAGEWQoDAqAKMAgCAQACAwehIKEKMAgCAQACAwGGoDANBgkqhkiG9w0B
# AQUFAAOBgQAGw7JSzJV6+aS5CfDPn+6kiTVxPqxaKfoO0jjoAW8KpfhMvsYKawug
# 3N/v6BXh024pj7wUBvOICk+VvAxvkWGrgPKjf6VLFfNwQSJPi1oEEGK+/NIY9/df
# dkHLWZ4wXzDxK+LylrqFCO0SBXYicz/A4yT1rtEzyjEII8av0iaqvDGCBA0wggQJ
# AgEBMIGTMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYD
# VQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAk
# BgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAABwFWkjcNk
# FcVLAAEAAAHAMA0GCWCGSAFlAwQCAQUAoIIBSjAaBgkqhkiG9w0BCQMxDQYLKoZI
# hvcNAQkQAQQwLwYJKoZIhvcNAQkEMSIEIJbtwzOTMIvreB86/VyVwDBuFuszq3t0
# jdwaLV1wkrCbMIH6BgsqhkiG9w0BCRACLzGB6jCB5zCB5DCBvQQgWvFYolIIXME0
# zK/W6XsCkkYX7lYNb9yA8JxwY04Pk08wgZgwgYCkfjB8MQswCQYDVQQGEwJVUzET
# MBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMV
# TWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1T
# dGFtcCBQQ0EgMjAxMAITMwAAAcBVpI3DZBXFSwABAAABwDAiBCDkKY/NJHZgcuAF
# HmxnWnqzE5NvjYV33BapA3qjdnQJFjANBgkqhkiG9w0BAQsFAASCAgAycVL9mdop
# NcjsgWXnj7bJl5cucR4G4/c01SJvhoanHs9eUi/nndATaIkgBElkEkhnteitMy47
# aktRIWWyUR9cGOj4f9f1Wi1QUyrrxwXgk8qgoqA/YOAus8a4dNnNJq/GMAbTxbvg
# naXxZPeSuDShpttUWfL+KRxHU0cF9aTJRcAMBGenyWDBJov9ai7tQx1TrGitlMwQ
# N1LZW9mOeq15LznN7E56O3mmw3WJVTx0IsmIACr/OalJ1zuIslhLe/quofSk8z6K
# pQzBJAxQA/ZPtbl8qwkO6JfdSU38ylSxQ63bAjr0vvj9mvti1DfAI5BDjcKD5CbM
# IgjW2LPa1r/0SXCrQtgUy0iwD0dsTwKFDC8OBinWQxvKx/TmlilsWNMEeXtCwPJr
# okEAQbFm5RoXxak5HHUa5BZ3seytx6hpQgp24BCoGCz+e1z3PCnS5KPTtar0EnFH
# 4lnStcjgY6YbkVsAOpOKs+0xwQB5lKXZQldoUpPpzwqsH2yPJ88vLChGNhgs/T1B
# aF5+syu9ajTdizZIOow+4rzdkPRmdw50FTqbE66PnG9BFhCRauVwLpo88WDPwmCB
# A6vxcMSt7oS9vtC44n8TYTKG3qgCTgAwqesh8Y82AeMv7R/De9UKQQ9g0keIPBnG
# jdOQUHmziqRpyRMIgGqq72E46vvs8fCuEA==
# SIG # End signature block
