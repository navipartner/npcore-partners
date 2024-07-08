page 6184503 "NPR Adyen Reconciliation Lines"
{
    Extensible = false;

    UsageCategory = None;
    Caption = 'Adyen Reconciliation Lines';
    SourceTable = "NPR Adyen Recon. Line";
    SourceTableView = sorting(Status) order(ascending);
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

                    trigger OnValidate()
                    begin
                        _StyleExprTxt := _AdyenManagement.ChangeColorLine(Rec);
                    end;
                }

                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Transaction Type.';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        _StyleExprTxt := _AdyenManagement.ChangeColorLine(Rec);
                    end;
                }
                field("Merchant Reference"; Rec."Merchant Reference")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Merchant Reference.';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        _StyleExprTxt := _AdyenManagement.ChangeColorLine(Rec);
                    end;
                }
                field("Amount (TCY)"; Rec."Amount (TCY)")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Trasnaction Currency Amount.';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        _StyleExprTxt := _AdyenManagement.ChangeColorLine(Rec);
                    end;
                }
                field("Transaction Currency Code"; Rec."Transaction Currency Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Trasnaction Currency Code.';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        _StyleExprTxt := _AdyenManagement.ChangeColorLine(Rec);
                    end;
                }
                field("Amount (AAC)"; Rec."Amount(AAC)")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Adyen Account Currency Amount.';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        _StyleExprTxt := _AdyenManagement.ChangeColorLine(Rec);
                    end;
                }
                field("Adyen Acc. Currency Code"; Rec."Adyen Acc. Currency Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Adyen Account Currency Code.';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        _StyleExprTxt := _AdyenManagement.ChangeColorLine(Rec);
                    end;
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Transaction Amount (LCY).';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        _StyleExprTxt := _AdyenManagement.ChangeColorLine(Rec);
                    end;
                }
                field("Matching Table Name"; Rec."Matching Table Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Transaction Matching Table.';
                    StyleExpr = _StyleExprTxt;
                    Editable = (Rec.Status = Rec.Status::"Failed to Match") or (Rec.Status = Rec.Status::"Matched Manually");

                    trigger OnValidate()
                    begin
                        _StyleExprTxt := _AdyenManagement.ChangeColorLine(Rec);
                    end;
                }
                field("Matching Entry No."; Rec."Matching Entry System ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Transaction Entry System ID';
                    StyleExpr = _StyleExprTxt;
                    Editable = (Rec.Status = Rec.Status::"Failed to Match") or (Rec.Status = Rec.Status::"Matched Manually");
                    AssistEdit = true;
                    Lookup = false;

                    trigger OnAssistEdit()
                    var
                        EFTTransactions: Page "NPR EFT Transaction Requests";
                        EFTTransaction: Record "NPR EFT Transaction Request";
                        MagentoPaymentLine: Record "NPR Magento Payment Line";
                        MagentoPaymentLines: Page "NPR Magento Payment Line List";
                        GLEntry: Record "G/L Entry";
                        GLEntries: Page "General Ledger Entries";
                    begin
                        case Rec."Matching Table Name" of
                            Rec."Matching Table Name"::"EFT Transaction":
                                begin
                                    EFTTransaction.FilterGroup(2);
                                    EFTTransaction.SetRange(Reconciled, false);
                                    EFTTransaction.FilterGroup(0);
                                    EFTTransactions.SetTableView(EFTTransaction);
                                    EFTTransactions.SetRecord(EFTTransaction);
                                    if (Rec.Status = Rec.Status::"Failed to Match") or (Rec.Status = Rec.Status::"Matched Manually") then begin
                                        EFTTransactions.LookupMode := true;
                                        if EFTTransactions.RunModal() = Action::LookupOK then begin
                                            Rec.Status := Rec.Status::"Matched Manually";
                                            EFTTransactions.SetSelectionFilter(EFTTransaction);
                                            if EFTTransaction.FindFirst() then
                                                Rec."Matching Entry System ID" := EFTTransaction.SystemId;
                                            Rec.Modify();
                                        end;
                                    end else
                                        EFTTransactions.RunModal();

                                end;
                            Rec."Matching Table Name"::"Magento Payment Line":
                                begin
                                    MagentoPaymentLine.FilterGroup(2);
                                    MagentoPaymentLine.SetRange(Reconciled, false);
                                    MagentoPaymentLine.FilterGroup(0);
                                    MagentoPaymentLines.SetTableView(MagentoPaymentLine);
                                    MagentoPaymentLines.SetRecord(MagentoPaymentLine);
                                    if (Rec.Status = Rec.Status::"Failed to Match") or (Rec.Status = Rec.Status::"Matched Manually") then begin
                                        MagentoPaymentLines.LookupMode := true;
                                        if MagentoPaymentLines.RunModal() = Action::LookupOK then begin
                                            Rec.Status := Rec.Status::"Matched Manually";
                                            MagentoPaymentLine.Reset();
                                            MagentoPaymentLines.SetSelectionFilter(MagentoPaymentLine);
                                            if MagentoPaymentLine.FindFirst() then
                                                Rec."Matching Entry System ID" := MagentoPaymentLine.SystemId;
                                            Rec.Modify();
                                        end;
                                    end else
                                        MagentoPaymentLines.RunModal();
                                end;
                            Rec."Matching Table Name"::"G/L Entry":
                                begin
                                    if (Rec.Status = Rec.Status::"Failed to Match") or (Rec.Status = Rec.Status::"Matched Manually") then begin
                                        GLEntries.LookupMode := true;
                                        if GLEntries.RunModal() = Action::LookupOK then begin
                                            Rec.Status := Rec.Status::"Matched Manually";
                                            GLEntries.SetSelectionFilter(GLEntry);
                                            if GLEntry.FindFirst() then
                                                Rec."Matching Entry System ID" := GLEntry.SystemId;
                                            Rec.Modify();
                                        end;
                                    end else
                                        GLEntries.RunModal();
                                end;
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        _StyleExprTxt := _AdyenManagement.ChangeColorLine(Rec);
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

                    trigger OnValidate()
                    begin
                        _StyleExprTxt := _AdyenManagement.ChangeColorLine(Rec);
                    end;
                }
                field("Payment Fees (NC)"; Rec."Payment Fees (NC)")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Payment Fees Total Amount (AAC). Must be a total of Commission, Markup, Scheme Fee and Interchange.';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        _StyleExprTxt := _AdyenManagement.ChangeColorLine(Rec);
                    end;
                }
                field("Commission (NC)"; Rec."Commission (NC)")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Commission Amount (AAC).';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        _StyleExprTxt := _AdyenManagement.ChangeColorLine(Rec);
                    end;
                }
                field("Scheme Fees (NC)"; Rec."Scheme Fees (NC)")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Scheme Fees Amount (AAC).';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        _StyleExprTxt := _AdyenManagement.ChangeColorLine(Rec);
                    end;
                }
                field("Interchange (NC)"; Rec."Interchange (NC)")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Interchange Amount (AAC).';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        _StyleExprTxt := _AdyenManagement.ChangeColorLine(Rec);
                    end;
                }
                field("Realized Gains or Losses"; Rec."Realized Gains or Losses")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Realized Gains or Losses Amount (AAC)';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        _StyleExprTxt := _AdyenManagement.ChangeColorLine(Rec);
                    end;
                }
                field("Posting allowed"; Rec."Posting allowed")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the Posting is allowed.';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        _StyleExprTxt := _AdyenManagement.ChangeColorLine(Rec);
                    end;
                }
                field("Posting No."; Rec."Posting No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Posting No.';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        _StyleExprTxt := _AdyenManagement.ChangeColorLine(Rec);
                    end;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Posting Date.';
                    StyleExpr = _StyleExprTxt;
                    Editable = false;

                    trigger OnValidate()
                    begin
                        _StyleExprTxt := _AdyenManagement.ChangeColorLine(Rec);
                    end;
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
                    MagentoPaymentLine: Record "NPR Magento Payment Line";
                    GLEntry: Record "G/L Entry";
                begin
                    if (not IsNullGuid(Rec."Matching Entry System ID")) then begin
                        case Rec."Matching Table Name" of
                            Rec."Matching Table Name"::"EFT Transaction":
                                begin
                                    if EFTTransaction.GetBySystemId(Rec."Matching Entry System ID") then
                                        Page.RunModal(Page::"NPR EFT Transaction Requests", EFTTransaction);
                                end;
                            Rec."Matching Table Name"::"G/L Entry":
                                begin
                                    if GLEntry.GetBySystemId(Rec."Matching Entry System ID") then
                                        Page.RunModal(Page::"General Ledger Entries", GLEntry);
                                end;
                            Rec."Matching Table Name"::"Magento Payment Line":
                                begin
                                    if MagentoPaymentLine.GetBySystemId(Rec."Matching Entry System ID") then
                                        Page.RunModal(Page::"NPR Magento Payment Line List", MagentoPaymentLine);
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
                    Header: Record "NPR Adyen Reconciliation Hdr";
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

                    Line.FindSet();
                    if not Header.Get(Line."Document No.") then
                        exit;
                    if not Confirm(ConfirmPostingLbl) then
                        exit;

                    Clear(AdyenTransMatching);
                    PostedEntries := AdyenTransMatching.PostUnmatchedEntries(Line, Header);

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
