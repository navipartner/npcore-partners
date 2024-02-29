page 6151351 "NPR Vipps Mp Payment Setup"
{
    Extensible = False;
    Caption = 'Vipps MobilePay Integration Config';
    PageType = Card;
    SourceTable = "NPR Vipps Mp Payment Setup";
    UsageCategory = None;
#if NOT BC17
    AboutTitle = 'Vipps MobilePay Integration Config';
    AboutText = 'This configuration is integration specific and defines common parameters used.';
#endif

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Log Level"; Rec."Log Level")
                {
                    ToolTip = 'Log level specifies how many logs should be generated when using this integration.';
                    ApplicationArea = NPRRetail;
#if NOT BC17
                    AboutTitle = 'Log Level';
                    AboutText = 'Log level specifies how many logs should be generated when using this integration.';
#endif
                }
            }
        }
    }
}

