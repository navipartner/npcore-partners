#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248329 "NPR AttrWalletAPI" implements "NPR API Request Handler"
{
    Access = Internal;

    var
        _ApiFunction: Enum "NPR AttrWalletApiFunctions";

    procedure Handle(var Request: Codeunit "NPR API Request"): Codeunit "NPR API Response"
    begin

        if (Request.Match('GET', '/attractionWallet')) then
            exit(Handle(_ApiFunction::FIND_WALLET_USING_REFERENCE_NUMBER, Request));

        if (Request.Match('GET', '/attractionWallet/:walletId')) then
            exit(Handle(_ApiFunction::GET_WALLET_USING_ID, Request));

        if (Request.Match('GET', '/attractionWallet/assetHistory/:assetId')) then
            exit(Handle(_ApiFunction::GET_ASSET_HISTORY, Request));

        if (Request.Match('PUT', '/attractionWallet/:walletId')) then
            exit(Handle(_ApiFunction::ADD_WALLET_ASSETS, Request));

        if (Request.Match('POST', '/attractionWallet/:walletId/confirmPrint')) then
            exit(Handle(_ApiFunction::CONFIRM_PRINT_WALLET, Request));

        if (Request.Match('POST', '/attractionWallet/:walletId/clearConfirmPrint')) then
            exit(Handle(_ApiFunction::CLEAR_CONFIRM_PRINT_WALLET, Request));

        if (Request.Match('POST', '/attractionWallet')) then
            exit(Handle(_ApiFunction::CREATE_WALLET, Request));

    end;

    local procedure Handle(ApiFunction: Enum "NPR AttrWalletApiFunctions"; var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        AttrWalletAPIHandler: Codeunit "NPR AttrWalletAPIHandler";
        StartTime: Time;
        ResponseMessage: Text;
        ApiError: Enum "NPR API Error Code";
    begin
        StartTime := Time();
        Commit();
        ClearLastError();

        Request.SkipCacheIfNonStickyRequest(AttractionWalletTransactionTables());

        AttrWalletAPIHandler.SetRequest(ApiFunction, Request);
        if (AttrWalletAPIHandler.Run()) then begin
            Response := AttrWalletAPIHandler.GetResponse();
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
        if (ErrorMessage.StartsWith('[XXXXX]')) then
            exit(Enum::"NPR API Error Code"::generic_error);

        exit(Enum::"NPR API Error Code"::generic_error);
    end;

    local procedure LogMessage(Function: Enum "NPR AttrWalletApiFunctions";
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

            Session.LogMessage('NPR_API_Membership', ResponseMessage, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
        end else begin
            JsonObj := Response.GetJson(); // Note: This will throw an error if the response is not JSON Object which might be true for some success responses
            ResponseMessage := StrSubstNo('Failure - HTTP %1', HttpStatusCode);
            if (JsonObj.Get('message', JToken)) then
                CustomDimensions.Add('NPR_ErrorText', JToken.AsValue().AsText());
            if (JsonObj.Get('code', JToken)) then
                CustomDimensions.Add('NPR_ErrorCodeName', JToken.AsValue().AsText());

            Session.LogMessage('NPR_API_Membership', ResponseMessage, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
        end;
    end;

    local procedure AttractionWalletTransactionTables() TableList: List of [Integer]
    begin
        TableList.Add(Database::"NPR AttractionWallet");
        TableList.Add(Database::"NPR AttractionWalletExtRef");
        TableList.Add(Database::"NPR AttractionWalletSaleHdr");
        TableList.Add(Database::"NPR AttractionWalletSaleLine");
        TableList.Add(Database::"NPR WalletAssetHeader");
        TableList.Add(Database::"NPR WalletAssetHeaderReference");
        TableList.Add(Database::"NPR WalletAssetLine");
        TableList.Add(Database::"NPR WalletAssetLineReference");

        TableList.Add(Database::"NPR MM Member Card");
        TableList.Add(Database::"NPR MM Member");
        TableList.Add(Database::"NPR MM Membership");
        TableList.Add(Database::"NPR MM Membership Role");

        TableList.Add(Database::"NPR TM Ticket");
        TableList.Add(Database::"NPR TM Ticket Type");
        TableList.Add(Database::"NPR TM Ticket Access Entry");
        TableList.Add(Database::"NPR TM Det. Ticket AccessEntry");
        TableList.Add(Database::"NPR TM Ticket Reservation Req.");
    end;

}
#endif