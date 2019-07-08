page 6060020 "GIM - Mail Line Subpage"
{
    AutoSplitKey = true;
    Caption = 'GIM - Mail Line Subpage';
    PageType = ListPart;
    SourceTable = "GIM - Mail Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Line Type";"Line Type")
                {
                }
                field(Description;Description)
                {
                }
            }
        }
    }

    actions
    {
    }
}

