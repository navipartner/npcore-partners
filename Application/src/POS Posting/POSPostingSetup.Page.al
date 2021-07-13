page 6150657 "NPR POS Posting Setup"
{
    Caption = 'POS Posting Setup';
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

                    ToolTip = 'Specifies the value of the POS Store Code field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Payment Method Code"; Rec."POS Payment Method Code")
                {

                    ToolTip = 'Specifies the value of the POS Payment Method Code field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Payment Bin Code"; Rec."POS Payment Bin Code")
                {

                    ToolTip = 'Specifies the value of the POS Payment Bin Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Account Type"; Rec."Account Type")
                {

                    ToolTip = 'Specifies the value of the Account Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Account No."; Rec."Account No.")
                {

                    ToolTip = 'Specifies the value of the Account No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Difference Account Type"; Rec."Difference Account Type")
                {

                    ToolTip = 'Specifies the value of the Difference Account Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Close to POS Bin No."; Rec."Close to POS Bin No.")
                {

                    ToolTip = 'Specifies the value of the Close to POS Bin No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Difference Acc. No."; Rec."Difference Acc. No.")
                {

                    ToolTip = 'Specifies the value of the Difference Acc. No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Difference Acc. No. (Neg)"; Rec."Difference Acc. No. (Neg)")
                {

                    ToolTip = 'Specifies the value of the Difference Acc. No. (Neg) field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

