[CmdletBinding(DefaultParameterSetName = "Container")]
param(
    [Parameter(Mandatory = $true)]
    [Uri] $BaseServiceUrl,

    [Parameter(Mandatory = $true)]
    [ValidateSet("NavUserPassword", "AAD")] # NavUserPassword=container; AAD=SaaS
    [string] $AuthorizationType,

    [Parameter(Mandatory = $true, ParameterSetName = "Container")]
    [PSCredential]$Credential,

    [Parameter(Mandatory = $true, ParameterSetName = "SaaS")]
    [string]$BearerToken,

    [Parameter(Mandatory=$false)]
    [string] $CompanyId,

    [Parameter(Mandatory=$false)]
    [string] $APIPublisher = "",

    [Parameter(Mandatory=$false)]
    [string] $APIGroup = "",

    [Parameter(Mandatory=$false)]
    [string] $APIVersion = "v1.0",

    [Parameter(Mandatory=$false)]
    [string] $Method = "GET",

    [Parameter(Mandatory=$false)]
    [string] $Path,

    [Parameter(Mandatory=$false)]
    [string] $Query,

    [Parameter(Mandatory=$false)]
    [hashtable] $Headers = @{},

    [Parameter(Mandatory=$false)]
    [string] $InFile,

    [Parameter(Mandatory=$false)]
    [System.Object] $Body = $null,

    [Switch] $Silent,
    [Switch] $DumpResponse
)
try {
    $parameters = @{}
    if ($AuthorizationType -eq 'NavUserPassword') {
        $parameters += @{ "credential" = $Credential }
    } elseif ($AuthorizationType -eq 'AAD') {
        $Headers += @{ Authorization = "Bearer $BearerToken" }
    }

    $serviceUrl = [System.UriBuilder]::new($BaseServiceUrl.ToString())

    # Disable SSL Verification
    $shouldDisableSslVerification = ($serviceUrl.Scheme -eq "https")
    if ($shouldDisableSslVerification) {
        if (-not ([System.Management.Automation.PSTypeName]"SslVerification").Type)
        {
            Add-Type -TypeDefinition "
                using System.Net.Security;
                using System.Security.Cryptography.X509Certificates;
                public static class SslVerification
                {
                    private static bool ValidationCallback(object sender, X509Certificate certificate, X509Chain chain, SslPolicyErrors sslPolicyErrors) { return true; }
                    public static void Disable() { System.Net.ServicePointManager.ServerCertificateValidationCallback = ValidationCallback; }
                    public static void Enable()  { System.Net.ServicePointManager.ServerCertificateValidationCallback = null; }
                }"
        }
        [SslVerification]::Disable()

        # Add TLS1.2
        #[Net.ServicePointManager]::SecurityProtocol += [Net.SecurityProtocolType]::Tls12
    }

    if ($Method -eq "POST" -and !$Body) {
        #$Body = @{}
    }

    $serviceUrl.Path += "/api"

    if ($APIPublisher) {
        $serviceUrl.Path += "/$APIPublisher"
    }

    if ($APIGroup) {
        $serviceUrl.Path += "/$APIGroup"
    }

    $serviceUrl.Path += "/$APIVersion"

    if ($CompanyId) {
        $serviceUrl.Path += "/companies($CompanyId)"
    }

    if ($Path) {
        if ($Path.StartsWith('/')) {
            $serviceUrl.Path += $Path
        } else {
            $serviceUrl.Path += "/$Path"
        }
    }

    if ($Query -ne '') {
        if ($serviceUrl.Query.Contains('?')) {
            $serviceUrl.Query = $serviceUrl.Query.Trim('?') + "&$($Query)"
        } else {
            $serviceUrl.Query += "?$($Query)"
        }
    }
    
    if ($InFile) {
        $Headers += @{"Content-Type" = "application/octet-stream" }
        $Headers += @{"Accept-Encoding" = "gzip, deflate" }
        $parameters += @{ "InFile" = $InFile }
        $parameters += @{ "DisableKeepAlive" = $true }
    }
    else {
        $Headers += @{"Content-Type" = "application/json" }
    }
    
    if ($Body) {
        $parameters += @{ "body" = [System.Text.UTF8Encoding]::GetEncoding('UTF-8').GetBytes((ConvertTo-Json $Body -Depth 100)) }
    }

    $response = Invoke-WebRequest -UseBasicParsing -Method $Method -Uri $($serviceUrl.Uri) -Headers $Headers @parameters
    
    if ($DumpResponse.IsPresent) {
        $substrWidth = 80
        $totalLines = [Math]::Floor($response.Content.Length / $substrWidth)
        
        for ($i = 0; $i -le $totalLines; $i++) {
            if ($i -eq $totalLines) {
                Write-Host $response.Content.substring(($i * $substrWidth))
            } else {
                Write-Host $response.Content.substring(($i * $substrWidth), $substrWidth)
            }
        }
    }
    
    $rsp = ($response.Content | ConvertFrom-Json)
    if ($rsp.value) {
        return $rsp.value
    } else {
        return $rsp
    }
}
catch {
    Write-Host "Invoke-ŞaaSApi Failed: $($_.StatusCode)"
    Write-Host $($_.Exception.Message)
    Write-Host $($_.Exception.Status)
    Write-Host ($_ | Out-String)
    if ($_.Exception.InnerException) {
        Write-Host $_.Exception.InnerException.Message
    }
    if (-not $Silent.IsPresent) {
        throw "Invoke-ŞaaSApi failed for $($serviceUrl.Uri.ToString())"
    }
}