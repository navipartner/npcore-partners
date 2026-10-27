#if not BC17
codeunit 6184942 "NPR Spfy Webhook Mgt."
{
    Access = Internal;

    var
        _GraphQLClient: Interface "NPR Spfy IGraphQL Client";
        _GraphQLClientSet: Boolean;
        _CurrentTenantId: Text;
        _CurrentEnvironmentName: Text;
        _CurrentCompanyName: Text;
        _CurrentDestinationSet: Boolean;
        ServiceNameTok: Label 'ShopifyWebhook', Locked = true, MaxLength = 240;

    internal procedure SetGraphQLClient(GraphQLClient: Interface "NPR Spfy IGraphQL Client")
    begin
        _GraphQLClient := GraphQLClient;
        _GraphQLClientSet := true;
    end;

    local procedure GetGraphQLClient(): Interface "NPR Spfy IGraphQL Client"
    var
        DefaultGraphQLClient: Codeunit "NPR Spfy GraphQL Client";
    begin
        if not _GraphQLClientSet then begin
            _GraphQLClient := DefaultGraphQLClient;
            _GraphQLClientSet := true;
        end;
        exit(_GraphQLClient);
    end;

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
        CleanupErrorText: Text;
        KeptElsewhere: List of [Text];
        WebhookRegistrationFailedErr: Label 'Failed to register webhook with Shopify. The following error occurred: %1', Comment = '%1 - Error message returned by Shopify';
        WebhookCleanupFailedErr: Label 'Could not remove this company''s existing webhook subscriptions from Shopify before registering a new one. The following error occurred: %1', Comment = '%1 - Error message returned by Shopify';
    begin
        // A leftover subscription with the same address would make Shopify refuse the new one, so a failed cleanup stops here with its own reason.
        if not RemoveSubscriptionsDeliveringHere(ShopifyStoreCode, Topic, CleanupErrorText, KeptElsewhere) then
            Error(WebhookCleanupFailedErr, CleanupErrorText);
        FilterWebhookSubscription(ShopifyStoreCode, Topic, SpfyWebhookSubscription);
        if not SpfyWebhookSubscription.IsEmpty() then
            SpfyWebhookSubscription.DeleteAll();
        ReportSubscriptionsKeptElsewhere(Topic, KeptElsewhere);

        ClearLastError();
        WebhookSubscrEntryNo := RegisterWebhookAtShopify(ShopifyStoreCode, Topic, IncludeFields);
        if WebhookSubscrEntryNo = 0 then
            Error(WebhookRegistrationFailedErr, GetLastErrorText());
    end;

    internal procedure DisableWebhook(ShopifyStoreCode: Code[20]; Topic: Enum "NPR Spfy Webhook Topic")
    var
        SpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription";
        CleanupErrorText: Text;
        KeptElsewhere: List of [Text];
        WebhookRemovalFailedMsg: Label 'The system was unable to remove the webhook subscriptions for this company from Shopify. Shopify returned the following error: "%1".\You can check what Shopify still holds with the Webhook Subscriptions action on the Shopify Store card.', Comment = '%1 - Shopify request error message';
    begin
        if not RemoveSubscriptionsDeliveringHere(ShopifyStoreCode, Topic, CleanupErrorText, KeptElsewhere) then
            Message(WebhookRemovalFailedMsg, CleanupErrorText);
        FilterWebhookSubscription(ShopifyStoreCode, Topic, SpfyWebhookSubscription);
        if not SpfyWebhookSubscription.IsEmpty() then
            SpfyWebhookSubscription.DeleteAll();
        ReportSubscriptionsKeptElsewhere(Topic, KeptElsewhere);
    end;

    /// <summary>
    /// Deletes the topic's Shopify subscriptions that deliver to this tenant, environment and company, whether or not this company has a record of them.
    /// Nothing that delivers elsewhere is ever deleted, not even a subscription this company has a record of: an environment restored or copied
    /// with "Skip environment cleanup" keeps the source environment's records, and from here that cannot be told apart from a company or environment rename.
    /// Recorded subscriptions that deliver elsewhere are returned in KeptElsewhere (as their destination) so the caller can tell the user.
    /// Returns false if Shopify could not be read or a delete failed, with the first reason in ErrorText.
    /// </summary>
    internal procedure RemoveSubscriptionsDeliveringHere(ShopifyStoreCode: Code[20]; Topic: Enum "NPR Spfy Webhook Topic"; var ErrorText: Text; var KeptElsewhere: List of [Text]) AllRemoved: Boolean
    var
        SpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription";
        JsonHelper: Codeunit "NPR Json Helper";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        ShopifyWebhook: JsonToken;
        WebhookSubscriptionNodes: JsonArray;
        Topics: List of [Enum "NPR Spfy Webhook Topic"];
        RecordedWebhookIds: List of [Text];
        ShopifyAddress: Text;
        WebhookId: Text;
    begin
        ErrorText := '';
        Clear(KeptElsewhere);
        Topics.Add(Topic);
        if not TryGetWebhookSubscriptionNodes(ShopifyStoreCode, Topics, true, WebhookSubscriptionNodes) then begin
            ErrorText := GetLastErrorText();
            exit(false);
        end;

        FilterWebhookSubscription(ShopifyStoreCode, Topic, SpfyWebhookSubscription);
        SpfyWebhookSubscription.SetLoadFields("Webhook ID");
        if SpfyWebhookSubscription.FindSet() then
            repeat
                RecordedWebhookIds.Add(SpfyWebhookSubscription."Webhook ID");
            until SpfyWebhookSubscription.Next() = 0;

        AllRemoved := true;
        foreach ShopifyWebhook in WebhookSubscriptionNodes do
            if JsonHelper.GetJText(ShopifyWebhook, 'topic', false) = SpfyWebhookTopicName(Topic, true) then begin
                WebhookId := SpfyIntegrationMgt.RemoveUntil(JsonHelper.GetJText(ShopifyWebhook, 'id', false), '/');
                ShopifyAddress := JsonHelper.GetJText(ShopifyWebhook, 'uri', false);
                if WebhookId <> '' then
                    if DeliversToCurrentCompany(ShopifyAddress) then begin
                        if not RemoveWebhookSubscriptionFromShopify(ShopifyStoreCode, CopyStr(WebhookId, 1, 50)) then begin
                            if AllRemoved then
                                ErrorText := GetLastErrorText();
                            AllRemoved := false;
                        end;
                    end else
                        if RecordedWebhookIds.Contains(WebhookId) then
                            KeptElsewhere.Add(DescribeDestination(ShopifyAddress));
            end;
    end;

    /// <summary>
    /// Deletes one subscription in Shopify on an explicit user request, wherever it delivers, and drops this company's record of it.
    /// Returns false with Shopify's reason in ErrorText if the delete failed; the record is then kept.
    /// </summary>
    internal procedure DeleteSubscriptionInShopify(ShopifyStoreCode: Code[20]; WebhookId: Text[50]; var ErrorText: Text): Boolean
    var
        SpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription";
    begin
        ErrorText := '';
        if not RemoveWebhookSubscriptionFromShopify(ShopifyStoreCode, WebhookId) then begin
            ErrorText := GetLastErrorText();
            exit(false);
        end;
        SpfyWebhookSubscription.SetRange("Store Code", ShopifyStoreCode);
        SpfyWebhookSubscription.SetRange("Webhook ID", WebhookId);
        if not SpfyWebhookSubscription.IsEmpty() then
            SpfyWebhookSubscription.DeleteAll();
        exit(true);
    end;

    /// <summary>Destination of a notification address for messages to the user: environment and company, or the masked address if it is not a Business Central one.</summary>
    internal procedure DescribeDestination(NotificationUrl: Text): Text
    var
        TenantId: Text;
        EnvironmentName: Text;
        DestinationCompanyName: Text;
        DestinationTok: Label '%1 / %2', Locked = true;
    begin
        if ParseNotificationUrl(NotificationUrl, TenantId, EnvironmentName, DestinationCompanyName) then
            exit(StrSubstNo(DestinationTok, EnvironmentName, DestinationCompanyName));
        exit(MaskNotificationUrl(NotificationUrl));
    end;

    local procedure ReportSubscriptionsKeptElsewhere(Topic: Enum "NPR Spfy Webhook Topic"; KeptElsewhere: List of [Text])
    var
        Destination: Text;
        Destinations: Text;
        KeptElsewhereMsg: Label 'This company had a record of a %1 webhook subscription that Shopify delivers to another environment or company (%2). The record was dropped, but the subscription was left in Shopify because it belongs there. If that environment or company no longer exists, delete it with the Webhook Subscriptions action on the Shopify Store card.', Comment = '%1 - Webhook topic, %2 - Environment / company the subscription delivers to';
    begin
        if KeptElsewhere.Count() = 0 then
            exit;
        foreach Destination in KeptElsewhere do
            if Destinations = '' then
                Destinations := Destination
            else
                Destinations += ', ' + Destination;
        Message(KeptElsewhereMsg, TopicName(Topic), Destinations);
    end;

    /// <summary>Overrides the tenant, environment and company that count as "this company". Defaults to the current session.</summary>
    internal procedure SetCurrentDestination(TenantId: Text; EnvironmentName: Text; CompanyNameParam: Text)
    begin
        _CurrentTenantId := TenantId;
        _CurrentEnvironmentName := EnvironmentName;
        _CurrentCompanyName := CompanyNameParam;
        _CurrentDestinationSet := true;
    end;

    internal procedure DeliversToCurrentCompany(NotificationUrl: Text): Boolean
    var
        TenantId: Text;
        EnvironmentName: Text;
        DestinationCompanyName: Text;
    begin
        if not ParseNotificationUrl(NotificationUrl, TenantId, EnvironmentName, DestinationCompanyName) then
            exit(false);
        exit(IsCurrentDestination(TenantId, EnvironmentName, DestinationCompanyName));
    end;

    internal procedure IsCurrentDestination(TenantId: Text; EnvironmentName: Text; DestinationCompanyName: Text): Boolean
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if not _CurrentDestinationSet then
            SetCurrentDestination(AzureADTenant.GetAadTenantId(), EnvironmentInformation.GetEnvironmentName(), CompanyName());
        if DestinationCompanyName = '' then
            exit(false);
        exit(
            (LowerCase(TenantId) = LowerCase(_CurrentTenantId)) and
            (LowerCase(EnvironmentName) = LowerCase(_CurrentEnvironmentName)) and
            (LowerCase(DestinationCompanyName) = LowerCase(_CurrentCompanyName)));
    end;

    /// <summary>
    /// Reads every webhook subscription the store's access token can see, across all topics and pages, without requiring the integration to be enabled.
    /// Returns false when Shopify could not be read; the reason is then available via GetLastErrorText().
    /// </summary>
    internal procedure GetAllWebhookSubscriptionNodes(ShopifyStoreCode: Code[20]; var WebhookSubscriptionNodes: JsonArray): Boolean
    var
        AllTopics: List of [Enum "NPR Spfy Webhook Topic"];
    begin
        exit(TryGetWebhookSubscriptionNodes(ShopifyStoreCode, AllTopics, false, WebhookSubscriptionNodes));
    end;

    [TryFunction]
    local procedure TryGetWebhookSubscriptionNodes(ShopifyStoreCode: Code[20]; Topics: List of [Enum "NPR Spfy Webhook Topic"]; CheckIntegrationIsEnabled: Boolean; var WebhookSubscriptionNodes: JsonArray)
    var
        JsonHelper: Codeunit "NPR Json Helper";
        ShopifyResponse: JsonToken;
        ShopifyWebhook: JsonToken;
        SubscriptionConnection: JsonToken;
        WebhookSubscriptions: JsonToken;
        Cursor: Text;
        ConnectionFound: Boolean;
        NoSubscriptionListErr: Label 'Shopify did not return the list of webhook subscriptions. %1', Comment = '%1 - Error message returned by Shopify';
    begin
        WebhookSubscriptionNodes.ReadFrom('[]');
        repeat
            Clear(ShopifyResponse);
            if not GetWebhookSubscriptionNextPageFromShopify(ShopifyStoreCode, Topics, CheckIntegrationIsEnabled, Cursor, ShopifyResponse) then
                Error(GetLastErrorText());
            // A response without the connection (e.g. GraphQL errors only) must not read as "Shopify has no subscriptions".
            ConnectionFound := ShopifyResponse.SelectToken('data.webhookSubscriptions', SubscriptionConnection);
            if ConnectionFound then
                ConnectionFound := SubscriptionConnection.IsObject();
            if not ConnectionFound then
                Error(NoSubscriptionListErr, JsonHelper.GetJText(ShopifyResponse, 'errors[0].message', false));
            if ShopifyResponse.SelectToken('data.webhookSubscriptions.edges', WebhookSubscriptions) then
                if WebhookSubscriptions.IsArray() then
                    foreach ShopifyWebhook in WebhookSubscriptions.AsArray() do
                        WebhookSubscriptionNodes.Add(JsonHelper.GetJsonToken(ShopifyWebhook, 'node'));
            Cursor := JsonHelper.GetJText(ShopifyResponse, 'data.webhookSubscriptions.pageInfo.endCursor', false);
        until not JsonHelper.GetJBoolean(ShopifyResponse, 'data.webhookSubscriptions.pageInfo.hasNextPage', false) or (Cursor = '');
    end;

    local procedure GetWebhookSubscriptionNextPageFromShopify(ShopifyStoreCode: Code[20]; Topics: List of [Enum "NPR Spfy Webhook Topic"]; CheckIntegrationIsEnabled: Boolean; Cursor: Text; var ShopifyResponse: JsonToken): Boolean
    var
        NcTask: Record "NPR Nc Task";
        QueryStream: OutStream;
    begin
        NcTask."Store Code" := ShopifyStoreCode;
        NcTask."Data Output".CreateOutStream(QueryStream, TextEncoding::UTF8);
        ShopifyWebhookSubscriptionsRequestQuery(Topics, Cursor, QueryStream);
        exit(GetGraphQLClient().ExecuteRequest(NcTask, CheckIntegrationIsEnabled, ShopifyResponse));
    end;

    local procedure ShopifyWebhookSubscriptionsRequestQuery(Topics: List of [Enum "NPR Spfy Webhook Topic"]; Cursor: Text; var QueryStream: OutStream)
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        RequestJson: JsonObject;
        VariablesJson: JsonObject;
        QueryTok: Label 'query($topics: [WebhookSubscriptionTopic!], $afterCursor: String) {webhookSubscriptions(first: 50, after: $afterCursor, topics : $topics, format : JSON){edges{node{id apiVersion{displayName supported} topic uri createdAt}} pageInfo{endCursor hasNextPage}}}', Locked = true;
    begin
        // Without topics the variable is left out, so Shopify applies no topic filter and returns every topic.
        if Topics.Count() > 0 then
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
        if not GetGraphQLClient().ExecuteRequest(NcTask, true, ShopifyResponse) then
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
        if not GetGraphQLClient().ExecuteRequest(NcTask, true, ShopifyResponse) then
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

    /// <summary>
    /// Reads the tenant, environment and company a notification URL built by GetNotificationUrl() delivers to.
    /// Returns false for any other address.
    /// </summary>
    internal procedure ParseNotificationUrl(NotificationUrl: Text; var TenantId: Text; var EnvironmentName: Text; var DestinationCompanyName: Text): Boolean
    var
        TypeHelper: Codeunit "Type Helper";
        PathSegments: List of [Text];
        QueryParameter: Text;
        PathPart: Text;
        QueryPart: Text;
        Position: Integer;
        NotificationUrlPathTok: Label '/api/ShopifyCloud/', Locked = true;
        CompanyNameParamTok: Label 'companyname=', Locked = true;
    begin
        TenantId := '';
        EnvironmentName := '';
        DestinationCompanyName := '';
        Position := LowerCase(NotificationUrl).IndexOf(LowerCase(NotificationUrlPathTok));
        if Position = 0 then
            exit(false);
        SplitUrl(CopyStr(NotificationUrl, Position + StrLen(NotificationUrlPathTok)), PathPart, QueryPart);
        PathSegments := PathPart.Split('/');
        if PathSegments.Count() < 2 then
            exit(false);
        TenantId := PathSegments.Get(1);
        EnvironmentName := PathSegments.Get(2);
        foreach QueryParameter in QueryPart.Split('&') do
            if LowerCase(QueryParameter).StartsWith(CompanyNameParamTok) then begin
                DestinationCompanyName := CopyStr(QueryParameter, StrLen(CompanyNameParamTok) + 1);
                TypeHelper.UrlDecode(DestinationCompanyName);
            end;
        exit((TenantId <> '') and (EnvironmentName <> '') and (DestinationCompanyName <> ''));
    end;

    /// <summary>Replaces the Azure Function key ("code" query parameter) in a notification URL, so the URL can be shown to users.</summary>
    internal procedure MaskNotificationUrl(NotificationUrl: Text) MaskedUrl: Text
    var
        QueryParameter: Text;
        PathPart: Text;
        QueryPart: Text;
        Separator: Text;
        CodeParamTok: Label 'code=', Locked = true;
        MaskedCodeParamTok: Label 'code=***', Locked = true;
    begin
        SplitUrl(NotificationUrl, PathPart, QueryPart);
        if QueryPart = '' then
            exit(NotificationUrl);
        MaskedUrl := PathPart;
        Separator := '?';
        foreach QueryParameter in QueryPart.Split('&') do begin
            if LowerCase(QueryParameter).StartsWith(CodeParamTok) then
                MaskedUrl += Separator + MaskedCodeParamTok
            else
                MaskedUrl += Separator + QueryParameter;
            Separator := '&';
        end;
    end;

    local procedure SplitUrl(Url: Text; var PathPart: Text; var QueryPart: Text)
    var
        Position: Integer;
    begin
        Position := Url.IndexOf('?');
        if Position = 0 then begin
            PathPart := Url;
            QueryPart := '';
            exit;
        end;
        PathPart := CopyStr(Url, 1, Position - 1);
        QueryPart := CopyStr(Url, Position + 1);
    end;

    /// <summary>Maps a GraphQL webhook topic (e.g. CUSTOMERS_UPDATE) to the topic enum. Returns false for topics the enum does not know.</summary>
    internal procedure FindTopicByGraphQLName(GraphQLTopicName: Text; var Topic: Enum "NPR Spfy Webhook Topic"): Boolean
    var
        CandidateTopic: Enum "NPR Spfy Webhook Topic";
        Ordinal: Integer;
    begin
        if GraphQLTopicName = '' then
            exit(false);
        foreach Ordinal in Enum::"NPR Spfy Webhook Topic".Ordinals() do begin
            CandidateTopic := Enum::"NPR Spfy Webhook Topic".FromInteger(Ordinal);
            if SpfyWebhookTopicName(CandidateTopic, true) = GraphQLTopicName then begin
                Topic := CandidateTopic;
                exit(true);
            end;
        end;
        exit(false);
    end;

    /// <summary>Topic as Shopify names it in notifications (e.g. customers/update).</summary>
    internal procedure TopicName(Topic: Enum "NPR Spfy Webhook Topic"): Text
    begin
        exit(SpfyWebhookTopicName(Topic, false));
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