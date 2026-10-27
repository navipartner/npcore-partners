#if not BC17
codeunit 6184565 "NPR Spfy Webhook Subscr. Check"
{
    Access = Internal;

    var
        _SpfyWebhookMgt: Codeunit "NPR Spfy Webhook Mgt.";

    internal procedure SetGraphQLClient(GraphQLClient: Interface "NPR Spfy IGraphQL Client")
    begin
        _SpfyWebhookMgt.SetGraphQLClient(GraphQLClient);
    end;

    /// <summary>Overrides the tenant, environment and company that count as "this company". Defaults to the current session.</summary>
    internal procedure SetCurrentDestination(TenantId: Text; EnvironmentName: Text; CompanyNameParam: Text)
    begin
        _SpfyWebhookMgt.SetCurrentDestination(TenantId, EnvironmentName, CompanyNameParam);
    end;

    /// <summary>
    /// Lists the store's webhook subscriptions held by Shopify next to the ones this company recorded, one buffer line per subscription.
    /// Returns false when Shopify could not be read: the company's records are then listed as Not Checked and ShopifyErrorText holds the reason.
    /// </summary>
    internal procedure CompareWithShopify(ShopifyStoreCode: Code[20]; var WebhookSubscrBuffer: Record "NPR Spfy WH Subscr. Buffer"; var ShopifyErrorText: Text): Boolean
    var
        SpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription";
    begin
        exit(CompareWithShopify(ShopifyStoreCode, SpfyWebhookSubscription, WebhookSubscrBuffer, ShopifyErrorText));
    end;

    internal procedure CompareWithShopify(ShopifyStoreCode: Code[20]; var SpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription"; var WebhookSubscrBuffer: Record "NPR Spfy WH Subscr. Buffer"; var ShopifyErrorText: Text) ShopifyRead: Boolean
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        JsonHelper: Codeunit "NPR Json Helper";
        ShopifyWebhook: JsonToken;
        WebhookSubscriptionNodes: JsonArray;
        ShopifyWebhookById: Dictionary of [Text, JsonToken];
        ShopifyWebhookIds: List of [Text];
        MatchedWebhookIds: List of [Text];
        WebhookId: Text;
    begin
        if not WebhookSubscrBuffer.IsTemporary() then
            SpfyIntegrationMgt.FunctionCallOnNonTempVarErr(StrSubstNo('[Codeunit::NPR Spfy Webhook Subscr. Check(%1)].%2', Codeunit::"NPR Spfy Webhook Subscr. Check", 'CompareWithShopify'));
        WebhookSubscrBuffer.Reset();
        WebhookSubscrBuffer.DeleteAll();
        ShopifyErrorText := '';

        ShopifyRead := _SpfyWebhookMgt.GetAllWebhookSubscriptionNodes(ShopifyStoreCode, WebhookSubscriptionNodes);
        if ShopifyRead then begin
            foreach ShopifyWebhook in WebhookSubscriptionNodes do begin
                WebhookId := SpfyIntegrationMgt.RemoveUntil(JsonHelper.GetJText(ShopifyWebhook, 'id', false), '/');
                if (WebhookId <> '') and not ShopifyWebhookById.ContainsKey(WebhookId) then begin
                    ShopifyWebhookById.Add(WebhookId, ShopifyWebhook);
                    ShopifyWebhookIds.Add(WebhookId);
                end;
            end;
        end else
            ShopifyErrorText := GetLastErrorText();

        SpfyWebhookSubscription.SetRange("Store Code", ShopifyStoreCode);
        if SpfyWebhookSubscription.FindSet() then
            repeat
                InitLine(ShopifyStoreCode, WebhookSubscrBuffer);
                WebhookSubscrBuffer.Topic := CopyStr(_SpfyWebhookMgt.TopicName(SpfyWebhookSubscription.Topic), 1, MaxStrLen(WebhookSubscrBuffer.Topic));
                WebhookSubscrBuffer."Webhook ID" := SpfyWebhookSubscription."Webhook ID";
                WebhookSubscrBuffer."API Version in BC" := SpfyWebhookSubscription."Api Version";
                WebhookSubscrBuffer."Address in BC" := CopyStr(_SpfyWebhookMgt.MaskNotificationUrl(SpfyWebhookSubscription.Address), 1, MaxStrLen(WebhookSubscrBuffer."Address in BC"));
                SetDestination(WebhookSubscrBuffer, SpfyWebhookSubscription.Address);
                if not ShopifyRead then
                    SetStatus(WebhookSubscrBuffer, WebhookSubscrBuffer.Status::"Not Checked")
                else
                    if not ShopifyWebhookById.Get(SpfyWebhookSubscription."Webhook ID", ShopifyWebhook) then
                        SetStatus(WebhookSubscrBuffer, WebhookSubscrBuffer.Status::"Missing in Shopify")
                    else begin
                        if not MatchedWebhookIds.Contains(SpfyWebhookSubscription."Webhook ID") then
                            MatchedWebhookIds.Add(SpfyWebhookSubscription."Webhook ID");
                        SetShopifyFields(WebhookSubscrBuffer, ShopifyWebhook);
                        if JsonHelper.GetJText(ShopifyWebhook, 'uri', false) <> SpfyWebhookSubscription.Address then
                            SetStatus(WebhookSubscrBuffer, WebhookSubscrBuffer.Status::"Address Mismatch")
                        else
                            if WebhookSubscrBuffer."Delivers to This Company" then
                                SetStatus(WebhookSubscrBuffer, WebhookSubscrBuffer.Status::OK)
                            else
                                SetStatus(WebhookSubscrBuffer, WebhookSubscrBuffer.Status::"Delivers Elsewhere");
                    end;
                WebhookSubscrBuffer.Insert();
            until SpfyWebhookSubscription.Next() = 0;

        foreach WebhookId in ShopifyWebhookIds do
            if not MatchedWebhookIds.Contains(WebhookId) then begin
                ShopifyWebhookById.Get(WebhookId, ShopifyWebhook);
                InitLine(ShopifyStoreCode, WebhookSubscrBuffer);
                WebhookSubscrBuffer."Webhook ID" := CopyStr(WebhookId, 1, MaxStrLen(WebhookSubscrBuffer."Webhook ID"));
                WebhookSubscrBuffer.Topic := CopyStr(ShopifyTopicName(JsonHelper.GetJText(ShopifyWebhook, 'topic', false)), 1, MaxStrLen(WebhookSubscrBuffer.Topic));
                SetShopifyFields(WebhookSubscrBuffer, ShopifyWebhook);
                SetStatus(WebhookSubscrBuffer, WebhookSubscrBuffer.Status::"Not Registered");
                WebhookSubscrBuffer.Insert();
            end;

        if WebhookSubscrBuffer.FindFirst() then;
    end;

    local procedure InitLine(ShopifyStoreCode: Code[20]; var WebhookSubscrBuffer: Record "NPR Spfy WH Subscr. Buffer")
    var
        EntryNo: Integer;
    begin
        WebhookSubscrBuffer.Reset();
        if WebhookSubscrBuffer.FindLast() then
            EntryNo := WebhookSubscrBuffer."Entry No.";
        WebhookSubscrBuffer.Init();
        WebhookSubscrBuffer."Entry No." := EntryNo + 1;
        WebhookSubscrBuffer."Store Code" := ShopifyStoreCode;
    end;

    local procedure SetShopifyFields(var WebhookSubscrBuffer: Record "NPR Spfy WH Subscr. Buffer"; ShopifyWebhook: JsonToken)
    var
        JsonHelper: Codeunit "NPR Json Helper";
        ShopifyAddress: Text;
    begin
        ShopifyAddress := JsonHelper.GetJText(ShopifyWebhook, 'uri', false);
        WebhookSubscrBuffer."Address in Shopify" := CopyStr(_SpfyWebhookMgt.MaskNotificationUrl(ShopifyAddress), 1, MaxStrLen(WebhookSubscrBuffer."Address in Shopify"));
#pragma warning disable AA0139
        WebhookSubscrBuffer."API Version in Shopify" := JsonHelper.GetJText(ShopifyWebhook, 'apiVersion.displayName', MaxStrLen(WebhookSubscrBuffer."API Version in Shopify"), false);
#pragma warning restore AA0139
        WebhookSubscrBuffer."Created in Shopify" := JsonHelper.GetJDT(ShopifyWebhook, 'createdAt', false);
        WebhookSubscrBuffer."Exists in Shopify" := true;
        SetDestination(WebhookSubscrBuffer, ShopifyAddress);
    end;

    local procedure SetDestination(var WebhookSubscrBuffer: Record "NPR Spfy WH Subscr. Buffer"; NotificationUrl: Text)
    var
        TenantId: Text;
        EnvironmentName: Text;
        DestinationCompanyName: Text;
    begin
        _SpfyWebhookMgt.ParseNotificationUrl(NotificationUrl, TenantId, EnvironmentName, DestinationCompanyName);
        WebhookSubscrBuffer."Destination Tenant ID" := CopyStr(TenantId, 1, MaxStrLen(WebhookSubscrBuffer."Destination Tenant ID"));
        WebhookSubscrBuffer."Destination Environment" := CopyStr(EnvironmentName, 1, MaxStrLen(WebhookSubscrBuffer."Destination Environment"));
        WebhookSubscrBuffer."Destination Company" := CopyStr(DestinationCompanyName, 1, MaxStrLen(WebhookSubscrBuffer."Destination Company"));
        WebhookSubscrBuffer."Delivers to This Company" := _SpfyWebhookMgt.IsCurrentDestination(TenantId, EnvironmentName, DestinationCompanyName);
    end;

    /// <summary>
    /// Counts the lines this company has to act on: RepairableByToggle are its own delivery problems that turning the setting off and on again repairs,
    /// ForeignRecords are its records of subscriptions that Shopify delivers elsewhere. Another environment's or company's own subscriptions are not counted.
    /// </summary>
    internal procedure CountNeedingAttention(var WebhookSubscrBuffer: Record "NPR Spfy WH Subscr. Buffer"; var RepairableByToggle: Integer; var ForeignRecords: Integer)
    var
        TempWebhookSubscrBuffer: Record "NPR Spfy WH Subscr. Buffer" temporary;
    begin
        RepairableByToggle := 0;
        ForeignRecords := 0;
        TempWebhookSubscrBuffer.Copy(WebhookSubscrBuffer, true);
        TempWebhookSubscrBuffer.Reset();
        if TempWebhookSubscrBuffer.FindSet() then
            repeat
                if TempWebhookSubscrBuffer.IsRepairableByToggle() then
                    RepairableByToggle += 1;
                if TempWebhookSubscrBuffer.IsForeignRecord() then
                    ForeignRecords += 1;
            until TempWebhookSubscrBuffer.Next() = 0;
    end;

    /// <summary>
    /// Fails, deleting nothing, if any selected line is not a Shopify subscription that delivers to another environment or company:
    /// this company's own subscriptions are managed by the webhook settings on the Shopify Store card.
    /// </summary>
    internal procedure CheckCanDeleteInShopify(var SelectedLines: Record "NPR Spfy WH Subscr. Buffer")
    var
        NotDeletableErr: Label 'Subscription %1 cannot be deleted here, because it is not a Shopify subscription that delivers to another environment or company. Use the related webhook setting on the Shopify Store card for this company''s own subscriptions.', Comment = '%1 - Shopify webhook subscription ID';
    begin
        if SelectedLines.FindSet() then
            repeat
                if not SelectedLines.CanDeleteInShopify() then
                    Error(NotDeletableErr, SelectedLines."Webhook ID");
            until SelectedLines.Next() = 0;
    end;

    /// <summary>The distinct destinations of the selected lines, for the confirmation before deleting them: environment / company, or the masked address.</summary>
    internal procedure DescribeDestinations(var SelectedLines: Record "NPR Spfy WH Subscr. Buffer") Destinations: Text
    var
        Destination: Text;
        Seen: List of [Text];
    begin
        if SelectedLines.FindSet() then
            repeat
                // The masked address still carries the path and company, so it parses like the original.
                Destination := _SpfyWebhookMgt.DescribeDestination(SelectedLines."Address in Shopify");
                if not Seen.Contains(Destination) then begin
                    Seen.Add(Destination);
                    if Destinations <> '' then
                        Destinations += ', ';
                    Destinations += Destination;
                end;
            until SelectedLines.Next() = 0;
    end;

    /// <summary>
    /// Deletes the selected subscriptions in Shopify, together with this company's records of them, after CheckCanDeleteInShopify.
    /// Every line is attempted; returns false if any delete failed, with each failure in FailedDeletes.
    /// </summary>
    internal procedure DeleteInShopify(ShopifyStoreCode: Code[20]; var SelectedLines: Record "NPR Spfy WH Subscr. Buffer"; var FailedDeletes: List of [Text]): Boolean
    var
        ErrorText: Text;
        FailedDeleteTok: Label '%1: %2', Locked = true;
    begin
        CheckCanDeleteInShopify(SelectedLines);
        Clear(FailedDeletes);
        if SelectedLines.FindSet() then
            repeat
                if not _SpfyWebhookMgt.DeleteSubscriptionInShopify(ShopifyStoreCode, SelectedLines."Webhook ID", ErrorText) then
                    FailedDeletes.Add(StrSubstNo(FailedDeleteTok, SelectedLines."Webhook ID", ErrorText));
            until SelectedLines.Next() = 0;
        exit(FailedDeletes.Count() = 0);
    end;

    local procedure ShopifyTopicName(GraphQLTopicName: Text): Text
    var
        Topic: Enum "NPR Spfy Webhook Topic";
    begin
        if _SpfyWebhookMgt.FindTopicByGraphQLName(GraphQLTopicName, Topic) then
            exit(_SpfyWebhookMgt.TopicName(Topic));
        exit(GraphQLTopicName);
    end;

    local procedure SetStatus(var WebhookSubscrBuffer: Record "NPR Spfy WH Subscr. Buffer"; Status: Enum "NPR Spfy WH Subscr. Status")
    var
        NotCheckedTxt: Label 'Shopify could not be reached, so this subscription was not checked.', MaxLength = 250;
        OKTxt: Label 'Shopify and Business Central agree, and Shopify delivers the notifications to this company.', MaxLength = 250;
        MissingInShopifyTxt: Label 'Business Central registered this subscription, but Shopify no longer has it. Turning the related webhook setting off and on again registers a new one.', MaxLength = 250;
        AddressMismatchHereTxt: Label 'Shopify delivers to a different address than Business Central registered. Turning the related webhook setting off and on again repairs it.', MaxLength = 250;
        AddressMismatchElsewhereTxt: Label 'Shopify delivers to a different address, in another environment or company. Use Delete in Shopify only if that environment or company no longer exists.', MaxLength = 250;
        DeliversElsewhereTxt: Label 'Shopify delivers to another environment or company. Turning the setting off and on only drops this record; use Delete in Shopify if that one no longer exists.', MaxLength = 250;
        NotRegisteredHereTxt: Label 'Shopify delivers the notifications to this company, but this company has no record of the subscription. Turning the related webhook setting off and on again removes it.', MaxLength = 250;
        NotRegisteredTxt: Label 'Registered by another environment or company using the same Shopify app, or outside Business Central. Use Delete in Shopify only if it no longer exists.', MaxLength = 250;
    begin
        WebhookSubscrBuffer.Status := Status;
        case Status of
            Status::"Not Checked":
                WebhookSubscrBuffer.Details := NotCheckedTxt;
            Status::OK:
                WebhookSubscrBuffer.Details := OKTxt;
            Status::"Missing in Shopify":
                WebhookSubscrBuffer.Details := MissingInShopifyTxt;
            Status::"Address Mismatch":
                if WebhookSubscrBuffer."Delivers to This Company" then
                    WebhookSubscrBuffer.Details := AddressMismatchHereTxt
                else
                    WebhookSubscrBuffer.Details := AddressMismatchElsewhereTxt;
            Status::"Delivers Elsewhere":
                WebhookSubscrBuffer.Details := DeliversElsewhereTxt;
            Status::"Not Registered":
                if WebhookSubscrBuffer."Delivers to This Company" then
                    WebhookSubscrBuffer.Details := NotRegisteredHereTxt
                else
                    WebhookSubscrBuffer.Details := NotRegisteredTxt;
        end;
    end;
}
#endif
