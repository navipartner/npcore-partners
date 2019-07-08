page 6060032 "GIM - Error Logs"
{
    Caption = 'GIM - Error Logs';
    Editable = false;
    PageType = List;
    SourceTable = "GIM - Error Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table ID";"Table ID")
                {
                }
                field("Table Caption";"Table Caption")
                {
                }
                field("Field ID";"Field ID")
                {
                }
                field("Field Caption";"Field Caption")
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

