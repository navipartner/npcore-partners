page 6184582 "NPR Adyen Merchant Setup"
{
    Extensible = false;
    UsageCategory = none;
    Caption = 'NP Pay Merchant Account Default Setup';
    PageType = Card;
    SourceTable = "NPR Adyen Merchant Setup";
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Merchant Account"; Rec."Merchant Account")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Company ID.';
                    Editable = false;
                }
                field("Posting Source Code"; Rec."Posting Source Code")
                {
                    ApplicationArea = NPRRetail;
                    Tooltip = 'Specifies the Source Code for posting.';
                }
            }
            group(Reconciliation)
            {
                Caption = 'Reconciliation';
                group("Merchant Payout")
                {
                    Caption = 'Merchant Payout';
                    field("Merchant Payout Acc. Type"; Rec."Merchant Payout Acc. Type")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the Merchant Payout Account Type.';
                    }
                    field("Merchant Payout Acc. No."; Rec."Merchant Payout Acc. No.")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the Merchant Payout Account No.';
                    }
                    field("Acquirer Payout Acc. Type"; Rec."Acquirer Payout Acc. Type")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the Acquirer Payout Account Type.';
                    }
                    field("Acquirer Payout Acc. No."; Rec."Acquirer Payout Acc. No.")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the Acquirer Payout Account No.';
                    }
                }
                group(Expenses)
                {
                    Caption = 'Expenses';
                    field("Fee G/L Account"; Rec."Fee G/L Account")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the Fee G/L Account.';
                    }
                    field("Deposit G/L Account"; Rec."Deposit G/L Account")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the Deposit G/L Account.';
                    }
                    field("Markup G/L Account"; Rec."Markup G/L Account")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the Markup G/L Account.';
                    }
                    field("Other commissions G/L Account"; Rec."Other commissions G/L Account")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the Other commissions G/L Account.';
                    }
                    field("Invoice Deduction G/L Account"; Rec."Invoice Deduction G/L Account")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the Invoice Deduction G/L Account.';
                    }
                }
                group(Balancing)
                {
                    Caption = 'Balancing';
                    field("Reconciled Payment Acc. Type"; Rec."Reconciled Payment Acc. Type")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the Reconciled Payment Account Type.';
                    }
                    field("Reconciled Payment Acc. No."; Rec."Reconciled Payment Acc. No.")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the Reconciled Payment Account No.';
                    }
                    field("Missing Transaction Acc. Type"; Rec."Missing Transaction Acc. Type")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the Account Type of Missing Transactions.';
                    }
                    field("Missing Transaction Acc. No."; Rec."Missing Transaction Acc. No.")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the Account No. of Missing Transactions.';
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Open Merchant Currency Setup")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Open Merchant Currency Setup';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Setup;
                ToolTip = 'Running this action will open the merchant currency setup.';
                RunObject = page "NPR Merchant Currency Setup";
                RunPageLink = "Merchant Account Name" = field("Merchant Account");
            }
        }
    }

    trigger OnOpenPage()
    var
        MerchantAccount: Record "NPR Adyen Merchant Account";
        AdyenManagement: Codeunit "NPR Adyen Management";
    begin
        Rec.Reset();
        if not Rec.FindFirst() then begin
            Rec.Init();
            MerchantAccount.Reset();
            if not MerchantAccount.FindFirst() then begin
                if AdyenManagement.UpdateMerchantList(0) then begin
                    MerchantAccount.FindFirst();
                end;
            end;
            Rec."Merchant Account" := MerchantAccount.Name;
            Rec.Insert();
        end;
    end;
}
