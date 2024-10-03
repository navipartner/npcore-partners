#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6185021 "NPR REST API Response"
{
    EventSubscriberInstance = Manual;

    var
        _CurrCodeunit: Variant;
        _HascurrCodeunit: Boolean;
        _StatusCode: Integer;
        _Headers: Dictionary of [Text, Text];
        _ResponseBody: JsonObject;
        NPRVersionHeader: Label 'NPR-Version', Locked = true;
        UnsupportedHttpMethodErr: Label 'Http method %1 is not supported', Comment = '%1 = name of the Http method, do not translate';
        UnsupportedErrorStatusCodeErr: Label 'Status Code %1 is not a supported status code for error handling. This is not a user error; it is a development error.';
        ResourceNotFoundErr: Label '%1 Not Found', Comment = '%1 = the resource requested by the client';

    #region Initialization
    procedure Init(): Codeunit "NPR REST API Response"
    begin
        InitcurrCodeunit();
        Clear(_Headers);
        Clear(_ResponseBody);
        _StatusCode := 200; // Default to OK
        AddHeader('Content-Type', 'application/json');
        AddHeader(NPRVersionHeader, GetNPRetailVersion(), true);
        exit(_CurrCodeunit);
    end;
    #endregion

    #region General functions
    procedure SetStatusCode(NewStatusCode: Integer): Codeunit "NPR REST API Response"
    begin
        InitcurrCodeunit();
        _StatusCode := NewStatusCode;
        exit(_CurrCodeunit);
    end;

    procedure SetStatusCode(NewStatusCode: Enum "NPR REST API HTTP Status Code"): Codeunit "NPR REST API Response"
    begin
        InitcurrCodeunit();
        _StatusCode := NewStatusCode.AsInteger();
        exit(_CurrCodeunit);
    end;

    procedure GetStatusCode(): Integer
    begin
        exit(_StatusCode);
    end;

    procedure AddHeader(ValueKey: Text; Value: Text): Codeunit "NPR REST API Response"
    begin
        InitcurrCodeunit();
        _Headers.Add(ValueKey, Value);
        exit(_CurrCodeunit);
    end;

    procedure AddHeader(ValueKey: Text; Value: Text; ReplaceExisting: Boolean): Codeunit "NPR REST API Response"
    var
        headerDict: Dictionary of [Text, Text];
    begin
        InitcurrCodeunit();
        if (ReplaceExisting) then begin
            headerDict := GetHeaders();
            if (headerDict.ContainsKey(ValueKey)) then begin
                headerDict.Remove(ValueKey);
            end;
        end;
        AddHeader(ValueKey, Value);
        exit(_CurrCodeunit);
    end;

    procedure GetHeaders() HeadersOut: Dictionary of [Text, Text]
    begin
        HeadersOut := _Headers;
    end;

    procedure SetJson(JsonBody: JsonObject): Codeunit "NPR REST API Response"
    begin
        InitcurrCodeunit();
        Clear(_ResponseBody);
        _ResponseBody := JsonBody;
        exit(_CurrCodeunit);
    end;

    procedure GetJson() JsonOut: JsonObject
    begin
        JsonOut := _ResponseBody;
    end;

    procedure GetResponseJson() ResponseJson: JsonObject
    var
        HeadersJson: JsonObject;
        HeaderKey: Text;
        HeaderValue: Text;
    begin
        ResponseJson.Add('statusCode', _StatusCode);

        Clear(HeadersJson);
        foreach HeaderKey in _Headers.Keys do begin
            _Headers.Get(HeaderKey, HeaderValue);
            HeadersJson.Add(HeaderKey, HeaderValue);
        end;
        ResponseJson.Add('headers', HeadersJson);
        ResponseJson.Add('frontmatter', true);

        ResponseJson.Add('body', EncodeJsonObjectToBase64(_ResponseBody));
    end;

    local procedure EncodeJsonObjectToBase64(var JsonObject: JsonObject) Base64String: Text
    var
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        OutStream: OutStream;
        InStream: InStream;
        JsonText: Text;
    begin
        JsonObject.WriteTo(JsonText);
        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(JsonText);
        TempBlob.CreateInStream(InStream);
        Base64String := Base64Convert.ToBase64(InStream);
    end;

    local procedure GetNPRetailVersion(): Text
    var
        currentAlModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(currentAlModuleInfo);
        exit(Format(currentAlModuleInfo.AppVersion));
    end;
    #endregion

    #region Standard Responses
    procedure RespondOK(Value: Text): Codeunit "NPR REST API Response"
    begin
        exit(CreateSuccessResponse("NPR REST API HTTP Status Code"::OK, CreateSimpleJsonResponse('value', Value)));
    end;

    procedure RespondOK(Value: JsonObject): Codeunit "NPR REST API Response"
    begin
        exit(CreateSuccessResponse("NPR REST API HTTP Status Code"::OK, Value));
    end;

    procedure RespondCreated(Value: Text): Codeunit "NPR REST API Response"
    begin
        exit(CreateSuccessResponse("NPR REST API HTTP Status Code"::Created, CreateSimpleJsonResponse('value', Value)));
    end;

    procedure RespondCreated(Value: JsonObject): Codeunit "NPR REST API Response"
    begin
        exit(CreateSuccessResponse("NPR REST API HTTP Status Code"::Created, Value));
    end;

    procedure RespondNoContent(): Codeunit "NPR REST API Response"
    begin
        exit(CreateSuccessResponse("NPR REST API HTTP Status Code"::"No Content", CreateEmptyJsonObject()));
    end;

    procedure RespondBadRequest(ErrorCode: Enum "NPR REST API Error Code"): Codeunit "NPR REST API Response"
    begin
        exit(CreateErrorResponse(ErrorCode));
    end;

    procedure RespondBadRequest(ErrorCode: Enum "NPR REST API Error Code"; ErrorMessage: Text): Codeunit "NPR REST API Response"
    begin
        exit(CreateErrorResponse(ErrorCode, ErrorMessage));
    end;

    procedure RespondBadRequest(ErrorMessage: Text): Codeunit "NPR REST API Response"
    begin
        exit(CreateErrorResponse("NPR REST API Error Code"::generic_error, ErrorMessage));
    end;

    procedure RespondBadRequestUnsupportedHttpMethod(UnsupportedHttpMethod: Enum "Http Method"): Codeunit "NPR REST API Response"
    begin
        exit(RespondBadRequest("NPR REST API Error Code"::unsupported_http_method, StrSubstNo(UnsupportedHttpMethodErr, UnsupportedHttpMethod)));
    end;

    procedure RespondResourceNotFound(HttpResource: Text): Codeunit "NPR REST API Response"
    begin
        exit(CreateErrorResponse("NPR REST API Error Code"::resource_not_found, StrSubstNo(ResourceNotFoundErr, HttpResource), "NPR REST API HTTP Status Code"::"Not Found"));
    end;
    #endregion

    #region Generic Response handling functions
    procedure CreateSuccessResponse(StatusCode: Enum "NPR REST API HTTP Status Code"; Value: JsonObject): Codeunit "NPR REST API Response"
    begin
        InitcurrCodeunit();
        Init();
        SetStatusCode(StatusCode);
        SetJson(Value);
        exit(_CurrCodeunit);
    end;

    procedure CreateErrorResponse(ErrorCode: Enum "NPR REST API Error Code"; ErrorMessage: Text): Codeunit "NPR REST API Response"
    begin
        exit(CreateErrorResponse(ErrorCode, ErrorMessage, "NPR REST API HTTP Status Code"::"Bad Request"));
    end;

    procedure CreateErrorResponse(ErrorCode: Enum "NPR REST API Error Code"): Codeunit "NPR REST API Response"
    begin
        exit(CreateErrorResponse(ErrorCode, Format(ErrorCode), "NPR REST API HTTP Status Code"::"Bad Request"));
    end;

    procedure CreateErrorResponse(ErrorCode: Enum "NPR REST API Error Code"; ErrorStatusCode: enum "NPR REST API HTTP Status Code"): Codeunit "NPR REST API Response"
    begin
        exit(CreateErrorResponse(ErrorCode, Format(ErrorCode), ErrorStatusCode));
    end;

    procedure CreateErrorResponse(ErrorCode: Enum "NPR REST API Error Code"; ErrorMessage: Text; ErrorStatusCode: enum "NPR REST API HTTP Status Code"): Codeunit "NPR REST API Response"
    var
        JsonBuilder: Codeunit "NPR JSON Builder";
        ErrorCodeName: Text;
    begin
        InitcurrCodeunit();
        if (ErrorMessage.Trim() = '') then begin
            ErrorMessage := Format(ErrorCode);
        end;

        if (ErrorStatusCode.AsInteger() = 0) then begin
            ErrorStatusCode := "NPR REST API HTTP Status Code"::"Bad Request";
        end else begin
            if (not (ErrorStatusCode.AsInteger() in [400 .. 499])) then begin
                Error(UnsupportedErrorStatusCodeErr, ErrorStatusCode.AsInteger());
            end;
        end;

        ErrorCodeName := ErrorCode.Names.Get(ErrorCode.Ordinals.IndexOf(ErrorCode.AsInteger()));

        JsonBuilder.Initialize()
            .StartObject('')
                .AddProperty('code', ErrorCodeName)
                .AddProperty('message', ErrorMessage)
            .EndObject();

        Init();
        SetStatusCode(ErrorStatusCode);
        SetJson(JsonBuilder.Build());
        exit(_CurrCodeunit);
    end;

    local procedure CreateSimpleJsonResponse(PropertyName: Text; PropertyValue: Text): JsonObject
    var
        JsonBuilder: Codeunit "NPR JSON Builder";
    begin
        JsonBuilder.Initialize()
            .StartObject('')
                .AddProperty(PropertyName, PropertyValue)
            .EndObject();
        exit(JsonBuilder.Build());
    end;

    local procedure CreateEmptyJsonObject(): JsonObject
    var
        EmptyJsonObject: JsonObject;
    begin
        exit(EmptyJsonObject);
    end;
    #endregion

    #region FluentInterface
    local procedure InitcurrCodeunit()
    var
        helper: Codeunit "NPR REST API Response";
        helperOutVar: Variant;
    begin
        if (_HascurrCodeunit) then
            exit;

        BindSubscription(helper);
        InvokeCurrent(helperOutVar);
        UnbindSubscription(helper);
        _CurrCodeunit := helperOutVar;
        _HascurrCodeunit := true;
    end;

    [InternalEvent(true)]
    local procedure InvokeCurrent(var returnCodeunit: Variant)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR REST API Response", 'InvokeCurrent', '', false, false)]
    local procedure OnInvokeCurrent(sender: Codeunit "NPR REST API Response"; var returnCodeunit: Variant)
    begin
        returnCodeunit := sender;
    end;
    #endregion
}
#endif