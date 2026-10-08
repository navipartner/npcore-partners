page 6150966 "NPR Spfy Legacy Return Queue"
{
    Caption = 'Shopify Legacy Return Queue';
    PageType = List;
    SourceTable = "NPR Spfy NC Return Queue";
    UsageCategory = Lists;
    ApplicationArea = NPRShopify;
    Editable = false;
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(Rows)
            {
                field("Shopify Store Code"; Rec."Shopify Store Code") { ToolTip = 'Specifies the Shopify store the return or refund belongs to.'; ApplicationArea = NPRShopify; }
                field("Entry No."; Rec."Entry No.") { ToolTip = 'Specifies the number of the queue row.'; ApplicationArea = NPRShopify; Visible = false; }
                field("Source Doc. Type"; Rec."Source Doc. Type") { ToolTip = 'Specifies whether the row imports a Shopify return or a refund made without a return.'; ApplicationArea = NPRShopify; }
                field("Source Doc. Name"; Rec."Source Doc. Name") { ToolTip = 'Specifies the return name shown in Shopify, or the order name for a refund made without a return, which has no name of its own.'; ApplicationArea = NPRShopify; }
                field("Source Doc. ID"; Rec."Source Doc. ID") { ToolTip = 'Specifies the Shopify id of the return or of the refund made without a return.'; ApplicationArea = NPRShopify; }
                field("Order Id"; Rec."Order Id") { ToolTip = 'Specifies the Shopify order id the return or refund belongs to.'; ApplicationArea = NPRShopify; Visible = false; }
                field(Status; Rec.Status) { ToolTip = 'Specifies where the return or refund is in the import.'; ApplicationArea = NPRShopify; StyleExpr = _StatusStyle; }
                field("Detected At"; Rec."Detected At") { ToolTip = 'Specifies when the poll first saw the closed return or the refund.'; ApplicationArea = NPRShopify; }
                field("Processed At"; Rec."Processed At") { ToolTip = 'Specifies when the return or refund was last attempted or dismissed.'; ApplicationArea = NPRShopify; }
                field("Retry Count"; Rec."Retry Count") { ToolTip = 'Specifies how many attempts count against the retry limit: failed ones and ones whose session was lost.'; ApplicationArea = NPRShopify; }
                field("Last Error"; Rec."Last Error") { ToolTip = 'Specifies the error of the last failed attempt.'; ApplicationArea = NPRShopify; }
                field("Outcome Note"; Rec."Outcome Note") { ToolTip = 'Specifies what the return or refund waits for, or why a refund has nothing to credit.'; ApplicationArea = NPRShopify; }
                field("Sales Header Doc. No."; Rec."Sales Header Doc. No.") { ToolTip = 'Specifies the Sales Return Order built for the return or refund. The number stays after posting, next to the posted document number.'; ApplicationArea = NPRShopify; }
                field("Posted Doc. No."; Rec."Posted Doc. No.") { ToolTip = 'Specifies the posted credit memo or return receipt.'; ApplicationArea = NPRShopify; }
                field("Location Fallback Used"; Rec."Location Fallback Used") { ToolTip = 'Specifies that the restock locations did not agree, so the store default was used.'; ApplicationArea = NPRShopify; }
                field("Not Restocked"; Rec."Not Restocked") { ToolTip = 'Specifies that Shopify did not restock at least one line.'; ApplicationArea = NPRShopify; }
                field("Refund Gift Card Amount"; Rec."Refund Gift Card Amount") { ToolTip = 'Specifies the part of the refund that went back to gift cards or Shopify store credit.'; ApplicationArea = NPRShopify; }
                field("Refund Voucher No."; Rec."Refund Voucher No.") { ToolTip = 'Specifies the retail voucher that is credited for the gift card part of the refund when the document is posted.'; ApplicationArea = NPRShopify; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(PollNow)
            {
                Caption = 'Poll Shopify Now';
                Image = Refresh;
                ToolTip = 'Look for closed returns and for refunds made without a return in every enabled store now, the same way the scheduled job does.';
                ApplicationArea = NPRShopify;
                trigger OnAction()
                var
                    SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
                    SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
                begin
                    SpfyLegacyReturnMgt.ErrorIfEcommerceFeatureEnabled();
                    SpfyLegacyReturnPollJQ.PollAllStores();
                    CurrPage.Update(false);
                end;
            }
            action(ProcessRow)
            {
                Caption = 'Process';
                Image = Process;
                ToolTip = 'Import this return or refund now, the same way the scheduled job does.';
                ApplicationArea = NPRShopify;
                trigger OnAction()
                var
                    SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
                    SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
                    SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
                    NotClaimedMsg: Label 'Shopify %1 was not processed: another session claimed it a moment ago, or since the list was shown it was dismissed, imported, found to have nothing to credit or deleted.', Comment = '%1 = Shopify document caption';
                begin
                    SpfyLegacyReturnMgt.ErrorIfEcommerceFeatureEnabled();
                    // Get, not Find: the page's filters would hide a row another session has moved to another status.
                    Rec.Get(Rec."Entry No.");
                    SpfyLegacyReturnMgt.ErrorIfDismissed(Rec);
                    if not SpfyLegacyReturnMgt.MarkImportedIfCreditMemoPosted(Rec) then begin
                        SpfyLegacyReturnMgt.ErrorIfAlreadyPosted(Rec);
                        SpfyLegacyReturnMgt.ErrorIfReturnsSwitchedOff(Rec."Shopify Store Code");
                        SpfyLegacyReturnMgt.ErrorIfBeingProcessed(Rec);
                        if not SpfyLegacyReturnProcessJQ.ProcessRow(Rec) then
                            Message(NotClaimedMsg, SpfyLegacyReturnAPI.DocumentCaption(Rec."Source Doc. Type", Rec."Source Doc. Name", Rec."Source Doc. ID"));
                    end;
                    CurrPage.Update(false);
                end;
            }
            action(DiscardDraftAndRetry)
            {
                Caption = 'Discard Draft and Retry';
                Image = Restore;
                ToolTip = 'Delete the Sales Return Order created for this row and queue it again from the start. This also queues a dismissed row again.';
                ApplicationArea = NPRShopify;
                trigger OnAction()
                var
                    SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
                begin
                    SpfyLegacyReturnMgt.ErrorIfEcommerceFeatureEnabled();
                    Rec.Get(Rec."Entry No.");
                    SpfyLegacyReturnMgt.DiscardDraft(Rec);
                    Rec.Validate(Status, Rec.Status::New);
                    Rec."Retry Count" := 0;
                    Rec."Last Error" := '';
                    Rec.Modify();
                    CurrPage.Update(false);
                end;
            }
            action(DismissReturn)
            {
                Caption = 'Dismiss';
                Image = Cancel;
                ToolTip = 'Mark the return or refund as handled outside this import. The row is kept and cannot be deleted, so it is not queued again; Discard Draft and Retry queues it again.';
                ApplicationArea = NPRShopify;
                trigger OnAction()
                var
                    SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
                begin
                    Rec.Get(Rec."Entry No.");
                    SpfyLegacyReturnMgt.DismissReturn(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(OpenDocument)
            {
                Caption = 'Open Document';
                Image = Document;
                ToolTip = 'Open the Sales Return Order, or the posted credit memo or return receipt once posted.';
                ApplicationArea = NPRShopify;
                trigger OnAction()
                var
                    SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
                begin
                    SpfyLegacyReturnMgt.OpenRelatedDocument(Rec);
                end;
            }
            action(OpenVoucher)
            {
                Caption = 'Open Voucher';
                Image = Voucher;
                ToolTip = 'Open the retail voucher this return or refund credits back to, or its archived copy while the card is still archived.';
                ApplicationArea = NPRShopify;
                Enabled = Rec."Refund Voucher No." <> '';
                trigger OnAction()
                var
                    Voucher: Record "NPR NpRv Voucher";
                    ArchVoucher: Record "NPR NpRv Arch. Voucher";
                begin
                    Rec.CalcFields("Refund Voucher No.");
                    if Voucher.Get(Rec."Refund Voucher No.") then begin
                        Page.Run(Page::"NPR NpRv Voucher Card", Voucher);
                        exit;
                    end;
                    // A spent card sits in the archive until the posting restores it; the archive may hold it under a number of its own series.
                    ArchVoucher.SetRange("Arch. No.", Rec."Refund Voucher No.");
                    if not ArchVoucher.FindFirst() then
                        ArchVoucher.Get(Rec."Refund Voucher No.");
                    Page.Run(Page::"NPR NpRv Arch. Voucher Card", ArchVoucher);
                end;
            }
        }
        area(Promoted)
        {
            actionref(PollNow_Promoted; PollNow) { }
            actionref(ProcessRow_Promoted; ProcessRow) { }
            actionref(DiscardDraftAndRetry_Promoted; DiscardDraftAndRetry) { }
            actionref(DismissReturn_Promoted; DismissReturn) { }
            actionref(OpenDocument_Promoted; OpenDocument) { }
            actionref(OpenVoucher_Promoted; OpenVoucher) { }
        }
    }

    trigger OnAfterGetRecord()
    begin
        case Rec.Status of
            Rec.Status::Error:
                _StatusStyle := 'Unfavorable';
            Rec.Status::Imported:
                _StatusStyle := 'Favorable';
            Rec.Status::"Draft Created":
                _StatusStyle := 'Ambiguous';
            Rec.Status::Dismissed:
                _StatusStyle := 'Subordinate';
            Rec.Status::Waiting:
                _StatusStyle := 'StandardAccent';
            Rec.Status::"Nothing to Credit":
                _StatusStyle := 'Favorable';
            else
                _StatusStyle := 'Standard';
        end;
    end;

    var
        _StatusStyle: Text;
}
