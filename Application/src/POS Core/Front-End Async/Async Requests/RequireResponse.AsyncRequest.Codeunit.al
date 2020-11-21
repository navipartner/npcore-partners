codeunit 6150764 "NPR Front-End: RequireResponse" implements "NPR Front-End Async Request"
{
    var
        _content: JsonObject;
        _id: Integer;
        _valueText: Text;
        _valueJson: JsonObject;
        _valueType: Option "None","Text","JSON";

    procedure Initialize(Id: Integer)
    begin
        _id := Id;
    end;

    procedure SetValue(Value: Text)
    begin
        _valueType := _valueType::Text;
        _valueText := Value;
    end;

    procedure SetValue(Value: JsonObject)
    begin
        _valueType := _valueType::JSON;
        _valueJson := Value;
    end;

    procedure GetJson() Json: JsonObject
    begin
        Json.Add('Method', 'SetOption');
        Json.Add('Content', _content);
        _content.Add('id', _id);
        case _valueType of
            _valueType::Text:
                _content.Add('value', _valueText);
            _valueType::JSON:
                _content.Add('value', _valueJson);
        end;
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;
}