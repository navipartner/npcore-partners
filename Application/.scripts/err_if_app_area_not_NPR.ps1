#The purpose is to make sure that ApplicationArea in each object starts with mandatory prefix NPR 

Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process

function IsApplicationAreaAllowed {
    param (        
        [Parameter(Mandatory=$true)]
        [Object] $fileLines
    )

    foreach ($line in $fileLines)
    {
        if ($line -match '\/\/') 
        {
            #ignore comments
        }
        elseif ($line.ToLower() -match 'page 6151231 "npr app. area setup"') {
            #ignore main application area setup. Main setup is build with app area All 
            return $true
        }
        elseif ($line.ToLower().replace(' ', '') -match 'applicationarea=') 
        {        
            if (-Not ($line.ToLower().replace(' ', '') -match 'applicationarea=npr'))
            {
                return $false
            }
        }
    }
    return $true
}

$fileList = Get-ChildItem -Path ..\src\ -Filter *.al -Recurse

foreach ($file in $fileList) 
{
    try {           
        $fileLines = Get-Content -LiteralPath $file.FullName        
        $ApplicationAreaAllowed = IsApplicationAreaAllowed $fileLines    
    }
    catch 
    { 
        Write-Host 'Error when handling file: ' $file.FullName
        throw $_
    }        

    if ($ApplicationAreaAllowed -ne $true) {
        throw 'One or more objects contain ApplicationArea which does not start with mandatory prefix NPR'
        #Write-Host $file.FullName
        #Write-Error 'One or more objects contain ApplicationArea which does not start with mandatory prefix NPR'
    }        
}

Write-Host 'ApplicationArea set correctly with mandatory prefix NPR in all objects'
#Write-Host "Press any key to continue..."
#$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 
