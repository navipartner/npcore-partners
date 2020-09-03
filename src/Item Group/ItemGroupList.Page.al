page 6014459 "NPR Item Group List"
{
    // NPR5.26/BHR /20160914 CASE 252128 Item Group List
    // NPR5.30/BHR /20170222 CASE 264145 change property 'IndentationControls'from 'No.','description' to 'No.'

    Caption = 'Item Group List';
    CardPageID = "NPR Item Group Page";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Item Group";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = Level;
                IndentationControls = "No.";
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Level; Level)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}

