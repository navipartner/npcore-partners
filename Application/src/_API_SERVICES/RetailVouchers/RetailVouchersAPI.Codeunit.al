#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248251 "NPR RetailVouchersAPI" implements "NPR API Request Handler"
{
    Access = Internal;

    var
        _ApiFunction: Enum "NPR RetailVoucherApiFunctions";

    procedure Handle(var Request: Codeunit "NPR API Request"): Codeunit "NPR API Response"
    begin
        if (Request.Match('GET', '/voucher')) then
            exit(Handle(_ApiFunction::FIND_VOUCHERS, Request));

        if (Request.Match('GET', '/voucher/:voucherId')) then
            exit(Handle(_ApiFunction::GET_VOUCHER, Request));

        if (Request.Match('POST', '/voucher')) then
            exit(Handle(_ApiFunction::CREATE_VOUCHER, Request));

        if (Request.Match('POST', '/voucher/:voucherId/reservation')) then
            exit(Handle(_ApiFunction::RESERVE_VOUCHER, Request));

        if (Request.Match('POST', '/voucher/reservation/:voucherId')) then
            exit(Handle(_ApiFunction::CANCEL_RES_VOUCHER, Request));
    end;

    local procedure Handle(ApiFunction: Enum "NPR RetailVoucherApiFunctions"; var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        RetailVouchersApiHandler: Codeunit "NPR RetailVouchersApiHandler";
        StartTime: Time;
        ResponseMessage: Text;
        ApiError: Enum "NPR API Error Code";
    begin
        StartTime := Time();
        Commit();
        ClearLastError();

        RetailVouchersApiHandler.SetRequest(ApiFunction, Request);
        if (RetailVouchersApiHandler.Run()) then begin
            Response := RetailVouchersApiHandler.GetResponse();
            LogMessage(ApiFunction, (Time() - StartTime), Response.GetStatusCode(), Response);
            exit(Response);
        end;

        ResponseMessage := GetLastErrorText();
        ApiError := ErrorToEnum();

        Response.CreateErrorResponse(ApiError, ResponseMessage);
        LogMessage(ApiFunction, (Time() - StartTime), Response.GetStatusCode(), Response);
        exit(Response);
    end;

    local procedure ErrorToEnum(): Enum "NPR API Error Code"
    begin
        exit(Enum::"NPR API Error Code"::generic_error);
    end;

    local procedure LogMessage(Function: Enum "NPR RetailVoucherApiFunctions"; DurationMs: Decimal; HttpStatusCode: Integer; Response: Codeunit "NPR API Response")
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

            Session.LogMessage('NPR_API_RetailVouchers', ResponseMessage, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
        end else begin
            JsonObj := Response.GetJson(); // Note: This will throw an error if the response is not JSON Object which might be true for some success responses
            ResponseMessage := StrSubstNo('Failure - HTTP %1', HttpStatusCode);
            if (JsonObj.Get('message', JToken)) then
                CustomDimensions.Add('NPR_ErrorText', JToken.AsValue().AsText());
            if (JsonObj.Get('code', JToken)) then
                CustomDimensions.Add('NPR_ErrorCodeName', JToken.AsValue().AsText());

            Session.LogMessage('NPR_API_RetailVouchers', ResponseMessage, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
        end;
    end;
}
#endif