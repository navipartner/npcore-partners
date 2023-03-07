function Run-AlTestsInternal
(
    [string] $TestSuite = $script:DefaultTestSuite,
    [string] $TestCodeunitsRange = "",
    [string] $TestProcedureRange = "",
    [string] $ExtensionId = "",
    [int] $TestRunnerId = $global:DefaultTestRunner,
    [ValidateSet('Windows','NavUserPassword','AAD')]
    [string] $AutorizationType = $script:DefaultAuthorizationType,
    [string] $TestPage = $global:DefaultTestPage,
    [switch] $DisableSSLVerification,
    [Parameter(Mandatory=$true)]
    [string] $ServiceUrl,
    [Parameter(Mandatory=$false)]
    [pscredential] $Credential,
    [bool] $Detailed = $true,
    [array] $DisabledTests = @(),
    [ValidateSet('Disabled', 'PerRun', 'PerCodeunit', 'PerTest')]
    [string] $CodeCoverageTrackingType = 'Disabled',
    [ValidateSet('Disabled','PerCodeunit','PerTest')]
    [string] $ProduceCodeCoverageMap = 'Disabled',
    [string] $CodeCoverageOutputPath = "$PSScriptRoot\CodeCoverage",
    [string] $CodeCoverageExporterId,
    [switch] $CodeCoverageTrackAllSessions,
    [string] $CodeCoverageFilePrefix,
    [bool] $StabilityRun
)
{
    $ErrorActionPreference = $script:DefaultErrorActionPreference
   
    Setup-TestRun -DisableSSLVerification:$DisableSSLVerification -AutorizationType $AutorizationType -Credential $Credential -ServiceUrl $ServiceUrl -TestSuite $TestSuite -TestCodeunitsRange $TestCodeunitsRange -TestProcedureRange $TestProcedureRange -ExtensionId $ExtensionId -TestRunnerId $TestRunnerId -TestPage $TestPage -DisabledTests $DisabledTests -CodeCoverageTrackingType $CodeCoverageTrackingType -CodeCoverageTrackAllSessions:$CodeCoverageTrackAllSessions -CodeCoverageOutputPath $CodeCoverageOutputPath -CodeCoverageExporterId $CodeCoverageExporterId -ProduceCodeCoverageMap $ProduceCodeCoverageMap -StabilityRun $StabilityRun
            
    $testRunResults = New-Object System.Collections.ArrayList 
    $testResult = ''
    $numberOfUnexpectedFailures = 0;

    do
    {
        try
        {
            $testStartTime = $(Get-Date)
            $testResult = Run-NextTest -DisableSSLVerification:$DisableSSLVerification -AutorizationType $AutorizationType -Credential $Credential -ServiceUrl $ServiceUrl -TestSuite $TestSuite
            if($testResult -eq $script:AllTestsExecutedResult)
            {
                return [Array]$testRunResults
            }
 
            $testRunResultObject = ConvertFrom-Json $testResult
            if($CodeCoverageTrackingType -ne 'Disabled') {
                $null = CollectCoverageResults -TrackingType $CodeCoverageTrackingType -OutputPath $CodeCoverageOutputPath -DisableSSLVerification:$DisableSSLVerification -AutorizationType $AutorizationType -Credential $Credential -ServiceUrl $ServiceUrl -CodeCoverageFilePrefix $CodeCoverageFilePrefix
            }
       }
        catch
        {
            $numberOfUnexpectedFailures++

            $stackTrace = $_.Exception.StackTrace + "Script stack trace: " + $_.ScriptStackTrace 
            $testMethodResult = @{
                method = "Unexpected Failure"
                codeUnit = "Unexpected Failure"
                startTime = $testStartTime.ToString($script:DateTimeFormat)
                finishTime = ($(Get-Date).ToString($script:DateTimeFormat))
                result = $script:FailureTestResultType
                message = $_.Exception.Message
                stackTrace = $stackTrace
            }

            $testRunResultObject = @{
                name = "Unexpected Failure"
                codeUnit = "UnexpectedFailure"
                startTime = $testStartTime.ToString($script:DateTimeFormat)
                finishTime = ($(Get-Date).ToString($script:DateTimeFormat))
                result = $script:FailureTestResultType
                testResults = @($testMethodResult)
            }
        }
        
        $testRunResults.Add($testRunResultObject) > $null
        if($Detailed)
        {
            Print-TestResults -TestRunResultObject $testRunResultObject
        }
    }
    until((!$testRunResultObject) -or ($NumberOfUnexpectedFailuresBeforeAborting -lt $numberOfUnexpectedFailures))

    throw "Expected to end the test execution, something went wrong with returning test results."      
}

