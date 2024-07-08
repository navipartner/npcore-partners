page 6150657 "NPR POS Posting Setup"
{
    ApplicationArea = NPRRetail;
    Caption = 'POS Posting Setup';
    ContextSensitiveHelpPage = 'docs/retail/posting_setup/explanation/pos_posting_setup/';
    PageType = List;
    SourceTable = "NPR POS Posting Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies a code to identify the POS Store';
                }
                field("POS Payment Method Code"; Rec."POS Payment Method Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies a code to identify the POS Payment Method';
                }
                field("POS Payment Bin Code"; Rec."POS Payment Bin Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies a code to identify the POS Payment Bin';
                }
                field("Close to POS Bin No."; Rec."Close to POS Bin No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the bin number used to close the POS';
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the type of account that a balancing entry is posted to, such as BANK for a cash account.';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the number of the general ledger, customer, vendor, or bank account that the balancing entry is posted to, such as a cash account for cash purchases.';
                }
                field("Difference Account Type"; Rec."Difference Account Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the account type used to track differences';
                }
                field("Difference Acc. No."; Rec."Difference Acc. No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the account to track positive differences based on the Difference Account Type selection';
                }
                field("Difference Acc. No. (Neg)"; Rec."Difference Acc. No. (Neg)")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the account to track negative differences based on the Difference Account Type selection';
                }
            }
        }
    }
}