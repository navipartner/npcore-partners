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
                field("Printjob ID"; "Printjob ID")
                {
                    ApplicationArea = All;
                }
                field("Printer ID"; "Printer ID")
                {
                    ApplicationArea = All;
                }
                field("Print Data"; "Print Data")
                {
                    ApplicationArea = All;
                }
                field("Time Created"; "Time Created")
                {
                    ApplicationArea = All;
                }
                field(Printed; Printed)
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

