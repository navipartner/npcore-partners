#Script scans all .al files in /src/ and checks if they are placed in _public folder correctly, as per either the "Access" property or "Extensible" property.
#The purpose is to always make it opt-in when we want to expose internals of the NPRetail to 3rd party dependencies, either our own customer extensions or partner extensions.


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
        "codeunit" { return "access = internal;" }
        "enum" { return "access = internal;" }
        "query" { return "access = internal;" }
        "table" { return "access = internal;" }
        "interface" { return "access = internal;" }
        "permissionset" { return "access = internal;" }
        "report" { return "extensible = false;" }
        "page" { return "extensible = false;" }

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

function IsObjectMarkedAsPublic {
    param (        
        [Parameter(Mandatory=$true)]
        [Object] $fileLines
    )
           
    $objectPrivateParameter = Get-ObjectPrivateProperty $fileLines    

    foreach ($line in $fileLines)
    {        

        if ($line -match '\/\/') 
        {
            #ignore comments
        }
        elseif ($line.ToLower() -match $objectPrivateParameter) 
        {
            return $false
        }
        elseif ($line.ToLower() -match '^\s?(trigger|procedure|event|layout|dataset|elements|fields)[\s\n]?$') 
        {
            #default objects in AL are access = public or extensible = true when nothing else is declared, hence if we get this far along in the object declaration it must be public
            return $true
        }        
    }
    
    return $true
}


$fileList = Get-ChildItem -Path ..\src\ -Filter *.al -Recurse
$throwError = $false;

foreach ($file in $fileList) 
{
    try {    
        $InPublicFolder = $file.directory.Name.ToLower().Equals('_public')        

        $fileLines = Get-Content -LiteralPath $file.FullName        

        if (Get-SkipObjectType $fileLines) {
            #Write-Host 'Skipping file: ' $file.FullName
            continue    
        }
    
        $IsObjectPublic = IsObjectMarkedAsPublic $fileLines    
    }
    catch 
    { 
        Write-Host 'Error when handling file: ' $file.FullName
        throw $_
    }        

    if ($InPublicFolder -eq $true -And $IsObjectPublic -eq $true) {
        #correctly marked as public
        #Write-Host $file.Name 'Marked correctly'
    }
    elseif ($InPublicFolder -eq $false -And $IsObjectPublic -eq $false) {
        #correctly marked as not public
        #Write-Host $file.Name 'Marked correctly'
    }
    elseif ($InPublicFolder -eq $true) {
        #placed in public folder but not marked as public
        Write-Host 'Object ' $file.Name ' placed in public folder but not marked as Access = Public or Extensible = True'
        $throwError = $true;
    }
    elseif ($InPublicFolder -eq $false) {
        #marked as public but not placed in public folder
        Write-Host 'Object ' $file.Name ' placed outside public folder but is marked as either Extensible = True or Access = Public'
        $throwError = $true;
    }        
}

if ($throwError) {
    throw 'One or more objects are not correctly placed inside/outside _public folders to match their Access/Extensible properties'
} 
else {
    Write-Host 'All objects placed correctly inside or outside _public folders'
}
