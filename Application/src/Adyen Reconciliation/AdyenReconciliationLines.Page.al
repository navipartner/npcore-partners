page 6184503 "NPR Adyen Reconciliation Lines"
{
    Extensible = false;

    UsageCategory = None;
    Caption = 'NP Pay Reconciliation Lines';
    SourceTable = "NPR Adyen Recon. Line";
    AutoSplitKey = true;
    DelayedInsert = true;
    LinksAllowed = false;
    PageType = ListPart;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Transaction Date"; Rec."Transaction Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Transaction Date.';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;
                }

                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Transaction Type.';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;
                }
                field("Merchant Reference"; Rec."Merchant Reference")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Merchant Reference.';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;
                }
                field("Amount (TCY)"; Rec."Amount (TCY)")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Trasnaction Currency Amount.';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;
                }
                field("Transaction Currency Code"; Rec."Transaction Currency Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Trasnaction Currency Code.';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;
                }
                field("Amount (AAC)"; Rec."Amount(AAC)")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Acquirer Account Currency Amount.';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;
                }
                field("Adyen Acc. Currency Code"; Rec."Adyen Acc. Currency Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Acquirer Account Currency Code.';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Transaction Amount (LCY).';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;
                }
                field("Matching Table Name"; Rec."Matching Table Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Transaction Matching Table.';
                    StyleExpr = _StyleExprTxt;
                    Editable = (Rec.Status = Rec.Status::"Failed to Match") or
                        (((Rec.Status = Rec.Status::Matched) or (Rec.Status = Rec.Status::"Failed to Post")) and Rec."Matched Manually");
                }
                field("Matching Entry No."; Rec."Matching Entry System ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Transaction Entry System ID';
                    StyleExpr = _StyleExprTxt;
                    Editable = (Rec.Status = Rec.Status::"Failed to Match") or
                        (((Rec.Status = Rec.Status::Matched) or (Rec.Status = Rec.Status::"Failed to Post")) and Rec."Matched Manually");
                    AssistEdit = true;
                    Lookup = false;

                    trigger OnAssistEdit()
                    var
                        EFTTransactions: Page "NPR EFT Transaction Requests";
                        EFTTransaction: Record "NPR EFT Transaction Request";
                        MagentoPaymentLine: Record "NPR Magento Payment Line";
                        MagentoPaymentLines: Page "NPR Magento Payment Line List";
                        SubscrPaymentRequests: Page "NPR MM Subscr.Payment Requests";
                        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
                        PaymentGateway: Record "NPR Magento Payment Gateway";
                        AdyenTransMatching: Codeunit "NPR Adyen Trans. Matching";
                        FilterPGCodes: Text;
                    begin
                        case Rec."Matching Table Name" of
                            Rec."Matching Table Name"::"EFT Transaction":
                                begin
                                    if _AdyenManagement.ManualMatchingAllowed(Rec) then begin
                                        EFTTransaction.FilterGroup(2);
                                        _AdyenManagement.SetEFTAdyenIntegrationFilter(EFTTransaction);
                                        if not (Rec."Transaction Type" in
                                            [Rec."Transaction Type"::Chargeback,
                                            Rec."Transaction Type"::SecondChargeback,
                                            Rec."Transaction Type"::RefundedReversed,
                                            Rec."Transaction Type"::ChargebackReversed,
                                            Rec."Transaction Type"::ChargebackReversedExternallyWithInfo])
                                        then
                                            EFTTransaction.SetRange(Reconciled, false)
                                        else
                                            EFTTransaction.SetRange(Reversed, false);
                                        EFTTransaction.FilterGroup(0);
                                        EFTTransactions.SetTableView(EFTTransaction);
                                        if not IsNullGuid(Rec."Matching Entry System ID") then
                                            if EFTTransaction.GetBySystemId(Rec."Matching Entry System ID") then
                                                if EFTTransaction.Find('=><') then
                                                    EFTTransactions.SetRecord(EFTTransaction);
                                        EFTTransactions.LookupMode := true;
                                        if EFTTransactions.RunModal() = Action::LookupOK then begin
                                            EFTTransactions.GetRecord(EFTTransaction);
                                            if AdyenTransMatching.EFTMatchingAllowed(EFTTransaction, Rec, false) then begin
                                                Rec."Matching Entry System ID" := EFTTransaction.SystemId;
                                                Rec.Status := Rec.Status::Matched;
                                                Rec."Matched Manually" := true;
                                                Rec.Modify();
                                            end;
                                        end;
                                    end else
                                        EFTTransactions.RunModal();
                                end;
                            Rec."Matching Table Name"::"Magento Payment Line":
                                begin
                                    if _AdyenManagement.ManualMatchingAllowed(Rec) then begin
                                        PaymentGateway.Reset();
                                        PaymentGateway.SetRange("Integration Type", Enum::"NPR PG Integrations"::Adyen);
                                        PaymentGateway.FindSet();
                                        repeat
                                            FilterPGCodes += PaymentGateway.Code + '|';
                                        until PaymentGateway.Next() = 0;
                                        if StrLen(FilterPGCodes) > 0 then
                                            FilterPGCodes := FilterPGCodes.TrimEnd('|');

                                        MagentoPaymentLine.FilterGroup(2);
                                        MagentoPaymentLine.SetFilter("Payment Gateway Code", FilterPGCodes);
                                        if not (Rec."Transaction Type" in
                                            [Rec."Transaction Type"::Chargeback,
                                            Rec."Transaction Type"::SecondChargeback,
                                            Rec."Transaction Type"::RefundedReversed,
                                            Rec."Transaction Type"::ChargebackReversed,
                                            Rec."Transaction Type"::ChargebackReversedExternallyWithInfo])
                                        then
                                            MagentoPaymentLine.SetRange(Reconciled, false)
                                        else
                                            MagentoPaymentLine.SetRange(Reversed, false);
                                        MagentoPaymentLine.FilterGroup(0);
                                        MagentoPaymentLines.SetTableView(MagentoPaymentLine);
                                        if not IsNullGuid(Rec."Matching Entry System ID") then
                                            if MagentoPaymentLine.GetBySystemId(Rec."Matching Entry System ID") then
                                                if MagentoPaymentLine.Find('=><') then
                                                    MagentoPaymentLines.SetRecord(MagentoPaymentLine);
                                        MagentoPaymentLines.LookupMode := true;
                                        if MagentoPaymentLines.RunModal() = Action::LookupOK then begin
                                            MagentoPaymentLines.GetRecord(MagentoPaymentLine);
                                            if AdyenTransMatching.MagentoMatchingAllowed(MagentoPaymentLine, Rec, false) then begin
                                                Rec."Matching Entry System ID" := MagentoPaymentLine.SystemId;
                                                Rec.Status := Rec.Status::Matched;
                                                Rec."Matched Manually" := true;
                                                Rec.Modify();
                                            end;
                                        end;
                                    end else
                                        MagentoPaymentLines.RunModal();
                                end;
                            Rec."Matching Table Name"::"Subscription Payment":
                                begin
                                    if _AdyenManagement.ManualMatchingAllowed(Rec) then begin
                                        SubscrPaymentRequest.FilterGroup(2);
                                        SubscrPaymentRequest.SetRange(PSP, Enum::"NPR MM Subscription PSP"::Adyen);
                                        if not (Rec."Transaction Type" in
                                            [Rec."Transaction Type"::Chargeback,
                                            Rec."Transaction Type"::SecondChargeback,
                                            Rec."Transaction Type"::RefundedReversed,
                                            Rec."Transaction Type"::ChargebackReversed,
                                            Rec."Transaction Type"::ChargebackReversedExternallyWithInfo])
                                        then
                                            SubscrPaymentRequest.SetRange(Reconciled, false)
                                        else
                                            SubscrPaymentRequest.SetRange(Reversed, false);
                                        SubscrPaymentRequest.FilterGroup(0);
                                        SubscrPaymentRequests.SetTableView(SubscrPaymentRequest);
                                        if not IsNullGuid(Rec."Matching Entry System ID") then
                                            if SubscrPaymentRequest.GetBySystemId(Rec."Matching Entry System ID") then
                                                if SubscrPaymentRequest.Find('=><') then
                                                    SubscrPaymentRequests.SetRecord(SubscrPaymentRequest);
                                        SubscrPaymentRequests.LookupMode := true;
                                        if SubscrPaymentRequests.RunModal() = Action::LookupOK then begin
                                            SubscrPaymentRequests.GetRecord(SubscrPaymentRequest);
                                            if AdyenTransMatching.SubscriptionMatchingAllowed(SubscrPaymentRequest, Rec, false) then begin
                                                Rec."Matching Entry System ID" := SubscrPaymentRequest.SystemId;
                                                Rec.Status := Rec.Status::Matched;
                                                Rec."Matched Manually" := true;
                                                Rec.Modify();
                                            end;
                                        end;
                                    end else
                                        SubscrPaymentRequests.RunModal();
                                end;
                        end;
                    end;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Transaction Status.';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        _StyleExprTxt := _AdyenManagement.ChangeColorLine(Rec);
                    end;
                }
                field("Markup (NC)"; Rec."Markup (NC)")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Markup Amount (AAC).';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;
                }
                field("Payment Fees (NC)"; Rec."Payment Fees (NC)")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Payment Fees Total Amount (AAC). Must be a total of Commission, Markup, Scheme Fee and Interchange.';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;
                }
                field("Commission (NC)"; Rec."Commission (NC)")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Commission Amount (AAC).';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;
                }
                field("Scheme Fees (NC)"; Rec."Scheme Fees (NC)")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Scheme Fees Amount (AAC).';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;
                }
                field("Interchange (NC)"; Rec."Interchange (NC)")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Interchange Amount (AAC).';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;
                }
                field("Realized Gains or Losses"; Rec."Realized Gains or Losses")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Realized Gains or Losses Amount (AAC)';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;
                }
                field("Posting allowed"; Rec."Posting allowed")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the Posting is allowed.';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;
                }
                field("Posting No."; Rec."Posting No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Posting No.';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Posting Date.';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;
                }
                field("Payment Method"; Rec."Payment Method")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Payment Method of the transaction.';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;
                }
                field("Payment Method Variant"; Rec."Payment Method Variant")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Payment Method Variant of the transaction.';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Show Original Entry")
            {
                ApplicationArea = NPRRetail;
                Ellipsis = true;
                Image = Navigate;
                Caption = 'Show Original Entry';
                ToolTip = 'Running this action will show the original entry.';

                trigger OnAction()
                var
                    EFTTransaction: Record "NPR EFT Transaction Request";
                    SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
                    MagentoPaymentLine: Record "NPR Magento Payment Line";
                    GLEntry: Record "G/L Entry";
                begin
                    if (not IsNullGuid(Rec."Matching Entry System ID")) then begin
                        case Rec."Matching Table Name" of
                            Rec."Matching Table Name"::"EFT Transaction":
                                begin
                                    EFTTransaction.FilterGroup(2);
                                    EFTTransaction.SetRange(SystemId, Rec."Matching Entry System ID");
                                    EFTTransaction.FilterGroup(0);
                                    Page.Run(Page::"NPR EFT Transaction Requests", EFTTransaction);
                                end;
                            Rec."Matching Table Name"::"G/L Entry":
                                begin
                                    GLEntry.FilterGroup(2);
                                    GLEntry.SetRange(SystemId, Rec."Matching Entry System ID");
                                    GLEntry.FilterGroup(0);
                                    Page.Run(Page::"General Ledger Entries", GLEntry);
                                end;
                            Rec."Matching Table Name"::"Magento Payment Line":
                                begin
                                    MagentoPaymentLine.FilterGroup(2);
                                    MagentoPaymentLine.SetRange(SystemId, Rec."Matching Entry System ID");
                                    MagentoPaymentLine.FilterGroup(0);
                                    Page.Run(Page::"NPR Magento Payment Line List", MagentoPaymentLine);
                                end;
                            Rec."Matching Table Name"::"Subscription Payment":
                                begin
                                    SubscrPaymentRequest.FilterGroup(2);
                                    SubscrPaymentRequest.SetRange(SystemId, Rec."Matching Entry System ID");
                                    SubscrPaymentRequest.FilterGroup(0);
                                    Page.Run(Page::"NPR MM Subscr.Payment Requests", SubscrPaymentRequest);
                                end;
                        end;
                    end;
                end;
            }
            action("Find Posted Entries...")
            {
                ApplicationArea = NPRRetail;
                Image = Navigate;
                Caption = 'Show Posted Amounts';
                ToolTip = 'Running this action will show posted amounts by amount type.';
                RunObject = Page "NPR Adyen Recon. Line Relation";
                RunPageLink = "Document No." = field("Document No."),
                                "Document Line No." = field("Line No.");
            }
            action("Confirm awareness")
            {
                ApplicationArea = NPRRetail;
                Enabled = _IsChargeBack;
                Image = Confirm;
                Caption = 'Confirm Awareness';
                ToolTip = 'Running this action will confirm that you are aware of a chargeback entry and unlock it for posting.';

                trigger OnAction()
                var
                    ConfirmAwarenessLbl: Label 'Do you wish to proceed with confirming your awareness of the selected Chargeback/Chargebacks?';
                    Lines: Record "NPR Adyen Recon. Line";
                begin
                    CurrPage.SetSelectionFilter(Lines);
                    Lines.SetRange("Posting allowed", false);
                    Lines.SetFilter("Transaction Type", '%1|%2|%3', Lines."Transaction Type"::Chargeback, Lines."Transaction Type"::ChargebackExternallyWithInfo, Lines."Transaction Type"::SecondChargeback);
                    if not Lines.IsEmpty() then
                        if Confirm(ConfirmAwarenessLbl) then begin
                            Lines.ModifyAll("Posting allowed", true);
                            CurrPage.Update(false);
                        end;
                end;
            }
            action("Post as Missing")
            {
                ApplicationArea = NPRRetail;
                Enabled = _IsMissing;
                Image = Post;
                Caption = 'Post as Missing';
                ToolTip = 'Running this action will post the Failed to Match transaction skipping the Matching process.';

                trigger OnAction()
                var
                    AdyenTransMatching: Codeunit "NPR Adyen Trans. Matching";
                    Line: Record "NPR Adyen Recon. Line";
                    PostedEntries: Integer;
                    ConfirmPostingLbl: Label 'Do you wish to proceed with posting selected transaction/s skipping the matching process?';
                    SuccessfullyPostedLbl: Label 'Successfully posted %1 entries bypassing the Matching process.';
                    NothingToPostLbl: Label 'Nothing to post.';
                begin
                    CurrPage.SetSelectionFilter(Line);
                    Line.FilterGroup(10);
                    Line.SetRange(Status, Line.Status::"Failed to Match");
                    Line.FilterGroup(0);
                    if Line.IsEmpty() then begin
                        Message(NothingToPostLbl);
                        exit;
                    end;
                    if not Confirm(ConfirmPostingLbl) then
                        exit;

                    Clear(AdyenTransMatching);
                    PostedEntries := AdyenTransMatching.PostUnmatchedEntries(Line);

                    if PostedEntries > 0 then begin
                        Message(SuccessfullyPostedLbl, Format(PostedEntries));
                        CurrPage.Update(false);
                    end else
                        Message(GetLastErrorText());
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        _IsChargeBack := Rec."Transaction Type" in [Rec."Transaction Type"::Chargeback, Rec."Transaction Type"::ChargebackExternallyWithInfo, Rec."Transaction Type"::SecondChargeback];
        _IsMissing := (Rec.Status = Rec.Status::"Failed to Match") and (IsNullGuid(Rec."Matching Entry System ID"));
    end;

    trigger OnAfterGetRecord()
    begin
        _StyleExprTxt := _AdyenManagement.ChangeColorLine(Rec);
    end;

    var
        _StyleExprTxt: Text[50];
        _AdyenManagement: Codeunit "NPR Adyen Management";
        _IsChargeBack: Boolean;
        _IsMissing: Boolean;
}
