Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-artifacts-credprovider.ps1) } -AddNetfx"

if (-not [System.IO.File]::Exists('.\.netpackages\nuget.exe')) {
  if (-not [System.IO.Directory]::Exists('.\.netpackages')) {
    [System.IO.Directory]::CreateDirectory('.\.netpackages')
  }
  Invoke-WebRequest https://dist.nuget.org/win-x86-commandline/latest/nuget.exe -OutFile '..\.netpackages\nuget.exe'
}
    
..\.netpackages\nuget.exe install NaviPartner.NPRetail.AddIns.BC -Source "https://api.nuget.org/v3/index.json;https://pkgs.dev.azure.com/navipartner/_packaging/NprAddIns/nuget/v3/index.json" -OutputDirectory .\.netpackages
..\.netpackages\nuget.exe install NaviPartner.NPRetail.AddIns.MS.BC -Source https://pkgs.dev.azure.com/navipartner/_packaging/NprAddIns/nuget/v3/index.json -OutputDirectory .\.netpackages