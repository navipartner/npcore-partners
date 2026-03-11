page 6150931 "NPR Item Addon Translation"
{
    Extensible = false;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR Item Addon Translation";
    Caption = 'Item Addon Translation';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Language Code"; Rec."Language Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the language code for this translation.';
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