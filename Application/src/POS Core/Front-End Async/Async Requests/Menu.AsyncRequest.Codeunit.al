codeunit 6150778 "NPR Front-End: Menu" implements "NPR Front-End Async Request"
{
    var
        _content: JsonObject;
        _menus: JsonArray;

    procedure Initialize(Menus: JsonArray);
    begin
        _menus := Menus;
    end;

    procedure GetJson() Json: JsonObject
    begin
        Json.Add('Method', 'Menu');
        Json.Add('Content', _content);
        Json.Add('Menus', _menus);
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;
}
