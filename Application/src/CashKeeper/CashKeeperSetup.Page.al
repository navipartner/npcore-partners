page 6059945 "NPR CashKeeper Setup"
{
    // NPR5.29\CLVA\20161108 CASE NPR5.29 Object Created
    // NPR5.40/CLVA/20180307 CASE 291921 Added field "Payment Type"
    // NPR5.43/CLVA/20180620 CASE 319764 Added action CashKeeper Overview

    Caption = 'CashKeeper Setup';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR CashKeeper Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Register No."; Rec."Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("Payment Type"; Rec."Payment Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Type field';
                }
                field("CashKeeper IP"; Rec."CashKeeper IP")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the CashKeeper IP field';
                }
                field("Debug Mode"; Rec."Debug Mode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Debug Mode field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("CashKeeper Transaction")
            {
                Caption = 'CashKeeper Transaction';
                Image = View;
                RunObject = Page "NPR CashKeeper Transaction";
                RunPageLink = "Register No." = FIELD("Register No.");
                ApplicationArea = All;
                ToolTip = 'Executes the CashKeeper Transaction action';
            }
            action("CashKeeper Overview")
            {
                Caption = 'CashKeeper Overview';
                Image = View;
                RunObject = Page "NPR CashKeeper Overview";
                RunPageLink = "Register No." = FIELD("Register No.");
                ApplicationArea = All;
                ToolTip = 'Executes the CashKeeper Overview action';
            }
        }
    }
}

