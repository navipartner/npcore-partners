page 6059855 "NPR Stripe Plan Tier Subpart"
{
    Caption = 'Plan Tiers';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "NPR Stripe Plan Tier";
    UsageCategory = None;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-09-03';
    ObsoleteReason = 'Not used. Using POS Billing API integration to control licenses.';

    layout
    {
        area(Content)
        {
            repeater(StripePlanTiers)
            {
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the description of the plan tier.';
                }
                field(Amount; Rec.Amount / 100)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Unit Price';
                    DecimalPlaces = 2 : 2;
                    Editable = false;
                    ToolTip = 'Specifies the price of the product per unit for plan tier.';
                    Width = 15;
                }
            }
        }
    }
}