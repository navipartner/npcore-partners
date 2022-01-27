page 6059945 "NPR CashKeeper Setup"
{
    Extensible = False;
    // NPR5.29\CLVA\20161108 CASE NPR5.29 Object Created
    // NPR5.40/CLVA/20180307 CASE 291921 Added field "Payment Type"
    // NPR5.43/CLVA/20180620 CASE 319764 Added action CashKeeper Overview

    Caption = 'CashKeeper Setup';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR CashKeeper Setup";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Register No."; Rec."Register No.")
                {

                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Payment Type"; Rec."Payment Type")
                {

                    ToolTip = 'Specifies the value of the Payment Type field';
                    ApplicationArea = NPRRetail;
                }
                field("CashKeeper IP"; Rec."CashKeeper IP")
                {

                    ToolTip = 'Specifies the value of the CashKeeper IP field';
                    ApplicationArea = NPRRetail;
                }
                field("Debug Mode"; Rec."Debug Mode")
                {

                    ToolTip = 'Specifies the value of the Debug Mode field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the CashKeeper Transaction action';
                ApplicationArea = NPRRetail;
            }
            action("CashKeeper Overview")
            {
                Caption = 'CashKeeper Overview';
                Image = View;
                RunObject = Page "NPR CashKeeper Overview";
                RunPageLink = "Register No." = FIELD("Register No.");

                ToolTip = 'Executes the CashKeeper Overview action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

