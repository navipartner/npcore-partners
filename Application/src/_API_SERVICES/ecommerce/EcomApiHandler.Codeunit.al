#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248361 "NPR EcomApiHandler"
{
    Access = Internal;

    var
        _Request: Codeunit "NPR API Request";
        _Response: Codeunit "NPR API Response";
        _ApiFunction: Enum "NPR EcomApiFunctions";
        _LastRoute: Text;

    trigger OnRun()
    begin
        HandleFunction();
    end;

    internal procedure SetRequest(ApiFunction: Enum "NPR EcomApiFunctions"; var Request: Codeunit "NPR API Request")
    var
        ErrorCode: Enum "NPR API Error Code";
        ErrorStatusCode: Enum "NPR API HTTP Status Code";
    begin
        _ApiFunction := ApiFunction;
        _Request := Request;
        _Response.CreateErrorResponse(ErrorCode::resource_not_found, StrSubstNo('The API function %1 is not yet supported.', _ApiFunction), ErrorStatusCode::"Bad Request");
    end;

    internal procedure GetResponse() Response: Codeunit "NPR API Response"
    begin
        Response := _Response;
    end;

    internal procedure HandleFunction()
    begin
        case _ApiFunction of
            _ApiFunction::CREATE_SALES_DOCUMENT:
                RouteCreate();
            _ApiFunction::GET_SALES_DOCUMENT:
                RouteGetById();
            _ApiFunction::FIND_SALES_DOCUMENTS:
                RouteFind();
        end;
    end;

    // Routing dates select API handlers only; document processing versions come from NPR Ecom Sales Doc Utils.GetApiVersionDateByRequest.
    internal procedure V2From(): Date
    begin
        exit(20251019D);
    end;

    internal procedure V3From(): Date
    begin
        exit(20261029D);
    end;

    local procedure RouteCreate()
    var
        CreateV1: Codeunit "NPR EcomSalesDocApiAgent";
        CreateV2: Codeunit "NPR EcomSalesDocApiAgentV2";
        RequestDate: Date;
        RequestedDate: Date;
        HeaderState: Text;
    begin
        HeaderState := ClassifyHeader(_Request, RequestedDate);
        if HeaderState = 'invalid' then
            LogRoute('create', HeaderState, RequestedDate, 'rejected');
        RequestDate := _Request.ApiVersion();
        case true of
            RequestDate >= V2From():
                begin
                    LogRoute('create', HeaderState, RequestedDate, 'CreateV2');
                    _Response := CreateV2.CreateIncomingEcomDocument(_Request);
                end;
            else begin
                LogRoute('create', HeaderState, RequestedDate, 'CreateV1');
                _Response := CreateV1.CreateIncomingEcomDocument(_Request);
            end;
        end;
    end;

    local procedure RouteGetById()
    var
        GetV1: Codeunit "NPR EcomSalesDocApiAgent";
        GetV2: Codeunit "NPR EcomSalesDocGetV2";
        GetV3: Codeunit "NPR EcomSalesDocGetV3";
        RequestDate: Date;
        RequestedDate: Date;
        HeaderState: Text;
    begin
        HeaderState := ClassifyHeader(_Request, RequestedDate);
        if HeaderState = 'invalid' then
            LogRoute('get', HeaderState, RequestedDate, 'rejected');
        RequestDate := _Request.ApiVersion();
        case true of
            RequestDate >= V3From():
                begin
                    LogRoute('get', HeaderState, RequestedDate, 'GetV3');
                    _Response := GetV3.GetIncomingEcomDocumentById(_Request);
                end;
            RequestDate >= V2From():
                begin
                    LogRoute('get', HeaderState, RequestedDate, 'GetV2');
                    _Response := GetV2.GetIncomingEcomDocumentById(_Request);
                end;
            else begin
                LogRoute('get', HeaderState, RequestedDate, 'GetV1');
                _Response := GetV1.GetIncomingEcomDocumentById(_Request);
            end;
        end;
    end;

    // Find has no V1, so dates before V2From() also get the V2 find.
    local procedure RouteFind()
    var
        FindV2: Codeunit "NPR EcomSalesDocFindV2";
        FindV3: Codeunit "NPR EcomSalesDocFindV3";
        RequestDate: Date;
        RequestedDate: Date;
        HeaderState: Text;
    begin
        HeaderState := ClassifyHeader(_Request, RequestedDate);
        if HeaderState = 'invalid' then
            LogRoute('find', HeaderState, RequestedDate, 'rejected');
        RequestDate := _Request.ApiVersion();
        case true of
            RequestDate >= V3From():
                begin
                    LogRoute('find', HeaderState, RequestedDate, 'FindV3');
                    _Response := FindV3.FindIncomingEcomDocumentsByEmail(_Request);
                end;
            else begin
                LogRoute('find', HeaderState, RequestedDate, 'FindV2');
                _Response := FindV2.FindIncomingEcomDocumentsByEmail(_Request);
            end;
        end;
    end;

    // Classify invalid headers without raising so telemetry can record them before ApiVersion() raises.
    local procedure ClassifyHeader(var Request: Codeunit "NPR API Request"; var RequestDate: Date): Text
    var
        Headers: Dictionary of [Text, Text];
        HeaderValue: Text;
    begin
        RequestDate := 0D;
        Headers := Request.Headers();
        if not Headers.Get('x-api-version', HeaderValue) then
            exit('absent');
        if HeaderValue = '' then
            exit('empty');
        if not Evaluate(RequestDate, HeaderValue, 9) then begin
            RequestDate := 0D;
            exit('invalid');
        end;
        if RequestDate = 0D then
            exit('empty');
        exit('date');
    end;

    local procedure LogRoute(Operation: Text; HeaderState: Text; RequestDate: Date; RoutedTo: Text)
    var
        Sentry: Codeunit "NPR Sentry";
        CustomDimensions: Dictionary of [Text, Text];
        RequestedDateText: Text;
        RouteMessageLbl: Label 'Ecommerce documents %1 routed to %2', Locked = true, Comment = '%1 = operation, %2 = the code that serves it';
    begin
        _LastRoute := Operation + '|' + HeaderState + '|' + RoutedTo;
        RequestedDateText := Format(RequestDate, 0, 9);

        CustomDimensions.Add('NPR_Operation', Operation);
        CustomDimensions.Add('NPR_HeaderState', HeaderState);
        CustomDimensions.Add('NPR_RequestedDate', RequestedDateText);
        CustomDimensions.Add('NPR_RoutedTo', RoutedTo);
        Session.LogMessage('NPR_API_EcomRoute', StrSubstNo(RouteMessageLbl, Operation, RoutedTo), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);

        Sentry.AddTransactionTag('bc.ecom-api.route', RoutedTo);
        Sentry.AddTransactionTag('bc.ecom-api.headerState', HeaderState);
        Sentry.AddTransactionData('bc.ecom-api.requestedDate', RequestedDateText);
    end;

    internal procedure LastRoute(): Text
    begin
        exit(_LastRoute);
    end;
}
#endif