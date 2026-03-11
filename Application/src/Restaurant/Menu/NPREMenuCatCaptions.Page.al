#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
page 6150932 "NPR NPRE Menu Cat Captions"
{
    Extensible = false;
    PageType = List;
    ApplicationArea = NPRRetail;
    UsageCategory = None;
    SourceTable = "NPR NPRE Menu Cat. Translation";

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
#endif