function CollectCoverageResults {
    param (
        [ValidateSet('PerRun', 'PerCodeunit', 'PerTest')]
        [string] $TrackingType,
        [string] $OutputPath,
        [switch] $DisableSSLVerification,
        [ValidateSet('Windows','NavUserPassword','AAD')]
        [string] $AutorizationType = $script:DefaultAuthorizationType,
        [Parameter(Mandatory=$false)]
        [pscredential] $Credential,
        [Parameter(Mandatory=$true)]
        [string] $ServiceUrl,
        [string] $CodeCoverageFilePrefix
    )
    try{
        $clientContext = Open-ClientSessionWithWait -DisableSSLVerification:$DisableSSLVerification -AuthorizationType $AutorizationType -Credential $Credential -ServiceUrl $ServiceUrl
        $form = Open-TestForm -TestPage $TestPage -ClientContext $clientContext
        do {
            $clientContext.InvokeAction($clientContext.GetActionByName($form, "GetCodeCoverage"))

            $CCResultControl = $clientContext.GetControlByName($form, "CCResultsCSVText")
            $CCInfoControl = $clientContext.GetControlByName($form, "CCInfo")
            $CCResult = $CCResultControl.StringValue
            $CCInfo = $CCInfoControl.StringValue
            if($CCInfo -ne $script:CCCollectedResult){
                $CCInfo = $CCInfo -replace ",","-"
                $CCOutputFilename = $CodeCoverageFilePrefix +"_$CCInfo.dat"
                Write-Host "Storing coverage results of $CCCodeunitId in:  $OutputPath\$CCOutputFilename"
                Set-Content -Path "$OutputPath\$CCOutputFilename" -Value $CCResult
            }
        } while ($CCInfo -ne $script:CCCollectedResult)
       
        if($ProduceCodeCoverageMap -ne 'Disabled') {
            $codeCoverageMapPath = Join-Path $OutputPath "TestCoverageMap"
            SaveCodeCoverageMap -OutputPath $codeCoverageMapPath  -DisableSSLVerification:$DisableSSLVerification -AutorizationType $AutorizationType -Credential $Credential -ServiceUrl $ServiceUrl
        }

        $clientContext.CloseForm($form)
    }
    finally{
        if($clientContext){
            $clientContext.Dispose()
        }
    }
}

function SaveCodeCoverageMap {
    param (
        [string] $OutputPath,
        [switch] $DisableSSLVerification,
        [ValidateSet('Windows','NavUserPassword','AAD')]
        [string] $AutorizationType = $script:DefaultAuthorizationType,
        [Parameter(Mandatory=$false)]
        [pscredential] $Credential,
        [Parameter(Mandatory=$true)]
        [string] $ServiceUrl
    )
    try{
        $clientContext = Open-ClientSessionWithWait -DisableSSLVerification:$DisableSSLVerification -AuthorizationType $AutorizationType -Credential $Credential -ServiceUrl $ServiceUrl
        $form = Open-TestForm -TestPage $TestPage -ClientContext $clientContext

        $clientContext.InvokeAction($clientContext.GetActionByName($form, "GetCodeCoverageMap"))

        $CCResultControl = $clientContext.GetControlByName($form, "CCMapCSVText")
        $CCMap = $CCResultControl.StringValue

        if (-not (Test-Path $OutputPath))
        {
            New-Item $OutputPath -ItemType Directory
        }
        
        $codeCoverageMapFileName = Join-Path $codeCoverageMapPath "TestCoverageMap.txt"
        if (-not (Test-Path $codeCoverageMapFileName))
        {
            New-Item $codeCoverageMapFileName -ItemType File
        }

        Add-Content -Path $codeCoverageMapFileName -Value $CCMap

        $clientContext.CloseForm($form)
    }
    finally{
        if($clientContext){
            $clientContext.Dispose()
        }
    }
}

