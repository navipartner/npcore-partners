$folder = "./docfx/download"

#Download docfx
$url = "https://github.com/dotnet/docfx/releases/download/v2.58.4/docfx.zip"

Remove-Item $folder -Recurse -ErrorAction Ignore
New-Item -ItemType Directory -Force -Path $folder

Invoke-WebRequest -OutFile ($folder+"/docfx.zip") $url
Expand-Archive -Path ($folder+"/docfx.zip") -DestinationPath $folder

#run docfx 
& ($folder + "/docfx.exe") "./docfx/docfx.json" "--warningsAsErrors"

if (-Not ($LastExitCode -eq 0)) {
    throw "docfx returned one or more errors"
}
