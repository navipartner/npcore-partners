page 6060009 "NPR EFT Softpay Config Card"
{
    Extensible = False;
    Caption = 'Softpay POS Merchant Card';
    PageType = Card;
    SourceTable = "NPR EFT Softpay Config";
    UsageCategory = None;
#if NOT BC17
    AboutTitle = 'Softpay Configuration';
    AboutText = 'On this page you can pair POS units and merchants. For example if you select POS unit 1 and merchant id Navi, Then everytime you use POS unit 1, then the account you log in with in Softpay is Navi.';
#endif
    ContextSensitiveHelpPage = 'docs/retail/eft/how-to/softpay/';
    ObsoleteState = Pending;
    ObsoleteTag = '2025-06-13';
    ObsoleteReason = 'No longer supported';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("POS Unit"; Rec."Register No.")
                {
                    ToolTip = 'Specifies the POS unit that is assigned to the merchant. You cannot assign multiple merchants to the same POS unit.';
                    ApplicationArea = NPRRetail;
#if NOT BC17
                    AboutTitle = 'POS Unit';
                    AboutText = 'Specifies the POS unit that is assigned to the merchant. You can only select the POS unit once. If it already exists, go back to the list view.';
#endif
                }
                field("Merchant id"; Rec."Merchant ID")
                {

                    ToolTip = 'Specifies which merchant is assigned to the POS unit. You can use the same merchant for multiple POS units.';
                    ApplicationArea = NPRRetail;
#if NOT BC17
                    AboutTitle = 'Softpay Merchant';
                    AboutText = 'Specifies a merchant that is assigned to the POS unit. The same merchant account can be selected for multiple POS units.';
#endif
                }
            }

        }
    }

}

