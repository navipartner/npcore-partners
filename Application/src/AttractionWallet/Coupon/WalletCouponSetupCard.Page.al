page 6184858 "NPR WalletCouponSetupCard"
{
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR WalletCouponSetup";
    Caption = 'Wallet Coupon Setup Card';
    Extensible = False;
    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(TriggerOnItemNo; Rec.TriggerOnItemNo)
                {
                    ToolTip = 'Specifies the value of the Trigger On Item No. field.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}