page 6060006 "GIM - Mapping Columns"
{
    Caption = 'GIM - Mapping Columns';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "GIM - Mapping Table";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = Level;
                IndentationControls = "Column Name";
                ShowAsTree = true;
                field("Column Name";"Column Name")
                {
                }
                field("Column No.";"Column No.")
                {
                    Editable = false;
                }
                field("Parsed Text";"Parsed Text")
                {
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }
}

