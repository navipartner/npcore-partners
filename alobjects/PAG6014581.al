page 6014581 "Web Print Buffer"
{
    // NPR4.15/MMV/20151001 CASE 223893 Created table for use with web service printing

    Caption = 'Web Print Buffer';
    Editable = false;
    PageType = List;
    SourceTable = "Web Print Buffer";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Printjob ID";"Printjob ID")
                {
                }
                field("Printer ID";"Printer ID")
                {
                }
                field("Print Data";"Print Data")
                {
                }
                field("Time Created";"Time Created")
                {
                }
                field(Printed;Printed)
                {
                }
            }
        }
    }

    actions
    {
    }
}

