codeunit 6150880 "NPR Workflow" implements "NPR IJsonSerializable"
{
    Access = Internal;
    var
        _name: Text;
        _requestContext: Boolean;
        _steps: JsonArray;
        _content: JsonObject;

    procedure Name(): Text;
    begin
        exit(_name);
    end;

    procedure SetName(NewName: Text);
    begin
        _name := NewName;
    end;

    procedure RequestContext(): Boolean;
    begin
        exit(_requestContext);
    end;

    procedure SetRequestContext(NewRequestContext: Boolean);
    begin
        _requestContext := NewRequestContext;
    end;

    procedure Steps(): JsonArray;
    begin
        exit(_steps);
    end;

    procedure Content(): JsonObject;
    begin
        exit(_content);
    end;

    procedure GetJson() Json: JsonObject;
    begin
        Json.Add('Name', _name);
        Json.Add('RequestContext', _requestContext);
        Json.Add('Steps', _steps);
        Json.Add('Content', _content);
    end;

    local procedure ClearPrivateState();
    begin
        Clear(_name);
        Clear(_requestContext);
        Clear(_steps);
    end;

    local procedure DeserializeFromJsonObject(Json: JsonObject);
    var
        Token: JsonToken;
    begin
        ClearPrivateState();

        // Name
        Json.Get('Name', Token);
        _name := Token.AsValue().AsText();

        // RequestContext
        Json.Get('RequestContext', Token);
        _requestContext := Token.AsValue().AsBoolean();

        // Steps
        Json.Get('Steps', Token);
        _steps := Token.AsArray();

        // Content
        Json.Get('Content', Token);
        _content := Token.AsObject();
    end;

    procedure DeserializeFromJsonString(JsonString: Text);
    var
        Json: JsonObject;
    begin
        Json.ReadFrom(JsonString);
        DeserializeFromJsonObject(Json);
    end;

    procedure DeserializeFromJsonStream(JsonStream: InStream);
    var
        Json: JsonObject;
    begin
        Json.ReadFrom(JsonStream);
        DeserializeFromJsonObject(Json);
    end;
}
