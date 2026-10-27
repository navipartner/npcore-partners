#if not BC17
page 6150991 "NPR Spfy Webhook Subscriptions"
{
    Extensible = false;
    Caption = 'Shopify Webhook Subscriptions';
    PageType = List;
    SourceTable = "NPR Spfy WH Subscr. Buffer";
    SourceTableTemporary = true;
    UsageCategory = None;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Subscriptions)
            {
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies whether the subscription Shopify holds and the one Business Central registered match. OK: both agree and Shopify delivers to this company. Missing in Shopify: Business Central registered it but Shopify no longer has it. Address Mismatch: Shopify delivers to a different address than Business Central registered. Delivers Elsewhere: both agree, but the address belongs to another environment or company. Not Registered in This Company: Shopify has it but this company did not register it. Not Checked: Shopify could not be reached.';
                    ApplicationArea = NPRShopify;
                    StyleExpr = _StatusStyle;
                }
                field(Topic; Rec.Topic)
                {
                    ToolTip = 'Specifies the Shopify event the subscription sends notifications for.';
                    ApplicationArea = NPRShopify;
                }
                field("Destination Environment"; Rec."Destination Environment")
                {
                    ToolTip = 'Specifies the Business Central environment the subscription delivers notifications to, read from its address.';
                    ApplicationArea = NPRShopify;
                }
                field("Destination Company"; Rec."Destination Company")
                {
                    ToolTip = 'Specifies the Business Central company the subscription delivers notifications to, read from its address.';
                    ApplicationArea = NPRShopify;
                }
                field(Details; Rec.Details)
                {
                    ToolTip = 'Specifies what the status means for this subscription.';
                    ApplicationArea = NPRShopify;
                }
                field("Webhook ID"; Rec."Webhook ID")
                {
                    ToolTip = 'Specifies the ID Shopify gave the webhook subscription.';
                    ApplicationArea = NPRShopify;
                }
                field("Created in Shopify"; Rec."Created in Shopify")
                {
                    ToolTip = 'Specifies when the subscription was created in Shopify.';
                    ApplicationArea = NPRShopify;
                }
                field("Address in Shopify"; Rec."Address in Shopify")
                {
                    ToolTip = 'Specifies the address Shopify delivers the notifications to. The access key in the address is hidden.';
                    ApplicationArea = NPRShopify;
                }
                field("Address in BC"; Rec."Address in BC")
                {
                    ToolTip = 'Specifies the address Business Central registered for the subscription. The access key in the address is hidden.';
                    ApplicationArea = NPRShopify;
                }
                field("API Version in Shopify"; Rec."API Version in Shopify")
                {
                    ToolTip = 'Specifies the Shopify API version the notifications are sent in.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                }
                field("API Version in BC"; Rec."API Version in BC")
                {
                    ToolTip = 'Specifies the Shopify API version Business Central registered for the subscription.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                }
                field("Destination Tenant ID"; Rec."Destination Tenant ID")
                {
                    ToolTip = 'Specifies the Microsoft Entra tenant the subscription delivers notifications to, read from its address.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                }
                field("Delivers to This Company"; Rec."Delivers to This Company")
                {
                    ToolTip = 'Specifies whether the subscription delivers notifications to this environment and company.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Refresh)
            {
                Caption = 'Refresh';
                ToolTip = 'Reads the webhook subscriptions from Shopify again and compares them with the ones Business Central registered.';
                ApplicationArea = NPRShopify;
                Image = Refresh;

                trigger OnAction()
                begin
                    LoadSubscriptions();
                    CurrPage.Update(false);
                end;
            }
            action(DeleteInShopify)
            {
                Caption = 'Delete in Shopify';
                ToolTip = 'Deletes the selected subscriptions in Shopify, for example ones left behind by an environment copy or a company rename. Only subscriptions that deliver to another environment or company can be deleted here, and that environment or company stops receiving these notifications.';
                ApplicationArea = NPRShopify;
                Image = Delete;

                trigger OnAction()
                var
                    TempSelectedLines: Record "NPR Spfy WH Subscr. Buffer" temporary;
                    SpfyWebhookSubscrCheck: Codeunit "NPR Spfy Webhook Subscr. Check";
                    FailedDeletes: List of [Text];
                    FailedDelete: Text;
                    Failures: Text;
                    ConfirmDeleteQst: Label 'Delete %1 webhook subscription(s) in Shopify?\Shopify will stop sending these notifications to: %2.\\Do this only if that environment or company no longer exists or no longer needs them.', Comment = '%1 - Number of subscriptions, %2 - Environments / companies the subscriptions deliver to';
                    DeleteFailedMsg: Label 'Some subscriptions could not be deleted in Shopify:\%1', Comment = '%1 - Webhook IDs with the error Shopify returned for each';
                begin
                    TempSelectedLines.Copy(Rec, true);
                    CurrPage.SetSelectionFilter(TempSelectedLines);
                    SpfyWebhookSubscrCheck.CheckCanDeleteInShopify(TempSelectedLines);
                    if not Confirm(ConfirmDeleteQst, false, TempSelectedLines.Count(), SpfyWebhookSubscrCheck.DescribeDestinations(TempSelectedLines)) then
                        exit;
                    if not SpfyWebhookSubscrCheck.DeleteInShopify(_ShopifyStoreCode, TempSelectedLines, FailedDeletes) then begin
                        foreach FailedDelete in FailedDeletes do
                            Failures += '\' + FailedDelete;
                        Message(DeleteFailedMsg, Failures);
                    end;
                    LoadSubscriptions();
                    CurrPage.Update(false);
                end;
            }
        }
        area(Promoted)
        {
            actionref(Refresh_Promoted; Refresh) { }
            actionref(DeleteInShopify_Promoted; DeleteInShopify) { }
        }
    }

    trigger OnOpenPage()
    var
        CaptionWithStoreTok: Label '%1 - %2', Locked = true;
    begin
        CurrPage.Caption(StrSubstNo(CaptionWithStoreTok, CurrPage.Caption(), _ShopifyStoreCode));
        LoadSubscriptions();
    end;

    trigger OnAfterGetRecord()
    begin
        _StatusStyle := Rec.StatusStyleExpr();
    end;

    var
        _ShopifyErrorNotification: Notification;
        _AttentionNotification: Notification;
        _ShopifyStoreCode: Code[20];
        _StatusStyle: Text;

    internal procedure SetShopifyStore(ShopifyStoreCode: Code[20])
    begin
        _ShopifyStoreCode := ShopifyStoreCode;
    end;

    local procedure LoadSubscriptions()
    var
        SpfyWebhookSubscrCheck: Codeunit "NPR Spfy Webhook Subscr. Check";
        ShopifyErrorText: Text;
        ShopifyNotReadMsg: Label 'Shopify could not be reached, so only the subscriptions Business Central registered are listed, and they were not checked. Shopify returned: %1', Comment = '%1 - Error message';
        RepairableMsg: Label '%1 subscriptions for this company can be repaired by turning the related webhook setting on the Shopify Store card off and on again.', Comment = '%1 - Number of subscriptions';
        ForeignRecordsMsg: Label '%1 subscriptions that this company has a record of deliver to another environment or company. Turning the setting off and on only drops those records; use Delete in Shopify only if that environment or company no longer exists.', Comment = '%1 - Number of subscriptions';
        AttentionText: Text;
        RepairableByToggle: Integer;
        ForeignRecords: Integer;
    begin
        if _ShopifyErrorNotification.Recall() then;
        if _AttentionNotification.Recall() then;

        if not SpfyWebhookSubscrCheck.CompareWithShopify(_ShopifyStoreCode, Rec, ShopifyErrorText) then begin
            _ShopifyErrorNotification.Id := CreateGuid();
            _ShopifyErrorNotification.Scope := NotificationScope::LocalScope;
            _ShopifyErrorNotification.Message := StrSubstNo(ShopifyNotReadMsg, ShopifyErrorText);
            _ShopifyErrorNotification.Send();
            exit;
        end;

        SpfyWebhookSubscrCheck.CountNeedingAttention(Rec, RepairableByToggle, ForeignRecords);
        if RepairableByToggle > 0 then
            AttentionText := StrSubstNo(RepairableMsg, RepairableByToggle);
        if ForeignRecords > 0 then begin
            if AttentionText <> '' then
                AttentionText += ' ';
            AttentionText += StrSubstNo(ForeignRecordsMsg, ForeignRecords);
        end;
        if AttentionText = '' then
            exit;
        _AttentionNotification.Id := CreateGuid();
        _AttentionNotification.Scope := NotificationScope::LocalScope;
        _AttentionNotification.Message := AttentionText;
        _AttentionNotification.Send();
    end;
}
#endif
