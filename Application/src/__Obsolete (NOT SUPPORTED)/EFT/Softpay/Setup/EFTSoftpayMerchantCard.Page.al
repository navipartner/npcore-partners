page 6060007 "NPR EFT Softpay Merchant Card"
{
    Extensible = False;
    Caption = 'Softpay Merchant Card';
    PageType = Card;
    SourceTable = "NPR EFT Softpay Merchant";
    UsageCategory = None;
#if NOT BC17
    AboutTitle = 'Softpay Merchant';
    AboutText = 'On this page you can specify values for the Softpay merchant.';
#endif
    ContextSensitiveHelpPage = 'retail/eft/howto/softpay.html';
    ObsoleteState = Pending;
    ObsoleteTag = '2025-06-13';
    ObsoleteReason = 'No longer supported';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Merchant id"; Rec."Merchant ID")
                {

                    ToolTip = 'Specifies the ID/username of a merchant provided by Softpay.';
                    ApplicationArea = NPRRetail;
#if NOT BC17
                    AboutTitle = 'Merchant ID';
                    AboutText = 'Specifies the ID of a merchant provided by Softpay. This value is also used as the username in the Softpay app.';
#endif
                }
                field("Merchant password"; Rec."Merchant Password")
                {

                    ToolTip = 'Specifies the password of a merchant provided by Softpay.';
                    ApplicationArea = NPRRetail;
#if NOT BC17
                    AboutTitle = 'Merchant Password';
                    AboutText = 'Specifies the password provided by Softpay that corresponds to the merchant ID.';
#endif
                }
                field("Merchant Description"; Rec.Description)
                {

                    ToolTip = 'Specifies the descriptive text which helps distinguish between different merchants.';
                    ApplicationArea = NPRRetail;
#if NOT BC17
                    AboutTitle = 'Merchant Description';
                    AboutText = 'Specifies the merchant account that can be used if there are multiple merchants with different configurations, so it''s easier to distinguish between them.';
#endif
                }
                field(Enviroment; Rec.Environment)
                {

                    ToolTip = 'Specifies the type of environment. For testing purposes choose Sandbox, otherwise choose Production.';
                    ApplicationArea = NPRRetail;
#if NOT BC17
                    AboutTitle = 'Enviroment Selection';
                    AboutText = 'Specifies the type of environment. For the purpose of testing the Softpay integration choose Sandbox, otherwise choose Production.';
#endif
                }
            }

        }
    }
}

