page 6059945 "CashKeeper Setup"
{
    // NPR5.29\CLVA\20161108 CASE NPR5.29 Object Created
    // NPR5.40/CLVA/20180307 CASE 291921 Added field "Payment Type"
    // NPR5.43/CLVA/20180620 CASE 319764 Added action CashKeeper Overview

    Caption = 'CashKeeper Setup';
    PageType = List;
    SourceTable = "CashKeeper Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Register No.";"Register No.")
                {
                }
                field("Payment Type";"Payment Type")
                {
                }
                field("CashKeeper IP";"CashKeeper IP")
                {
                }
                field("Debug Mode";"Debug Mode")
                {
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
                RunObject = Page "CashKeeper Transaction";
                RunPageLink = "Register No."=FIELD("Register No.");
            }
            action("CashKeeper Overview")
            {
                Caption = 'CashKeeper Overview';
                Image = View;
                RunObject = Page "CashKeeper Overview";
                RunPageLink = "Register No."=FIELD("Register No.");
            }
        }
    }
}

