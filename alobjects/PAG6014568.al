page 6014568 "Saved Export Wizard"
{
    // NPR5.23/THRO/20160404 CASE 234161 Table for saving template setup

    Caption = 'Saved Export Wizard';
    PageType = List;
    SourceTable = "Saved Export Wizard";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
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

