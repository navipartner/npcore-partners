codeunit 6150768 "NPR Front-End: AppGWResp." implements "NPR Front-End Async Request"
{
    var
        _content: JsonObject;
        _event: Text;
        _data: Text;

    procedure Initialize(EventName: Text; EventData: Text)
    begin
        _event := EventName;
        _data := EventData;
    end;

    procedure GetJson() Json: JsonObject
    begin
        Json.Add('Method', 'AppGatewayProtocolResponse');
        Json.Add('Content', _content);
        Json.Add('Event', _event);
        Json.Add('Data', _data);
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;
}
