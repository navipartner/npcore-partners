#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6185052 "NPR API Request Processor"
{
    var
        EmptyPathErr: Label 'The path is empty.';
        SentryTracerHeaderNameTok: Label 'x-sentry-trace-header', Locked = true;
        _SessionMetadata: Codeunit "NPR API Session Metadata";


    [ServiceEnabled]
    procedure httpmethod(message: Text): Text
    var
        requestJson: JsonObject;
        responseJson: JsonObject;
        responseString: Text;
        RequestStartTime: DateTime;
        SentryStartTime: DateTime;
        Sentry: Codeunit "NPR Sentry";
        WSSessionInit: Codeunit "NPR API WS Session Init";
        ApiProcessingSpan: Codeunit "NPR Sentry Span";
        ApiFinalizationSpan: Codeunit "NPR Sentry Span";
    begin
        RequestStartTime := CurrentDateTime();

        if WSSessionInit.IsInitialized() then
            SentryStartTime := WSSessionInit.GetSessionStartTime()
        else
            SentryStartTime := RequestStartTime;

        _SessionMetadata.SetStartTime(RequestStartTime);
#if API_PERF_DEBUG
        _SessionMetadata.SetStartRowsRead(SessionInformation.SqlRowsRead());
        _SessionMetadata.SetStartStatementsExecuted(SessionInformation.SqlStatementsExecuted());
#endif

        requestJson.ReadFrom(message);
        responseJson := ProcessRequest(requestJson, SentryStartTime, RequestStartTime, ApiProcessingSpan, ApiFinalizationSpan);
        responseString := Format(responseJson);
        ApiFinalizationSpan.Finish();
        ApiProcessingSpan.Finish();
        Sentry.FinalizeScope();
        exit(responseString);
    end;

    local procedure ProcessRequest(requestJson: JsonObject; StartTime: DateTime; RequestStartTime: DateTime; var ApiProcessingSpan: Codeunit "NPR Sentry Span"; var ApiFinalizationSpan: Codeunit "NPR Sentry Span"): JsonObject
    var
        apiModuleResolver: Interface "NPR API Module Resolver";
        apiModule: Enum "NPR API Module";
        apiModuleName: Text;
        requestCodeunit: Codeunit "NPR API Request";
        requestResolver: Interface "NPR API Request Handler";
        requestHttpMethod: Enum "Http Method";
        requestHttpMethodStr: Text;
        requestPath: Text;
        requestRelativePathSegments: List of [Text];
        requestPathSegment: Text;
        requestPathSegmentsStr: Text;
        requestHeaders: Dictionary of [Text, Text];
        requestQueryParams: Dictionary of [Text, Text];
        requestBodyJson: JsonToken;
        jToken: JsonToken;
        responseCodeunit: Codeunit "NPR API Response";
        SentryHttp: Codeunit "NPR Sentry Http";
        Sentry: Codeunit "NPR Sentry";
        ParseSpan: Codeunit "NPR Sentry Span";
        HandleSpan: Codeunit "NPR Sentry Span";
        ExternalTraceId: Text;
        ExternalSpanId: Text;
        ExternalSampled: Boolean;
        ParameterizedName: Text;
    begin
        if requestJson.Get('httpMethod', jToken) then
            requestHttpMethodStr := jToken.AsValue().AsText();
        if requestJson.Get('path', jToken) then
            requestPath := jToken.AsValue().AsText();
        if requestJson.Get('body', jToken) then
            if jToken.IsValue() then begin
                // Normalize stringified JSON bodies sent by older proxy versions
                if not requestBodyJson.ReadFrom(jToken.AsValue().AsText()) then
                    requestBodyJson := jToken;
            end else
                requestBodyJson := jToken;
        ParseDictionaryFromJson(requestJson, 'queryParams', requestQueryParams);
        ParseDictionaryFromJson(requestJson, 'headers', requestHeaders);
        ParseListFromJson(requestJson, 'relativePathSegments', requestRelativePathSegments);

        Evaluate(requestHttpMethod, requestHttpMethodStr);

        requestRelativePathSegments.Remove('');
        if (requestRelativePathSegments.Count = 0) then begin
            Error(EmptyPathErr);
        end;

        if requestHeaders.ContainsKey(SentryTracerHeaderNameTok) then begin
            if SentryHttp.TryParseSentryTraceHeader(requestHeaders.Get(SentryTracerHeaderNameTok), ExternalTraceId, ExternalSpanId, ExternalSampled) then
                Sentry.InitScopeAndTransaction(StrSubstNo('%1 %2', requestHttpMethodStr, requestPath), StrSubstNo('http.server.bc:%1_%2', requestHttpMethodStr, requestPath), ExternalTraceId, ExternalSpanId, ExternalSampled, StartTime)
            else
                Sentry.InitScopeAndTransaction(StrSubstNo('%1 %2', requestHttpMethodStr, requestPath), StrSubstNo('http.server.bc:%1_%2', requestHttpMethodStr, requestPath), StartTime);
        end else begin
            Sentry.InitScopeAndTransaction(StrSubstNo('%1 %2', requestHttpMethodStr, requestPath), StrSubstNo('http.server.bc:%1_%2', requestHttpMethodStr, requestPath), StartTime);
        end;

        Sentry.StartSpan(ApiProcessingSpan, 'bc.api.request.processor');
        ApiProcessingSpan.SetStartTime(RequestStartTime);

        Sentry.StartSpan(ParseSpan, 'bc.api.parse');
        ParseSpan.SetStartTime(RequestStartTime);

        apiModuleName := requestRelativePathSegments.Get(1);
        if (not Evaluate(apiModule, apiModuleName)) then begin
            foreach requestPathSegment in requestRelativePathSegments do begin
                requestPathSegmentsStr += StrSubstNo('/%1', requestPathSegment)
            end;
            ParseSpan.Finish();
            exit(responseCodeunit.RespondResourceNotFound(requestPathSegmentsStr).AddMetadataHeaders(_SessionMetadata).GetResponseJson());
        end;

        requestCodeunit.Init(requestHttpMethod, requestPath, requestRelativePathSegments, requestQueryParams, requestHeaders, requestBodyJson);

        apiModuleResolver := apiModule;
# pragma warning disable AA0139
        if not HasUserPermissionSetAssigned(UserSecurityId(), CompanyName(), apiModuleResolver.GetRequiredPermissionSet()) then begin
# pragma warning restore AA0139
            // For the API module, we require explicit permission sets declared on the entra app for each module to avoid "BC365 FULL ACCESS + NPR RETAIL" as go-to everywhere in prod.
            ParseSpan.Finish();
            exit(responseCodeunit.RespondForbidden(StrSubstNo('Missing permissions: %1', apiModuleResolver.GetRequiredPermissionSet())).AddMetadataHeaders(_SessionMetadata).GetResponseJson());
        end;

        requestResolver := apiModuleResolver.Resolve(requestCodeunit);
        ParseSpan.Finish();

        Sentry.StartSpan(HandleSpan, 'bc.api.handle');
        case requestHttpMethod of
            requestHttpMethod::GET, requestHttpMethod::POST, requestHttpMethod::PUT, requestHttpMethod::PATCH, requestHttpMethod::DELETE:
                begin
                    responseCodeunit := requestResolver.Handle(requestCodeunit);
                end;
            else begin
                HandleSpan.Finish();
                exit(responseCodeunit.RespondBadRequestUnsupportedHttpMethod(requestHttpMethod).AddMetadataHeaders(_SessionMetadata).GetResponseJson());
            end;
        end;
        HandleSpan.Finish();

        Sentry.StartSpan(ApiFinalizationSpan, 'bc.api.finalize');
        if requestCodeunit.GetMatchedRouteTemplate() <> '' then begin
            ParameterizedName := BuildParameterizedTransactionName(requestHttpMethodStr, requestPath, requestRelativePathSegments, requestCodeunit.GetMatchedRouteTemplate());
            Sentry.SetTransactionName(ParameterizedName, StrSubstNo('http.server.bc:%1_%2', requestHttpMethodStr, requestCodeunit.GetMatchedRouteTemplate()));
        end;

        if (not responseCodeunit.IsInitialized()) then begin
            exit(ResponseCodeunit.RespondResourceNotFound().AddMetadataHeaders(_SessionMetadata).GetResponseJson());
        end;

        exit(ResponseCodeunit.AddMetadataHeaders(_SessionMetadata).GetResponseJson());
    end;

    procedure RegisterService()
    var
        WebService: Record "Web Service Aggregate";
        WebServiceMgt: Codeunit "Web Service Management";
        CurrCodeunit: Variant;
    begin
        if ((not WebService.ReadPermission) or (not WebService.WritePermission)) then begin
            exit;
        end;

        CurrCodeunit := Codeunit::"NPR API Request Processor";
        WebServiceMgt.CreateTenantWebService(WebService."Object Type"::Codeunit, CurrCodeunit, 'npr_rest_api', true);
    end;

    local procedure HasUserPermissionSetAssigned(UserSecurityId: Guid; Company: Text; RoleId: Code[20]): Boolean
    var
        AccessControl: Record "Access Control";
    begin
        AccessControl.SetRange("User Security ID", UserSecurityId);
        AccessControl.SetRange("Role ID", RoleId);
        AccessControl.SetFilter("Company Name", '%1|%2', '', Company);
        exit(not AccessControl.IsEmpty());
    end;

    local procedure BuildParameterizedTransactionName(Method: Text; FullPath: Text; RelativePathSegments: List of [Text]; RouteTemplate: Text): Text
    var
        FullPathSegments: List of [Text];
        TemplateSegments: List of [Text];
        Segment: Text;
        Result: Text;
        PrefixCount: Integer;
        i: Integer;
    begin
        FullPathSegments := FullPath.Split('/');
        FullPathSegments.Remove('');

        PrefixCount := FullPathSegments.Count() - RelativePathSegments.Count();
        if PrefixCount < 0 then
            PrefixCount := 0;
        for i := 1 to PrefixCount do
            Result += '/*';

        TemplateSegments := RouteTemplate.Split('/');
        TemplateSegments.Remove('');
        foreach Segment in TemplateSegments do begin
            if Segment.StartsWith(':') then
                Result += '/*'
            else
                Result += StrSubstNo('/%1', Segment);
        end;

        exit(StrSubstNo('%1 %2', Method, Result));
    end;

    local procedure ParseDictionaryFromJson(SourceJson: JsonObject; PropertyName: Text; var Dict: Dictionary of [Text, Text])
    var
        jToken: JsonToken;
        PropToken: JsonToken;
        ChildObj: JsonObject;
        PropName: Text;
    begin
        Clear(Dict);
        if not SourceJson.Get(PropertyName, jToken) then
            exit;
        if not jToken.IsObject() then
            exit;
        ChildObj := jToken.AsObject();
        foreach PropName in ChildObj.Keys() do
            if ChildObj.Get(PropName, PropToken) and PropToken.IsValue() then
                Dict.Add(PropName, PropToken.AsValue().AsText());
    end;

    local procedure ParseListFromJson(SourceJson: JsonObject; PropertyName: Text; var ListOut: List of [Text])
    var
        jToken: JsonToken;
        ArrayElement: JsonToken;
    begin
        Clear(ListOut);
        if not SourceJson.Get(PropertyName, jToken) then
            exit;
        if not jToken.IsArray() then
            exit;
        foreach ArrayElement in jToken.AsArray() do
            ListOut.Add(ArrayElement.AsValue().AsText());
    end;

}
#endif