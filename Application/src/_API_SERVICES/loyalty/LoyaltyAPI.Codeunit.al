#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6185114 "NPR LoyaltyAPI" implements "NPR API Request Handler"
{
    Access = Internal;

    var
        _ApiFunction: Enum "NPR LoyaltyApiFunctions";

    procedure Handle(var Request: Codeunit "NPR API Request"): Codeunit "NPR API Response"
    begin
        // ***** GET ******************************************************
        if (Request.Match('GET', '/loyalty/points')) then
            exit(Handle(_ApiFunction::GET_LOYALTY_POINTS, Request));

        if (Request.Match('GET', '/loyalty/pointEntries')) then
            exit(Handle(_ApiFunction::GET_LOYALTY_POINT_ENTRIES, Request));

        if (Request.Match('GET', '/loyalty/membership/receipt/list')) then
            exit(Handle(_ApiFunction::GET_MEMBERSHIP_RECEIPT_LIST, Request));

        if (Request.Match('GET', '/loyalty/membership/receipt/pdf/:membershipNumber/:ReceiptEntryNo')) then
            exit(Handle(_ApiFunction::GET_MEMBERSHIP_RECEIPT_PDF, Request));

        if (Request.Match('GET', '/loyalty/configuration')) then
            exit(Handle(_ApiFunction::GET_LOYALTY_CONFIGURATION, Request));

        if (Request.Match('GET', '/loyalty/coupon/eligibility')) then
            exit(Handle(_ApiFunction::GET_COUPON_ELIGIBILITY, Request));

        // ***** POST ******************************************************
        if (Request.Match('POST', '/loyalty/registerSale')) then
            exit(Handle(_ApiFunction::REGISTER_SALE, Request));

        if (Request.Match('POST', '/loyalty/reservePoints')) then
            exit(Handle(_ApiFunction::RESERVE_POINTS, Request));

        if (Request.Match('POST', '/loyalty/cancelReservePoints')) then
            exit(Handle(_ApiFunction::CANCEL_RESERVE_POINTS, Request));

        if (Request.Match('POST', '/loyalty/captureReservePoints')) then
            exit(Handle(_ApiFunction::CAPTURE_RESERVE_POINTS, Request));

        if (Request.Match('POST', '/loyalty/coupon/create')) then
            exit(Handle(_ApiFunction::CREATE_COUPON, Request));

        if (Request.Match('POST', '/loyalty/coupon/list')) then
            exit(Handle(_ApiFunction::LIST_COUPON, Request));

        // ***** DELETE *******************************************************
        if (Request.Match('DELETE', '/loyalty/coupon/:couponId')) then
            exit(Handle(_ApiFunction::DELETE_COUPON, Request));
    end;

    local procedure Handle(ApiFunction: Enum "NPR LoyaltyApiFunctions"; var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        LoyaltyApiHandler: Codeunit "NPR LoyaltyApiHandler";
        StartTime: Time;
        ResponseMessage: Text;
        ApiError: Enum "NPR API Error Code";
    begin
        StartTime := Time();
        Commit();
        ClearLastError();

        LoyaltyApiHandler.SetRequest(ApiFunction, Request);
        if (LoyaltyApiHandler.Run()) then begin
            Response := LoyaltyApiHandler.GetResponse();
            LogMessage(ApiFunction, (Time() - StartTime), Response.GetStatusCode(), Response);
            exit(Response);
        end;

        ResponseMessage := GetLastErrorText();
        ApiError := ErrorToEnum(ResponseMessage);

        Response.CreateErrorResponse(ApiError, ResponseMessage);
        LogMessage(ApiFunction, (Time() - StartTime), Response.GetStatusCode(), Response);
        exit(Response);
    end;

    local procedure ErrorToEnum(ErrorMessage: Text): Enum "NPR API Error Code"
    begin
        if (ErrorMessage.StartsWith('[-127001]')) then
            exit(Enum::"NPR API Error Code"::member_count_exceeded);

        if (ErrorMessage.StartsWith('[-127002]')) then
            exit(Enum::"NPR API Error Code"::member_card_exists);

        if (ErrorMessage.StartsWith('[-127003]')) then
            exit(Enum::"NPR API Error Code"::no_admin_member);

        if (ErrorMessage.StartsWith('[-127004]')) then
            exit(Enum::"NPR API Error Code"::member_card_blank);

        if (ErrorMessage.StartsWith('[-127005]')) then
            exit(Enum::"NPR API Error Code"::invalid_contact);

        if (ErrorMessage.StartsWith('[-127006]')) then
            exit(Enum::"NPR API Error Code"::age_verification_setup);

        if (ErrorMessage.StartsWith('[-127007]')) then
            exit(Enum::"NPR API Error Code"::age_verification);

        if (ErrorMessage.StartsWith('[-127008]')) then
            exit(Enum::"NPR API Error Code"::allow_member_merge_not_set);

        if (ErrorMessage.StartsWith('[-127009]')) then
            exit(Enum::"NPR API Error Code"::member_unique_id_violation);

        exit(Enum::"NPR API Error Code"::generic_error);
    end;

    local procedure LogMessage(Function: Enum "NPR LoyaltyApiFunctions"; DurationMs: Decimal; HttpStatusCode: Integer; Response: Codeunit "NPR API Response")
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
        CustomDimensions.Add('NPR_ClientComputerName', ActiveSession."Client Computer Name");

        if (HttpStatusCode in [200 .. 299]) then begin
            ResponseMessage := StrSubstNo('Success - HTTP %1', HttpStatusCode);
            CustomDimensions.Add('NPR_ErrorText', '');
            CustomDimensions.Add('NPR_ErrorCodeName', '');

            Session.LogMessage('NPR_API_Loyalty', ResponseMessage, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
        end else begin
            JsonObj := Response.GetJson(); // Note: This will throw an error if the response is not JSON Object which might be true for some success responses
            ResponseMessage := StrSubstNo('Failure - HTTP %1', HttpStatusCode);
            if (JsonObj.Get('message', JToken)) then
                CustomDimensions.Add('NPR_ErrorText', JToken.AsValue().AsText());
            if (JsonObj.Get('code', JToken)) then
                CustomDimensions.Add('NPR_ErrorCodeName', JToken.AsValue().AsText());

            Session.LogMessage('NPR_API_Loyalty', ResponseMessage, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
        end;
    end;


}
#endif