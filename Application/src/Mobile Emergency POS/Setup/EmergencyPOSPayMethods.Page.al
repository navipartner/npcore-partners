page 6184948 "NPR Emergency POS Pay. Methods"
{
    PageType = ListPart;
    Extensible = False;
    UsageCategory = None;
    SourceTable = "NPR Emergency POS Pay Methods";

    layout
    {
        area(Content)
        {
            repeater("Manual POS Payment Methods")
            {
                field("POS Payment Method Code"; Rec."POS Payment Method Code")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'POS Payment Method Code';
                    ToolTip = 'Specifies POS Payment Method Code to use when using a payment.';
                }
            }
        }
    }
}