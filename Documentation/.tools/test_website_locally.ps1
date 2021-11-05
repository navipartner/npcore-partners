[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [string]$workspaceFolder = "..\..",  #if .ps1 file is executed directly in cloned project
    [Parameter(Mandatory=$false)]
    [string]$docfxUrl = "https://github.com/dotnet/docfx/releases/download/v2.58.4/docfx.zip"
)
$ErrorActionPreference = 'Stop';

Write-Host "workspaceFolder:" $workspaceFolder
Write-Host "docfxUrl:" $docfxUrl
Write-Host "------------"

Write-Host "Cleaning and creating docfx folders"

$downloadFolder = ($workspaceFolder + "\Documentation\.tools\docfx\download")
$buildFolder = ($workspaceFolder + "\Documentation\.tools\docfx\_site")
Remove-Item $downloadFolder -Recurse -ErrorAction Ignore
Remove-Item $buildFolder -Recurse -ErrorAction Ignor
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
Copy-Item -Path ($workspaceFolder + "\Documentation\public\openapi\*") -Destination ($buildFolder + "\api\") -Recurse
Copy-Item ($workspaceFolder + "\Documentation\.tools\rapidocs\sandbox.html") -Destination ($buildFolder + "\api\")

Write-Host "Serve site on localhost"
& ($downloadFolder + "\docfx.exe") "serve" $buildFolder "-p 8080"