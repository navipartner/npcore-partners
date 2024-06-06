page 6184582 "NPR Adyen Merchant Setup"
{
    Extensible = false;

    UsageCategory = Administration;
    ApplicationArea = NPRRetail;
    Caption = 'Adyen Merchant Setup';
    PageType = Card;
    SourceTable = "NPR Adyen Merchant Setup";
    AdditionalSearchTerms = 'adyen setup,adyen reconciliation setup,adyen merchant setup';

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
                }
                field("Posting Source Code"; Rec."Posting Source Code")
                {
                    ApplicationArea = NPRRetail;
                    Tooltip = 'Specifies the Source Code for posting.';
                }
            }
            group(Reconciliation)
            {
                Caption = 'Reconciliatiom';
                field("Fee G/L Account"; Rec."Fee G/L Account")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Adyen Fee G/L Account.';
                }
                field("Deposit G/L Account"; Rec."Deposit G/L Account")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Adyen Deposit G/L Account.';
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
                field("Merchant Payout G/L Account"; Rec."Merchant Payout G/L Account")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Merchant Payout G/L Account.';
                }
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
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.FindFirst() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
