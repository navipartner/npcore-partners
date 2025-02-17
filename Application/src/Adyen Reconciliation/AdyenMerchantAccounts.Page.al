page 6184552 "NPR Adyen Merchant Accounts"
{
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    Caption = 'NP Pay Merchant Accounts';
    RefreshOnActivate = true;
    PageType = List;
    SourceTable = "NPR Adyen Merchant Account";
    Editable = false;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Company ID"; Rec."Company ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Company ID.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the NP Pay Merchant Account Name.';
                }
                field(PostingSourceCode; _MerchantAccountSetup."Posting Source Code")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Posting Source Code';
                    ToolTip = 'Specifies the Posting Source Code.';
                }
                field(MerchantPayoutAccType; _MerchantAccountSetup."Merchant Payout Acc. Type")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Merchant Payout Acc. Type';
                    ToolTip = 'Specifies the Merchant Payout Acc. Type.';
                }
                field(MerchantPayoutAccountNo; _MerchantAccountSetup."Merchant Payout Acc. No.")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Merchant Payout Account No.';
                    ToolTip = 'Specifies the Merchant Payout Account No.';
                }
                field(AcquirerPayoutAccType; _MerchantAccountSetup."Acquirer Payout Acc. Type")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Acquire Payout Acc. Type';
                    ToolTip = 'Specifies the Acquire Payout Acc. Type.';
                }
                field(AcquirerAccountNo; _MerchantAccountSetup."Acquirer Payout Acc. No.")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Acquirer Account No.';
                    ToolTip = 'Specifies the Acquirer Account No.';
                }
                field(ReconciledPaymentAccType; _MerchantAccountSetup."Reconciled Payment Acc. Type")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Reconciled Payment Acc. Type';
                    ToolTip = 'Specifies the Reconciled Payment Acc. Type.';
                }
                field(ReconciledPaymentAccountNo; _MerchantAccountSetup."Reconciled Payment Acc. No.")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Reconciled Payment Account No.';
                    ToolTip = 'Specifies the Reconciled Payment Account No.';
                }
                field(MissingTransactionAccType; _MerchantAccountSetup."Missing Transaction Acc. Type")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Missing Transaction Acc. Type';
                    ToolTip = 'Specifies the Missing Transaction Acc. Type.';
                }
                field(MissingTransactionAccountNo; _MerchantAccountSetup."Missing Transaction Acc. No.")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Missing Transaction Account No.';
                    ToolTip = 'Specifies the Missing Transaction Account No.';
                }
                field(FeeGLAccount; _MerchantAccountSetup."Fee G/L Account")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Fee G/L Account No.';
                    ToolTip = 'Specifies the Fee G/L Account No.';
                }
                field(DepositGLAccount; _MerchantAccountSetup."Deposit G/L Account")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Deposit G/L Account No.';
                    ToolTip = 'Specifies the Deposit G/L Account No.';
                }
                field(MarkupGLAccount; _MerchantAccountSetup."Markup G/L Account")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Markup G/L Account No.';
                    ToolTip = 'Specifies the Markup G/L Account No.';
                }
                field(OtherCommGLAccount; _MerchantAccountSetup."Other commissions G/L Account")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Other commissions G/L Account No.';
                    ToolTip = 'Specifies the Other commissions G/L Account No.';
                }
                field(InvoiceDeductGLAccount; _MerchantAccountSetup."Invoice Deduction G/L Account")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Invoice Deducttion G/L Account No.';
                    ToolTip = 'Specifies the Invoice Deducttion G/L Account No.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Update List")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Update List';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Refresh;
                ToolTip = 'Running this action will refresh Merchant Account List.';

                trigger OnAction()
                begin
                    if _AdyenManagement.UpdateMerchantList(0) then
                        CurrPage.Update(false);
                end;
            }
            action("Open Setup")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Open Setup';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Setup;
                ToolTip = 'Running this action will open the merchant account setup.';

                trigger OnAction()
                var
                    MerchantAccountSetup: Record "NPR Adyen Merchant Setup";
                    CreateNewMerchantAccountSetupLbl: Label '%1 merchant account does not have a setup. Do you wish to create it?', Comment = '%1 - Merchant account name';
                begin
                    Rec.TestField(Name);
                    if not MerchantAccountSetup.Get(Rec.Name) then begin
                        if not Confirm(CreateNewMerchantAccountSetupLbl, true, Rec.Name) then
                            exit;
                        MerchantAccountSetup.Init();
                        MerchantAccountSetup."Merchant Account" := Rec.Name;
                        MerchantAccountSetup.Insert();
                    end;
                    Page.Run(Page::"NPR Adyen Merchant Setup", MerchantAccountSetup);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if _AdyenManagement.UpdateMerchantList(0) then
            CurrPage.Update(false);
    end;

    trigger OnAfterGetRecord()
    begin
        if _MerchantAccountSetup.Get(Rec.Name) then;
    end;

    var
        _AdyenManagement: Codeunit "NPR Adyen Management";
        _MerchantAccountSetup: Record "NPR Adyen Merchant Setup";
}
