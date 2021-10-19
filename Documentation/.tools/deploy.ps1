[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$workspaceFolder,
    [Parameter(Mandatory=$true)]
    [string]$docfxUrl,
    [Parameter(Mandatory=$true)]
    [string]$AzureBlobStorageSAS,
    [Parameter(Mandatory=$true)]
    [string]$AzureBlobStorageUrl,
    [Parameter(Mandatory=$true)]
    [string]$AzureCopyUrl
)

$ErrorActionPreference = 'Stop';

Write-Host "workspaceFolder:" $workspaceFolder
Write-Host "docfxUrl:" $docfxUrl
Write-Host "AzureBlobStorageUrl:" $AzureBlobStorageUrl
Write-Host "AzureCopyUrl:" $AzureCopyUrl
Write-Host "------------"

Write-Host "Cleaning and creating docfx folders"

$downloadFolder = ($workspaceFolder + "\Documentation\.tools\docfx\download")
$buildFolder = ($workspaceFolder + "\Documentation\.tools\docfx\_site")
Remove-Item $downloadFolder -Recurse -ErrorAction Ignore
Remove-Item $buildFolder -Recurse -ErrorAction Ignore
New-Item -ItemType Directory -Force -Path $downloadFolder

Write-Host "Downloading docfx"

Invoke-WebRequest -OutFile ($downloadFolder+"\docfx.zip") $docfxUrl
Expand-Archive -Path ($downloadFolder+"\docfx.zip") -DestinationPath $downloadFolder

Write-Host "Executing docfx"

& ($downloadFolder + "\docfx.exe") ($workspaceFolder + "\Documentation\.tools\docfx\docfx.json") "--warningsAsErrors"

if (-Not ($LastExitCode -eq 0)) {
    throw "docfx returned one or more errors"
}

Write-Host "Copying API library and openapi files into _site folder"
Copy-Item -Path ($workspaceFolder + "\Documentation\openapi\*") -Destination ($buildFolder + "\api\") -Recurse
Copy-Item ($workspaceFolder + "\Documentation\.tools\rapidocs\sandbox.html") -Destination ($buildFolder + "\api\")

Write-Host "Downloading AzCopy"
$azCopyPath = ($workspaceFolder + "\Documentation\.tools\azcopy")
Remove-Item $azCopyPath -Recurse -ErrorAction Ignore
New-Item -ItemType Directory -Force -Path $azCopyPath
Invoke-WebRequest -OutFile ($azCopyPath+"\azcopy.zip") $AzureCopyUrl
Expand-Archive -Path ($azCopyPath+"\azcopy.zip") -DestinationPath $azCopyPath
$azCopyPath += $AzureCopyUrl.Substring($AzureCopyUrl.LastIndexOf("/"))
$azCopyPath = $azCopyPath.Substring(0, $azCopyPath.Length-4) #Strip away ".zip"

Write-Host "Uploading _site folder via AzCopy"
Write-Host "Azure Blob Storage URL:" $AzureBlobStorageUrl
Write-Host "Azure Blob SAS defined?:" $(If ($AzureBlobStorageSAS.Length -gt 0) {"true"} Else {"false"})
Write-Host "AzCopy path" $azCopyPath
Write-Host "Build folder to sync" $buildFolder

& ($azCopyPath + "\azcopy.exe") "sync" $buildFolder ($AzureBlobStorageUrl+"?"+$AzureBlobStorageSAS) "--delete-destination=true"

if (-Not ($LastExitCode -eq 0)) {
    throw "azcopy returned one or more errors"
}

Write-Host "Documentation website successfully updated"