param (
    [String] $WorkspaceFolder
)

Write-Host "Compiling workspace at path:" $WorkspaceFolder

#Sort to latest if multiple AL extensions installed in vscode
$alExtensionFolder = (Get-ChildItem -Path "$($env:USERPROFILE)\.vscode\extensions\" -Filter "ms-dynamics-smb.al-*" -Directory | Sort-Object -Bottom 1)
$compilerPath = (Join-Path -Path $alExtensionFolder.FullName -ChildPath "\bin\win32\alc.exe");

Write-Host "Using compiler at path:" $compilerPath

$project = ('/project:"' + $WorkspaceFolder + '"');
$probingPath = "/assemblyprobingpaths:""$(Join-Path $WorkspaceFolder '.netpackages')"",C:\Windows\Microsoft.NET\Assembly";
$packageCache = "/packagecachepath:""$(Join-Path $WorkspaceFolder '.alpackages')""";
$alzrCodeCop = "/analyzer:""$(Join-Path -Path $alExtensionFolder.FullName -ChildPath "\bin\Analyzers\Microsoft.Dynamics.Nav.CodeCop.dll")""";
$alzrAppSourceCop = "/analyzer:""$(Join-Path -Path $alExtensionFolder.FullName -ChildPath "\bin\Analyzers\Microsoft.Dynamics.Nav.AppSourceCop.dll")""";
$alzrUICop = "/analyzer:""$(Join-Path -Path $alExtensionFolder.FullName -ChildPath "\bin\Analyzers\Microsoft.Dynamics.Nav.UICop.dll")""";
$contOnError = "/continuebuildonerror:false";
$ruleSet = "/ruleset:""$(Join-Path $WorkspaceFolder 'main.ruleset.json')""";

Write-Host "Invoking compiler with parameters:" $compilerPath $project $probingPath $packageCache $alzrCodeCop $alzrAppSourceCop $alzrUICop $contOnError $ruleSet
&$compilerPath $project $probingPath $packageCache $alzrCodeCop $alzrAppSourceCop $alzrUICop $contOnError $ruleSet
