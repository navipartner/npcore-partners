page 6059856 "NPR Stripe POS Users"
{
    ApplicationArea = NPRRetail;
    Caption = 'POS Users';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR Stripe POS User";
    UsageCategory = Administration;

    layout
    {
        area(content)
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

    actions
    {
        area(Processing)
        {
            action("Stripe Customer Portal")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Stripe Customer Portal';
                Enabled = MonetizationEnabled;
                Image = LinkWeb;
                ToolTip = 'Opens a link to the Stripe customer portal.';
                Visible = MonetizationEnabled;

                trigger OnAction()
                var
                    StripeCustomer: Record "NPR Stripe Customer";
                    CustomerPortalURL: Text;
                begin
                    StripeCustomer.FindFirst();
                    if StripeCustomer.GetCustomerPortalURL(CustomerPortalURL) then
                        Hyperlink(CustomerPortalURL);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        MonetizationEnabled := IsMonetizationEnabled();
    end;

    var
        MonetizationEnabled: Boolean;

    local procedure IsMonetizationEnabled(): Boolean
    var
        StripeSetup: Record "NPR Stripe Setup";
        StripeCustomer: Record "NPR Stripe Customer";
    begin
        if not StripeSetup.IsStripeActive() then
            exit(false);

        exit(not StripeCustomer.IsEmpty());
    end;
}
