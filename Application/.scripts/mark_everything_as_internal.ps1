#Script scans all .al files in /src/ and checks if they are placed in _public folder correctly, as per either the "Access" property or "Extensible" property.
#Anything outside outside _public, missing the internal flag will get it set.


Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
$ErrorActionPreference = “Stop”

function Get-ObjectType {
    param (
        [Parameter(Mandatory=$true)]
        [Object] $fileLines
    )    
    
    $objectDeclarations = $fileLines | Select-String -Pattern '^(codeunit|pageextension|pagecustomization|page|dotnet|enumextension|enum|query|tableextension|table|xmlport|profile|controladdin|reportextension|report|interface|permissionset|permissionsetextension|entitlement)[\s\n]*'
    if ($objectDeclarations.Matches.Groups.Count -eq 0) 
    {
        return ""
    }
    else 
    {
        $objectType = $objectDeclarations.Matches.Groups[1].Value    
        return $objectType
    }
    
}

function Get-ObjectPrivateProperty {
    param (
        [Parameter(Mandatory=$true)]
        [Object] $fileLines
    )

    switch (Get-ObjectType $fileLines)
    {
        "codeunit" { return "Access = Internal;" }
        "enum" { return "Access = Internal;" }
        "query" { return "Access = Internal;" }
        "table" { return "Access = Internal;" }
        "interface" { return "Access = Internal;" }
        "permissionset" { return "Access = Internal;" }
        "report" { return "Extensible = False;" }
        "page" { return "Extensible = False;" }

        default { throw "unknown object type private property" }
    }
}

function Get-SkipObjectType {
    param (        
        [Parameter(Mandatory=$true)]
        [Object] $fileLines
    )

    switch (Get-ObjectType $fileLines)
    {
        "codeunit" { return $false }
        "enum" { return $false }
        "query" { return $false }
        "table" { return $false }
        "interface" { return $false }
        "permissionset" { return $false }
        "report" { return $false }
        "page" { return $false }

        default { return $true }
    }
    
}

function SetAsPrivate {
    param (        
        [Parameter(Mandatory=$true)]
        [Object] $file
    )
           
    [System.Collections.ArrayList]$fileLines = Get-Content -LiteralPath $file.FullName
    $objectPrivateParameter = Get-ObjectPrivateProperty $fileLines        
    $outerScopeLineNumber = -1
    $lineNumber = 0

    foreach ($line in $fileLines)
    {        
        $lineNumber += 1

        if ($line -match '^{$')
        {
            $outerScopeLineNumber = $lineNumber
        }
        elseif ($line -match '\/\/') 
        {
            #ignore comments
        }
        elseif ($line.ToLower() -match $objectPrivateParameter.ToLower()) 
        {
            return
        }
        elseif ($line.ToLower() -match '^\s?(trigger|procedure|event|layout|dataset|elements|fields)[\s\n]?$') 
        {
            #default objects in AL are access = public or extensible = true when nothing else is declared, hence if we get this far along in the object declaration it must be public
            break
        }        
    }    

    if ($outerScopeLineNumber -eq -1) 
    {
        throw "Object needs to be marked as private but does not have any outer { } scope"
    }

    $fileLines.Insert($outerScopeLineNumber, ("    " + $objectPrivateParameter))
    $fileLines | Set-Content -LiteralPath $file.FullName    
    Write-Host 'Updated file ' $file.FullName
}


$fileList = Get-ChildItem -Path ..\src\ -Filter *.al -Recurse

foreach ($file in $fileList) 
{
    try {            
        $InPublicFolder = $file.directory.parent.Name.ToLower().Equals('_public')        

        $fileLines = Get-Content -LiteralPath $file.FullName                        

        if (Get-SkipObjectType $fileLines) {
            #Write-Host 'Skipping file: ' $file.FullName
            continue    
        }
    
        if (-not $InPublicFolder) {
            SetAsPrivate $file
        }
        
    }
    catch 
    { 
        Write-Host 'Error when handling file: ' $file.FullName
        throw $_
    }    
}