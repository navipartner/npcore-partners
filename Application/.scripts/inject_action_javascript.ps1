param (
    [String] $AlFileName
)

if (Test-Path $AlFileName)
{
    $file = Get-Item $AlFileName
    $find = $file | Select-String -Pattern '\/\/###NPR_INJECT_FROM_FILE:([\w-. ]*\.js)###'
    if ($find)
    {
        $jsfilePath = Join-Path $file.Directory ('/'+$find.Matches.Groups[1].Value)
        $jsfileFound = Test-Path $jsfilePath
        if ($jsfileFound) 
        {
            $jsfileContent = Get-Content -Path $jsfilePath -Raw
            $minifiedJs = $jsfileContent | .\.scripts\esbuild.exe --minify

            $alfileContent = Get-Content -Path $file.FullName
            $alfileContent[$find.LineNumber] = "'" + $minifiedJs.Replace("'","''") + "'";

            Write-Host "Replacing file " + $file.Name + ", line number" + $find.LineNumber
            $alfileContent | Set-Content $file.FullName
        }
    }
}