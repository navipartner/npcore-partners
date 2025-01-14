#if not BC17
codeunit 6184942 "NPR Spfy Webhook Mgt."
{
    Access = Internal;

    var
        ServiceNameTok: Label 'ShopifyWebhook', Locked = true, MaxLength = 240;

    internal procedure ToggleWebhook(ShopifyStoreCode: Code[20]; Topic: Enum "NPR Spfy Webhook Topic"; Enable: Boolean) WebhookSubscrEntryNo: Integer
    var
        SpfyWebhookProcessorJQ: Codeunit "NPR Spfy Webhook Processor JQ";
    begin
        if Enable then begin
            WebhookSubscrEntryNo := EnableWebhook(ShopifyStoreCode, Topic);
            RegisterShopifWebhookListenerWebservice();
        end else begin
            DisableWebhook(ShopifyStoreCode, Topic);
            RemoveShopifWebhookListenerWebservice();
        end;
        SpfyWebhookProcessorJQ.RegisterShopifyWebhookNotificationProcessingJQ(Enable);
        Commit();
    end;

    local procedure EnableWebhook(ShopifyStoreCode: Code[20]; Topic: Enum "NPR Spfy Webhook Topic") WebhookSubscrEntryNo: Integer
    var
        SpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        SpfyWebhookIds: List of [Text[50]];
        SpfyWebhookId: Text[50];
        WebhookRegistrationFailedErr: Label 'Failed to register webhook with Shopify.';
    begin
        FilterWebhookSubscription(ShopifyStoreCode, Topic, SpfyWebhookSubscription);
        if not SpfyWebhookSubscription.IsEmpty() then
            SpfyWebhookSubscription.DeleteAll();

        if GetRegisteredWebhookIdsFromShopify(ShopifyStoreCode, Topic, SpfyWebhookIds) then
            foreach SpfyWebhookId in SpfyWebhookIds do
                SpfyCommunicationHandler.DeleteRegisteredWebhook(ShopifyStoreCode, SpfyWebhookId);
        WebhookSubscrEntryNo := RegisterWebhookAtShopify(ShopifyStoreCode, Topic);
        if WebhookSubscrEntryNo = 0 then
            Error(WebhookRegistrationFailedErr);
    end;

    local procedure DisableWebhook(ShopifyStoreCode: Code[20]; Topic: Enum "NPR Spfy Webhook Topic")
    var
        SpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        WebhookDeleteRequestFailedErr: Label 'The system was unable to delete the webhook from Shopify. Shopify returned the following error: "%1".\You may want to take this up with Shopify directly. Shopify Webhook ID: %2', Comment = '%1 - Shopify request error message, %2 - Shopify webhook ID';
    begin
        FilterWebhookSubscription(ShopifyStoreCode, Topic, SpfyWebhookSubscription);
        if SpfyWebhookSubscription.IsEmpty() then
            exit;
#if not (BC18 or BC19 or BC20 or BC21)
        SpfyWebhookSubscription.ReadIsolation := IsolationLevel::UpdLock;
#else
        SpfyWebhookSubscription.LockTable();
#endif
        SpfyWebhookSubscription.FindFirst();
        if SpfyWebhookSubscription."Webhook ID" <> '' then
            if not SpfyCommunicationHandler.DeleteRegisteredWebhook(ShopifyStoreCode, SpfyWebhookSubscription."Webhook ID") then
                Message(WebhookDeleteRequestFailedErr, GetLastErrorText(), SpfyWebhookSubscription."Webhook ID");
        SpfyWebhookSubscription.Delete();
    end;

    local procedure GetRegisteredWebhookIdsFromShopify(ShopifyStoreCode: Code[20]; Topic: Enum "NPR Spfy Webhook Topic"; var SpfyWebhookIds: List of [Text[50]]): Boolean
    var
        JsonHelper: Codeunit "NPR Json Helper";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        ShopifyResponse: JsonToken;
        ShopifyWebhook: JsonToken;
        ShopifyWebhooks: JsonToken;
        SpfyWebhookId: Text[50];
    begin
        Clear(SpfyWebhookIds);
        if not SpfyCommunicationHandler.GetRegisteredWebhooks(ShopifyStoreCode, SpfyWebhookTopicEnumValueName(Topic), ShopifyResponse) then
            exit(false);
        if JsonHelper.GetJsonToken(ShopifyResponse, 'webhooks', ShopifyWebhooks) then
            if ShopifyWebhooks.IsArray() then
                foreach ShopifyWebhook in ShopifyWebhooks.AsArray() do begin
#pragma warning disable AA0139
                    SpfyWebhookId := JsonHelper.GetJText(ShopifyWebhook, 'id', false);
#pragma warning restore AA0139
                    if SpfyWebhookId <> '' then
                        if not SpfyWebhookIds.Contains(SpfyWebhookId) then
                            SpfyWebhookIds.Add(SpfyWebhookId);
                end;
        exit(SpfyWebhookIds.Count() > 0);
    end;

    local procedure RegisterWebhookAtShopify(ShopifyStoreCode: Code[20]; Topic: Enum "NPR Spfy Webhook Topic"): Integer
    var
        NcTask: Record "NPR Nc Task";
        JsonHelper: Codeunit "NPR Json Helper";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        Request: JsonObject;
        WebhookConfig: JsonObject;
        ShopifyResponse: JsonToken;
        ShopifyWebhook: JsonToken;
        OutStr: OutStream;
        ApiVersion: Text[10];
        NotificationUrl: Text;
        SpfyWebhookId: Text[50];
    begin
        NotificationUrl := GetNotificationUrl();
        WebhookConfig.Add('topic', SpfyWebhookTopicEnumValueName(Topic));
        WebhookConfig.Add('address', NotificationUrl);
        WebhookConfig.Add('format', 'json');
        Request.Add('webhook', WebhookConfig);

        NcTask."Store Code" := ShopifyStoreCode;
        NcTask."Record Value" := CopyStr(StrSubstNo('%1: %2', ShopifyStoreCode, JsonHelper.GetJText(WebhookConfig.AsToken(), 'topic', false)), 1, MaxStrLen(NcTask."Record Value"));
        NcTask."Data Output".CreateOutStream(OutStr);
        Request.WriteTo(OutStr);

        ShopifyResponse := SpfyCommunicationHandler.RegisterWebhook(NcTask);
        if JsonHelper.GetJsonToken(ShopifyResponse, 'webhook', ShopifyWebhook) then begin
#pragma warning disable AA0139
            SpfyWebhookId := JsonHelper.GetJText(ShopifyWebhook, 'id', true);
            ApiVersion := JsonHelper.GetJText(ShopifyWebhook, 'api_version', true);
#pragma warning restore AA0139
            exit(CreateWebhookSubscription(SpfyWebhookId, ApiVersion, ShopifyStoreCode, Topic, NotificationUrl));
        end;
        exit(0);
    end;

    local procedure FilterWebhookSubscription(ShopifyStoreCode: Code[20]; Topic: Enum "NPR Spfy Webhook Topic"; var SpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription")
    begin
        SpfyWebhookSubscription.SetRange("Store Code", ShopifyStoreCode);
        SpfyWebhookSubscription.SetRange(Topic, Topic);
    end;

    local procedure CreateWebhookSubscription(SpfyWebhookId: Text[50]; ApiVersion: Text[10]; ShopifyStoreCode: Code[20]; Topic: Enum "NPR Spfy Webhook Topic"; NotificationUrl: Text): Integer
    var
        SpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription";
    begin
        SpfyWebhookSubscription.Init();
        SpfyWebhookSubscription."Entry No." := 0;
        SpfyWebhookSubscription."Webhook ID" := SpfyWebhookId;
        SpfyWebhookSubscription.Topic := Topic;
        SpfyWebhookSubscription."Store Code" := ShopifyStoreCode;
        SpfyWebhookSubscription."Api Version" := ApiVersion;
        SpfyWebhookSubscription.Address := CopyStr(NotificationUrl, 1, MaxStrLen(SpfyWebhookSubscription.Address));
        SpfyWebhookSubscription.Insert();

        exit(SpfyWebhookSubscription."Entry No.");
    end;

    local procedure SpfyWebhookTopicEnumValueName(Topic: Enum "NPR Spfy Webhook Topic") Result: Text
    begin
        Topic.Names().Get(Topic.Ordinals().IndexOf(Topic.AsInteger()), Result);
    end;

    local procedure GetNotificationUrl(): Text
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        EnvironmentInformation: Codeunit "Environment Information";
        KeyNameLbl: Label 'NPShopifyAFCode', Locked = True;
        SaasNotificationUrlTok: Label 'https://npshopifywebhook.azurewebsites.net/api/ShopifyCloud/%1/%2?code=%3&CompanyName=%4', Locked = true,
                                Comment = '%1 - Tenant ID, %2 - Environment, %3 - Azure function authentication code, %4 - Company name';
        SaasOnlyLbl: Label 'Shopify webhooks are only supported for BC Saas environments.';
    begin
        if EnvironmentInformation.IsOnPrem() then
            Error(SaasOnlyLbl);

        exit(
            StrSubstNo(SaasNotificationUrlTok,
                AzureADTenant.GetAadTenantId(),
                EnvironmentInformation.GetEnvironmentName(),
                AzureKeyVaultMgt.GetAzureKeyVaultSecret(KeyNameLbl),
                UrlEncode(CompanyName()))
            );
    end;

    local procedure UrlEncode(Value: Text): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(TypeHelper.UrlEncode(Value));
    end;

    local procedure RegisterShopifWebhookListenerWebservice()
    var
        TenantWebService: Record "Tenant Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Codeunit, Codeunit::"NPR Spfy Webhook Webservice", ServiceNameTok, true);
    end;

    local procedure RemoveShopifWebhookListenerWebservice()
    var
        SpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription";
        TenantWebService: Record "Tenant Web Service";
    begin
        if not SpfyWebhookSubscription.IsEmpty() then
            exit;
        if ShopifWebhookListenerWebserviceExists(TenantWebService) then
            TenantWebService.Delete(true);
    end;

    local procedure ShopifWebhookListenerWebserviceExists(var TenantWebService: Record "Tenant Web Service"): Boolean
    begin
        exit(TenantWebService.Get(TenantWebService."Object Type"::Codeunit, ServiceNameTok));
    end;
}
#endif