function Print-TestResults
(
    $TestRunResultObject
)
{              
    $startTime = Convert-ResultStringToDateTimeSafe -DateTimeString $TestRunResultObject.startTime
    $finishTime = Convert-ResultStringToDateTimeSafe -DateTimeString $TestRunResultObject.finishTime
    $duration = $finishTime.Subtract($startTime)
    $durationSeconds = [Math]::Round($duration.TotalSeconds,3)

    switch($TestRunResultObject.result)
    {
        $script:SuccessTestResultType
        {
            Write-Host -ForegroundColor Green "Success - Codeunit $($TestRunResultObject.name) - Duration $durationSeconds seconds"
            break;
        }
        $script:FailureTestResultType
        {
            Write-Host -ForegroundColor Red "Failure - Codeunit $($TestRunResultObject.name) -  Duration $durationSeconds seconds"
            break;
        }
        default
        {
            if($codeUnitId -ne "0")
            {
                Write-Host -ForegroundColor Yellow "No tests were executed - Codeunit $"
            }
        }
    }

    if($TestRunResultObject.testResults)
    {
        foreach($testFunctionResult in $TestRunResultObject.testResults)
        {
            $durationSeconds = 0;
            $methodName = $testFunctionResult.method

            if($testFunctionResult.result -ne $script:SkippedTestResultType)
            {
                $startTime = Convert-ResultStringToDateTimeSafe -DateTimeString $testFunctionResult.startTime
                $finishTime = Convert-ResultStringToDateTimeSafe -DateTimeString $testFunctionResult.finishTime
                $duration = $finishTime.Subtract($startTime)
                $durationSeconds = [Math]::Round($duration.TotalSeconds,3)
            }

            switch($testFunctionResult.result)
            {
                $script:SuccessTestResultType
                {
                    Write-Host -ForegroundColor Green "   Success - Test method: $methodName - Duration $durationSeconds seconds)"
                    break;
                }
                $script:FailureTestResultType
                {
                    $callStack = $testFunctionResult.stackTrace
                    Write-Host -ForegroundColor Red "   Failure - Test method: $methodName - Duration $durationSeconds seconds"
                    Write-Host -ForegroundColor Red "      Error:"
                    Write-Host -ForegroundColor Red "         $($testFunctionResult.message)"
                    Write-Host -ForegroundColor Red "      Call Stack:"                    
                    if($callStack)
                    {
                        Write-Host -ForegroundColor Red "         $($callStack.Replace(';',"`n         "))"
                    }
                    break;
                }
                $script:SkippedTestResultType
                {
                    Write-Host -ForegroundColor Yellow "   Skipped - Test method: $methodName"
                    break;
                }
            }
        }
    }            
}

function Setup-TestRun
(
    [switch] $DisableSSLVerification,
    [ValidateSet('Windows','NavUserPassword','AAD')]
    [string] $AutorizationType = $script:DefaultAuthorizationType,
    [Parameter(Mandatory=$false)]
    [pscredential] $Credential,
    [Parameter(Mandatory=$true)]
    [string] $ServiceUrl,
    [string] $TestSuite = $script:DefaultTestSuite,
    [string] $TestCodeunitsRange = "",
    [string] $TestProcedureRange = "",
    [string] $ExtensionId = "",
    [int] $TestRunnerId = $global:DefaultTestRunner,
    [string] $TestPage = $global:DefaultTestPage,
    [array] $DisabledTests = @(),
    [ValidateSet('Disabled', 'PerRun', 'PerCodeunit', 'PerTest')]
    [string] $CodeCoverageTrackingType = 'Disabled',
    [ValidateSet('Disabled','PerCodeunit','PerTest')]
    [string] $ProduceCodeCoverageMap = 'Disabled',
    [string] $CodeCoverageOutputPath = "$PSScriptRoot\CodeCoverage",
    [string] $CodeCoverageExporterId,
    [switch] $CodeCoverageTrackAllSessions,
    [bool] $StabilityRun
)
{
    Write-Host "Setting up test run: $CodeCoverageTrackingType - $CodeCoverageOutputPath"
    if($CodeCoverageTrackingType -ne 'Disabled')
    {
        if (-not (Test-Path -Path $CodeCoverageOutputPath))
        {
            $null = New-Item -Path $CodeCoverageOutputPath -ItemType Directory
        }
    }

    try
    {
        $clientContext = Open-ClientSessionWithWait -DisableSSLVerification:$DisableSSLVerification -AuthorizationType $AutorizationType -Credential $Credential -ServiceUrl $ServiceUrl 

        $form = Open-TestForm -TestPage $TestPage -DisableSSLVerification:$DisableSSLVerification -AuthorizationType $AutorizationType -ClientContext $clientContext
        Set-TestSuite -TestSuite $TestSuite -ClientContext $clientContext -Form $form
        Set-ExtensionId -ExtensionId $ExtensionId -Form $form -ClientContext $clientContext
        Set-TestCodeunits -TestCodeunitsFilter $TestCodeunitsRange -Form $form -ClientContext $clientContext
        Set-TestProcedures -Filter $TestProcedureRange -Form $form $ClientContext $clientContext
        Set-TestRunner -TestRunnerId $TestRunnerId -Form $form -ClientContext $clientContext
        Set-RunFalseOnDisabledTests -DisabledTests $DisabledTests -Form $form -ClientContext $clientContext
        Set-StabilityRun -StabilityRun $StabilityRun -Form $form -ClientContext $clientContext
        Clear-TestResults -Form $form -ClientContext $clientContext
        if($CodeCoverageTrackingType -ne 'Disabled'){
            Set-CCTrackingType -Value $CodeCoverageTrackingType -Form $form -ClientContext $clientContext
            Set-CCTrackAllSessions -Value:$CodeCoverageTrackAllSessions -Form $form -ClientContext $clientContext
            Set-CCExporterID -Value $CodeCoverageExporterId -Form $form -ClientContext $clientContext
            Clear-CCResults -Form $form -ClientContext $clientContext
            Set-CCProduceCodeCoverageMap -Value $ProduceCodeCoverageMap -Form $form -ClientContext $clientContext
        }
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

function Run-NextTest
(
    [switch] $DisableSSLVerification,
    [ValidateSet('Windows','NavUserPassword','AAD')]
    [string] $AutorizationType = $script:DefaultAuthorizationType,
    [Parameter(Mandatory=$false)]
    [pscredential] $Credential,
    [Parameter(Mandatory=$true)]
    [string] $ServiceUrl,
    [string] $TestSuite = $script:DefaultTestSuite
)
{
    try
    {
        $clientContext = Open-ClientSessionWithWait -DisableSSLVerification:$DisableSSLVerification -AuthorizationType $AutorizationType -Credential $Credential -ServiceUrl $ServiceUrl
        $form = Open-TestForm -TestPage $TestPage -DisableSSLVerification:$DisableSSLVerification -AuthorizationType $AutorizationType -ClientContext $clientContext
        if($TestSuite -ne $script:DefaultTestSuite)
        {
            Set-TestSuite -TestSuite $TestSuite -ClientContext $clientContext -Form $form
        }

        $clientContext.InvokeAction($clientContext.GetActionByName($form, "RunNextTest"))
        
        $testResultControl = $clientContext.GetControlByName($form, "TestResultJson")
        $testResultJson = $testResultControl.StringValue
        $clientContext.CloseForm($form)
        return $testResultJson
    }
    finally
    {
        if($clientContext)
        {
            $clientContext.Dispose()
        }
    } 
}

function Open-ClientSessionWithWait
(
    [ValidateSet('Windows','NavUserPassword','AAD')]
    [string] $AuthorizationType = $script:DefaultAuthorizationType,
    [switch] $DisableSSLVerification,
    [string] $ServiceUrl,
    [pscredential] $Credential,
    [int] $ClientSessionTimeout = 20
)
{
        $lastErrorMessage = ""
        while(($ClientSessionTimeout -gt 0) -and (-not $clientSessionOpen))
        {
            try
            {
                $clientContext = Open-ClientSession -DisableSSLVerification:$DisableSSLVerification -AuthorizationType $AuthorizationType -Credential $Credential -ServiceUrl $ServiceUrl
                return $clientContext
            }
            catch
            {
                Start-Sleep -Seconds 1
                $ClientSessionTimeout--
                $lastErrorMessage = $_.Exception.Message
            }
        }

        throw "Could not open the client session. Check if the web server is running and you can log in. Last error: $lastErrorMessage"
}

function Set-TestCodeunits
(
    [string] $TestCodeunitsFilter,
    [ClientContext] $ClientContext,
    $Form
)
{
    if(!$TestCodeunitsFilter)
    {
        return
    }

    $testCodeunitRangeFilterControl = $ClientContext.GetControlByName($Form, "TestCodeunitRangeFilter")
    $ClientContext.SaveValue($testCodeunitRangeFilterControl, $TestCodeunitsFilter)
}

function Set-TestRunner
(
    [int] $TestRunnerId,
    [ClientContext] $ClientContext,
    $Form
)
{
    if(!$TestRunnerId)
    {
        return
    }

    $testRunnerCodeunitIdControl = $ClientContext.GetControlByName($Form, "TestRunnerCodeunitId")
    $ClientContext.SaveValue($testRunnerCodeunitIdControl, $TestRunnerId)
}

function Clear-TestResults
(
    [ClientContext] $ClientContext,
    $Form
)
{
    $ClientContext.InvokeAction($ClientContext.GetActionByName($Form, "ClearTestResults"))
}

function Set-ExtensionId
(
    [string] $ExtensionId,
    [ClientContext] $ClientContext,
    $Form
)
{
    if(!$ExtensionId)
    {
        return
    }

    $extensionIdControl = $ClientContext.GetControlByName($Form, "ExtensionId")
    $ClientContext.SaveValue($extensionIdControl, $ExtensionId)
}

function Set-TestSuite
(
    [string] $TestSuite = $script:DefaultTestSuite,
    [ClientContext] $ClientContext,
    $Form
)
{
    $suiteControl = $ClientContext.GetControlByName($Form, "CurrentSuiteName")
    $ClientContext.SaveValue($suiteControl, $TestSuite)
}

function Set-CCTrackingType
{
    param (
        [ValidateSet('Disabled', 'PerRun', 'PerCodeunit', 'PerTest')]
        [string] $Value,
        [ClientContext] $ClientContext,
        $Form
    )
    $TypeValues = @{
        Disabled = 0
        PerRun = 1
        PerCodeunit=2
        PerTest=3
    }
    $suiteControl = $ClientContext.GetControlByName($Form, "CCTrackingType")
    $ClientContext.SaveValue($suiteControl, $TypeValues[$Value])
}

function Set-CCTrackAllSessions
{
    param (
        [switch] $Value,
        [ClientContext] $ClientContext,
        $Form
    )
    if($Value){
        $suiteControl = $ClientContext.GetControlByName($Form, "CCTrackAllSessions");
        $ClientContext.SaveValue($suiteControl, $Value)
    }
}

function Set-CCExporterID
{
    param (
        [string] $Value,
        [ClientContext] $ClientContext,
        $Form
    )
    if($Value){
        $suiteControl = $ClientContext.GetControlByName($Form, "CCExporterID");
        $ClientContext.SaveValue($suiteControl, $Value)
    }
}

function Set-CCProduceCodeCoverageMap
{

    param (
        [ValidateSet('Disabled', 'PerCodeunit', 'PerTest')]
        [string] $Value,
        [ClientContext] $ClientContext,
        $Form
    )
    $TypeValues = @{
        Disabled = 0
        PerCodeunit = 1
        PerTest=2
    }
    $suiteControl = $ClientContext.GetControlByName($Form, "CCMap")
    $ClientContext.SaveValue($suiteControl, $TypeValues[$Value])
}

function Set-TestProcedures
{
    param (
        [string] $Filter,
        [ClientContext] $ClientContext,
        $Form
    )
    $Control = $ClientContext.GetControlByName($Form, "TestProcedureRangeFilter")
    $ClientContext.SaveValue($Control, $Filter)
}

function Clear-CCResults
{
    param (
        [ClientContext] $ClientContext,
        $Form
    )
    $ClientContext.InvokeAction($ClientContext.GetActionByName($Form, "ClearCodeCoverage"))
}
function Set-StabilityRun
(
    [bool] $StabilityRun,
    [ClientContext] $ClientContext,
    $Form
)
{
    $stabilityRunControl = $ClientContext.GetControlByName($Form, "StabilityRun")
    $ClientContext.SaveValue($stabilityRunControl, $StabilityRun)
}

function Set-RunFalseOnDisabledTests
(
    [ClientContext] $ClientContext,
    [array] $DisabledTests,
    $Form
)
{
    if(!$DisabledTests)
    {
        return
    }

    foreach($disabledTestMethod in $DisabledTests)
    {
        $testKey = $disabledTestMethod.codeunitName + "," + $disabledTestMethod.method
        $removeTestMethodControl = $ClientContext.GetControlByName($Form, "DisableTestMethod")
        $ClientContext.SaveValue($removeTestMethodControl, $testKey)
    }
}

function Open-TestForm(
    [int] $TestPage = $global:DefaultTestPage,
    [ClientContext] $ClientContext
)
{ 
    $form = $ClientContext.OpenForm($TestPage)
    if (!$form) 
    {
        throw "Cannot open page $TestPage. Verify if the test tool and test objects are imported and can be opened manually."
    }

    return $form;
}

function Open-ClientSession
(
    [switch] $DisableSSLVerification,
    [ValidateSet('Windows','NavUserPassword','AAD')]
    [string] $AuthorizationType,
    [Parameter(Mandatory=$false)]
    [pscredential] $Credential,
    [Parameter(Mandatory=$true)]
    [string] $ServiceUrl,
    [string] $Culture = $script:DefaultCulture,
    [timespan] $TransactionTimeout = $script:DefaultTransactionTimeout,
    [timespan] $TcpKeepActive = $script:DefaultTcpKeepActive
)
{
    [System.Net.ServicePointManager]::SetTcpKeepAlive($true, [int]$TcpKeepActive.TotalMilliseconds, [int]$TcpKeepActive.TotalMilliseconds)

    if($DisableSSLVerification)
    {
        Disable-SslVerification
    }

    switch ($AuthorizationType)
    {
        "Windows" 
        {
            $clientContext = [ClientContext]::new($ServiceUrl, $TransactionTimeout, $Culture)
            break;
        }
        "NavUserPassword" 
        {
            if ($Credential -eq $null -or $Credential -eq [System.Management.Automation.PSCredential]::Empty) 
            {
                throw "You need to specify credentials if using NavUserPassword authentication"
            }
        
            $clientContext = [ClientContext]::new($ServiceUrl, $Credential, $TransactionTimeout, $Culture)
            break;
        }
        "AAD"
        {
            $AadTokenProvider = $global:AadTokenProvider
            if ($AadTokenProvider -eq $null) 
            {
                throw "You need to specify the AadTokenProvider for obtaining the token if using AAD authentication"
            }

            $token = $AadTokenProvider.GetToken($Credential)
            $tokenCredential = [Microsoft.Dynamics.Framework.UI.Client.TokenCredential]::new($token)
            $clientContext = [ClientContext]::new($ServiceUrl, $tokenCredential, $TransactionTimeout, $Culture)
        }
    }

    return $clientContext;
}

function Disable-SslVerification
{
    if (-not ([System.Management.Automation.PSTypeName]"SslVerification").Type)
    {
        Add-Type -TypeDefinition  @"
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
public static class SslVerification
{
    private static bool ValidationCallback(object sender, X509Certificate certificate, X509Chain chain, SslPolicyErrors sslPolicyErrors) { return true; }
    public static void Disable() { System.Net.ServicePointManager.ServerCertificateValidationCallback = ValidationCallback; }
    public static void Enable()  { System.Net.ServicePointManager.ServerCertificateValidationCallback = null; }
}
"@
    }
    [SslVerification]::Disable()
}

function Enable-SslVerification
{
    if (([System.Management.Automation.PSTypeName]"SslVerification").Type)
    {
        [SslVerification]::Enable()
    }
}


function Convert-ResultStringToDateTimeSafe([string] $DateTimeString)
{
    [datetime]$parsedDateTime = New-Object DateTime
    
    try
    {
        [datetime]$parsedDateTime = [datetime]$DateTimeString
    }
    catch
    {
        Write-Host -ForegroundColor Red "Failed parsing DateTime: $DateTimeString"
    }

    return $parsedDateTime
}

if(!$script:TypesLoaded)
{
    Add-type -Path "$PSScriptRoot\Microsoft.Dynamics.Framework.UI.Client.dll"
    Add-type -Path "$PSScriptRoot\NewtonSoft.Json.dll"
    
    $clientContextScriptPath = Join-Path $PSScriptRoot "ClientContext.ps1"
    . "$clientContextScriptPath"
}

$script:TypesLoaded = $true;

$script:ActiveDirectoryDllsLoaded = $false;
$script:DateTimeFormat = 's';

# Console test tool
$global:DefaultTestPage = 130455;
$global:AadTokenProvider = $null

# Test Isolation Disabled
$global:TestRunnerIsolationCodeunit = 130450
$global:TestRunnerIsolationDisabled = 130451
$global:DefaultTestRunner = $global:TestRunnerIsolationCodeunit
$global:TestRunnerAppId = "23de40a6-dfe8-4f80-80db-d70f83ce8caf"

$script:CodeunitLineType = '0'
$script:FunctionLineType = '1'

$script:FailureTestResultType = '1';
$script:SuccessTestResultType = '2';
$script:SkippedTestResultType = '3';

$script:NumberOfUnexpectedFailuresBeforeAborting = 50;

$script:DefaultAuthorizationType = 'NavUserPassword'
$script:DefaultTestSuite = 'DEFAULT'
$script:DefaultErrorActionPreference = 'Stop'

$script:DefaultTcpKeepActive = [timespan]::FromMinutes(2);
$script:DefaultTransactionTimeout = [timespan]::FromMinutes(10);
$script:DefaultCulture = "en-US";

$script:AllTestsExecutedResult = "All tests executed."
$script:CCCollectedResult = "Done."
Export-ModuleMember -Function Run-AlTestsInternal,Open-ClientSessionWithWait, Open-TestForm, Open-ClientSession
# SIG # Begin signature block
# MIIn1QYJKoZIhvcNAQcCoIInxjCCJ8ICAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCKysbfASPyH6hm
# rFdddoCt2tgMEZMyKx7+ZR8z2oiiZ6CCDYUwggYDMIID66ADAgECAhMzAAACzfNk
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
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIEaH
# kgJWNhcgQVjRgi3hLtvA8G0DoNwA3g7SHvsLo1MQMHIGCisGAQQBgjcCAQwxZDBi
# oESAQgBNAGkAYwByAG8AcwBvAGYAdABfAFAAZQByAGYAbwByAG0AYQBuAGMAZQAg
# AFQAbwBvAGwAawBpAHQALgBhAHAAcKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAJseQKyxJ6QPLKeTfeNogKk3ZCqKXQqWIFIWB
# j1tUodbbjzFVCAmPNwPywqox1CWnW5GEG0id9nQlqtBRyFh7/L1SsAIDb7otjaHm
# YABByXn+ObpBO2qu9pOYXPcWzrXVmCnftN8yTwzKYj3//eH8RTz63FbQTUjfmj2+
# nn3buVhEVLIls+tXrrnDdVAmRNwM8EnQIzoUf5iHFfScZro9Mb/EFGJ9ykE980dY
# kpHxoYD/8Zo0YfGu+ZQMvT/5PwPuH5cG/iOgQMupL6ajdnJ6loT5REYEKkVt6jCX
# jkpCzw/WsxU5p3I3oHF8B7KjKlCNrvyxc1ZQ4mui8BvV9/SsSKGCFwAwghb8Bgor
# BgEEAYI3AwMBMYIW7DCCFugGCSqGSIb3DQEHAqCCFtkwghbVAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFRBgsqhkiG9w0BCRABBKCCAUAEggE8MIIBOAIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCDlbIpquJJWxXfPfjC9yFioyN6YJjILKJTA
# 35/Ri4m1WwIGY+53ls1EGBMyMDIzMDIyMzExMTc1MS4xNzdaMASAAgH0oIHQpIHN
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
# hvcNAQkQAQQwLwYJKoZIhvcNAQkEMSIEIHXGQX00meiMHx6GfboR0tT6FEwEIjfD
# w7W81ANmlrfLMIH6BgsqhkiG9w0BCRACLzGB6jCB5zCB5DCBvQQgWvFYolIIXME0
# zK/W6XsCkkYX7lYNb9yA8JxwY04Pk08wgZgwgYCkfjB8MQswCQYDVQQGEwJVUzET
# MBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMV
# TWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1T
# dGFtcCBQQ0EgMjAxMAITMwAAAcBVpI3DZBXFSwABAAABwDAiBCDkKY/NJHZgcuAF
# HmxnWnqzE5NvjYV33BapA3qjdnQJFjANBgkqhkiG9w0BAQsFAASCAgC0R3LtaX5P
# aVqR5hiMRhhmkU0YGpWH0y3Kh/N4+laG8vyIyQcjE/m4L9+OSHgKgL6BmzjoPCZE
# P08v9Bm6bUz9hr9Km7MtAKehNbet3MQS6ay7WwFgR2B0tklxxISMG/d5MDHH/C2k
# KntCdfC91JHB8ezI5wEeGuNjIxwRvWCT95JX3YrJS4wsOK8F+kmV2VVRpegO/s+e
# v+PudDkoDp0dLybpeuxSFntEJEEoZPPhRwvVdXgpRVhG9xDA77B3DU+cTDr3Lmhn
# 23DAP6uyPvlNiaE+xMuMClZ15utHs/5vwVmXUtpD3xyfeL3rg1j+AHsdAikP7oPE
# ATGtz4DiMOtpd8sxriHWCb3w8XQ+gmzBy9OFq4e5MuNxfdngKE2/dt2uR5zi4C96
# i/7puP9RclnjFryxel3aYR3KHd3QvMdvZ5JoqBJyhsrzI4OF3ygtuZutnmeuTcyw
# u0AZMNGg5ovmf1G3NyMuM6y2xpnEexm45mBIccmyILw9Rqg7HscCrb52DsBcUYfb
# 0CLJsSEsl1ReFpHASvKA/wM6ZSjXfd9jfimz0n9VIDTNdhRJJ8VPb7IL3ujWmno3
# K+orMqMs0mMqELuHEzEK8UhBFWkRwjgVH/sAEg0mVKyPxUbqokfo5vUkCYFxkEdA
# 4YRdXoYXUPuUGjhClzA/yf5V12Gevq8vXQ==
# SIG # End signature block
