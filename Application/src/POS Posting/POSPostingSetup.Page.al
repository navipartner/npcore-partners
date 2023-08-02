page 6150657 "NPR POS Posting Setup"
{
    Extensible = False;
    Caption = 'POS Posting Setup';
    ContextSensitiveHelpPage = 'docs/retail/pos_processes/explanation/posting/';
    PageType = List;
    SourceTable = "NPR POS Posting Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Store Code"; Rec."POS Store Code")
                {

                    ToolTip = 'Specifies a code to identify the POS Store';
                    ApplicationArea = NPRRetail;
                }
                field("POS Payment Method Code"; Rec."POS Payment Method Code")
                {

                    ToolTip = 'Specifies a code to identify the POS Payment Method';
                    ApplicationArea = NPRRetail;
                }
                field("POS Payment Bin Code"; Rec."POS Payment Bin Code")
                {

                    ToolTip = 'Specifies a code to identify the POS Payment Bin';
                    ApplicationArea = NPRRetail;
                }
                field("Account Type"; Rec."Account Type")
                {
                    ToolTip = 'Specifies the type of account that a balancing entry is posted to, such as BANK for a cash account.';
                    ApplicationArea = NPRRetail;
                }
                field("Account No."; Rec."Account No.")
                {
                    ToolTip = 'Specifies the number of the general ledger, customer, vendor, or bank account that the balancing entry is posted to, such as a cash account for cash purchases.';
                    ApplicationArea = NPRRetail;
                }
                field("Difference Account Type"; Rec."Difference Account Type")
                {
                    ToolTip = 'Specifies the account type used to track differences';
                    ApplicationArea = NPRRetail;
                }
                field("Close to POS Bin No."; Rec."Close to POS Bin No.")
                {
                    ToolTip = 'Specifies the bin number used to close the POS';
                    ApplicationArea = NPRRetail;
                }
                field("Difference Acc. No."; Rec."Difference Acc. No.")
                {
                    ToolTip = 'Specifies the account to track positive differences based on the Difference Account Type selection';
                    ApplicationArea = NPRRetail;
                }
                field("Difference Acc. No. (Neg)"; Rec."Difference Acc. No. (Neg)")
                {
                    ToolTip = 'Specifies the account to track negative differences based on the Difference Account Type selection';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

