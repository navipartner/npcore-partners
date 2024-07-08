page 6184593 "NPR TM CouponProfile"
{
    Extensible = false;
    PageType = Card;
    UsageCategory = None;
    DelayedInsert = true;
    RefreshOnActivate = true;
    Caption = 'Ticket Coupon Profiles';
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/how-to/create_coupon_profile/';
    SourceTable = "NPR TM CouponProfile";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(ProfileCode; Rec.ProfileCode)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Profile Code field.';
                }
            }

            part(Coupons; "NPR TM CouponProfilePart")
            {
                Caption = 'Coupons';
                ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                SubPageLink = ProfileCode = field(ProfileCode);
                SubPageView = sorting(ProfileCode, AliasCode);
            }
        }
    }

}