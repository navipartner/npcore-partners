page 6059857 "NPR Stripe POS User Subpart"
{
    Caption = 'POS Users';
    Extensible = false;
    PageType = ListPart;
    SourceTable = "NPR Stripe POS User";
    UsageCategory = None;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-09-03';
    ObsoleteReason = 'Not used. Using POS Billing API integration to control licenses.';

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