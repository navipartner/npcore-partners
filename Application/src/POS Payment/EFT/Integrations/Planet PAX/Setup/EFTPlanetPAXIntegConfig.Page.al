page 6151318 "NPR EFT Planet Integ. Conf."
{
    Extensible = False;
    Caption = 'Planet Pax Integration Configuration';
    PageType = Card;
    SourceTable = "NPR EFT Planet Integ. Config";
    UsageCategory = None;
#if NOT BC17
    AboutTitle = 'Planet Pax Integration Configuration';
    AboutText = 'This page contains info about the integration configuration.';
#endif
    //ContextSensitiveHelpPage = '';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Log Level"; Rec."Log Level")
                {
                    ToolTip = 'Specifies how much should be logged.';
                    ApplicationArea = NPRRetail;
#if NOT BC17
                    AboutTitle = 'Log Level';
                    AboutText = 'Specifies how much should be logged.';
#endif
                }
            }

        }
    }

}

