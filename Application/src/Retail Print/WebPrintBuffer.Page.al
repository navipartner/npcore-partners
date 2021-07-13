page 6014581 "NPR Web Print Buffer"
{
    // NPR4.15/MMV/20151001 CASE 223893 Created table for use with web service printing

    Caption = 'Web Print Buffer';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Web Print Buffer";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Printjob ID"; Rec."Printjob ID")
                {

                    ToolTip = 'Specifies the value of the Printjob ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Printer ID"; Rec."Printer ID")
                {

                    ToolTip = 'Specifies the value of the Printer ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Time Created"; Rec."Time Created")
                {

                    ToolTip = 'Specifies the value of the Time Created field';
                    ApplicationArea = NPRRetail;
                }
                field(Printed; Rec.Printed)
                {

                    ToolTip = 'Specifies the value of the Printed field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

