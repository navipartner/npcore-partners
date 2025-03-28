param (
    [string] $BaseFolder,
    [String] $JsFileName
)

$fileList = Get-ChildItem -Path $BaseFolder -Filter *.al
foreach ($file in $fileList)
{
    $find = $file | Select-String -Pattern ($('\/\/###NPR_INJECT_FROM_FILE:({0})###') -f $JsFileName)
    if ($find)
    {
        $jsfilePath = Join-Path $file.Directory ('/'+$find.Matches.Groups[1].Value)
        $jsfileFound = Test-Path $jsfilePath
        if ($jsfileFound) 
        {
            $jsfileContent = Get-Content -Path $jsfilePath -Raw            
            if (-not $jsfileContent.Length -eq 0)
            {
                $minifiedJs = $jsfileContent | .\.scripts\esbuild.exe --minify
            }
            else 
            {
                $minifiedJs = "";
            }

            $alfileContent = Get-Content -Path $file.FullName
            Write-Host ("'" + $minifiedJs.Replace("'","\'") + "'");
            $alfileContent[$find.LineNumber] = "'" + $minifiedJs.Replace("'","''") + "'";

            Write-Host "Replacing file " + $file.Name + ", line number" + $find.LineNumber
            $alfileContent | Set-Content $file.FullName
        }
    }
}