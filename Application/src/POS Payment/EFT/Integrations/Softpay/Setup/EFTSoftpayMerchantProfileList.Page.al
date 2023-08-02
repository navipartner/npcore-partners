page 6060008 "NPR EFT Softpay Merchant List"
{
    Extensible = False;
    PageType = List;
    CardPageId = "NPR EFT Softpay Merchant Card";
    SourceTable = "NPR EFT Softpay Merchant";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;
    Caption = 'Softpay Merchant List';
    Editable = false;
#if NOT BC17
    AboutTitle = 'Softpay Merchants';
    AboutText = 'This is a list of all your configured Softpay merchants. These merchants are supplied by Softpay.';
#endif
    ContextSensitiveHelpPage = 'docs/retail/eft/how-to/softpay/';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Merchant id"; Rec."Merchant ID")
                {

                    ToolTip = 'Specifies the ID/username of a merchant provided by Softpay.';
                    ApplicationArea = NPRRetail;
                }
                field("Merchant password"; Rec."Merchant Password")
                {

                    ToolTip = 'Specifies the password of a merchant provided by Softpay.';
                    ApplicationArea = NPRRetail;
                }
                field("Merchant Description"; Rec.Description)
                {

                    ToolTip = 'Specifies a descriptive text which helps distinguish between multiple merchants.';
                    ApplicationArea = NPRRetail;
                }
                field("Enviroment"; Rec.Environment)
                {
                    ToolTip = 'For testing purposes select Sandbox, otherwise choose Production.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
