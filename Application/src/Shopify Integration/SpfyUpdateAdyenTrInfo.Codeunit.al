#if not BC17
codeunit 6248515 "NPR Spfy Update Adyen Tr. Info"
{
    Access = Internal;

    local procedure UpdatePaymentLineWithDataFromAdyen(var PaymentLine: Record "NPR Magento Payment Line")
    var
        SpfyTransactionSync: Record "NPR Spfy Trans. PSP Details";
    begin
        if not PaymentLine."External Payment Gateway".Contains('Adyen') then
            exit;
        if not TransactionExistsByMerchantRefAndPSP(SpfyTransactionSync, PaymentLine) then
            exit;
        UpdateTransactionDetails(SpfyTransactionSync, PaymentLine);
    end;

    local procedure TryDeleteSpfyTransactionSync(SpfyTransactionSyncSystemId: Guid)
    var
        PaymentLine: Record "NPR Magento Payment Line";
        SpfyTransactionSync: Record "NPR Spfy Trans. PSP Details";
    begin
        if not SpfyTransactionSync.GetBySystemId(SpfyTransactionSyncSystemId) then
            exit;

        PaymentLine.SetCurrentKey("Transaction ID", Posted, "Date Captured");
        PaymentLine.FilterGroup(-1);
        PaymentLine.SetRange(Posted, false);
        PaymentLine.SetRange("Date Captured", 0D);
        PaymentLine.FilterGroup(0);
        if TransactionExistsByMerchantRef(PaymentLine, SpfyTransactionSync."Merchant Reference") then
            exit;
        if TransactionExistsByPSPRef(PaymentLine, SpfyTransactionSync."PSP Reference") then
            exit;
        SpfyTransactionSync.Delete();
    end;

    local procedure TransactionExistsByMerchantRef(var PaymentLine: Record "NPR Magento Payment Line"; MerchantReference: Text): Boolean
    begin
        PaymentLine.SetRange("Transaction ID", CopyStr(MerchantReference.Split('-').Get(2), 1, MaxStrLen(PaymentLine."Transaction ID")));
        exit(not PaymentLine.IsEmpty());
    end;

    local procedure TransactionExistsByPSPRef(var PaymentLine: Record "NPR Magento Payment Line"; PSPReference: Text[100]): Boolean
    begin
        PaymentLine.SetRange("Transaction ID", PSPReference);
        exit(not PaymentLine.IsEmpty());
    end;

    internal procedure SyncShopifyTransactionsWithPSPData(AdyenWebhook: Record "NPR Adyen Webhook")
    var
        PaymentLine: Record "NPR Magento Payment Line";
        JsonHelper: Codeunit "NPR Json Helper";
        NotificationItem: JsonToken;
        NotificationRequestItem: JsonToken;
        WebhookDataToken: JsonToken;
        MerchantReference: Text;
        TransactionDetailsUpdated: Boolean;
        TransactionExists: Boolean;
    begin
        if not GetWebhookData(AdyenWebhook, WebhookDataToken) then
            exit;

        WebhookDataToken.AsObject().Get('notificationItems', NotificationItem);
        NotificationItem.AsArray().Get(0, NotificationRequestItem);
        if NotificationRequestItem.IsObject() then
            MerchantReference := JsonHelper.GetJText(NotificationRequestItem, 'NotificationRequestItem.merchantReference', true);

        TransactionExists := TransactionExistsByMerchantRef(PaymentLine, MerchantReference);
        if not TransactionExists then
            TransactionExists := TransactionExistsByPSPRef(PaymentLine, AdyenWebhook."PSP Reference");

        if TransactionExists and NotificationRequestItem.IsObject() then
            TransactionDetailsUpdated := UpdateTransactionDetails(PaymentLine, NotificationRequestItem);

        if not TransactionDetailsUpdated then
            SaveTransactionDetails(NotificationRequestItem);
    end;

    local procedure TransactionExistsByMerchantRefAndPSP(var SpfyTransactionSync: Record "NPR Spfy Trans. PSP Details"; PaymentLine: Record "NPR Magento Payment Line"): Boolean
    begin
        SpfyTransactionSync.SetRange("Transaction PSP", SpfyTransactionSync."Transaction PSP"::Adyen);
        SpfyTransactionSync.SetFilter("Merchant Reference", StrSubstNo('*-%1', PaymentLine."Transaction ID"));
        exit(SpfyTransactionSync.FindFirst());
    end;

    local procedure UpdateTransactionDetails(SpfyTransactionSync: Record "NPR Spfy Trans. PSP Details"; var PaymentLine: Record "NPR Magento Payment Line")
    begin
        if SpfyTransactionSync."PSP Reference" <> '' then
            PaymentLine."Transaction ID" := SpfyTransactionSync."PSP Reference";
        if SpfyTransactionSync."Card Summary" <> '' then
            PaymentLine."Card Summary" := SpfyTransactionSync."Card Summary";
        if SpfyTransactionSync."Payment Method" <> '' then
            PaymentLine."External Payment Method Code" := SpfyTransactionSync."Payment Method";
        if SpfyTransactionSync."Expiry Date" <> '' then
            PaymentLine."Expiry Date Text" := SpfyTransactionSync."Expiry Date";
    end;

    local procedure GetWebhookData(var AdyenWebhook: Record "NPR Adyen Webhook"; var WebhookDataToken: JsonToken): Boolean
    var
        TypeHelper: Codeunit "Type Helper";
        InStr: InStream;
    begin
        AdyenWebhook."Webhook Data".CreateInStream(InStr, TextEncoding::UTF8);
        exit(WebhookDataToken.ReadFrom(TypeHelper.ReadAsTextWithSeparator(InStr, TypeHelper.LFSeparator())));
    end;

    local procedure SaveTransactionDetails(NotificationRequestItem: JsonToken)
    begin
        PrepareWebhookDataFields(NotificationRequestItem);
    end;

    local procedure UpdateTransactionDetails(var PaymentLine: Record "NPR Magento Payment Line"; NotificationRequestItem: JsonToken): Boolean
    var
        PaymentLine2: Record "NPR Magento Payment Line";
        SpfyTransactionSync: Record "NPR Spfy Trans. PSP Details";
    begin
        if not PaymentLine.FindSet(true) then
            exit;

        SpfyTransactionSync := PrepareWebhookDataFields(NotificationRequestItem);
        repeat
            PaymentLine2 := PaymentLine;

            UpdateTransactionDetails(SpfyTransactionSync, PaymentLine2);

            if Format(PaymentLine2) <> Format(PaymentLine) then begin
                PaymentLine2.Modify();
            end;
        until PaymentLine.Next() = 0;

        TryDeleteSpfyTransactionSync(SpfyTransactionSync.SystemId);
        exit(true);
    end;

    local procedure PrepareWebhookDataFields(NotificationRequestItem: JsonToken) SpfyTransactionSync: Record "NPR Spfy Trans. PSP Details";
    var
        JsonHelper: Codeunit "NPR Json Helper";
    begin
        SpfyTransactionSync.SetCurrentKey("Transaction PSP", "PSP Reference");
        SpfyTransactionSync.SetRange("Transaction PSP", SpfyTransactionSync."Transaction PSP"::Adyen);
        SpfyTransactionSync.SetRange("PSP Reference", JsonHelper.GetJCode(NotificationRequestItem, 'NotificationRequestItem.pspReference', MaxStrLen(SpfyTransactionSync."PSP Reference"), true));
        if SpfyTransactionSync.FindFirst() then
            exit;

        SpfyTransactionSync.Init();
        SpfyTransactionSync."Transaction PSP" := SpfyTransactionSync."Transaction PSP"::Adyen;
        SpfyTransactionSync."Entry No." := 0;
        SpfyTransactionSync."Payment Method" := CopyStr(JsonHelper.GetJText(NotificationRequestItem, 'NotificationRequestItem.paymentMethod', true), 1, MaxStrLen(SpfyTransactionSync."Payment Method"));
        SpfyTransactionSync."Merchant Account" := CopyStr(JsonHelper.GetJText(NotificationRequestItem, 'NotificationRequestItem.merchantAccountCode', true), 1, MaxStrLen(SpfyTransactionSync."Merchant Account"));
        SpfyTransactionSync."Merchant Reference" := CopyStr(JsonHelper.GetJText(NotificationRequestItem, 'NotificationRequestItem.merchantReference', true), 1, MaxStrLen(SpfyTransactionSync."Merchant Reference"));
        SpfyTransactionSync."PSP Reference" := CopyStr(JsonHelper.GetJCode(NotificationRequestItem, 'NotificationRequestItem.pspReference', true), 1, MaxStrLen(SpfyTransactionSync."PSP Reference"));
        SpfyTransactionSync."Card Summary" := CopyStr(JsonHelper.GetJText(NotificationRequestItem, 'NotificationRequestItem.additionalData.cardSummary', false), 1, MaxStrLen(SpfyTransactionSync."Card Summary"));
        SpfyTransactionSync."Expiry Date" := CopyStr(JsonHelper.GetJCode(NotificationRequestItem, 'NotificationRequestItem.additionalData.expiryDate', false), 1, MaxStrLen(SpfyTransactionSync."Expiry Date"));
        SpfyTransactionSync.Amount := JsonHelper.GetJInteger(NotificationRequestItem, 'NotificationRequestItem.amount.value', true);
        SpfyTransactionSync."Card Function" := CopyStr(JsonHelper.GetJText(NotificationRequestItem, 'NotificationRequestItem.additionalData.cardFunction', false), 1, MaxStrLen(SpfyTransactionSync."Card Function"));
        SpfyTransactionSync."Card Added Brand" := CopyStr(JsonHelper.GetJText(NotificationRequestItem, 'NotificationRequestItem.additionalData.checkout.cardAddedBrand', false), 1, MaxStrLen(SpfyTransactionSync."Card Added Brand"));
        SpfyTransactionSync."Merchant Order Reference" := CopyStr(JsonHelper.GetJText(NotificationRequestItem, 'NotificationRequestItem.additionalData.merchantOrderReference', false), 1, MaxStrLen(SpfyTransactionSync."Merchant Order Reference"));
        SpfyTransactionSync.Insert();
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Spfy Integration Events", 'OnAfterSetPaymentCardDetails', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Spfy Integration Events", OnAfterSetPaymentCardDetails, '', false, false)]
#endif
    local procedure OnAfterSetPaymentCardDetails(Transaction: JsonToken; var PaymentLine: Record "NPR Magento Payment Line")
    begin
        UpdatePaymentLineWithDataFromAdyen(PaymentLine);
    end;
}
#endif
