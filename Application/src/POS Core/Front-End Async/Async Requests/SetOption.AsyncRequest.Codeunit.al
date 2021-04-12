codeunit 6150763 "NPR Front-End: SetOption" implements "NPR Front-End Async Request"
{
    var
        _content: JsonObject;
        _option: Text;
        _value: Variant;

    procedure Initialize(Option: Text; Value: Variant)
    begin
        _option := Option;
        _value := Value;
    end;

    procedure GetJson() Json: JsonObject
    var
        JsonMgt: Codeunit "NPR POS JSON Management";
    begin
        Json.Add('Method', 'SetOption');
        Json.Add('Content', _content);
        Json.Add('Option', _option);
        JsonMgt.AddVariantValueToJsonObject(Json, 'Value', _value);
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;
}