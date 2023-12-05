page 6150798 "NPR EFT Planet PAX Config Card"
{
    Extensible = False;
    Caption = 'Planet Pax Terminal Configuration';
    PageType = Card;
    SourceTable = "NPR EFT Planet PAX Config";
    UsageCategory = None;
#if NOT BC17
    AboutTitle = 'Planet Pax Terminal Configuration';
    AboutText = 'This page contains info about the terminal configuration.';
#endif
    //ContextSensitiveHelpPage = '';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("POS Unit"; Rec."Register No.")
                {
                    ToolTip = 'POS Unit which ther terminal should be paired with.';
                    ApplicationArea = NPRRetail;
#if NOT BC17
                    AboutTitle = '';
                    AboutText = 'POS Unit which ther terminal should be paired with.';
#endif
                }
                field("Terminal ID"; Rec."Terminal ID")
                {
                    ToolTip = 'The terminal identifier.';
                    ApplicationArea = NPRRetail;
#if NOT BC17
                    AboutTitle = 'The terminal identifier.';
                    AboutText = 'The unique number of the terminal.';
#endif
                }
                field("Location ID"; Rec."Location ID")
                {
                    ToolTip = 'The store location identifier.';
                    ApplicationArea = NPRRetail;
#if NOT BC17
                    AboutTitle = 'The store location identifier.';
                    AboutText = 'The unique number linked with the store.';
#endif
                }
                field("Url Endpoint"; Rec."Url Endpoint")
                {
                    ToolTip = 'The endpoint that connects to the terminal.';
                    ApplicationArea = NPRRetail;
#if NOT BC17
                    AboutTitle = 'The Url endpoint';
                    AboutText = 'The endpoint used to connect to the terminal.';
#endif
                }
            }

        }
    }

}

