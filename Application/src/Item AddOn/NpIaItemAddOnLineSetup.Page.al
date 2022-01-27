page 6151129 "NPR NpIa ItemAddOn Line Setup"
{
    Extensible = False;
    UsageCategory = None;
    Caption = 'Item AddOn Line Setup';
    PageType = Card;
    SourceTable = "NPR NpIa ItemAddOn Line Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Unit Price % from Master"; Rec."Unit Price % from Master")
                {

                    ToolTip = 'Specifies the percentage which will be applied to the ratio of total amount and quantity before creating POS entry.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

