codeunit 6014573 "NPR Front-End: HWC" implements "NPR Front-End Async Request"
{
    var
        _content: JsonObject;
        _request: JsonObject;
        _awaitResponse: Boolean;
        _requestId: Guid;
        _handler: Text;

    procedure GetJson() Json: JsonObject
    begin
        Json.Add('Method', 'InvokeHardwareConnector');
        Json.Add('Content', _content);
        Json.Add('handler', _handler);
        Json.Add('request', _request);
        if (_awaitResponse) then begin
            Json.Add('requestId', _requestId);
            Json.Add('awaitResponse', _awaitResponse);
        end;
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;

    procedure SetContent(Json: Interface "NPR IJsonSerializable")
    begin
        _content := Json.GetJson();
    end;

    procedure SetRequest(Request: JsonObject)
    begin
        _request := Request;
    end;

    procedure AwaitResponse(AwaitResponseIn: Boolean): Guid
    begin
        _awaitResponse := AwaitResponseIn;
        _requestId := CreateGuid();
        exit(_requestId);
    end;

    procedure SetHandler(Handler: Text)
    begin
        _handler := Handler;
    end;
}
