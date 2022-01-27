page 6059793 "NPR E-mail Templ. Subform"
{
    Extensible = False;
    AutoSplitKey = true;
    Caption = 'E-mail Template Subform';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR E-mail Templ. Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Mail Body Line"; Rec."Mail Body Line")
                {

                    ToolTip = 'Specifies the value of the Mail Body Line field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

}

