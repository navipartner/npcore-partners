page 6060015 "GIM - Mapping Priorities"
{
    Caption = 'GIM - Mapping Priorities';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "GIM - Mapping Table Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Column No.";"Column No.")
                {
                    Editable = false;
                }
                field("Table ID";"Table ID")
                {
                    Editable = false;
                }
                field("Table Caption";"Table Caption")
                {
                    Editable = false;
                }
                field(Priority;Priority)
                {
                }
            }
        }
    }

    actions
    {
    }
}

