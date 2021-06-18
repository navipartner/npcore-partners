$connectionDefinition = New-AzDoConnectionDefinition `
    -ProjectCollection NaviPartner `
    -Project $env:SYSTEM_TEAMPROJECT `
    -ApiVersion  5.1 `
    -AccessToken $env:SYSTEM_ACCESSTOKEN

$prevVersionInfo = Read-AzDoBuildVariable `
    -ConnectionDefinition $connectionDefinition `
    -BuildId $env:BUILD_BUILDID `
    -VariableName 'LastUsedVerNo'

$prevVersion = [version]$prevVersionInfo.Value 
$newVersion = [version]::new($prevVersion.Major, $prevVersion.Minor, $prevVersion.Build, $prevVersion.Revision + 1)

Set-AzDoBuildVariable `
    -ConnectionDefinition $connectionDefinition `
    -BuildDefinition $prevVersionInfo.Definition `
    -VariableName 'LastUsedVerNo' `
    -Value $newVersion.ToString()

Write-Host "##vso[build.updatebuildnumber]$newVersion"