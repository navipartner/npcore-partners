page 6151129 "NPR NpIa ItemAddOn Line Setup"
{
    // NPR5.48/MHA /20181109  CASE 334922 Object created - Before Insert Setup

    Caption = 'Item AddOn Line Setup';
    PageType = Card;
    SourceTable = "NPR NpIa ItemAddOn Line Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Unit Price % from Master"; "Unit Price % from Master")
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

