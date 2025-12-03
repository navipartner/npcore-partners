#if not BC17
codeunit 6184942 "NPR Spfy Webhook Mgt."
{
    Access = Internal;

    var
        ServiceNameTok: Label 'ShopifyWebhook', Locked = true, MaxLength = 240;

    internal procedure ToggleWebhook(ShopifyStoreCode: Code[20]; Topic: Enum "NPR Spfy Webhook Topic"; Enable: Boolean) WebhookSubscrEntryNo: Integer
    var
        IncludeFields: List of [Text];
    begin
        WebhookSubscrEntryNo := ToggleWebhook(ShopifyStoreCode, Topic, IncludeFields, Enable);
    end;

    internal procedure ToggleWebhook(ShopifyStoreCode: Code[20]; Topic: Enum "NPR Spfy Webhook Topic"; IncludeFields: List of [Text]; Enable: Boolean) WebhookSubscrEntryNo: Integer
    var
        SpfyWebhookProcessorJQ: Codeunit "NPR Spfy Webhook Processor JQ";
    begin
        if Enable then begin
            WebhookSubscrEntryNo := EnableWebhook(ShopifyStoreCode, Topic, IncludeFields);
            RegisterShopifWebhookListenerWebservice();
        end else begin
            DisableWebhook(ShopifyStoreCode, Topic);
            RemoveShopifWebhookListenerWebservice();
        end;
        SpfyWebhookProcessorJQ.RegisterShopifyWebhookNotificationProcessingJQ(Enable);
        Commit();
    end;

    local procedure EnableWebhook(ShopifyStoreCode: Code[20]; Topic: Enum "NPR Spfy Webhook Topic"; IncludeFields: List of [Text]) WebhookSubscrEntryNo: Integer
    var
        SpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription";
        TempSpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription" temporary;
        Topics: List of [Enum "NPR Spfy Webhook Topic"];
        WebhookRegistrationFailedErr: Label 'Failed to register webhook with Shopify. The following error occurred: %1', Comment = '%1 - Error message returned by Shopify';
    begin
        FilterWebhookSubscription(ShopifyStoreCode, Topic, SpfyWebhookSubscription);
        if not SpfyWebhookSubscription.IsEmpty() then
            SpfyWebhookSubscription.DeleteAll();

        Topics.Add(Topic);
        if GetWebhookSubscriptionsFromShopify(ShopifyStoreCode, Topics, TempSpfyWebhookSubscription) then
            if TempSpfyWebhookSubscription.FindSet() then
                repeat
                    RemoveWebhookSubscriptionFromShopify(ShopifyStoreCode, TempSpfyWebhookSubscription."Webhook ID");
                until TempSpfyWebhookSubscription.Next() = 0;

        ClearLastError();
        WebhookSubscrEntryNo := RegisterWebhookAtShopify(ShopifyStoreCode, Topic, IncludeFields);
        if WebhookSubscrEntryNo = 0 then
            Error(WebhookRegistrationFailedErr, GetLastErrorText());
    end;

    local procedure DisableWebhook(ShopifyStoreCode: Code[20]; Topic: Enum "NPR Spfy Webhook Topic")
    var
        SpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription";
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
            if not RemoveWebhookSubscriptionFromShopify(ShopifyStoreCode, SpfyWebhookSubscription."Webhook ID") then
                Message(WebhookDeleteRequestFailedErr, GetLastErrorText(), SpfyWebhookSubscription."Webhook ID");
        SpfyWebhookSubscription.Delete();
    end;

    local procedure GetWebhookSubscriptionsFromShopify(ShopifyStoreCode: Code[20]; Topics: List of [Enum "NPR Spfy Webhook Topic"]; var SpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription"): Boolean
    var
        SpfyWebhookSubscription2: Record "NPR Spfy Webhook Subscription";
        JsonHelper: Codeunit "NPR Json Helper";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyWebhookNotifParser: Codeunit "NPR Spfy Webhook Notif. Parser";
        ShopifyResponse: JsonToken;
        ShopifyWebhook: JsonToken;
        WebhookSubscriptions: JsonToken;
        Cursor: Text;
        LastEntryNo: Integer;
    begin
        if not SpfyWebhookSubscription.IsTemporary() then
            SpfyIntegrationMgt.FunctionCallOnNonTempVarErr(StrSubstNo('[Codeunit::NPR Spfy Webhook Mgt.(%1)].%2', Codeunit::"NPR Spfy Webhook Mgt.", 'GetWebhookSubscriptionsFromShopify'));
        SpfyWebhookSubscription.Reset();
        if SpfyWebhookSubscription.FindLast() then
            LastEntryNo := SpfyWebhookSubscription."Entry No.";

        repeat
            Clear(ShopifyResponse);
            if not GetWebhookSubscriptionNextPageFromShopify(ShopifyStoreCode, Topics, Cursor, ShopifyResponse) then
                exit(false);
            if ShopifyResponse.SelectToken('data.webhookSubscriptions.edges', WebhookSubscriptions) then
                if WebhookSubscriptions.IsArray() then
                    foreach ShopifyWebhook in WebhookSubscriptions.AsArray() do begin
                        Clear(SpfyWebhookSubscription2);
#pragma warning disable AA0139
                        SpfyWebhookSubscription2."Webhook ID" := SpfyIntegrationMgt.RemoveUntil(JsonHelper.GetJText(ShopifyWebhook, 'node.id', false), '/');
#pragma warning restore AA0139
                        if SpfyWebhookSubscription2."Webhook ID" <> '' then
                            if SpfyWebhookNotifParser.TryParseTopic(JsonHelper.GetJText(ShopifyWebhook, 'node.topic', false), SpfyWebhookSubscription2.Topic) then begin
                                SpfyWebhookSubscription.SetRange("Store Code", ShopifyStoreCode);
                                SpfyWebhookSubscription.SetRange(Topic, SpfyWebhookSubscription2.Topic);
                                SpfyWebhookSubscription.SetRange("Webhook ID", SpfyWebhookSubscription2."Webhook ID");
                                if SpfyWebhookSubscription.IsEmpty() then begin
                                    SpfyWebhookSubscription.Init();
                                    SpfyWebhookSubscription."Entry No." := LastEntryNo + 1;
                                    SpfyWebhookSubscription."Store Code" := ShopifyStoreCode;
                                    SpfyWebhookSubscription.Topic := SpfyWebhookSubscription2.Topic;
                                    SpfyWebhookSubscription."Webhook ID" := SpfyWebhookSubscription2."Webhook ID";
#pragma warning disable AA0139
                                    SpfyWebhookSubscription."Api Version" := JsonHelper.GetJText(ShopifyWebhook, 'node.apiVersion.displayName', MaxStrLen(SpfyWebhookSubscription."Api Version"), false);
                                    SpfyWebhookSubscription.Address := JsonHelper.GetJText(ShopifyWebhook, 'node.uri', MaxStrLen(SpfyWebhookSubscription.Address), false);
#pragma warning restore AA0139
                                    SpfyWebhookSubscription.Insert();
                                    LastEntryNo := SpfyWebhookSubscription."Entry No.";
                                end;
                            end;
                    end;
            Cursor := JsonHelper.GetJText(ShopifyResponse, 'data.webhookSubscriptions.pageInfo.endCursor', false);
        until not JsonHelper.GetJBoolean(ShopifyResponse, 'data.webhookSubscriptions.pageInfo.hasNextPage', false) or (Cursor = '');
        SpfyWebhookSubscription.Reset();
        exit(not SpfyWebhookSubscription.IsEmpty());
    end;

    local procedure GetWebhookSubscriptionNextPageFromShopify(ShopifyStoreCode: Code[20]; Topics: List of [Enum "NPR Spfy Webhook Topic"]; Cursor: Text; var ShopifyResponse: JsonToken): Boolean
    var
        NcTask: Record "NPR Nc Task";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        QueryStream: OutStream;
    begin
        NcTask."Store Code" := ShopifyStoreCode;
        NcTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        ShopifyWebhookSubscriptionsRequestQuery(Topics, Cursor, QueryStream);
        exit(SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, true, ShopifyResponse));
    end;

    local procedure ShopifyWebhookSubscriptionsRequestQuery(Topics: List of [Enum "NPR Spfy Webhook Topic"]; Cursor: Text; var QueryStream: OutStream)
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        RequestJson: JsonObject;
        VariablesJson: JsonObject;
        QueryTok: Label 'query($topics: [WebhookSubscriptionTopic!], $afterCursor: String) {webhookSubscriptions(first: 50, after: $afterCursor, topics : $topics, format : JSON){edges{node{id apiVersion{displayName supported} topic uri}} pageInfo{endCursor hasNextPage}}}', Locked = true;
    begin
        VariablesJson.Add('topics', TopicsToJsonArray(Topics));
        SpfyCommunicationHandler.AddGraphQLCursor(VariablesJson, Cursor);

        RequestJson.Add('query', QueryTok);
        RequestJson.Add('variables', VariablesJson);
        RequestJson.WriteTo(QueryStream);
    end;

    local procedure RemoveWebhookSubscriptionFromShopify(ShopifyStoreCode: Code[20]; WebhookID: Text[50]): Boolean
    var
        NcTask: Record "NPR Nc Task";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        QueryStream: OutStream;
        ResponseDataItemUserErrors: JsonToken;
        ShopifyResponse: JsonToken;
    begin
        NcTask."Store Code" := ShopifyStoreCode;
        NcTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        ShopifyWebhookSubscriptionDeleteQuery(WebhookID, QueryStream);
        if not SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, true, ShopifyResponse) then
            exit(false);
        if SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse, ResponseDataItemUserErrors) then begin
            if ThrowFirstUserError(ResponseDataItemUserErrors) then;
            exit(false);
        end;
        exit(true);
    end;

    local procedure ShopifyWebhookSubscriptionDeleteQuery(WebhookID: Text[50]; var QueryStream: OutStream)
    var
        RequestJson: JsonObject;
        VariablesJson: JsonObject;
        QueryTok: Label 'mutation webhookSubscriptionDelete($id: ID!) {webhookSubscriptionDelete(id: $id) {deletedWebhookSubscriptionId userErrors{field message}}}', Locked = true;
    begin
        VariablesJson.Add('id', StrSubstNo('gid://shopify/WebhookSubscription/%1', WebhookID));

        RequestJson.Add('query', QueryTok);
        RequestJson.Add('variables', VariablesJson);
        RequestJson.WriteTo(QueryStream);
    end;

    local procedure TopicsToJsonArray(Topics: List of [Enum "NPR Spfy Webhook Topic"]): JsonArray
    var
        Topic: Enum "NPR Spfy Webhook Topic";
        TopicsJsonArray: JsonArray;
    begin
        TopicsJsonArray.ReadFrom('[]');
        foreach Topic in Topics do
            TopicsJsonArray.Add(SpfyWebhookTopicName(Topic, true));
        exit(TopicsJsonArray);
    end;

    local procedure IncludeFieldsToJsonArray(IncludeFields: List of [Text]): JsonArray
    var
        FieldName: Text;
        IncludeFieldsJsonArray: JsonArray;
    begin
        IncludeFieldsJsonArray.ReadFrom('[]');
        foreach FieldName in IncludeFields do
            if FieldName <> '' then
                IncludeFieldsJsonArray.Add(FieldName);
        exit(IncludeFieldsJsonArray);
    end;

    [TryFunction]
    local procedure ThrowFirstUserError(ResponseDataItemUserErrors: JsonToken)
    var
        JsonHelper: Codeunit "NPR Json Helper";
        UserError: JsonToken;
        ErrorMessage: Text;
        UnknownErr: Label 'An unknown error occurred while processing the Shopify request.';
    begin
        foreach UserError in ResponseDataItemUserErrors.AsArray() do begin
            ErrorMessage := JsonHelper.GetJText(UserError, 'message', false);
            if ErrorMessage <> '' then
                Error(ErrorMessage);
        end;
        Error(UnknownErr);
    end;

    local procedure RegisterWebhookAtShopify(ShopifyStoreCode: Code[20]; Topic: Enum "NPR Spfy Webhook Topic"; IncludeFields: List of [Text]): Integer
    var
        NcTask: Record "NPR Nc Task";
        JsonHelper: Codeunit "NPR Json Helper";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        ResponseDataItemUserErrors: JsonToken;
        ShopifyResponse: JsonToken;
        ShopifyWebhook: JsonToken;
        QueryStream: OutStream;
        ApiVersion: Text[10];
        NotificationUrl: Text;
        SpfyWebhookId: Text[50];
    begin
        NcTask."Store Code" := ShopifyStoreCode;
        NcTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        ShopifyWebhookSubscriptionCreateQuery(Topic, IncludeFields, QueryStream);
        if not SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, true, ShopifyResponse) then
            exit(0);
        if SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse, ResponseDataItemUserErrors) then begin
            if ThrowFirstUserError(ResponseDataItemUserErrors) then;
            exit(0);
        end;

        ShopifyWebhook := JsonHelper.GetJsonToken(ShopifyResponse, 'data.webhookSubscriptionCreate.webhookSubscription');
