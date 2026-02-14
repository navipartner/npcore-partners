#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6185040 "NPR TicketingApi" implements "NPR API Request Handler"
{
    Access = Internal;

    var
        _ApiFunction: Enum "NPR TicketingApiFunctions";

    procedure Handle(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    begin

        #region GET
        if (Request.Match('GET', '/ticket')) then
            exit(Handle(_ApiFunction::FIND_TICKETS, Request));

        if (Request.Match('GET', '/ticket/catalog')) then
            exit(Handle(_ApiFunction::CATALOG, Request));

        if (Request.Match('GET', '/ticket/:ticketId')) then
            exit(Handle(_ApiFunction::GET_TICKET, Request));

        if (Request.Match('GET', '/ticket/catalog/:storCode')) then
            exit(Handle(_ApiFunction::CATALOG, Request));

        if (Request.Match('GET', '/ticket/capacity/search')) then
            exit(Handle(_ApiFunction::CAPACITY_SEARCH, Request));

        if (Request.Match('GET', '/ticket/reservation/:token')) then
            exit(Handle(_ApiFunction::GET_RESERVATION, Request));

        if (Request.Match('GET', '/ticket/reservation/:token/tickets')) then
            exit(Handle(_ApiFunction::GET_RESERVATION_TICKETS, Request));

        if (Request.Match('GET', '/ticket/schedule/search')) then
            exit(Handle(_ApiFunction::SCHEDULE_SEARCH, Request));

        if (Request.Match('GET', '/ticket/reports/dynamicPriceProfileList')) then
            exit(Handle(_ApiFunction::DYNAMIC_PRICE_PROFILE_LIST, Request));

        if (Request.Match('GET', '/ticket/reports/dynamicPriceRuleList')) then
            exit(Handle(_ApiFunction::DYNAMIC_PRICE_RULE_LIST, Request));
        #endregion

        #region POST
        if (Request.Match('POST', '/ticket/import')) then
            exit(Handle(_ApiFunction::IMPORT_TICKET, Request));

        if (Request.Match('POST', '/ticket/:ticketId/requestRevoke')) then
            exit(Handle(_ApiFunction::REQUEST_REVOKE_TICKET, Request));

        if (Request.Match('POST', '/ticket/:ticketId/confirmRevoke')) then
            exit(Handle(_ApiFunction::CONFIRM_REVOKE_TICKET, Request));

        if (Request.Match('POST', '/ticket/:ticketId/confirmPrint')) then
            exit(Handle(_ApiFunction::CONFIRM_PRINT_TICKET, Request));

        if (Request.Match('POST', '/ticket/:ticketId/clearConfirmPrint')) then
            exit(Handle(_ApiFunction::CLEAR_CONFIRM_PRINT_TICKET, Request));

        if (Request.Match('POST', '/ticket/:ticketId/validateArrival')) then
            exit(Handle(_ApiFunction::VALIDATE_ARRIVAL, Request));

        if (Request.Match('POST', '/ticket/:ticketId/validateDeparture')) then
            exit(Handle(_ApiFunction::VALIDATE_DEPARTURE, Request));

        if (Request.Match('POST', '/ticket/:ticketId/validateMemberArrival')) then
            exit(Handle(_ApiFunction::VALIDATE_MEMBER_ARRIVAL, Request));

        if (Request.Match('POST', '/ticket/:ticketId/sendToWallet')) then
            exit(Handle(_ApiFunction::SEND_TO_WALLET, Request));

        if (Request.Match('POST', '/ticket/:ticketId/exchangeForCoupon')) then
            exit(Handle(_ApiFunction::EXCHANGE_TICKET_FOR_COUPON, Request));

        if (Request.Match('POST', '/ticket/reservation')) then
            exit(Handle(_ApiFunction::CREATE_RESERVATION, Request));

        if (Request.Match('POST', '/ticket/reservation/:token/cancel')) then
            exit(Handle(_ApiFunction::CANCEL_RESERVATION, Request));

        if (Request.Match('POST', '/ticket/reservation/:token/pre-confirm')) then
            exit(Handle(_ApiFunction::PRE_CONFIRM_RESERVATION, Request));

        if (Request.Match('POST', '/ticket/reservation/:token/confirm')) then
            exit(Handle(_ApiFunction::CONFIRM_RESERVATION, Request));
        #endregion

        #region PUT
        if (Request.Match('PUT', '/ticket/reservation/:token')) then
            exit(Handle(_ApiFunction::UPDATE_RESERVATION, Request));
        #endregion

        exit(Response.RespondResourceNotFound('API endpoint not found'));
    end;

    local procedure Handle(ApiFunction: Enum "NPR TicketingApiFunctions"; var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        TicketingApiHandler: Codeunit "NPR TicketingApiHandler";
        StartTime: Time;
        ResponseMessage: Text;
        CallStack: Text;
        ApiError: Enum "NPR API Error Code";
        ApiName: Text;
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
    begin
        StartTime := Time();
        Sentry.StartSpan(Span, 'bc.ticket_api.handler');
        Commit();
        ClearLastError();

        Request.SkipCacheIfNonStickyRequest(TicketTransactionTables());
        ApiName := ApiFunction.Names.Get(ApiFunction.Ordinals.IndexOf(ApiFunction.AsInteger())).ToLower();

        TicketingApiHandler.SetRequest(ApiFunction, Request);
        if (TicketingApiHandler.Run()) then begin
            Response := TicketingApiHandler.GetResponse();

            LogMessage(Request, ApiFunction, (Time() - StartTime), Response.GetStatusCode(), Response, '');
            Span.Finish();
            exit(Response);
        end;

        // When the code throws an error, the response is not set by the handler
        ResponseMessage := GetLastErrorText();
        CallStack := GetLastErrorCallStack();
        ApiError := ErrorToEnum();

        Response.CreateErrorResponse(ApiError, ResponseMessage);

        LogMessage(Request, ApiFunction, (Time() - StartTime), Response.GetStatusCode(), Response, CallStack);
        Span.Finish();
        exit(Response);
    end;

    local procedure ErrorToEnum(): Enum "NPR API Error Code"
    begin
        exit(Enum::"NPR API Error Code"::generic_error);
    end;

    local procedure LogMessage(Request: Codeunit "NPR API Request"; Function: Enum "NPR TicketingApiFunctions"; DurationMs: Decimal; HttpStatusCode: Integer; Response: Codeunit "NPR API Response"; CallStack: Text)
    var
        CustomDimensions: Dictionary of [Text, Text];
        ActiveSession: Record "Active Session";
        JsonObj: JsonObject;
        JToken: JsonToken;
        ResponseMessage: Text;
    begin
        if (not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId())) then
            ActiveSession.Init();

        CustomDimensions.Add('NPR_FunctionName', Function.Names.Get(Function.Ordinals.IndexOf(Function.AsInteger())));
        CustomDimensions.Add('NPR_DurationMs', Format(DurationMs, 0, 9));

        CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
        CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
        CustomDimensions.Add('NPR_TenantId', Database.TenantId());
        CustomDimensions.Add('NPR_CompanyName', CompanyName());
        CustomDimensions.Add('NPR_UserID', ActiveSession."User ID");
        CustomDimensions.Add('NPR_SessionId', Format(Database.SessionId(), 0, 9));
        CustomDimensions.Add('NPR_StickyCache', CheckStickyCache(Request));
        CustomDimensions.Add('NPR_ClientComputerName', ActiveSession."Client Computer Name");
        CustomDimensions.Add('NPR_CallStack', CallStack);

        if (HttpStatusCode in [200 .. 299]) then begin
            ResponseMessage := StrSubstNo('Success - HTTP %1', HttpStatusCode);
            CustomDimensions.Add('NPR_ErrorText', '');
            CustomDimensions.Add('NPR_ErrorCodeName', '');

            Session.LogMessage('NPR_API_Ticketing', ResponseMessage, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
        end else begin
            JsonObj := Response.GetJson(); // Note: This will throw an error if the response is not JSON Object which might be true for some success responses
            ResponseMessage := StrSubstNo('Failure - HTTP %1', HttpStatusCode);
            if (JsonObj.Get('message', JToken)) then
                CustomDimensions.Add('NPR_ErrorText', JToken.AsValue().AsText());
            if (JsonObj.Get('code', JToken)) then
                CustomDimensions.Add('NPR_ErrorCodeName', JToken.AsValue().AsText());

            Session.LogMessage('NPR_API_Ticketing', ResponseMessage, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
        end;
    end;

    local procedure CheckStickyCache(var Request: Codeunit "NPR API Request"): Text
    var
        RequestServerId: Integer;
    begin
        if (Request.Headers().ContainsKey('x-server-cache-id')) then
            if (Evaluate(RequestServerId, Request.Headers().Get('x-server-cache-id'))) then
                if (RequestServerId = ServiceInstanceId()) then
                    exit('sticky-cache [match]')
                else
                    exit(StrSubstNo('sticky-cache [%1 <> %2]', RequestServerId, ServiceInstanceId()));

        exit('sticky-cache [no header]');
    end;

    internal procedure TicketTransactionTables() TableList: List of [Integer]
    begin
        TableList.Add(Database::"NPR TM Admission");
        TableList.Add(Database::"NPR TM Ticket Admission BOM");

        TableList.Add(Database::"NPR TM Adm. Dependency");
        TableList.Add(Database::"NPR TM Adm. Dependency Line");
        TableList.Add(Database::"NPR TM Admis. Schedule");
        TableList.Add(Database::"NPR TM Admis. Schedule Entry");
        TableList.Add(Database::"NPR TM Admis. Schedule Lines");

        TableList.Add(Database::"NPR TM Ticket Access Fact");
        TableList.Add(Database::"NPR TM Ticket Access Stats");

        TableList.Add(Database::"NPR TM Notification Profile");
        TableList.Add(Database::"NPR TM Notif. Profile Line");
        TableList.Add(Database::"NPR TM Detained Notification");
        TableList.Add(Database::"NPR TM Ticket Notif. Entry");

        TableList.Add(Database::"NPR TM Ticket Type");
        TableList.Add(Database::"NPR TM Ticket");
        TableList.Add(Database::"NPR TM Ticket Access Entry");
        TableList.Add(Database::"NPR TM Det. Ticket AccessEntry");
        TableList.Add(Database::"NPR TM DurationGroup");
        TableList.Add(Database::"NPR TM DynamicPriceItemList");
        TableList.Add(Database::"NPR TM Dynamic Price Profile");
        TableList.Add(Database::"NPR TM Dynamic Price Rule");
        TableList.Add(Database::"NPR TM TicketRequestMutex");
        TableList.Add(Database::"NPR TM Ticket Reservation Req.");
        TableList.Add(Database::"NPR TM Ticket Reserv. Resp.");

        TableList.Add(Database::"NPR TM DeferRevenueProfile");
        TableList.Add(Database::"NPR TM DeferRevenueReqDetail");
        TableList.Add(Database::"NPR TM DeferRevenueRequest");
        TableList.Add(Database::"NPR TM DeferralCue");

        TableList.Add(Database::"NPR TM CouponProfile");
        TableList.Add(Database::"NPR TM TicketCoupons");
        TableList.Add(Database::"NPR TM POS Default Admission");
        TableList.Add(Database::"NPR TM ImportTicketHeader");
        TableList.Add(Database::"NPR TM ImportTicketLine");
        TableList.Add(Database::"NPR TM TicketHolder");
        TableList.Add(Database::"NPR TM Category");
    end;

}
#endif