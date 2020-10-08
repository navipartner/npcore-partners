function MovePackageContent {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string]$OutputDirectory,
    [Parameter(Mandatory = $true)]
    [string]$PackageID,     
    [Parameter(Mandatory = $true)]
    [string]$PackageDestinationPath
  )

  $sourcePath = Join-Path -Path $OutputDirectory -ChildPath $PackageID
  $sourcePath = (Get-Item -Path "$sourcePath*").FullName

  $items = Get-ChildItem -Path $sourcePath -Force

  if (-not (Test-Path -Path $PackageDestinationPath -PathType Container)) {
    New-Item -Path $PackageDestinationPath -Type Container -Force
  }

  $items | Where-Object { -not ($_.Name -Like "*.zip") } | Move-Item -Destination $PackageDestinationPath -Force
  Remove-Item -Path $sourcePath -Force

  Write-Host "Destination Path: $PackageDestinationPath"
  Get-ChildItem -Path $PackageDestinationPath -Force
}

Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-artifacts-credprovider.ps1) } -AddNetfx"

if (-not [System.IO.File]::Exists('.\.netpackages\nuget.exe')) {
  if (-not [System.IO.Directory]::Exists('.\.netpackages')) {
    [System.IO.Directory]::CreateDirectory('.\.netpackages')
  }
  Invoke-WebRequest https://dist.nuget.org/win-x86-commandline/latest/nuget.exe -OutFile '.\.netpackages\nuget.exe'
}
    
.\.netpackages\nuget.exe install NaviPartner.NPRetail.AddIns.BC -Source "https://api.nuget.org/v3/index.json;https://pkgs.dev.azure.com/navipartner/_packaging/NprAddIns/nuget/v3/index.json" -OutputDirectory .\.netpackages
.\.netpackages\nuget.exe install NaviPartner.NPRetail.AddIns.MS.BC -Source https://pkgs.dev.azure.com/navipartner/_packaging/NprAddIns/nuget/v3/index.json -OutputDirectory .\.netpackages
.\.netpackages\nuget.exe install NaviPartner.Dragonglass.BC -Source https://pkgs.dev.azure.com/navipartner/_packaging/JSDependancies/nuget/v3/index.json -OutputDirectory .\src\_ControlAddIns\Dragonglass\Scripts

MovePackageContent -OutputDirectory .\src\_ControlAddIns\Dragonglass\Scripts -PackageID NaviPartner.Dragonglass.BC -PackageDestinationPath .\src\_ControlAddIns\Dragonglass\Scripts

