#if not BC17
codeunit 6184924 "NPR Spfy Communication Handler"
{
    Access = Internal;
    SingleInstance = true;

    var
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

        ResponseText := SendShopifyRequest(NcTask, 'GET', Url, NextLink);

        Result.ReadFrom(ResponseText);
        Result.SelectToken('orders', Token);
        Orders := Token.AsArray();
        OrderCount := Orders.Count();
        if OrderCount = 0 then
            Error(NoOrdersErr, Url);
    end;

    [TryFunction]
    procedure SendFulfillmentRequest(var NcTask: Record "NPR Nc Task")
    var
        Url: Text;
    begin
        CheckRequestContent(NcTask);

        Url := GetShopifyUrl(NcTask."Store Code") + 'fulfillments.json';
        SendShopifyRequest(NcTask, 'POST', Url);
    end;

    procedure GetShopifyOrderFulfillmentOrders(ShopifyStoreCode: Code[20]; ShopifyOrderID: Text[30]; var ShopifyResponse: JsonToken)
    var
        ResponseText: Text;
        Url: Text;
    begin
        Url := GetShopifyUrl(ShopifyStoreCode) + StrSubstNo('orders/%1/fulfillment_orders.json', ShopifyOrderID);
        ResponseText := SendShopifyRequest(ShopifyStoreCode, 'GET', Url);
        ShopifyResponse.ReadFrom(ResponseText);
    end;

    [TryFunction]
    procedure GetShopifyLocations(ShopifyStoreCode: Code[20]; var ShopifyResponse: JsonToken)
    var
        NcTask: Record "NPR Nc Task";
        ResponseText: Text;
        Url: Text;
    begin
        NcTask."Store Code" := ShopifyStoreCode;
        Url := GetShopifyUrl(NcTask."Store Code") + 'locations.json';
        ResponseText := SendShopifyRequest(NcTask, 'GET', Url);
        ShopifyResponse.ReadFrom(ResponseText);
    end;

    [TryFunction]
    procedure SendTransactionRequest(var NcTask: Record "NPR Nc Task")
    var
        Url: Text;
    begin
        CheckRequestContent(NcTask);

        Url := GetShopifyUrl(NcTask."Store Code") + StrSubstNo('orders/%1/transactions.json', NcTask."Record Value");
        SendShopifyRequest(NcTask, 'POST', Url);
    end;

    [TryFunction]
    procedure TryGetShopifyOrderTransactions(var NcTask: Record "NPR Nc Task"; var SpfyOrderTransactions: JsonObject)
    begin
        GetShopifyOrderTransactions(NcTask, SpfyOrderTransactions);
    end;

    procedure GetShopifyOrderTransactions(var NcTask: Record "NPR Nc Task"; var SpfyOrderTransactions: JsonObject)
    var
        ResponseText: Text;
        Url: Text;
    begin
        Url := GetShopifyUrl(NcTask."Store Code") + StrSubstNo('orders/%1/transactions.json', NcTask."Record Value");
        ResponseText := SendShopifyRequest(NcTask, 'GET', Url);
        SpfyOrderTransactions.ReadFrom(ResponseText);
    end;

    [TryFunction]
    procedure ExecuteShopifyGraphQLRequest(var NcTask: Record "NPR Nc Task"; var ShopifyResponse: JsonToken)
    var
        ResponseText: Text;
        Url: Text;
    begin
        Url := GetShopifyUrl(NcTask."Store Code") + 'graphql.json';
        ResponseText := SendShopifyRequest(NcTask, 'POST', Url);
        ShopifyResponse.ReadFrom(ResponseText);
    end;

    [TryFunction]
    procedure SendItemCreateRequest(var NcTask: Record "NPR Nc Task"; var ShopifyResponse: JsonToken)
    var
        ResponseText: Text;
        Url: Text;
    begin
        CheckRequestContent(NcTask);

        Url := GetShopifyUrl(NcTask."Store Code") + 'products.json';
        ResponseText := SendShopifyRequest(NcTask, 'POST', Url);
        ShopifyResponse.ReadFrom(ResponseText);
    end;

    [TryFunction]
    procedure SendItemUpdateRequest(var NcTask: Record "NPR Nc Task"; ShopifyItemID: Text[30]; var ShopifyResponse: JsonToken)
    var
        ResponseText: Text;
        Url: Text;
    begin
        CheckRequestContent(NcTask);

        Url := GetShopifyUrl(NcTask."Store Code") + StrSubstNo('products/%1.json', ShopifyItemID);
        ResponseText := SendShopifyRequest(NcTask, 'PUT', Url);
        ShopifyResponse.ReadFrom(ResponseText);
    end;

    [TryFunction]
    procedure SendItemDeleteRequest(var NcTask: Record "NPR Nc Task"; ShopifyItemID: Text[30])
    var
        Url: Text;
    begin
        Url := GetShopifyUrl(NcTask."Store Code") + StrSubstNo('products/%1.json', ShopifyItemID);
        SendShopifyRequest(NcTask, 'DELETE', Url);
    end;

    [TryFunction]
    procedure SendItemVariantCreateRequest(var NcTask: Record "NPR Nc Task"; ShopifyItemID: Text[30]; var ShopifyResponse: JsonToken)
    var
        ResponseText: Text;
        Url: Text;
    begin
        CheckRequestContent(NcTask);

        Url := GetShopifyUrl(NcTask."Store Code") + StrSubstNo('products/%1/variants.json', ShopifyItemID);
        ResponseText := SendShopifyRequest(NcTask, 'POST', Url);
        ShopifyResponse.ReadFrom(ResponseText);
    end;

    [TryFunction]
    procedure SendItemVariantUpdateRequest(var NcTask: Record "NPR Nc Task"; ShopifyVariantID: Text[30]; var ShopifyResponse: JsonToken)
    var
        ResponseText: Text;
        Url: Text;
    begin
        CheckRequestContent(NcTask);

        Url := GetShopifyUrl(NcTask."Store Code") + StrSubstNo('variants/%1.json', ShopifyVariantID);
        ResponseText := SendShopifyRequest(NcTask, 'PUT', Url);
        ShopifyResponse.ReadFrom(ResponseText);
    end;

    [TryFunction]
    procedure SendItemVariantDeleteRequest(var NcTask: Record "NPR Nc Task"; ShopifyItemID: Text[30]; ShopifyVariantID: Text[30])
    var
        Url: Text;
    begin
        Url := GetShopifyUrl(NcTask."Store Code") + StrSubstNo('products/%1/variants/%2.json', ShopifyItemID, ShopifyVariantID);
        SendShopifyRequest(NcTask, 'DELETE', Url);
    end;

    [TryFunction]
    procedure SendInvetoryLevelUpdateRequest(var NcTask: Record "NPR Nc Task")
    var
        Url: Text;
    begin
        CheckRequestContent(NcTask);

        Url := GetShopifyUrl(NcTask."Store Code") + 'inventory_levels/set.json';
        SendShopifyRequest(NcTask, 'POST', Url);
    end;

    [TryFunction]
    procedure SendInvetoryItemUpdateRequest(var NcTask: Record "NPR Nc Task"; ShopifyInventoryItemID: Text[30])
    var
        Url: Text;
    begin
        CheckRequestContent(NcTask);

        Url := GetShopifyUrl(NcTask."Store Code") + StrSubstNo('inventory_items/%1.json', ShopifyInventoryItemID);
        SendShopifyRequest(NcTask, 'PUT', Url);
    end;

    [TryFunction]
    procedure SendCloseOrderRequest(var NcTask: Record "NPR Nc Task")
    var
        Url: Text;
    begin
        Url := GetShopifyUrl(NcTask."Store Code") + StrSubstNo('orders/%1/close.json', NcTask."Record Value");
        SendShopifyRequest(NcTask, 'POST', Url);
    end;

    [TryFunction]
    procedure RetrieveGiftCardInfoFromShopify(ShopifyStoreCode: Code[20]; ShopifyGiftCardID: Text[30]; var ShopifyResponse: JsonToken)
    var
        NcTask: Record "NPR Nc Task";
        ResponseText: Text;
        Url: Text;
    begin
        NcTask."Store Code" := ShopifyStoreCode;
        Url := GetShopifyUrl(NcTask."Store Code") + StrSubstNo('gift_cards/%1.json', ShopifyGiftCardID);
        ResponseText := SendShopifyRequest(NcTask, 'GET', Url);
        ShopifyResponse.ReadFrom(ResponseText);
    end;

    [TryFunction]
    procedure SendGiftCardCreateRequest(var NcTask: Record "NPR Nc Task"; var ShopifyResponse: JsonToken)
    var
        ResponseText: Text;
        Url: Text;
    begin
        CheckRequestContent(NcTask);

        Url := GetShopifyUrl(NcTask."Store Code") + 'gift_cards.json';
        ResponseText := SendShopifyRequest(NcTask, 'POST', Url);
        ShopifyResponse.ReadFrom(ResponseText);
    end;

    [TryFunction]
    procedure SendGiftCardUpdateRequest(var NcTask: Record "NPR Nc Task"; ShopifyGiftCardID: Text[30]; var ShopifyResponse: JsonToken)
    var
        ResponseText: Text;
        Url: Text;
    begin
        CheckRequestContent(NcTask);

        Url := GetShopifyUrl(NcTask."Store Code") + StrSubstNo('gift_cards/%1.json', ShopifyGiftCardID);
        ResponseText := SendShopifyRequest(NcTask, 'PUT', Url);
        ShopifyResponse.ReadFrom(ResponseText);
    end;

    [TryFunction]
    procedure SendGiftCardDisableRequest(var NcTask: Record "NPR Nc Task"; ShopifyGiftCardID: Text[30]; var ShopifyResponse: JsonToken)
    var
        ResponseText: Text;
        Url: Text;
    begin
        Url := GetShopifyUrl(NcTask."Store Code") + StrSubstNo('gift_cards/%1/disable.json', ShopifyGiftCardID);
        ResponseText := SendShopifyRequest(NcTask, 'POST', Url);
        ShopifyResponse.ReadFrom(ResponseText);
    end;

    [TryFunction]
    procedure SendGiftCardBalanceAdjustmentRequest(var NcTask: Record "NPR Nc Task"; ShopifyGiftCardID: Text[30])
    var
        Url: Text;
    begin
        CheckRequestContent(NcTask);

        Url := GetShopifyUrl(NcTask."Store Code") + StrSubstNo('gift_cards/%1/adjustments.json', ShopifyGiftCardID);
        SendShopifyRequest(NcTask, 'POST', Url);
    end;

    [TryFunction]
    procedure GetRegisteredWebhooks(SpfyStoreCode: Code[20]; Topic: Text; var ShopifyResponse: JsonToken)
    var
        NcTask: Record "NPR Nc Task";
        Url: Text;
    begin
        NcTask."Store Code" := SpfyStoreCode;
        Url := GetShopifyUrl(NcTask."Store Code") + StrSubstNo('webhooks.json?topic=%1', Topic);
        ShopifyResponse.ReadFrom(SendShopifyRequest(NcTask, 'GET', Url));
    end;

    [TryFunction]
    procedure DeleteRegisteredWebhook(SpfyStoreCode: Code[20]; SpfyWebhookId: Text[50])
    var
        NcTask: Record "NPR Nc Task";
        Url: Text;
    begin
        NcTask."Store Code" := SpfyStoreCode;
        Url := GetShopifyUrl(NcTask."Store Code") + StrSubstNo('webhooks/%1.json', SpfyWebhookId);
        SendShopifyRequest(NcTask, 'DELETE', Url);
    end;

    procedure RegisterWebhook(var NcTask: Record "NPR Nc Task") ShopifyResponse: JsonToken
    var
        Url: Text;
    begin
        CheckRequestContent(NcTask);

        Url := GetShopifyUrl(NcTask."Store Code") + 'webhooks.json';
        ShopifyResponse.ReadFrom(SendShopifyRequest(NcTask, 'POST', Url));
    end;

    local procedure CheckRequestContent(var NcTask: Record "NPR Nc Task")
    var
        NoRequestBodyErr: Label 'Each request must have a json formatted content attached';
    begin
        NcTask.TestField("Store Code");
        NcTask.testfield("Record Value");
        if not NcTask."Data Output".HasValue then
            Error(NoRequestBodyErr);
    end;

    local procedure SendShopifyRequest(ShopifyStoreCode: Code[20]; RestMethod: text; Url: Text) ResponseText: Text
    var
        NcTask: Record "NPR Nc Task";
        NextLink: Text;
    begin
        Clear(NcTask);
        NcTask."Store Code" := ShopifyStoreCode;
        ResponseText := SendShopifyRequest(NcTask, RestMethod, Url, NextLink);
    end;

    local procedure SendShopifyRequest(var NcTask: Record "NPR Nc Task"; RestMethod: text; Url: Text) ResponseText: Text
    var
        NextLink: Text;
    begin
        ResponseText := SendShopifyRequest(NcTask, RestMethod, Url, NextLink);
    end;

    local procedure SendShopifyRequest(var NcTask: Record "NPR Nc Task"; RestMethod: text; Url: Text; var NextLink: Text) ResponseText: Text
    begin
        if not TrySendShopifyRequest(NcTask, RestMethod, Url, NextLink, ResponseText) then
            Error(GetLastErrorText());
    end;

    [TryFunction]
    local procedure TrySendShopifyRequest(var NcTask: Record "NPR Nc Task"; RestMethod: text; Url: Text; var NextLink: Text; var ResponseText: Text)
    var
        Client: HttpClient;
        RequestMsg: HttpRequestMessage;
        ResponseMsg: HttpResponseMessage;
        Links: array[1] of Text;
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
                if RetryCounter >= MaxRetries then
                    Retry := false
                else
                    Retry := ResponseAllowsRetries(ResponseMsg)
        until Success or not Retry;

        SaveResponse(NcTask, ResponseMsg);

        if not ResponseMsg.Content().ReadAs(ResponseText) then
            ResponseText := '';
        if ResponseText = '' then
            ResponseText := '{}';

        if not Success then
            if not TreatAsSuccess(NcTask, ResponseMsg) then
                Error('%1: %2\%3', ResponseMsg.HttpStatusCode(), ResponseMsg.ReasonPhrase, ResponseText);

        if ResponseMsg.Headers().GetValues('Link', Links) then
            NextLink := ParseNextLink(Links[1]);
    end;

    local procedure CreateRequestMsg(var NcTask: Record "NPR Nc Task"; RestMethod: text; Url: Text; var RequestMsg: HttpRequestMessage)
    var
        Content: HttpContent;
        Headers: HttpHeaders;
        InStr: InStream;
    begin
        if NcTask."Data Output".HasValue() then begin
            NcTask."Data Output".CreateInStream(InStr);
            Content.WriteFrom(InStr);

            Content.GetHeaders(Headers);
            if Headers.Contains('Content-Type') then
                Headers.Remove('Content-Type');
            Headers.Add('Content-Type', 'application/json');

            RequestMsg.Content := Content;
        end;

        RequestMsg.SetRequestUri(Url);
        RequestMsg.Method(RestMethod);
        RequestMsg.GetHeaders(Headers);
        Headers.Add('X-Shopify-Access-Token', GetShopifyAccessToken(NcTask."Store Code"));
        Headers.Add('Accept', 'application/json');
        Headers.Add('User-Agent', 'NPRetail-BC');
    end;

    local procedure SaveResponse(var NcTask: Record "NPR Nc Task"; var ResponseMsg: HttpResponseMessage)
    var
        Content: HttpContent;
        InStr: InStream;
        OutStr: OutStream;
    begin
        Content := ResponseMsg.Content();

        clear(NcTask.Response);
        NcTask.Response.CreateInStream(InStr);
        Content.ReadAs(InStr);

        NcTask.Response.CreateOutStream(OutStr);
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

        if WaitTime > 0 then
            Sleep(WaitTime);
        exit(true);
    end;

    local procedure TreatAsSuccess(NcTask: Record "NPR Nc Task"; ResponseMsg: HttpResponseMessage): Boolean
    var
        ResponseJToken: JsonToken;
        ErrorJToken: JsonToken;
        ResponseText: Text;
        AlreadyCapturedTok: Label 'The authorized transaction has already been captured', Locked = true;
        AlreadyDisabledTok: Label 'Gift card is disabled', Locked = true;
    begin
        if not (ResponseMsg.Content.ReadAs(ResponseText) and ResponseJToken.ReadFrom(ResponseText)) then
            exit(false);
        case true of
            (NcTask."Table No." = Database::"NPR Magento Payment Line") and (ResponseMsg.HttpStatusCode() = 422):
                if ResponseJToken.SelectToken('errors.base[0]', ErrorJToken) then
                    exit(ErrorJToken.AsValue().AsText() = AlreadyCapturedTok);

            (NcTask."Table No." = Database::"NPR NpRv Voucher Entry") and (ResponseMsg.HttpStatusCode() = 422):
                if ResponseJToken.SelectToken('errors.base[0]', ErrorJToken) then
                    exit(ErrorJToken.AsValue().AsText() = AlreadyDisabledTok);
        end;
        exit(false);
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
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        SpfyIntegrationMgt.CheckIsEnabled("NPR Spfy Integration Area"::" ");

        ShopifyStore.Get(ShopifyStoreCode);
        ShopifyStore.TestField(Enabled);
        ShopifyStore.TestField("Shopify Url");

        ShopifyUrl := StrSubstNo('%1/admin/api/%2/', ShopifyStore."Shopify Url", SpfyIntegrationMgt.ShopifyApiVersion());
    end;

    local procedure GetShopifyAccessToken(ShopifyStoreCode: Code[20]): Text
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        SpfyIntegrationMgt.CheckIsEnabled("NPR Spfy Integration Area"::" ");

        ShopifyStore.Get(ShopifyStoreCode);
        ShopifyStore.TestField(Enabled);
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
}
#endif