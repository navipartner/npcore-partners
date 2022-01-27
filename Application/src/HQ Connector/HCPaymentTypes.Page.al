page 6150904 "NPR HC Payment Types"
{
    Extensible = False;
    Caption = 'HC Payment Types';
    PageType = List;
    SourceTable = "NPR HC Payment Type POS";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Account Type"; Rec."Account Type")
                {

                    ToolTip = 'Specifies the value of the Account Type field';
                    ApplicationArea = NPRRetail;
                }
                field("G/L Account No."; Rec."G/L Account No.")
                {

                    ToolTip = 'Specifies the value of the G/L Account field';
                    ApplicationArea = NPRRetail;
                }
                field("Bank Acc. No."; Rec."Bank Acc. No.")
                {

                    ToolTip = 'Specifies the value of the Bank field';
                    ApplicationArea = NPRRetail;
                }
                field("HQ Processing"; Rec."HQ Processing")
                {

                    ToolTip = 'Specifies the value of the HQ Processing field';
                    ApplicationArea = NPRRetail;
                }
                field("HQ Post Sales Document"; Rec."HQ Post Sales Document")
                {

                    ToolTip = 'Specifies the value of the HQ Post Sales Document field';
                    ApplicationArea = NPRRetail;
                }
                field("HQ Post Payment"; Rec."HQ Post Payment")
                {

                    ToolTip = 'Specifies the value of the HQ Post Payment field';
                    ApplicationArea = NPRRetail;
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {

                    ToolTip = 'Specifies the value of the Payment Method Code field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

