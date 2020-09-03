Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-artifacts-credprovider.ps1) } -AddNetfx"

if (-not [System.IO.File]::Exists('.\.netpackages\nuget.exe')) {
  if (-not [System.IO.Directory]::Exists('.\.netpackages')) {
    [System.IO.Directory]::CreateDirectory('.\.netpackages')
  }
  Invoke-WebRequest https://dist.nuget.org/win-x86-commandline/latest/nuget.exe -OutFile '.\.netpackages\nuget.exe'
}
    
.\.netpackages\nuget.exe restore packages.config -PackagesDirectory .\.netpackages