#if not BC17
codeunit 6184810 "NPR Spfy Integration Mgt."
{
    Access = Internal;
    SingleInstance = true;
    Permissions = tabledata "NPR Spfy Integration Setup" = rim;

    var
        ShopifySetup: Record "NPR Spfy Integration Setup";

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
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMsg: HttpRequestMessage;
        ResponseMsg: HttpResponseMessage;
        InStr: InStream;
        Links: array[1] of Text;
    begin
        CheckHttpClientRequestsAllowed();

        Clear(NextLink);

        if NcTask."Data Output".HasValue then begin
            NcTask.CalcFields("Data Output");
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
        Headers.Add('User-Agent', 'Dynamics 365');

        if not Client.Send(RequestMsg, ResponseMsg) then
            Error(GetLastErrorText);

        SaveResponse(NcTask, ResponseMsg);

        if not ResponseMsg.Content.ReadAs(ResponseText) then
            ResponseText := '';
        if ResponseText = '' then
            ResponseText := '{}';

        if not ResponseMsg.IsSuccessStatusCode() then
            if not TreatAsSuccess(NcTask, ResponseMsg) then
                Error('%1: %2\%3', ResponseMsg.HttpStatusCode(), ResponseMsg.ReasonPhrase, ResponseText);

        Headers := ResponseMsg.Headers();
        if Headers.Contains('Link') then begin
            Headers.GetValues('Link', Links);
            NextLink := ParseNextLink(Links[1]);
        end;
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
        ShopifySetup.GetRecordOnce(false);
        ShopifySetup.TestField("Enable Integration");
        ShopifySetup.TestField("Shopify Api Version");

        ShopifyStore.Get(ShopifyStoreCode);
        ShopifyStore.TestField(Enabled);
        ShopifyStore.TestField("Shopify Url");

        ShopifyUrl := StrSubstNo('%1/admin/api/%2/', ShopifyStore."Shopify Url", ShopifySetup."Shopify Api Version");
    end;

    local procedure GetShopifyAccessToken(ShopifyStoreCode: Code[20]): Text
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        ShopifySetup.GetRecordOnce(false);
        ShopifySetup.TestField("Enable Integration");

        ShopifyStore.Get(ShopifyStoreCode);
        ShopifyStore.TestField(Enabled);
        ShopifyStore.TestField("Shopify Access Token");

        exit(ShopifyStore."Shopify Access Token");
    end;

    procedure IsEnabled(IntegrationArea: Enum "NPR Spfy Integration Area"): Boolean
    var
        SpfyIntegrationEvents: Codeunit "NPR Spfy Integration Events";
        AreaIsEnabled: Boolean;
        Handled: Boolean;
    begin
        SpfyIntegrationEvents.OnCheckIfIntegrationAreaIsEnabled(IntegrationArea, AreaIsEnabled, Handled);
        if Handled then
            exit(AreaIsEnabled);

        ShopifySetup.GetRecordOnce(false);
        if not ShopifySetup."Enable Integration" then
            exit(false);
        case IntegrationArea of
            IntegrationArea::" ":
                exit(ShopifySetup."Enable Integration");
            IntegrationArea::Items:
                exit(ShopifySetup."Item List Integration");
            IntegrationArea::"Inventory Levels":
                exit(ShopifySetup."Send Inventory Updates");
            IntegrationArea::"Sales Orders":
                exit(ShopifySetup."Sales Order Integration");
            IntegrationArea::"Order Fulfillments":
                exit(ShopifySetup."Send Order Fulfillments");
            IntegrationArea::"Payment Capture Requests":
                exit(ShopifySetup."Send Payment Capture Requests");
            IntegrationArea::"Close Order Requests":
                exit(ShopifySetup."Send Close Order Requets");
            IntegrationArea::"Retail Vouchers":
                exit(ShopifySetup."Retail Voucher Integration");
            IntegrationArea::"Click And Collect":
                exit(ShopifySetup."C&C Order Integration");
        end;
    end;

    procedure ShopifyStoreIsEnabled(ShopifyStoreCode: Code[20]): Boolean
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        exit(ShopifyStore.Get(ShopifyStoreCode) and ShopifyStore.Enabled);
    end;

    procedure IsSendSalesPrices(): Boolean
    begin
        ShopifySetup.GetRecordOnce(false);
        exit(not ShopifySetup."Do Not Sync. Sales Prices");
    end;

    procedure IsSendShopifyNameAndDescription(): Boolean
    begin
        ShopifySetup.GetRecordOnce(false);
        exit(ShopifySetup."Set Shopify Name/Descr. in BC");
    end;

    procedure IsAllowedFinancialStatus(FinancialStatus: Text): Boolean
    begin
        ShopifySetup.GetRecordOnce(false);
        case FinancialStatus of
            'authorized':
                exit(ShopifySetup."Allowed Payment Statuses" in
                    [ShopifySetup."Allowed Payment Statuses"::Authorized, ShopifySetup."Allowed Payment Statuses"::Both]);
            'paid':
                exit(ShopifySetup."Allowed Payment Statuses" in
                    [ShopifySetup."Allowed Payment Statuses"::Paid, ShopifySetup."Allowed Payment Statuses"::Both]);
        end;
        exit(false);
    end;

    procedure IsSendNegativeInventory(): Boolean
    begin
        ShopifySetup.GetRecordOnce(false);
        exit(ShopifySetup."Send Negative Inventory");
    end;

    procedure IncludeTrasferOrders(): Option No,Outbound,All
    begin
        ShopifySetup.GetRecordOnce(false);
        exit(ShopifySetup."Include Transfer Orders");
    end;

    procedure GetCCWorkflowCode(): Code[20]
    begin
        ShopifySetup.GetRecordOnce(false);
        ShopifySetup.TestField("C&C Order Workflow Code");
        exit(ShopifySetup."C&C Order Workflow Code");
    end;

    procedure SetRereadSetup()
    begin
        Clear(ShopifySetup);
    end;

    procedure ShopifyCode(): Code[10]
    var
        ShopifyTaskProcessorCode: Label 'SHOPIFY', Locked = true, MaxLength = 10;
    begin
        exit(ShopifyTaskProcessorCode);
    end;

    procedure UnsupportedIntegrationTable(NcTask: Record "NPR Nc Task"; CallerFunction: Text)
    var
        UnsupportedErr: Label '%1: unsupported integration table %2 %3';
    begin
        NcTask.CalcFields("Table Name");
        Error(UnsupportedErr, CallerFunction, NcTask."Table No.", NcTask."Table Name");
    end;

    procedure LongRunningProcessConfirmQst(): Text
    var
        ConfirmQst: Label 'The process might take significant amount of time to complete. Are you sure you want to continue?';
    begin
        exit(ConfirmQst);
    end;

    procedure FunctionCallOnNonTempVarErr(ObjectAndProcedureName: Text)
    var
        NotTempErr: Label '%1: function call on a non-temporary variable. This is a programming bug, not a user error. Please contact system vendor.', Comment = '%1 - object and procedure names';
    begin
        Error(NotTempErr, ObjectAndProcedureName);
    end;

    #region Azure AD application
    internal procedure CreateAzureADApplication()
    var
        AADApplicationMgt: Codeunit "NPR AAD Application Mgt.";
        PermissionSets: List of [Code[20]];
        AppDisplayNameLbl: Label 'NaviPartner Shopify integration', MaxLength = 50, Locked = true;
    begin
        PermissionSets.Add('D365 BUS FULL ACCESS');
        PermissionSets.Add('NPR NP RETAIL');

        AADApplicationMgt.CreateAzureADApplicationAndSecret(AppDisplayNameLbl, SecretDisplayName(), PermissionSets);
    end;

    internal procedure CreateAzureADApplicationSecret()
    var
        AppInfo: ModuleInfo;
        AADApplication: Record "AAD Application";
        AADApplicationList: Page "AAD Application List";
        AADApplicationMgt: Codeunit "NPR AAD Application Mgt.";
        NoAppsToManageErr: Label 'No AAD Apps with App Name like %1 to manage.';
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);

        AADApplication.SetFilter("App Name", '@' + AppInfo.Name);
        if AADApplication.IsEmpty() then
            Error(NoAppsToManageErr, AppInfo.Name);

        AADApplicationList.LookupMode(true);
        AADApplicationList.SetTableView(AADApplication);
        if AADApplicationList.RunModal() <> Action::LookupOK then
            exit;

        AADApplicationList.GetRecord(AADApplication);
        AADApplicationMgt.CreateAzureADSecret(AADApplication."Client Id", SecretDisplayName());
    end;

    local procedure SecretDisplayName(): Text
    var
        SecretDisplayNameLbl: Label 'NaviPartner Shopify integration - %1', Comment = '%1 = today''s date', Locked = true;
    begin
        exit(StrSubstNo(SecretDisplayNameLbl, Format(Today(), 0, 9)));
    end;
    #endregion
}
#endif