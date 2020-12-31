page 6059794 "NPR E-mail Templ. Filters"
{
    AutoSplitKey = true;
    Caption = 'E-mail Template Filters';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR E-mail Template Filter";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field No."; "Field No.")
                {
                    ApplicationArea = All;
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                }
                field(Value; Value)
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

