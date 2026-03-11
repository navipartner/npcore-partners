page 6248193 "NPR NpIa AddOn Cat. Trans."
{
    Extensible = false;
    Caption = 'Item AddOn Category Translations';
    PageType = List;
    SourceTable = "NPR NpIa ItemAddOn Cat. Trans.";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Language Code"; Rec."Language Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the language code for this translation.';
                }
                field(Title; Rec.Title)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the translated title.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the translated description.';
                }
            }
        }
    }
}
