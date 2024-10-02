#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6184997 "NPR REST API Request Processor"
{
    var
        EmptyPathErr: Label 'The path is empty.';

    [ServiceEnabled]
    procedure httpmethod(message: Text): Text
    var
        requestJson: JsonObject;
        responseJson: JsonObject;
        responseString: Text;
    begin
        requestJson.ReadFrom(message);
        responseJson := ProcessRequest(requestJson);
        responseString := Format(responseJson);
        exit(responseString);
    end;

    local procedure ProcessRequest(requestJson: JsonObject): JsonObject
    var
        apiModuleResolver: Interface "NPR REST API Module Resolver";
        apiModule: Enum "NPR REST API Module";
        apiModuleName: Text;
        requestCodeunit: Codeunit "NPR REST API Request";
        requestResolver: Interface "NPR REST API Request Handler";
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
        responseCodeunit: Codeunit "NPR REST API Response";
        jsonParser: Codeunit "NPR JSON Parser";
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

        apiModuleName := requestRelativePathSegments.Get(1);
        if (not Evaluate(apiModule, apiModuleName)) then begin
            foreach requestPathSegment in requestRelativePathSegments do begin
                requestPathSegmentsStr += StrSubstNo('/%1', requestPathSegment)
            end;
            exit(responseCodeunit.RespondResourceNotFound(requestPathSegmentsStr).GetResponseJson());
        end;

        requestCodeunit.Init(requestHttpMethod, requestPath, requestRelativePathSegments, requestQueryParams, requestHeaders, requestBodyJson);

        apiModuleResolver := apiModule;
        requestResolver := apiModuleResolver.Resolve(requestCodeunit);

        case requestHttpMethod of
            requestHttpMethod::GET, requestHttpMethod::POST, requestHttpMethod::PUT, requestHttpMethod::PATCH, requestHttpMethod::DELETE:
                begin
                    responseCodeunit := requestResolver.Handle(requestCodeunit);
                end;
            else begin
                exit(responseCodeunit.RespondBadRequestUnsupportedHttpMethod(requestHttpMethod).GetResponseJson());
            end;
        end;

        exit(responseCodeunit.GetResponseJson());
    end;

    procedure RegisterService()
    var
        WebService: Record "Web Service Aggregate";
        WebServiceMgt: Codeunit "Web Service Management";
        CurrCodeunit: Variant;
    begin
        if ((not WebService.ReadPermission) and (not WebService.WritePermission)) then begin
            exit;
        end;

        //CurrCodeunit := this;
        CurrCodeunit := Codeunit::"NPR REST API Request Processor";
        WebServiceMgt.CreateTenantWebService(WebService."Object Type"::Codeunit, CurrCodeunit, 'npr_rest_api', true);
    end;
}
#endif