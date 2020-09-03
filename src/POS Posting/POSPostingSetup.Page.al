page 6150657 "NPR POS Posting Setup"
{
    // NPR5.36/BR  /20170810  CASE  277096 Object created

    Caption = 'POS Posting Setup';
    PageType = List;
    SourceTable = "NPR POS Posting Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Store Code"; "POS Store Code")
                {
                    ApplicationArea = All;
                }
                field("POS Payment Method Code"; "POS Payment Method Code")
                {
                    ApplicationArea = All;
                }
                field("POS Payment Bin Code"; "POS Payment Bin Code")
                {
                    ApplicationArea = All;
                }
                field("Account Type"; "Account Type")
                {
                    ApplicationArea = All;
                }
                field("Account No."; "Account No.")
                {
                    ApplicationArea = All;
                }
                field("Difference Account Type"; "Difference Account Type")
                {
                    ApplicationArea = All;
                }
                field("Close to POS Bin No."; "Close to POS Bin No.")
                {
                    ApplicationArea = All;
                }
                field("Difference Acc. No."; "Difference Acc. No.")
                {
                    ApplicationArea = All;
                }
                field("Difference Acc. No. (Neg)"; "Difference Acc. No. (Neg)")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

