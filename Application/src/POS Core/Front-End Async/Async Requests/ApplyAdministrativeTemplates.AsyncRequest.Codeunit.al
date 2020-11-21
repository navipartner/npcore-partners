codeunit 6150755 "NPR Front-End: ApplAdminTempl." implements "NPR Front-End Async Request"
{
    var
        _content: JsonObject;
        _templates: JsonArray;
        _version: Text;

    procedure Initialize(Version: Text)
    begin
        _version := Version;
    end;

    procedure SetTemplates(Templates: JsonArray)
    begin
        _templates := Templates;
    end;

    procedure GetTemplates(): JsonArray
    begin
        exit(_templates);
    end;

    procedure GetJson() Json: JsonObject
    begin
        Json.Add('Method', 'ApplyAdministrativeTemplates');
        Json.Add('Content', _content);
        _content.Add('version', _version);
        _content.Add('templates', _templates);
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;
}
