$ErrorActionPreference = “Stop”

Add-Type -Path ".\.scripts\NUglify.dll" # https://github.com/trullock/NUglify

$fileList = Get-ChildItem -Path .\src\ -Filter *.al -Recurse
foreach ($file in $fileList)
{
    $find = $file | Select-String -Pattern '\/\/###NP_FILE_REPLACE:(\w+\.js)###'
    if ($find)
    {                      
        $jsfilePath = Join-Path $file.Directory ('/'+$find.Matches.Groups[1].Value)        
        $jsfileFound = Test-Path $jsfilePath
        if ($jsfileFound) 
        {
            $jsfileContent = Get-Content -Path $jsfilePath -Raw      
            $minifiedJs = [NUglify.Uglify]::Js($jsfileContent).Code   

            $alfileContent = Get-Content -Path $file.FullName            
            $alfileContent[$find.LineNumber] = "'" + $minifiedJs.Replace("'","''") + "'";

            Write-Host "Replacing file " + $file.Name + ", line number" + $find.LineNumber
            $alfileContent | Set-Content $file.FullName            
        }                
    }
}