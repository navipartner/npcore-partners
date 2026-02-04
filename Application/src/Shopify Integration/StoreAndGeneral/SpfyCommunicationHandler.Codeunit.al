#if not BC17
codeunit 6184924 "NPR Spfy Communication Handler"
{
    Access = Internal;
    SingleInstance = true;

    var
        SpfyIntegrationEvents: Codeunit "NPR Spfy Integration Events";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";

    [TryFunction]
    procedure TryDownloadOrders(ShopifyStoreCode: Code[20]; Link: Text; FromDT: DateTime; Limit: Integer; Status: Text; var Orders: JsonArray; var NextLink: Text)
    var
        NcTask: Record "NPR Nc Task";
        Result: JsonObject;
        Token: JsonToken;
        ResponseText: Text;
        Url: Text;
        OrderCount: Integer;
        NoOrdersErr: Label 'No Orders within the filter: %1';
    begin
        Clear(NextLink);
        Clear(NcTask);
        NcTask."Store Code" := ShopifyStoreCode;

        if Link = '' then
            Url := GetShopifyUrl(NcTask."Store Code") +
                StrSubstNo('orders.json?status=%1&updated_at_min=%2&limit=%3', Status, Format(FromDT, 0, 9), Format(Limit))
        else
            Url := Link;

        ResponseText := SendShopifyRequest(NcTask, Enum::"Http Request Type"::GET, Url, NextLink);

        Result.ReadFrom(ResponseText);
        Result.SelectToken('orders', Token);
        Orders := Token.AsArray();
        OrderCount := Orders.Count();
        if OrderCount = 0 then
            Error(NoOrdersErr, Url);
    end;


    [Obsolete('This procedure is part of the Shopify REST API , which is deprecated. Use the GraphQL query instead.', '2026-01-15')]
    procedure GetShopifyOrderFulfillmentOrders(ShopifyStoreCode: Code[20]; ShopifyOrderID: Text[30]; var ShopifyResponse: JsonToken)
    var
        ResponseText: Text;
        Url: Text;
    begin
        Url := GetShopifyUrl(ShopifyStoreCode) + StrSubstNo('orders/%1/fulfillment_orders.json', ShopifyOrderID);
        ResponseText := SendShopifyRequest(ShopifyStoreCode, Enum::"Http Request Type"::GET, Url);
        ShopifyResponse.ReadFrom(ResponseText);
    end;

    procedure GetShopifyStoreConfiguration(ShopifyStoreCode: Code[20]; var ShopifyResponse: JsonToken): Boolean
    var
        NcTask: Record "NPR Nc Task";
        QueryStream: OutStream;
        RequestJson: JsonObject;
    begin
        NcTask."Store Code" := ShopifyStoreCode;
        RequestJson.Add('query', 'query { shop { id name currencyCode plan { displayName shopifyPlus } } }');
        NcTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        RequestJson.WriteTo(QueryStream);

        exit(ExecuteShopifyGraphQLRequest(NcTask, false, ShopifyResponse));
    end;

    [TryFunction]
    procedure ExecuteShopifyGraphQLRequest(var NcTask: Record "NPR Nc Task"; CheckIntegrationIsEnabled: Boolean; var ShopifyResponse: JsonToken)
    var
        ResponseText: Text;
        Url: Text;
    begin
        Url := GetShopifyUrl(NcTask."Store Code", CheckIntegrationIsEnabled) + 'graphql.json';
        ResponseText := SendShopifyRequest(NcTask, Enum::"Http Request Type"::POST, Url);
        ShopifyResponse.ReadFrom(ResponseText);
    end;

    procedure UserErrorsExistInGraphQLResponse(ShopifyResponse: JsonToken): Boolean
    var
        ResponseDataItemUserErrors: JsonToken;
    begin
        exit(UserErrorsExistInGraphQLResponse(ShopifyResponse, ResponseDataItemUserErrors));
    end;

    procedure UserErrorsExistInGraphQLResponse(ShopifyResponse: JsonToken; var ResponseDataItemUserErrors: JsonToken): Boolean
    var
        ResponseDataSet: JsonToken;
        DataKey: Text;
    begin
        if not (ShopifyResponse.SelectToken('data', ResponseDataSet) and ResponseDataSet.IsObject()) then
            exit(false);

        foreach DataKey in ResponseDataSet.AsObject().Keys() do
            if ResponseDataSet.SelectToken(DataKey + '.userErrors', ResponseDataItemUserErrors) then
                if ResponseDataItemUserErrors.IsArray() then
                    exit(ResponseDataItemUserErrors.AsArray().Count() > 0);

        exit(false);
    end;

    procedure AddGraphQLCursor(var VariablesJson: JsonObject; Cursor: Text)
    var
        CursorValue: JsonValue;
    begin
        if Cursor = '' then
            CursorValue.SetValueToNull()
        else
            CursorValue.SetValue(Cursor);

        VariablesJson.Add('afterCursor', CursorValue);
    end;

    internal procedure CompleteGraphQLRequest(RequestString: Text; VariablesJson: JsonObject; var NcTask: Record "NPR Nc Task")
    var
        RequestJson: JsonObject;
        QueryStream: OutStream;
    begin
        RequestJson.Add('query', RequestString);
        RequestJson.Add('variables', VariablesJson);
        NcTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        RequestJson.WriteTo(QueryStream);
    end;

    [Obsolete('This procedure is part of the Shopify REST API , which is deprecated. Use the GraphQL query instead.', '2026-01-15')]
    local procedure SendShopifyRequest(ShopifyStoreCode: Code[20]; RestMethod: Enum "Http Request Type"; Url: Text) ResponseText: Text
    var
        NcTask: Record "NPR Nc Task";
        NextLink: Text;
    begin
        Clear(NcTask);
        NcTask."Store Code" := ShopifyStoreCode;
        ResponseText := SendShopifyRequest(NcTask, RestMethod, Url, NextLink);
    end;

    internal procedure CreateGraphQLRequestWithOrderIdFilter(var NcTask: Record "NPR Nc Task"; Cursor: Text; ShopifyStoreCode: Code[20]; RequestString: Text; OrderGID: Text[100]; IncludeCursor: Boolean)
    var
        VariablesJson: JsonObject;
    begin
        NcTask."Store Code" := ShopifyStoreCode;
        VariablesJson.Add('OrderId', OrderGID);
        if IncludeCursor then // Cursor is added only for paginated GraphQL queries. Header-level queries do not support pagination parameters.
            AddGraphQLCursor(VariablesJson, Cursor);
        CompleteGraphQLRequest(RequestString, VariablesJson, NcTask);
    end;

    internal procedure InitializePagingState(var Cursor: Text; var HasNext: Boolean)
    begin
        Cursor := '';
        HasNext := true;
    end;

    internal procedure CheckRequestContent(var NcTask: Record "NPR Nc Task")
    var
        NoRequestBodyErr: Label 'Each request must have a json formatted content attached';
    begin
        NcTask.TestField("Store Code");
        NcTask.testfield("Record Value");
        if not NcTask."Data Output".HasValue then
            Error(NoRequestBodyErr);
    end;

    local procedure SendShopifyRequest(var NcTask: Record "NPR Nc Task"; RestMethod: Enum "Http Request Type"; Url: Text) ResponseText: Text
    var
        NextLink: Text;
    begin
        ResponseText := SendShopifyRequest(NcTask, RestMethod, Url, NextLink);
    end;

    local procedure SendShopifyRequest(var NcTask: Record "NPR Nc Task"; RestMethod: Enum "Http Request Type"; Url: Text; var NextLink: Text) ResponseText: Text
    begin
        if not TrySendShopifyRequest(NcTask, RestMethod, Url, NextLink, ResponseText) then
            Error(GetLastErrorText());
    end;

    [TryFunction]
    local procedure TrySendShopifyRequest(var NcTask: Record "NPR Nc Task"; RestMethod: Enum "Http Request Type"; Url: Text; var NextLink: Text; var ResponseText: Text)
    var
        Client: HttpClient;
        RequestMsg: HttpRequestMessage;
        ResponseMsg: HttpResponseMessage;
        Links: array[1] of Text;
        ErrorTxt: Text;
        MaxRetries: Integer;
        RetryCounter: Integer;
        Retry: Boolean;
        Success: Boolean;
    begin
        CheckHttpClientRequestsAllowed();

        Clear(NextLink);
        MaxRetries := 3;
        RetryCounter := 0;

        repeat
            RetryCounter += 1;
            Clear(Client);
            Clear(RequestMsg);
            Clear(ResponseMsg);

            CreateRequestMsg(NcTask, RestMethod, Url, RequestMsg);
            if not Client.Send(RequestMsg, ResponseMsg) then
                Error(GetLastErrorText());

            Success := ResponseMsg.IsSuccessStatusCode();
            if not Success then
                case true of
                    RetryCounter >= MaxRetries:
                        Retry := false;
                    TreatAsSuccess(NcTask, ResponseMsg):
                        Retry := false;
                    else
                        Retry := ResponseAllowsRetries(ResponseMsg);
                end;
        until Success or not Retry;

        SaveResponse(NcTask, ResponseMsg);

        if not ResponseMsg.Content().ReadAs(ResponseText) then
            ResponseText := '';
        if ResponseText = '' then
            ResponseText := '{}';

        if Success then
            if TreatAsError(NcTask, ResponseMsg, ResponseText, ErrorTxt) then
                Error(ErrorTxt);

        if not Success then
            if not TreatAsSuccess(NcTask, ResponseMsg, ResponseText, ErrorTxt) then
                Error(ErrorTxt);

        if ResponseMsg.Headers().GetValues('Link', Links) then
            NextLink := ParseNextLink(Links[1]);
    end;

    local procedure CreateRequestMsg(var NcTask: Record "NPR Nc Task"; RestMethod: Enum "Http Request Type"; Url: Text; var RequestMsg: HttpRequestMessage)
    var
        Content: HttpContent;
        Headers: HttpHeaders;
        InStr: InStream;
    begin
        if NcTask."Data Output".HasValue() then begin
            NcTask."Data Output".CreateInStream(InStr, TextEncoding::UTF8);
            Content.WriteFrom(InStr);

            Content.GetHeaders(Headers);
            if Headers.Contains('Content-Type') then
                Headers.Remove('Content-Type');
            Headers.Add('Content-Type', 'application/json');

            RequestMsg.Content := Content;
        end;

        RequestMsg.SetRequestUri(Url);
        RequestMsg.Method(Format(RestMethod));
        RequestMsg.GetHeaders(Headers);
        Headers.Add('X-Shopify-Access-Token', GetShopifyAccessToken(NcTask."Store Code"));
        Headers.Add('Accept', 'application/json');
        Headers.Add('User-Agent', 'NPRetail-BC');
    end;

    local procedure SaveResponse(var NcTask: Record "NPR Nc Task"; var ResponseMsg: HttpResponseMessage)
    var
        InStr: InStream;
        OutStr: OutStream;
    begin
        ResponseMsg.Content().ReadAs(InStr);
        Clear(NcTask.Response);
        NcTask.Response.CreateOutStream(OutStr, TextEncoding::UTF8);
        CopyStream(OutStr, InStr);
    end;

    local procedure ResponseAllowsRetries(ResponseMsg: HttpResponseMessage): Boolean
    var
        Values: array[1] of Text;
        BucketPerc: Decimal;
        BucketSize: Integer;
        BucketUse: Integer;
        Status: Integer;
        WaitTime: Integer;
    begin
        Status := ResponseMsg.HttpStatusCode();
        case Status of
            429:  //Too Many Requests
                begin
                    if ResponseMsg.Headers().GetValues('Retry-After', Values) then
                        if Evaluate(WaitTime, Values[1], 9) then
                            if WaitTime > 0 then begin
                                if WaitTime > 10 then
                                    exit(false);  //Too long wait time
                                WaitTime := WaitTime * 1000;
                            end;
                    if WaitTime <= 0 then
                        WaitTime := 2000;
                end;

            500 .. 599:  //Internal Shopify errors
                WaitTime := 5000;

            else begin
                WaitTime := -1;
                if ResponseMsg.Headers().GetValues('X-Shopify-Shop-Api-Call-Limit', Values) then
                    if Evaluate(BucketUse, Values[1].Split('/').Get(1)) and Evaluate(BucketSize, Values[1].Split('/').Get(2)) then begin
                        BucketPerc := 100 * BucketUse / BucketSize;
                        case true of
                            BucketPerc >= 90:
                                WaitTime := 1000;
                            BucketPerc >= 80:
                                WaitTime := 800;
                            BucketPerc >= 70:
                                WaitTime := 600;
                            BucketPerc >= 60:
                                WaitTime := 400;
                            BucketPerc >= 50:
                                WaitTime := 200;
                            else
                                WaitTime := 0;
                        end;
                    end;
                if WaitTime = -1 then
                    exit(false);
            end;
        end;

        if WaitTime > 0 then begin
            EmitError(Status);
            Sleep(WaitTime);
        end;
        exit(true);
    end;

    local procedure TreatAsError(NcTask: Record "NPR Nc Task"; ResponseMsg: HttpResponseMessage; ResponseText: Text; var ErrorTxt: Text): Boolean
    var
        ErrorJToken: JsonToken;
        ResponseJToken: JsonToken;
        Handled: Boolean;
        IsError: Boolean;
        UnknownErrorTxt: Label 'An error has occurred while processing the request. The system did not provide any details of the error.';
    begin
        if not ResponseJToken.ReadFrom(ResponseText) then
            exit(false);
        SpfyIntegrationEvents.OnTreatSuccessfulResponseAsError(NcTask, ResponseMsg, ResponseJToken, ErrorTxt, IsError, Handled);
        if not Handled then begin
            IsError := ResponseJToken.SelectToken('errors', ErrorJToken);
            if IsError then begin
                ResponseJToken.SelectToken('errors[0].message', ErrorJToken);
                ErrorTxt := ErrorJToken.AsValue().AsText();
            end;
        end;
        if IsError and (ErrorTxt = '') then
            ErrorTxt := UnknownErrorTxt;
        exit(IsError);
    end;

    local procedure TreatAsSuccess(NcTask: Record "NPR Nc Task"; ResponseMsg: HttpResponseMessage): Boolean
    var
        ResponseText: Text;
        ErrorTxt: Text;
    begin
        if not ResponseMsg.Content().ReadAs(ResponseText) then
            ResponseText := '';
        if ResponseText = '' then
            ResponseText := '{}';
        ErrorTxt := 'n/a';
        exit(TreatAsSuccess(NcTask, ResponseMsg, ResponseText, ErrorTxt));
    end;

    local procedure TreatAsSuccess(NcTask: Record "NPR Nc Task"; ResponseMsg: HttpResponseMessage; ResponseText: Text; var ErrorTxt: Text): Boolean
    var
        ErrorJToken: JsonToken;
        ResponseJToken: JsonToken;
        Handled: Boolean;
        IsSuccess: Boolean;
        AlreadyCapturedTok: Label 'The authorized transaction has already been captured', Locked = true;
        AlreadyDisabledTok: Label 'Gift card is disabled', Locked = true;
    begin
        if not ResponseJToken.ReadFrom(ResponseText) then
            exit(false);
        SpfyIntegrationEvents.OnTreatErroneousResponseAsSuccess(NcTask, ResponseMsg, ResponseJToken, ErrorTxt, IsSuccess, Handled);
        if not Handled then
            case true of
                (NcTask."Table No." = Database::"NPR Magento Payment Line") and (ResponseMsg.HttpStatusCode() = 422):
                    if ResponseJToken.SelectToken('errors.base[0]', ErrorJToken) then
                        IsSuccess := ErrorJToken.AsValue().AsText() = AlreadyCapturedTok;

                (NcTask."Table No." = Database::"NPR NpRv Voucher Entry") and (ResponseMsg.HttpStatusCode() = 422):
                    if ResponseJToken.SelectToken('errors.base[0]', ErrorJToken) then
                        IsSuccess := ErrorJToken.AsValue().AsText() = AlreadyDisabledTok;
            end;
        if not IsSuccess and (ErrorTxt = '') then
            ErrorTxt := StrSubstNo('%1: %2\%3', ResponseMsg.HttpStatusCode(), ResponseMsg.ReasonPhrase(), ResponseText);
        exit(IsSuccess);
    end;

    local procedure ParseNextLink(Link: Text) NextLink: Text
    var
        Rel: Text;
        RelPosition: Integer;
        IndexPosition: Integer;
        RelKey: Text;
        RelLen: Integer;
    begin
        RelKey := '>; rel=';
        RelLen := StrLen(RelKey);
        repeat
            if Link = '' then
                exit('');

            if Link[1] = '<' then
                Link := DelStr(Link, 1, 1);
            RelPosition := StrPos(Link, RelKey);
            if RelPosition = 0 then
                exit('');

            IndexPosition := StrPos(Link, ', ');

            if IndexPosition < RelPosition + RelLen then
                Rel := CopyStr(Link, RelPosition + RelLen)
            else
                Rel := CopyStr(Link, RelPosition + RelLen, IndexPosition - RelPosition - RelLen);
            Rel := DelChr(Rel, '=', '"');
            if Rel = 'next' then begin
                NextLink := DelStr(Link, RelPosition);
                exit(NextLink);
            end;

            if IndexPosition > 0 then
                Link := DelStr(Link, 1, IndexPosition + 1)
            else
                Link := '';
        until Link = '';

        exit('');
    end;

    local procedure CheckHttpClientRequestsAllowed()
    var
        EnvironmentInfo: Codeunit "Environment Information";
        NAVAppSettings: Record "NAV App Setting";
        HttpRequrestsAreNotAllowedErr: Label 'Http requests are blocked by default in sandbox environments. In order to proceed, you must allow HttpClient requests for NP Retail extension.';
    begin
        if EnvironmentInfo.IsSandbox() then
            if not (NAVAppSettings.Get('992c2309-cca4-43cb-9e41-911f482ec088') and NAVAppSettings."Allow HttpClient Requests") then
                Error(HttpRequrestsAreNotAllowedErr);
    end;

    local procedure GetShopifyUrl(ShopifyStoreCode: Code[20]) ShopifyUrl: Text
    begin
        ShopifyUrl := GetShopifyUrl(ShopifyStoreCode, true);
    end;

    local procedure GetShopifyUrl(ShopifyStoreCode: Code[20]; CheckIsEnabled: Boolean) ShopifyUrl: Text
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        if CheckIsEnabled then
            SpfyIntegrationMgt.CheckIsEnabled("NPR Spfy Integration Area"::" ", ShopifyStoreCode);

        ShopifyStore.Get(ShopifyStoreCode);
        ShopifyStore.TestField("Shopify Url");

        ShopifyUrl := StrSubstNo('%1/admin/api/%2/', ShopifyStore."Shopify Url", SpfyIntegrationMgt.ShopifyApiVersion());
    end;

    local procedure GetShopifyAccessToken(ShopifyStoreCode: Code[20]): Text
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        ShopifyStore.Get(ShopifyStoreCode);
        ShopifyStore.TestField("Shopify Access Token");

        exit(ShopifyStore."Shopify Access Token");
    end;

    procedure IsValidShopUrl(ShopUrl: Text): Boolean
    var
        Regex: Codeunit Regex;
        PatternLbl: Label '^(https)\:\/\/[a-zA-Z0-9][a-zA-Z0-9\-]*\.myshopify\.com[\/]*$', Locked = true;
    begin
        exit(Regex.IsMatch(ShopUrl, PatternLbl))
    end;

    local procedure EmitError(StatusCode: Integer)
    var
        ActiveSession: Record "Active Session";
        CustomDimensions: Dictionary of [Text, Text];
        InputMessage: text;
        InternalErr: Label 'Shopify is experiencing internal errors and requests are throttled.';
        ThrottleErr: Label 'GraphQL API rate limit has been exceeded and requests are throttled.';
    begin
        if (StatusCode in [500 .. 599]) then
            InputMessage := InternalErr
        else
            InputMessage := ThrottleErr;

        if (not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId())) then
            ActiveSession.Init();
        CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
        CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
        CustomDimensions.Add('NPR_TenantId', Database.TenantId());
        CustomDimensions.Add('NPR_CompanyName', CompanyName());
        CustomDimensions.Add('NPR_UserID', ActiveSession."User ID");
        CustomDimensions.Add('NPR_SessionId', Format(Database.SessionId(), 0, 9));
        CustomDimensions.Add('NPR_ClientComputerName', ActiveSession."Client Computer Name");

        Session.LogMessage('Shopify_GraphQlAPI_Throttle', InputMessage, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;
}
#endif