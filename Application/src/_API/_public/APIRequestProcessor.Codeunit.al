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
    begin
        _SessionMetadata.SetStartTime(CurrentDateTime());
        _SessionMetadata.SetStartRowsRead(SessionInformation.SqlRowsRead());
        _SessionMetadata.SetStartStatementsExecuted(SessionInformation.SqlStatementsExecuted());

        requestJson.ReadFrom(message);
        responseJson := ProcessRequest(requestJson);
        responseString := Format(responseJson);
        exit(responseString);
    end;

    local procedure ProcessRequest(requestJson: JsonObject): JsonObject
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
        requestBodyStr: Text;
        responseCodeunit: Codeunit "NPR API Response";
        jsonParser: Codeunit "NPR JSON Parser";
        SentryTraceHeader: Text;
        SentryTraceHeaderValues: List of [Text];
    begin
        jsonParser.Load(requestJson);
        jsonParser
            .GetProperty('httpMethod', requestHttpMethodStr)
            .GetProperty('path', requestPath)
            .GetProperty('queryParams', requestQueryParams)
            .GetProperty('body', requestBodyStr)
            .GetProperty('relativePathSegments', requestRelativePathSegments)
            .GetProperty('headers', requestHeaders);

        if (not requestBodyJson.ReadFrom(requestBodyStr)) then;

        Evaluate(requestHttpMethod, requestHttpMethodStr);

        requestRelativePathSegments.Remove('');
        if (requestRelativePathSegments.Count = 0) then begin
            Error(EmptyPathErr);
        end;

        if (requestHeaders.ContainsKey(SentryTracerHeaderNameTok)) then begin
            Evaluate(SentryTraceHeader, requestHeaders.Get(SentryTracerHeaderNameTok));
            SentryTraceHeaderValues := SentryTraceHeader.Split('-');
        end else begin
            Clear(SentryTraceHeader);
            Clear(SentryTraceHeaderValues);
        end;

        apiModuleName := requestRelativePathSegments.Get(1);
        if (not Evaluate(apiModule, apiModuleName)) then begin
            foreach requestPathSegment in requestRelativePathSegments do begin
                requestPathSegmentsStr += StrSubstNo('/%1', requestPathSegment)
            end;
            exit(responseCodeunit.RespondResourceNotFound(requestPathSegmentsStr).AddMetadataHeaders(_SessionMetadata).GetResponseJson());
        end;

        requestCodeunit.Init(requestHttpMethod, requestPath, requestRelativePathSegments, requestQueryParams, requestHeaders, requestBodyJson);

        apiModuleResolver := apiModule;
# pragma warning disable AA0139
        if not HasUserPermissionSetAssigned(UserSecurityId(), CompanyName(), apiModuleResolver.GetRequiredPermissionSet()) then begin
# pragma warning restore AA0139
            // For the API module, we require explicit permission sets declared on the entra app for each module to avoid "BC365 FULL ACCESS + NPR RETAIL" as go-to everywhere in prod.
            exit(responseCodeunit.RespondForbidden(StrSubstNo('Missing permissions: %1', apiModuleResolver.GetRequiredPermissionSet())).AddMetadataHeaders(_SessionMetadata).GetResponseJson());
        end;

        requestResolver := apiModuleResolver.Resolve(requestCodeunit);

        case requestHttpMethod of
            requestHttpMethod::GET, requestHttpMethod::POST, requestHttpMethod::PUT, requestHttpMethod::PATCH, requestHttpMethod::DELETE:
                begin
                    responseCodeunit := requestResolver.Handle(requestCodeunit);
                end;
            else begin
                exit(responseCodeunit.RespondBadRequestUnsupportedHttpMethod(requestHttpMethod).AddMetadataHeaders(_SessionMetadata).GetResponseJson());
            end;
        end;

        if (not responseCodeunit.IsInitialized()) then begin
            exit(responseCodeunit.RespondResourceNotFound().AddMetadataHeaders(_SessionMetadata).GetResponseJson());
        end;

        exit(responseCodeunit.AddMetadataHeaders(_SessionMetadata).GetResponseJson());
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

}
#endif