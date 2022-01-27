codeunit 6150771 "NPR Front-End: StargatePkg." implements "NPR Front-End Async Request"
{
    Access = Internal;
    var
        _content: JsonObject;
        _packages: JsonArray;

    procedure AddPackage(Package: JsonObject)
    begin
        _packages.Add(Package);
    end;

    procedure GetJson() Json: JsonObject
    begin
        Json.Add('Method', 'StargatePackages');
        Json.Add('Content', _content);
        _content.Add('Packages', _packages);
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;
}
