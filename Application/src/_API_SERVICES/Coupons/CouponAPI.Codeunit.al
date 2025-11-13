#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248526 "NPR CouponAPI" implements "NPR API Request Handler"
{
    Access = Internal;

    var
        _ApiFunction: Enum "NPR CouponApiFunctions";

    procedure Handle(var Request: Codeunit "NPR API Request"): Codeunit "NPR API Response"
    begin
        if (Request.Match('POST', '/coupon')) then
            exit(Handle(_ApiFunction::CREATE_COUPON, Request));

        if (Request.Match('GET', '/coupon/:couponId')) then
            exit(Handle(_ApiFunction::GET_COUPON, Request));

        if (Request.Match('DELETE', '/coupon/:couponId')) then
            exit(Handle(_ApiFunction::DELETE_COUPON, Request));
    end;

    local procedure Handle(ApiFunction: Enum "NPR CouponApiFunctions"; var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        CouponAPIHandler: Codeunit "NPR CouponAPIHandler";
        StartTime: Time;
        ResponseMessage: Text;
        ApiError: Enum "NPR API Error Code";
    begin
        StartTime := Time();
        Commit();
        ClearLastError();

        CouponAPIHandler.SetRequest(ApiFunction, Request);
        if (CouponAPIHandler.Run()) then begin
            Response := CouponAPIHandler.GetResponse();
            LogMessage(ApiFunction, GetTimeDifference(Time(), StartTime), Response.GetStatusCode(), Response);
            exit(Response);
        end;

        ResponseMessage := GetLastErrorText();
        ApiError := ErrorToEnum();

        Response.CreateErrorResponse(ApiError, ResponseMessage);
        LogMessage(ApiFunction, GetTimeDifference(Time(), StartTime), Response.GetStatusCode(), Response);
        exit(Response);
    end;

    procedure GetTimeDifference(Time1: Time; Time2: Time): Decimal
    var
        OneDayInMs: Decimal;
        DiffMs: Decimal;
    begin
        OneDayInMs := 24 * 60 * 60 * 1000;
        DiffMs := Time2 - Time1;

        if DiffMs < 0 then
            DiffMs := DiffMs + OneDayInMs; // crossed midnight

        exit(DiffMs);
    end;

    local procedure ErrorToEnum(): Enum "NPR API Error Code"
    begin
        exit(Enum::"NPR API Error Code"::generic_error);
    end;

    local procedure LogMessage(Function: Enum "NPR CouponApiFunctions";
        DurationMs: Decimal;
        HttpStatusCode: Integer;
        Response: Codeunit "NPR API Response")
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

            Session.LogMessage('NPR_API_Coupon', ResponseMessage, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
        end else begin
            JsonObj := Response.GetJson(); // Note: This will throw an error if the response is not JSON Object which might be true for some success responses
            ResponseMessage := StrSubstNo('Failure - HTTP %1', HttpStatusCode);
            if (JsonObj.Get('message', JToken)) then
                CustomDimensions.Add('NPR_ErrorText', JToken.AsValue().AsText());
            if (JsonObj.Get('code', JToken)) then
                CustomDimensions.Add('NPR_ErrorCodeName', JToken.AsValue().AsText());

            Session.LogMessage('NPR_API_Coupon', ResponseMessage, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
        end;
    end;

}
#endif