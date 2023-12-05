page 6150799 "NPR EFT Planet PAX Config List"
{
    Extensible = False;
    PageType = List;
    CardPageId = "NPR EFT Planet PAX Config Card";
    SourceTable = "NPR EFT Planet PAX Config";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;
    Caption = 'Planet PAX Terminal Configurations';
    Editable = false;
#if NOT BC17
    AboutTitle = 'Planet PAX Terminal Configurations';
    AboutText = 'This is a list over all configurations for different PAX Terminals.';
#endif
    //ContextSensitiveHelpPage = '';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("POS Unit"; Rec."Register No.")
                {
                    ToolTip = 'POS Unit which ther terminal should be paired with.';
                    ApplicationArea = NPRRetail;
                }
                field("Terminal ID"; Rec."Terminal ID")
                {
                    ToolTip = 'The terminal identifier.';
                    ApplicationArea = NPRRetail;
                }
                field("Location ID"; Rec."Location ID")
                {
                    ToolTip = 'The store location identifier.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
