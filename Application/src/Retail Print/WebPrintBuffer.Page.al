page 6014581 "NPR Web Print Buffer"
{
    // NPR4.15/MMV/20151001 CASE 223893 Created table for use with web service printing

    Caption = 'Web Print Buffer';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Web Print Buffer";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Printjob ID"; "Printjob ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Printjob ID field';
                }
                field("Printer ID"; "Printer ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Printer ID field';
                }
                field("Print Data"; "Print Data")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print Data field';
                }
                field("Time Created"; "Time Created")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Time Created field';
                }
                field(Printed; Printed)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Printed field';
                }
            }
        }
    }

    actions
    {
    }
}

