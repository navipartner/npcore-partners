#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6185116 "NPR ApiSpeedgate" implements "NPR API Request Handler"
{
    Access = Internal;

    var
        _Functions: Enum "NPR ApiSpeedgateFunctions";

    procedure Handle(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    begin
        if (Request.Match('GET', '/speedgate')) then
            exit(Handle(_Functions::GET_SPEEDGATE_SETUP, Request));

        if (Request.Match('GET', '/speedgate/:id')) then
            exit(Handle(_Functions::GET_SPEEDGATE_SETUP, Request));


        if (Request.Match('POST', '/speedgate/try')) then
            exit(Handle(_Functions::TRY_ADMIT, Request));

        if (Request.Match('POST', '/speedgate/admit')) then
            exit(Handle(_Functions::ADMIT, Request));

    end;

    local procedure Handle(Function: Enum "NPR ApiSpeedgateFunctions"; Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        SpeedgateHandler: Codeunit "NPR ApiSpeedgateHandler";
        ResponseMessage: Text;
        ApiError: Enum "NPR API Error Code";
        StartTime: Time;
    begin
        StartTime := Time();

        Commit();
        SpeedgateHandler.SetRequest(Function, Request);

        if (SpeedgateHandler.Run()) then begin
            Response := SpeedgateHandler.GetResponse();
            LogMessage(Function, (Time() - StartTime), Response.GetStatusCode(), Response);
            exit(Response);
        end;

        // When the code throws an error, the response is not set by the handler
        ResponseMessage := GetLastErrorText();
        ApiError := ErrorToEnum(ResponseMessage);

        if (Function in [_Functions::TRY_ADMIT, _Functions::ADMIT]) then begin
            SpeedgateHandler.SetRequest(_Functions::MARK_AS_DENIED, Request, ApiError, ResponseMessage);
            if (SpeedgateHandler.Run()) then;
        end;

        Response.CreateErrorResponse(ApiError, ResponseMessage);
        LogMessage(Function, (Time() - StartTime), Response.GetStatusCode(), Response);
        exit(Response);
    end;

    local procedure LogMessage(Function: Enum "NPR ApiSpeedgateFunctions"; DurationMs: Decimal; HttpStatusCode: Integer; Response: Codeunit "NPR API Response")
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

            Session.LogMessage('NPR_API_Speedgate', ResponseMessage, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
        end else begin
            JsonObj := Response.GetJson();

            ResponseMessage := StrSubstNo('Failure - HTTP %1', HttpStatusCode);
            if (JsonObj.Get('message', JToken)) then
                CustomDimensions.Add('NPR_ErrorText', JToken.AsValue().AsText());
            if (JsonObj.Get('code', JToken)) then
                CustomDimensions.Add('NPR_ErrorCodeName', JToken.AsValue().AsText());

            Session.LogMessage('NPR_API_Speedgate', ResponseMessage, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
        end;
    end;

    local procedure ErrorToEnum(ErrorMessage: Text): Enum "NPR API Error Code"
    begin
        if (ErrorMessage.StartsWith('[-1001]')) then
            exit(Enum::"NPR API Error Code"::invalid_reference);
        if (ErrorMessage.StartsWith('[-1002]')) then
            Exit(Enum::"NPR API Error Code"::reservation_not_found);
        if (ErrorMessage.StartsWith('[-1003]')) then
            Exit(Enum::"NPR API Error Code"::not_valid);
        if (ErrorMessage.StartsWith('[-1004]')) then
            Exit(Enum::"NPR API Error Code"::capacity_exceeded);
        if (ErrorMessage.StartsWith('[-1005]')) then
            Exit(Enum::"NPR API Error Code"::reservation_mismatch);
        if (ErrorMessage.StartsWith('[-1008]')) then
            Exit(Enum::"NPR API Error Code"::admission_not_open);
        if (ErrorMessage.StartsWith('[-1009]')) then
            Exit(Enum::"NPR API Error Code"::admission_not_open_entry);
        if (ErrorMessage.StartsWith('[-1010]')) then
            Exit(Enum::"NPR API Error Code"::not_confirmed);
        if (ErrorMessage.StartsWith('[-1014]')) then
            Exit(Enum::"NPR API Error Code"::reservation_not_for_today);
        if (ErrorMessage.StartsWith('[-1015]')) then
            Exit(Enum::"NPR API Error Code"::reservation_capacity_exceeded);
        if (ErrorMessage.StartsWith('[-1016]')) then
            Exit(Enum::"NPR API Error Code"::ticket_canceled);
        if (ErrorMessage.StartsWith('[-1017]')) then
            Exit(Enum::"NPR API Error Code"::ticket_not_valid_yet);
        if (ErrorMessage.StartsWith('[-1018]')) then
            Exit(Enum::"NPR API Error Code"::ticket_expired);
        if (ErrorMessage.StartsWith('[-1019]')) then
            Exit(Enum::"NPR API Error Code"::quantity_change_not_allowed);
        if (ErrorMessage.StartsWith('[-1021]')) then
            Exit(Enum::"NPR API Error Code"::no_default_schedule);
        if (ErrorMessage.StartsWith('[-1022]')) then
            Exit(Enum::"NPR API Error Code"::missing_payment);
        if (ErrorMessage.StartsWith('[-1023]')) then
            Exit(Enum::"NPR API Error Code"::schedule_entry_expired);
        if (ErrorMessage.StartsWith('[-1028]')) then
            Exit(Enum::"NPR API Error Code"::reservation_not_for_now);
        if (ErrorMessage.StartsWith('[-1030]')) then
            Exit(Enum::"NPR API Error Code"::concurrent_capacity_exceeded);
        if (ErrorMessage.StartsWith('[-1031]')) then
            Exit(Enum::"NPR API Error Code"::reschedule_not_allowed);
        if (ErrorMessage.StartsWith('[-1032]')) then
            Exit(Enum::"NPR API Error Code"::invalid_admission_code);
        if (ErrorMessage.StartsWith('[-1033]')) then
            Exit(Enum::"NPR API Error Code"::has_payment);
        if (ErrorMessage.StartsWith('[-1035]')) then
            Exit(Enum::"NPR API Error Code"::duration_exceeded);

        if (ErrorMessage.StartsWith('[-3149]')) then
            Exit(Enum::"NPR API Error Code"::member_card_limitation_error);

    end;
}
#endif