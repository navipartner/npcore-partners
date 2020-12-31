page 6059793 "NPR E-mail Templ. Subform"
{
    AutoSplitKey = true;
    Caption = 'E-mail Template Subform';
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR E-mail Templ. Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Mail Body Line"; "Mail Body Line")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

