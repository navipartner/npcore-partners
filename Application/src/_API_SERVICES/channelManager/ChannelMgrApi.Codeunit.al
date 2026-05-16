#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6151044 "NPR ChannelMgrApi" implements "NPR API Request Handler"
{
    Access = Internal;

    var
        _ApiFunction: Enum "NPR ChannelMgrApiFunctions";

    procedure Handle(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    begin
        #region GET
        if (Request.Match('GET', '/channelManager/orders/:partnerId')) then
            exit(Handle(_ApiFunction::LIST_ORDERS_BY_PARTNER, Request));

        if (Request.Match('GET', '/channelManager/:orderId')) then
            exit(Handle(_ApiFunction::GET_ORDER, Request));
        #endregion

        #region POST
        if (Request.Match('POST', '/channelManager/:orderId/confirm')) then
            exit(Handle(_ApiFunction::CONFIRM_ORDER, Request));

        if (Request.Match('POST', '/channelManager')) then
            exit(Handle(_ApiFunction::CREATE_ORDER, Request));
        #endregion

        #region PUT
        if (Request.Match('PUT', '/channelManager/:orderId')) then
            exit(Handle(_ApiFunction::REPLACE_ORDER, Request));
        #endregion

        #region DELETE
        if (Request.Match('DELETE', '/channelManager/:orderId')) then
            exit(Handle(_ApiFunction::DELETE_ORDER, Request));
        #endregion

        exit(Response.RespondResourceNotFound('API endpoint not found'));
    end;

    local procedure Handle(ApiFunction: Enum "NPR ChannelMgrApiFunctions"; var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Order: Record "NPR CMOrder";
        ApiHandler: Codeunit "NPR ChannelMgrApiHandler";
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
        StartTime: Time;
        ResponseMessage: Text;
        CallStack: Text;
        ApiError: Enum "NPR API Error Code";
        ApiName: Text;
        PartnerId: Guid;
        OrderId: Guid;
        SellToRef: Code[50];
    begin
        StartTime := Time();
        Commit();
        ClearLastError();

        ApiName := ApiFunction.Names.Get(ApiFunction.Ordinals.IndexOf(ApiFunction.AsInteger())).ToLower();
        Sentry.StartSpan(Span, StrSubstNo('bc.channel-manager-api.handler.%1', ApiName));

        ApiHandler.SetRequest(ApiFunction, Request);
        if (ApiHandler.Run()) then begin
            Response := ApiHandler.GetResponse();
            LogMessage(ApiFunction, (Time() - StartTime), Response.GetStatusCode(), Response, '');
            Span.Finish();
            exit(Response);
        end;

        // When the code throws an error, the response is not set by the handler
        ResponseMessage := GetLastErrorText();
        CallStack := GetLastErrorCallStack();

        ApiError := ErrorToEnum();
        Response.CreateErrorResponse(ApiError, ResponseMessage);
        LogMessage(ApiFunction, (Time() - StartTime), Response.GetStatusCode(), Response, CallStack);

        // Order Status Recovery: Ensure Processing orders that encounter an error during CREATE/REPLACE/CONFIRM are marked as Error,
        // so the existing replace/delete paths (which allow Status::Error) can recover it.
        case ApiFunction of
            ApiFunction::CREATE_ORDER:
                if (TryReadPartnerAndSellToRef(Request, PartnerId, SellToRef)) then begin
                    Order.SetCurrentKey(PartnerId, SellToOrderReference);
                    Order.SetRange(PartnerId, PartnerId);
                    Order.SetRange(SellToOrderReference, SellToRef);
                    if (Order.FindFirst()) then
                        EnsureOrderErrorStatus(Order, ResponseMessage);
                end;
            ApiFunction::REPLACE_ORDER,
            ApiFunction::CONFIRM_ORDER:
                if (TryReadOrderIdFromPathSegment(Request, 2, OrderId)) then
                    if (Order.Get(OrderId)) then
                        EnsureOrderErrorStatus(Order, ResponseMessage);
        end;

        Span.Finish();
        exit(Response);
    end;

    local procedure EnsureOrderErrorStatus(var Order: Record "NPR CMOrder"; ErrorMessage: Text)
    begin
        if (Order.Status <> Order.Status::Processing) then
            exit;
        Order.Status := Order.Status::Error;
        Order.StatusMessage := CopyStr(ErrorMessage, 1, MaxStrLen(Order.StatusMessage));
        Order.Modify();
        Commit();
    end;

    local procedure TryReadPartnerAndSellToRef(var Request: Codeunit "NPR API Request"; var PartnerId: Guid; var SellToRef: Code[50]): Boolean
    var
        Body: JsonObject;
        JToken: JsonToken;
        PartnerIdText: Text;
        SellToRefText: Text;
    begin
        Clear(PartnerId);
        SellToRef := '';
        if (not Request.BodyJson().IsObject()) then
            exit(false);

        Body := Request.BodyJson().AsObject();
        if (not Body.Get('partnerId', JToken)) then
            exit(false);

        if (not JToken.IsValue()) then
            exit(false);

        PartnerIdText := JToken.AsValue().AsText();
        if (not Evaluate(PartnerId, PartnerIdText)) then
            exit(false);

        if (not Body.Get('sellToOrderReference', JToken)) then
            exit(false);

        if (not JToken.IsValue()) then
            exit(false);

        SellToRefText := JToken.AsValue().AsText();
        if (SellToRefText = '') then
            exit(false);

        SellToRef := CopyStr(SellToRefText, 1, MaxStrLen(SellToRef));
        exit(true);
    end;

    local procedure TryReadOrderIdFromPathSegment(var Request: Codeunit "NPR API Request"; PathPosition: Integer; var OrderId: Guid): Boolean
    var
        OrderIdText: Text;
    begin
        Clear(OrderId);
        if (Request.Paths().Count() < PathPosition) then
            exit(false);

        OrderIdText := Request.Paths().Get(PathPosition);
        if (OrderIdText = '') then
            exit(false);

        exit(Evaluate(OrderId, OrderIdText));
    end;

    local procedure ErrorToEnum(): Enum "NPR API Error Code"
    begin
        exit(Enum::"NPR API Error Code"::generic_error);
    end;

    local procedure LogMessage(Function: Enum "NPR ChannelMgrApiFunctions"; DurationMs: Decimal; HttpStatusCode: Integer; Response: Codeunit "NPR API Response"; CallStack: Text)
    var
        ActiveSession: Record "Active Session";
        CustomDimensions: Dictionary of [Text, Text];
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
        CustomDimensions.Add('NPR_ClientComputerName', ActiveSession."Client Computer Name");
        CustomDimensions.Add('NPR_CallStack', CallStack);

        if (HttpStatusCode in [200 .. 299]) then begin
            ResponseMessage := StrSubstNo('Success - HTTP %1', HttpStatusCode);
            CustomDimensions.Add('NPR_ErrorText', '');
            CustomDimensions.Add('NPR_ErrorCodeName', '');

            Session.LogMessage('NPR_API_ChannelManager', ResponseMessage, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
        end else begin
            JsonObj := Response.GetJson();
            ResponseMessage := StrSubstNo('Failure - HTTP %1', HttpStatusCode);
            if (JsonObj.Get('message', JToken)) then
                CustomDimensions.Add('NPR_ErrorText', JToken.AsValue().AsText());
            if (JsonObj.Get('code', JToken)) then
                CustomDimensions.Add('NPR_ErrorCodeName', JToken.AsValue().AsText());

            Session.LogMessage('NPR_API_ChannelManager', ResponseMessage, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
        end;
    end;
}
#endif
