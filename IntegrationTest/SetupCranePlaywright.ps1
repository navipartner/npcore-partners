Param(
    [Parameter(HelpMessage = "Crane container name", Mandatory = $true)]
    [string] $containerName,

    [Parameter(HelpMessage = "Crane container password", Mandatory = $true)]
    [string] $containerPw,

    [Parameter(HelpMessage = "Crane container address/landing page", Mandatory = $true)]
    [string] $containerAddress
)

$errorActionPreference = "Stop";

try {
    [string]$psSessionUser = "$($containerName)PS";
    [securestring]$psSessionSecPassword = ConvertTo-SecureString $containerPw -AsPlainText -Force;
    [pscredential]$psCred = New-Object System.Management.Automation.PSCredential($psSessionUser, $psSessionSecPassword);
    $containerAddress = $containerAddress.TrimStart('https://').Trim('/')
    
    Write-Host "Container: $($containerAddress)"
    Write-Host "User: $($psSessionUser)"
    Write-Host "Password: $($containerPw)"
} catch {
    throw "Error creating credentials"
}

try {
    Write-Host "Creating session..."
    $session = New-PSSession -ComputerName $containerAddress -Credential $psCred -Port 443 -UseSSL -Authentication Basic

    Write-Host "Create default user in container..."
    Invoke-Command -Session $session -ScriptBlock {
        Set-ExecutionPolicy unrestricted -Force
        . "C:\Run\Prompt.ps1"

        $company = (Get-NAVCompany -ServerInstance BC -Tenant default).CompanyName
        $me = whoami
        $userexist = Get-NAVServerUser -ServerInstance BC -Tenant default | Where-Object username -eq $me
        if (!($userexist)) {
            New-NAVServerUser -ServerInstance BC -Tenant default -Company "$($company)" -WindowsAccount $me -Force -Verbose
            Start-Sleep -Seconds 2
            New-NAVServerUserPermissionSet -ServerInstance BC -Tenant default -WindowsAccount $me -PermissionSetId SUPER -Verbose
            Start-Sleep -Seconds 2
        } elseif ($userexist.state -eq "Disabled") {
            Set-NAVServerUser -ServerInstance BC -Tenant default -WindowsAccount $me -state Enabled -Company $company -Verbose
        }
    }

    Write-Host "Create BC users in container..."
    Invoke-Command -Session $session -ScriptBlock {
        Set-ExecutionPolicy unrestricted -Force
        . "C:\Run\Prompt.ps1"

        $bcUsers = (Get-NAVServerUser -ServerInstance BC -Tenant default).UserName
        $bcUsersArray = @("RESTUSER", "MPOSUSER", "E2EWORKER1", "E2EWORKER2", "E2EWORKER3", "E2EWORKER4", "E2EWORKER5", "E2EWORKER6")
        foreach ($usr in $bcUsersArray) {
            if ($bcUsers.Contains($usr)) {
                Write-Host "$usr already created"
            } else {
                Write-Host "Creating BC user '$($usr)'..."
                $usrCreds = New-Object System.Management.Automation.PSCredential($usr, (ConvertTo-SecureString -String "e2e!UserP@ssw0rd" -AsPlainText -Force));
                New-NAVServerUser -ServerInstance BC -Tenant default -Username $usrCreds.UserName -Password $usrCreds.Password -LicenseType Full -State Enabled -Force -Verbose
                Start-Sleep -Seconds 1
                New-NAVServerUserPermissionSet -ServerInstance BC -Tenant default -UserName "$($usr)" -PermissionSetId SUPER -Verbose
                Start-Sleep -Seconds 1
            }
            Start-Sleep -Seconds 1
        }
    }

    Write-Host "Invoke codeunit..."
    Invoke-Command -Session $session -ScriptBlock {
        Set-ExecutionPolicy unrestricted -Force
        . "C:\Run\Prompt.ps1"

        $company = (Get-NAVCompany -ServerInstance BC -Tenant default).CompanyName

        Write-Host "Invoke codeunit 6060099 'NPR Import Playwright NPR Data'..."
        Invoke-NAVCodeunit -ServerInstance BC -Tenant default -CompanyName $company -CodeunitId 6060099 -Verbose
        #Invoke-NAVCodeunit -ServerInstance BC -Tenant default -CompanyName $company -CodeunitId 6060099 -MethodName "ImportPosUnitsAndUsers" -Verbose

    }

    Write-Host "Removing session..."
    Remove-PSSession -Session $session
} catch {
    Write-Host "Error Message: $($_.Exception.Message.Replace("`r",'').Replace("`n",' ')), StackTrace: $($_.ScriptStackTrace.Replace("`r",'').Replace("`n",' <- '))";
    throw "Error executing commands"
}