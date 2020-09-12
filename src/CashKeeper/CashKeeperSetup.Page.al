page 6059945 "NPR CashKeeper Setup"
{
    // NPR5.29\CLVA\20161108 CASE NPR5.29 Object Created
    // NPR5.40/CLVA/20180307 CASE 291921 Added field "Payment Type"
    // NPR5.43/CLVA/20180620 CASE 319764 Added action CashKeeper Overview

    Caption = 'CashKeeper Setup';
    PageType = List;
    SourceTable = "NPR CashKeeper Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                }
                field("Payment Type"; "Payment Type")
                {
                    ApplicationArea = All;
                }
                field("CashKeeper IP"; "CashKeeper IP")
                {
                    ApplicationArea = All;
                }
                field("Debug Mode"; "Debug Mode")
                {
                    ApplicationArea = All;
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
            }
            action("CashKeeper Overview")
            {
                Caption = 'CashKeeper Overview';
                Image = View;
                RunObject = Page "NPR CashKeeper Overview";
                RunPageLink = "Register No." = FIELD("Register No.");
                ApplicationArea = All;
            }
        }
    }
}

