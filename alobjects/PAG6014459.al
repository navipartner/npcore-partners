page 6014459 "Item Group List"
{
    // NPR5.26/BHR /20160914 CASE 252128 Item Group List
    // NPR5.30/BHR /20170222 CASE 264145 change property 'IndentationControls'from 'No.','description' to 'No.'

    Caption = 'Item Group List';
    CardPageID = "Item Group Page";
    Editable = false;
    PageType = List;
    SourceTable = "Item Group";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = Level;
                IndentationControls = "No.";
                field("No.";"No.")
                {
                }
                field(Description;Description)
                {
                }
                field(Level;Level)
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}

