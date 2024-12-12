#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6185053 "NPR API Response"
{
    EventSubscriberInstance = Manual;

    var
        _CurrCodeunit: Variant;
        _HascurrCodeunit: Boolean;
        _StatusCode: Integer;
        _Headers: Dictionary of [Text, Text];
        _ResponseBody: JsonToken;
        _ResponseJsonStream: InStream;
        _StreamInitialized: Boolean;
        NPRVersionHeader: Label 'NPR-Version', Locked = true;
        UnsupportedHttpMethodErr: Label 'Http method %1 is not supported', Comment = '%1 = name of the Http method, do not translate';
        UnsupportedErrorStatusCodeErr: Label 'Status Code %1 is not a supported status code for error handling. This is not a user error; it is a development error.';
        ResourceNotFoundErr: Label '%1 Not Found', Comment = '%1 = the resource requested by the client';

    #region Initialization
    procedure Init(): Codeunit "NPR API Response"
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
    procedure SetStatusCode(NewStatusCode: Integer): Codeunit "NPR API Response"
    begin
        InitcurrCodeunit();
        _StatusCode := NewStatusCode;
        exit(_CurrCodeunit);
    end;

    procedure SetStatusCode(NewStatusCode: Enum "NPR API HTTP Status Code"): Codeunit "NPR API Response"
    begin
        InitcurrCodeunit();
        _StatusCode := NewStatusCode.AsInteger();
        exit(_CurrCodeunit);
    end;

    procedure GetStatusCode(): Integer
    begin
        exit(_StatusCode);
    end;

    procedure AddHeader(ValueKey: Text; Value: Text): Codeunit "NPR API Response"
    begin
        InitcurrCodeunit();
        _Headers.Add(ValueKey, Value);
        exit(_CurrCodeunit);
    end;

    procedure AddHeader(ValueKey: Text; Value: Text; ReplaceExisting: Boolean): Codeunit "NPR API Response"
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

    procedure SetJson(JsonBody: JsonObject): Codeunit "NPR API Response"
    begin
        SetJson(JsonBody.AsToken());
    end;

    procedure SetJson(JsonBody: JsonArray): Codeunit "NPR API Response"
    begin
        SetJson(JsonBody.AsToken());
    end;

    procedure SetJson(JsonBody: JsonToken): Codeunit "NPR API Response"
    begin
        InitcurrCodeunit();
        Clear(_ResponseBody);
        Clear(_ResponseJsonStream);
        Clear(_StreamInitialized);
        _ResponseBody := JsonBody;
        exit(_CurrCodeunit);
    end;

    procedure SetJson(var JsonStream: InStream): Codeunit "NPR API Response"
    begin
        InitcurrCodeunit();
        Clear(_ResponseBody);
        Clear(_ResponseJsonStream);
        Clear(_StreamInitialized);
        _ResponseJsonStream := JsonStream;
        _StreamInitialized := true;
        exit(_CurrCodeunit);
    end;

    procedure GetJson() JsonOut: JsonObject
    begin
        JsonOut := _ResponseBody.AsObject();
    end;

    procedure GetJsonArray() JsonArrayOut: JsonArray
    begin
        JsonArrayOut := _ResponseBody.AsArray();
    end;

    procedure GetJsonStream() JsonStreamOut: InStream
    begin
        JsonStreamOut := _ResponseJsonStream;
    end;

    procedure GetResponseJson() ResponseJson: JsonObject
    var
        HeadersJson: JsonObject;
        HeaderKey: Text;
        HeaderValue: Text;
        Base64Convert: Codeunit "Base64 Convert";
    begin
        ResponseJson.Add('statusCode', _StatusCode);

        Clear(HeadersJson);
        foreach HeaderKey in _Headers.Keys do begin
            _Headers.Get(HeaderKey, HeaderValue);
            HeadersJson.Add(HeaderKey, HeaderValue);
        end;
        ResponseJson.Add('headers', HeadersJson);
        ResponseJson.Add('frontmatter', true);

        if _StreamInitialized then begin
            ResponseJson.Add('body', Base64Convert.ToBase64(_ResponseJsonStream));
        end else begin
            ResponseJson.Add('body', EncodeJsonObjectToBase64(_ResponseBody));
        end;
    end;

    procedure IsInitialized(): Boolean
    begin
        exit(_HascurrCodeunit);
    end;

    local procedure EncodeJsonObjectToBase64(var JsonToken: JsonToken) Base64String: Text
    var
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
    begin
        JsonToken.WriteTo(TempBlob.CreateOutStream(TextEncoding::UTF8));
        Base64String := Base64Convert.ToBase64(TempBlob.CreateInStream(TextEncoding::UTF8));
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
    /// <summary>
    /// Responds with an HTTP 200 OK status and a simple JSON response containing a single value.
    /// </summary>
    /// <param name="Value">The text value to be included in the response.</param>
    /// <returns>An API response with OK (200) status and a JSON object with the given value.</returns>
    procedure RespondOK(Value: Text): Codeunit "NPR API Response"
    begin
        exit(CreateSuccessResponse("NPR API HTTP Status Code"::OK, CreateSimpleJsonResponse('value', Value)));
    end;

    /// <summary>
    /// Responds with an HTTP 200 OK status and the provided JSON object.
    /// </summary>
    /// <param name="Value">The JSON object to be returned in the response.</param>
    /// <returns>An API response with OK (200) status and the given JSON object.</returns>
    procedure RespondOK(Value: JsonObject): Codeunit "NPR API Response"
    begin
        exit(CreateSuccessResponse("NPR API HTTP Status Code"::OK, Value));
    end;

    /// <summary>
    /// Responds with an HTTP 200 OK status and the provided JSON array.
    /// </summary>
    /// <param name="Value">The JSON array to be returned in the response.</param>
    /// <returns>An API response with OK (200) status and the given JSON array.</returns>
    procedure RespondOK(Value: JsonArray): Codeunit "NPR API Response"
    begin
        exit(CreateSuccessResponse("NPR API HTTP Status Code"::OK, Value));
    end;

    /// <summary>
    /// Responds with an HTTP 200 OK status and the provided JSON stream.
    /// </summary>
    /// <param name="JsonStream">The JSON input stream to be returned in the response.</param>
    /// <returns>An API response with OK (200) status and the given JSON stream.</returns>
    procedure RespondOK(JsonStream: InStream): Codeunit "NPR API Response"
    begin
        exit(CreateSuccessResponse("NPR API HTTP Status Code"::OK, JsonStream));
    end;

    /// <summary>
    /// Responds with an HTTP 200 OK status using a JSON builder.
    /// </summary>
    /// <param name="JsonBuilder">The JSON builder used to construct the response payload.</param>
    /// <returns>An API response with OK (200) status and the built JSON object.</returns>
    procedure RespondOK(JsonBuilder: Codeunit "NPR JSON Builder"): Codeunit "NPR API Response"
    begin
        exit(CreateSuccessResponse("NPR API HTTP Status Code"::OK, JsonBuilder.Build()));
    end;

    /// <summary>
    /// Responds with an HTTP 201 Created status and a simple JSON response containing a single value.
    /// </summary>
    /// <param name="Value">The text value to be included in the response.</param>
    /// <returns>An API response with Created (201) status and a JSON object with the given value.</returns>
    procedure RespondCreated(Value: Text): Codeunit "NPR API Response"
    begin
        exit(CreateSuccessResponse("NPR API HTTP Status Code"::Created, CreateSimpleJsonResponse('value', Value)));
    end;

    /// <summary>
    /// Responds with an HTTP 201 Created status and the provided JSON object.
    /// </summary>
    /// <param name="Value">The JSON object to be returned in the response.</param>
    /// <returns>An API response with Created (201) status and the given JSON object.</returns>
    procedure RespondCreated(Value: JsonObject): Codeunit "NPR API Response"
    begin
        exit(CreateSuccessResponse("NPR API HTTP Status Code"::Created, Value));
    end;

    /// <summary>
    /// Responds with an HTTP 201 Created status and the provided JSON array.
    /// </summary>
    /// <param name="Value">The JSON array to be returned in the response.</param>
    /// <returns>An API response with Created (201) status and the given JSON array.</returns>
    procedure RespondCreated(Value: JsonArray): Codeunit "NPR API Response"
    begin
        exit(CreateSuccessResponse("NPR API HTTP Status Code"::Created, Value));
    end;

    /// <summary>
    /// Responds with an HTTP 204 No Content status.
    /// </summary>
    /// <returns>An API response with No Content (204) status.</returns>
    procedure RespondNoContent(): Codeunit "NPR API Response"
    begin
        exit(CreateSuccessResponse("NPR API HTTP Status Code"::"No Content", CreateEmptyJsonObject()));
    end;

    /// <summary>
    /// Responds with an HTTP 400 Bad Request status using a generic error code.
    /// </summary>
    /// <returns>An API response with Bad Request (400) status and a generic error.</returns>
    procedure RespondBadRequest(): Codeunit "NPR API Response"
    begin
        exit(CreateErrorResponse("NPR API Error Code"::generic_error));
    end;

    /// <summary>
    /// Responds with an HTTP 400 Bad Request status using a specific error code.
    /// </summary>
    /// <param name="ErrorCode">The specific error code to be used in the response.</param>
    /// <returns>An API response with Bad Request (400) status and the specified error code.</returns>
    procedure RespondBadRequest(ErrorCode: Enum "NPR API Error Code"): Codeunit "NPR API Response"
    begin
        exit(CreateErrorResponse(ErrorCode));
    end;


    /// <summary>
    /// Responds with an HTTP 400 Bad Request status using a specific error code and message.
    /// </summary>
    /// <param name="ErrorCode">The specific error code to be used in the response.</param>
    /// <param name="ErrorMessage">A descriptive error message to provide additional context.</param>
    /// <returns>An API response with Bad Request (400) status, specified error code, and message.</returns>
    procedure RespondBadRequest(ErrorCode: Enum "NPR API Error Code"; ErrorMessage: Text): Codeunit "NPR API Response"
    begin
        exit(CreateErrorResponse(ErrorCode, ErrorMessage));
    end;

    /// <summary>
    /// Responds with an HTTP 400 Bad Request status using a generic error code and custom message.
    /// </summary>
    /// <param name="ErrorMessage">A descriptive error message to provide additional context.</param>
    /// <returns>An API response with Bad Request (400) status, generic error code, and custom message.</returns>
    procedure RespondBadRequest(ErrorMessage: Text): Codeunit "NPR API Response"
    begin
        exit(CreateErrorResponse("NPR API Error Code"::generic_error, ErrorMessage));
    end;

    /// <summary>
    /// Responds with an HTTP 400 Bad Request status for an unsupported HTTP method.
    /// </summary>
    /// <param name="UnsupportedHttpMethod">The HTTP method that is not supported.</param>
    /// <returns>An API response with Bad Request (400) status and an unsupported method error.</returns>
    procedure RespondBadRequestUnsupportedHttpMethod(UnsupportedHttpMethod: Enum "Http Method"): Codeunit "NPR API Response"
    begin
        exit(RespondBadRequest("NPR API Error Code"::unsupported_http_method, StrSubstNo(UnsupportedHttpMethodErr, UnsupportedHttpMethod)));
    end;

    /// <summary>
    /// Responds with an HTTP 404 Not Found status using a generic resource not found error code.
    /// </summary>
    /// <returns>An API response with Not Found (404) status and a resource not found error.</returns>
    procedure RespondResourceNotFound(): Codeunit "NPR API Response"
    begin
        exit(CreateErrorResponse("NPR API Error Code"::resource_not_found, "NPR API HTTP Status Code"::"Not Found"));
    end;

    /// <summary>
    /// Responds with an HTTP 404 Not Found status for a specific HTTP resource.
    /// </summary>
    /// <param name="HttpResource">The name or identifier of the resource that was not found.</param>
    /// <returns>An API response with Not Found (404) status and a specific resource not found error.</returns>
    procedure RespondResourceNotFound(HttpResource: Text): Codeunit "NPR API Response"
    begin
        exit(CreateErrorResponse("NPR API Error Code"::resource_not_found, StrSubstNo(ResourceNotFoundErr, HttpResource), "NPR API HTTP Status Code"::"Not Found"));
    end;

    /// <summary>
    /// Responds with an HTTP 403 Forbidden status and a custom error message.
    /// </summary>
    /// <param name="Message">A descriptive message explaining the reason for forbidden access.</param>
    /// <returns>An API response with Forbidden (403) status and the provided error message.</returns>
    procedure RespondForbidden(Message: Text): Codeunit "NPR API Response"
    begin
        exit(CreateErrorResponse("NPR API Error Code"::generic_error, Message, "NPR API HTTP Status Code"::Forbidden));
    end;

    #endregion

    #region Generic Response handling functions
    procedure CreateSuccessResponse(StatusCode: Enum "NPR API HTTP Status Code"; Value: JsonObject): Codeunit "NPR API Response"
    begin
        exit(CreateSuccessResponse(StatusCode, Value.AsToken()));
    end;

    procedure CreateSuccessResponse(StatusCode: Enum "NPR API HTTP Status Code"; Value: JsonArray): Codeunit "NPR API Response"
    begin
        exit(CreateSuccessResponse(StatusCode, Value.AsToken()));
    end;

    local procedure CreateSuccessResponse(StatusCode: Enum "NPR API HTTP Status Code"; Value: JsonToken): Codeunit "NPR API Response"
    begin
        InitcurrCodeunit();
        Init();
        SetStatusCode(StatusCode);
        SetJson(Value);
        exit(_CurrCodeunit);
    end;

    local procedure CreateSuccessResponse(StatusCode: Enum "NPR API HTTP Status Code"; JsonStream: InStream): Codeunit "NPR API Response"
    begin
        InitcurrCodeunit();
        Init();
        SetStatusCode(StatusCode);
        SetJson(JsonStream);
        exit(_CurrCodeunit);
    end;

    procedure CreateErrorResponse(ErrorCode: Enum "NPR API Error Code"; ErrorMessage: Text): Codeunit "NPR API Response"
    begin
        exit(CreateErrorResponse(ErrorCode, ErrorMessage, "NPR API HTTP Status Code"::"Bad Request"));
    end;

    procedure CreateErrorResponse(ErrorCode: Enum "NPR API Error Code"): Codeunit "NPR API Response"
    begin
        exit(CreateErrorResponse(ErrorCode, Format(ErrorCode), "NPR API HTTP Status Code"::"Bad Request"));
    end;

    procedure CreateErrorResponse(ErrorCode: Enum "NPR API Error Code"; ErrorStatusCode: enum "NPR API HTTP Status Code"): Codeunit "NPR API Response"
    begin
        exit(CreateErrorResponse(ErrorCode, Format(ErrorCode), ErrorStatusCode));
    end;

    procedure CreateErrorResponse(ErrorCode: Enum "NPR API Error Code"; ErrorMessage: Text; ErrorStatusCode: enum "NPR API HTTP Status Code"): Codeunit "NPR API Response"
    var
        JsonBuilder: Codeunit "NPR JSON Builder";
        ErrorCodeName: Text;
    begin
        InitcurrCodeunit();
        if (ErrorMessage.Trim() = '') then begin
            ErrorMessage := Format(ErrorCode);
        end;

        if (ErrorStatusCode.AsInteger() = 0) then begin
            ErrorStatusCode := "NPR API HTTP Status Code"::"Bad Request";
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
        helper: Codeunit "NPR API Response";
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR API Response", 'InvokeCurrent', '', false, false)]
    local procedure OnInvokeCurrent(sender: Codeunit "NPR API Response"; var returnCodeunit: Variant)
    begin
        returnCodeunit := sender;
    end;
    #endregion
}
#endif