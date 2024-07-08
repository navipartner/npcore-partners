page 6060011 "NPR EFT Softpay Config List"
{
    Extensible = False;
    PageType = List;
    CardPageId = "NPR EFT Softpay Config Card";
    SourceTable = "NPR EFT Softpay Config";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;
    Caption = 'Softpay POS Merchant List';
    Editable = false;
#if NOT BC17
    AboutTitle = 'Softpay POS Merchants';
    AboutText = 'This is a list of POS units and which Softpay merchants is configured to it.';
#endif
    ContextSensitiveHelpPage = 'docs/retail/eft/how-to/softpay/';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("POS Unit"; Rec."Register No.")
                {
                    ToolTip = 'Specifies the POS unit that is assigned to the merchant. Only one POS unit can be selected per a merchant.';
                    ApplicationArea = NPRRetail;
                }
                field("Merchant id"; Rec."Merchant ID")
                {

                    ToolTip = 'Specifies the merchant which is assigned to the POS unit. Only one merchant can be selected per a POS unit.';
                    ApplicationArea = NPRRetail;
                }

            }
        }
    }
}
