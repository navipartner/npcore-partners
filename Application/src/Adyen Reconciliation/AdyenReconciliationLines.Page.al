page 6184503 "NPR Adyen Reconciliation Lines"
{
    Extensible = false;

    UsageCategory = Documents;
    ApplicationArea = NPRRetail;
    Caption = 'Adyen Reconciliation Lines';
    SourceTable = "NPR Adyen Reconciliation Line";
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
                    ToolTip = 'Specifies the Payment Fees Total Amount (AAC). Must be a total of Commission, Markup, Scheme Fee and Intercharge.';
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
                field("Intercharge (NC)"; Rec."Intercharge (NC)")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Intercharge Amount (AAC).';
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
                    ToolTip = 'Specifies the Transaction Entry No.';
                    StyleExpr = _StyleExprTxt;
                    Editable = ((Rec.Status = Rec.Status::"Failed to Match") or (Rec.Status = Rec.Status::"Matched Manually") and (Rec."Matching Table Name" <> Rec."Matching Table Name"::"Magento Payment Line"));
                    AssistEdit = true;
                    Lookup = false;

                    trigger OnAssistEdit()
                    var
                        EFTTransactions: Page "NPR EFT Transaction Requests";
                        EFTTransaction: Record "NPR EFT Transaction Request";
                        GLEntry: Record "G/L Entry";
                        GLEntries: Page "General Ledger Entries";
                    begin
                        case Rec."Matching Table Name" of
                            Rec."Matching Table Name"::"EFT Transaction":
                                begin
                                    EFTTransaction.FilterGroup(2);
                                    EFTTransaction.SetRange(Reconciled, false);
                                    EFTTransactions.SetTableView(EFTTransaction);
                                    EFTTransactions.LookupMode := true;
                                    if EFTTransactions.RunModal() = Action::LookupOK then begin
                                        Rec.Status := Rec.Status::"Matched Manually";
                                        EFTTransaction.Reset();
                                        EFTTransactions.SetSelectionFilter(EFTTransaction);
                                        if EFTTransaction.FindFirst() then
                                            Rec."Matching Entry System ID" := EFTTransaction.SystemId;
                                        Rec.Modify();
                                    end;
                                    EFTTransaction.FilterGroup(0);
                                end;
                            Rec."Matching Table Name"::"G/L Entry":
                                begin
                                    GLEntries.LookupMode := true;
                                    if GLEntries.RunModal() = Action::LookupOK then begin
                                        Rec.Status := Rec.Status::"Matched Manually";
                                        GLEntries.SetSelectionFilter(GLEntry);
                                        if GLEntry.FindFirst() then
                                            Rec."Matching Entry System ID" := GLEntry.SystemId;
                                        Rec.Modify();
                                    end;
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
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Navigate to Origin...")
            {
                ApplicationArea = NPRRetail;
                Ellipsis = true;
                Image = Navigate;
                Caption = 'Navigate to Origin...';
                ToolTip = 'Running this action will open the original entry.';

                trigger OnAction()
                var
                    EFTTransaction: Record "NPR EFT Transaction Request";
                    MagentoPaymentLine: Record "NPR Magento Payment Line";
                    GLEntry: Record "G/L Entry";
                    ReconciliationLine: Record "NPR Adyen Reconciliation Line";
                begin
                    CurrPage.SetSelectionFilter(ReconciliationLine);
                    if ReconciliationLine.FindFirst() then begin
                        case ReconciliationLine."Matching Table Name" of
                            ReconciliationLine."Matching Table Name"::"EFT Transaction":
                                begin
                                    if (not IsNullGuid(ReconciliationLine."Matching Entry System ID")) then begin
                                        EFTTransaction.Reset();
                                        EFTTransaction.GetBySystemId(ReconciliationLine."Matching Entry System ID");
                                        Page.Run(Page::"NPR EFT Transaction Requests", EFTTransaction);
                                    end;
                                end;
                            ReconciliationLine."Matching Table Name"::"G/L Entry":
                                begin
                                    if (not IsNullGuid(ReconciliationLine."Matching Entry System ID")) then begin
                                        GLEntry.Reset();
                                        GLEntry.GetBySystemId(ReconciliationLine."Matching Entry System ID");
                                        Page.Run(Page::"General Ledger Entries", GLEntry);
                                    end;
                                end;
                            ReconciliationLine."Matching Table Name"::"Magento Payment Line":
                                begin
                                    if (ReconciliationLine."Matching Entry System ID" > '') then begin
                                        MagentoPaymentLine.Reset();
                                        MagentoPaymentLine.GetBySystemId(ReconciliationLine."Matching Entry System ID");
                                        Page.Run(Page::"NPR Magento Payment Line List", MagentoPaymentLine);
                                    end;
                                end;
                        end;
                    end;
                end;
            }
            action("Find Posted Entries...")
            {
                ApplicationArea = NPRRetail;
                Ellipsis = true;
                Image = Navigate;
                Caption = 'Find Posted Entries...';
                ToolTip = 'Running this action will find posted entries.';

                trigger OnAction()
                var
                    AdyenMerchantSetup: Record "NPR Adyen Merchant Setup";
                    GLEntry: Record "G/L Entry";
                    ReconciliationLine: Record "NPR Adyen Reconciliation Line";
                begin
                    CurrPage.SetSelectionFilter(ReconciliationLine);
                    if ReconciliationLine.FindFirst() and (ReconciliationLine.Status = ReconciliationLine.Status::Posted) then begin

                        case ReconciliationLine."Matching Table Name" of
                            ReconciliationLine."Matching Table Name"::"EFT Transaction":
                                begin
                                    GLEntry.Reset();
                                    GLEntry.FilterGroup(0);
                                    GLEntry.SetRange("Document No.", ReconciliationLine."PSP Reference");
                                    GLEntry.SetRange("Document Type", GLEntry."Document Type"::" ");
                                    if AdyenMerchantSetup.Get(ReconciliationLine."Merchant Account") then
                                        GLEntry.SetRange("Source Code", AdyenMerchantSetup."Posting Source Code");
                                    GLEntry.FilterGroup(2);
                                    Page.Run(Page::"General Ledger Entries", GLEntry);
                                end;
                            ReconciliationLine."Matching Table Name"::"G/L Entry":
                                begin
                                    GLEntry.Reset();
                                    GLEntry.FilterGroup(0);
                                    GLEntry.SetFilter("Document No.", ReconciliationLine."Document No.");
                                    GLEntry.FilterGroup(2);
                                    Page.Run(Page::"General Ledger Entries", GLEntry);
                                end;
                            ReconciliationLine."Matching Table Name"::"Magento Payment Line":
                                begin
                                    GLEntry.Reset();
                                    GLEntry.FilterGroup(0);
                                    GLEntry.SetRange("Document No.", ReconciliationLine."PSP Reference");
                                    GLEntry.SetRange("Document Type", GLEntry."Document Type"::" ");
                                    if AdyenMerchantSetup.Get(ReconciliationLine."Merchant Account") then
                                        GLEntry.SetRange("Source Code", AdyenMerchantSetup."Posting Source Code");
                                    GLEntry.FilterGroup(2);
                                    Page.Run(Page::"General Ledger Entries", GLEntry);
                                end;
                        end;
                    end;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        _StyleExprTxt := _AdyenManagement.ChangeColorLine(Rec);
    end;

    var
        _StyleExprTxt: Text[50];
        _AdyenManagement: Codeunit "NPR Adyen Management";
}
