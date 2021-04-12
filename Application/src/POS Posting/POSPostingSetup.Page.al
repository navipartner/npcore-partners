page 6150657 "NPR POS Posting Setup"
{
    Caption = 'POS Posting Setup';
    PageType = List;
    SourceTable = "NPR POS Posting Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Store Code field';
                }
                field("POS Payment Method Code"; Rec."POS Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Payment Method Code field';
                }
                field("POS Payment Bin Code"; Rec."POS Payment Bin Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Payment Bin Code field';
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Account Type field';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Account No. field';
                }
                field("Difference Account Type"; Rec."Difference Account Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Difference Account Type field';
                }
                field("Close to POS Bin No."; Rec."Close to POS Bin No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Close to POS Bin No. field';
                }
                field("Difference Acc. No."; Rec."Difference Acc. No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Difference Acc. No. field';
                }
                field("Difference Acc. No. (Neg)"; Rec."Difference Acc. No. (Neg)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Difference Acc. No. (Neg) field';
                }
            }
        }
    }

    actions
    {
    }
}

