codeunit 6150886 "NPR Workflow Step" implements "NPR IJsonSerializable"
{
    var
        _label: Text;
        _code: Text;

    procedure Label(NewLabel: Text): Text;
    begin
        _label := NewLabel;
        exit(_label);
    end;

    procedure Code(NewCode: Text): Text;
    begin
        _code := NewCode;
        exit(_code);
    end;

    procedure GetJson() Json: JsonObject;
    begin
        Json.Add('Label', _label);
        Json.Add('Code', _code);
    end;
}
