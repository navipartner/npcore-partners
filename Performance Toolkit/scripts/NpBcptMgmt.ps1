class NpBcptMgmt
{
    [ValidateSet('Cloud','Crane')]
    [String] $BcType
    [string] $Username
    [string] $Password
    [String] $TenantId
    [String] $SandboxName
    [String] $CompanyName
    [string] $ClientId

    [string] $AadActiveDirectoryPath
    [string] $Token

    NpBcptMgmt([String] $BcType, [string] $Username, [string] $Password, [String] $TenantId, [String] $SandboxName, [String] $CompanyName, [String] $ClientId, [string] $AadActiveDirectoryPath)
    {
        $this.BcType = $BcType
        $this.Username = $Username
        $this.Password = $Password
        $this.TenantId = $TenantId
        $this.SandboxName = $SandboxName
        $this.CompanyName = $CompanyName
        $this.ClientId = $ClientId
        $this.AadActiveDirectoryPath = $AadActiveDirectoryPath
    }

    [void] WaitForEnvironment()
    {
        # Crane
        if ($this.BcType -eq 'Crane') {
            return;
        }
        # Cloud
        else {
            $isReady = $false
            Do {
                $response = Invoke-RestMethod -UseBasicParsing -Method Get -Uri "https://businesscentral.dynamics.com/$($this.TenantId)/$($this.SandboxName)/deployment/url"
                Write-Host "Status: $($response.status)"
                if ($response.status -eq "Ready") {
                    Write-Host "Environment '$($this.SandboxName)' is ready."
                    $isReady = $true
                } else {
                    Write-Host "Waiting for environment '$($this.SandboxName)', status: $($response.status)" -NoNewline 
                    Start-Sleep -Seconds 30
                }
            } while ($isReady -eq $false)
        }
    }

    [string] GetInternalServiceUrl()
    {
        # Crane
        if ($this.BcType -eq 'Crane') {
            return "https://$($this.Username).dynamics-retail.net/BC/?company=$([Uri]::EscapeDataString($this.CompanyName))&tenant=default";
        }
        # Cloud
        else {
            return "https://businesscentral.dynamics.com/$($this.TenantId)/$($this.SandboxName)?company=$([Uri]::EscapeDataString($this.CompanyName))"
        }
    }

    [PSCredential] GetCredentials()
    {
        return New-Object System.Management.Automation.PSCredential "$($this.Username)", (ConvertTo-SecureString -String "$($this.Password)" -AsPlainText -Force)
    }

    [string] GetToken()
    {
        $requestNewToken = ($null -eq $this.Token -or $this.Token -eq '')
        
        # Validate token expiration
        if (-not $requestNewToken) {
            $parts = $this.Token.Split('.')
            $data = $parts[1] # Data in 2nd segment

            $jsonTokenBase64 = $data.Replace('–', '+').Replace('_', '/')
            switch($jsonTokenBase64.Length % 4) {
                0 {break}
                2 {$jsonTokenBase64 += '=='; break}
                3 {$jsonTokenBase64 += '='; break}
                DEFAULT {Write-Warning 'Illegal base64 string!'}
            }

            $jsonToken = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($jsonTokenBase64))
            $tokenData = $jsonToken | ConvertFrom-Json

            $expiration = (Get-Date -Date "01-01-1970") + ([System.TimeSpan]::FromSeconds(($tokenData.exp)))
            $currentDateTime = [System.DateTime]::UtcNow.AddMinutes(-10)

            $requestNewToken = ($expiration -le $currentDateTime)
            if ($requestNewToken) {
                Write-Host "Token will expire soon... $($expiration)"
            }
        }

        if ($requestNewToken) {
            Write-Host "Requesting new token..."
            $authority = "https://login.microsoftonline.com/"
            $resource = "https://api.businesscentral.dynamics.com"
            $credential = $this.GetCredentials()
            $aadTokenProvider = [AadTokenProvider]::new($authority, $resource, $this.ClientId, $credential, $this.AadActiveDirectoryPath)
            $this.Token = $aadTokenProvider.GetToken($credential)
        }
        return $this.Token
    }

    [Uri] GetApiBaseUrl()
    {
        # Crane
        if ($this.BcType -eq 'Crane') {
            return [Uri]"https://$($this.Username).dynamics-retail.net/BC";
        }
        # Cloud
        else {
            return [Uri]"https://api.businesscentral.dynamics.com/v2.0/$($this.TenantId)/$($this.SandboxName)"
        }
    }

    [void] WaitForBcpt([int]$sleepInterval = 5, [int]$timeout = 1800)
    {
        $apiAuthParams = $this.ApiAuthParams()

        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

        $isBcptInProgress = $false
        Do
        {
            $checkBcptUrl = "$($this.GetApiBaseUrl().ToString())/ODataV4/BCPTTestSuite_IsAnyTestRunInProgress?company=$([Uri]::EscapeDataString($this.CompanyName))"
            $checkRunning = @(Invoke-BcSaaS @apiAuthParams `
                -BaseServiceUrl $checkBcptUrl `
                -Method "POST" `
                -NotApi)

                $running = ($checkRunning[0] -eq $true)
                
                if ($running -eq $true) {
                    if ($running -eq $true -and $isBcptInProgress -eq $false) {
                        Write-Host "Waiting for BCPT to finish current run" -NoNewline
                    } else {
                        Write-Host "." -NoNewline
                        
                        # Timeout
                        if ([math]::Round($stopwatch.Elapsed.TotalSeconds, 0) -gt $timeout) {
                            Write-Host "BCPT waited more than $([math]::Round($stopwatch.Elapsed.TotalSeconds, 0)) seconds" 
                            throw "BCPT timeout while waiting current run to finish"
                        }
                    }
                    Start-Sleep -Seconds $sleepInterval
                } else {
                    if ($isBcptInProgress -eq $true) {
                        Write-Host ""
                        Write-Host "Done waiting after $([math]::Round($stopwatch.Elapsed.TotalSeconds, 0)) seconds" 
                        Write-Host ""
                    }
                }
                $isBcptInProgress = $running

        } While ($isBcptInProgress -eq $true)

        $stopwatch.Stop()
    }

    [Hashtable] ApiAuthParams()
    {
        # Crane
        if ($this.BcType -eq 'Crane') {
            return @{
                AuthorizationType = "NavUserPassword"
                Credential = $this.GetCredentials()
            }
        }
        # Cloud
        else {
            return @{
                AuthorizationType = "AAD"
                BearerToken = $this.GetToken()
            }
        }
    }

}

function Invoke-BcSaaS {
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
        [Switch] $DumpResponse,
        [Switch] $NotApi
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

        if (-not $NotApi.IsPresent) {
            $serviceUrl.Path += "/api"
        }

        if ($APIPublisher) {
            $serviceUrl.Path += "/$APIPublisher"
        }

        if ($APIGroup) {
            $serviceUrl.Path += "/$APIGroup"
        }

        if (-not $NotApi.IsPresent) {
            $serviceUrl.Path += "/$APIVersion"
        }

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
                $serviceUrl.Query += "$($Query)"
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
}