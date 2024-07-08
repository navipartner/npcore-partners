page 6059857 "NPR Stripe POS User Subpart"
{
    Caption = 'POS Users';
    Extensible = false;
    PageType = ListPart;
    SourceTable = "NPR Stripe POS User";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(StripePOSUsers)
            {
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the user that has access to the NP Retail POS app.';
                }
            }
        }
    }
}