#pragma warning disable AA0139
        SpfyWebhookId := SpfyIntegrationMgt.RemoveUntil(JsonHelper.GetJText(ShopifyWebhook, 'id', true), '/');
        ApiVersion := JsonHelper.GetJText(ShopifyWebhook, 'apiVersion.displayName', MaxStrLen(ApiVersion), false);
#pragma warning restore AA0139
        NotificationUrl := JsonHelper.GetJText(ShopifyWebhook, 'uri', false);
        exit(CreateWebhookSubscription(SpfyWebhookId, ApiVersion, ShopifyStoreCode, Topic, NotificationUrl));
    end;

    local procedure ShopifyWebhookSubscriptionCreateQuery(Topic: Enum "NPR Spfy Webhook Topic"; IncludeFields: List of [Text]; var QueryStream: OutStream)
    var
        RequestJson: JsonObject;
        VariablesJson: JsonObject;
        WebhookSubscriptionDetails: JsonObject;
        QueryTok: Label 'mutation CreateWebhookSubscription($topic: WebhookSubscriptionTopic!, $webhookSubscription: WebhookSubscriptionInput!) {webhookSubscriptionCreate(topic: $topic, webhookSubscription: $webhookSubscription) {webhookSubscription{id topic includeFields uri apiVersion{displayName supported}} userErrors{field message}}}', Locked = true;
    begin
        WebhookSubscriptionDetails.Add('format', 'JSON');
        WebhookSubscriptionDetails.Add('uri', GetNotificationUrl());
        if IncludeFields.Count > 0 then
            WebhookSubscriptionDetails.Add('includeFields', IncludeFieldsToJsonArray(IncludeFields));
        VariablesJson.Add('topic', SpfyWebhookTopicName(Topic, true));
        VariablesJson.Add('webhookSubscription', WebhookSubscriptionDetails);

        RequestJson.Add('query', QueryTok);
        RequestJson.Add('variables', VariablesJson);
        RequestJson.WriteTo(QueryStream);
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

    local procedure SpfyWebhookTopicName(Topic: Enum "NPR Spfy Webhook Topic"; GraphQLName: Boolean) Result: Text
    var
        SpfyIntegrationEvents: Codeunit "NPR Spfy Integration Events";
    begin
        SpfyIntegrationEvents.OnSpfyWebhookTopicName(Topic, GraphQLName, Result);
        if Result <> '' then
            exit;

        if GraphQLName then
            case Topic of
                Topic::"products/create":
                    Result := 'PRODUCTS_CREATE';
                Topic::"products/delete":
                    Result := 'PRODUCTS_DELETE';
                Topic::"products/update":
                    Result := 'PRODUCTS_UPDATE';
                Topic::"customers/create":
                    Result := 'CUSTOMERS_CREATE';
                Topic::"customers/delete":
                    Result := 'CUSTOMERS_DELETE';
                Topic::"customers/update":
                    Result := 'CUSTOMERS_UPDATE';
            end;
        if Result <> '' then
            exit;

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
        TenantWebService: Record "Tenant Web Service";
    begin
        if ShopifWebhookSubscriptionsExist() then
            exit;
        if ShopifWebhookListenerWebserviceExists(TenantWebService) then
            TenantWebService.Delete(true);
    end;

    local procedure ShopifWebhookSubscriptionsExist(): Boolean
    var
        Company: Record Company;
        SpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription";
    begin
        if not SpfyWebhookSubscription.IsEmpty() then
            exit(true);
        Company.SetFilter(Name, '<>%1', CopyStr(CompanyName(), 1, MaxStrLen(Company.Name)));
        if Company.Find('-') then
            repeat
                SpfyWebhookSubscription.ChangeCompany(Company.Name);
                if not SpfyWebhookSubscription.IsEmpty() then
                    exit(true);
            until Company.Next() = 0;
        exit(false);
    end;

    local procedure ShopifWebhookListenerWebserviceExists(var TenantWebService: Record "Tenant Web Service"): Boolean
    begin
        exit(TenantWebService.Get(TenantWebService."Object Type"::Codeunit, ServiceNameTok));
    end;
}
#endif