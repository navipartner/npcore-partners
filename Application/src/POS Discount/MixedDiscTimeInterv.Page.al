page 6014448 "NPR Mixed Disc. Time Interv."
{
    // NPR5.45/MHA /20180820  CASE 323568 Object created
    // NPR5.51/MAOT/20190614 CASE 352650 Fixed scaling error by changing grid layout to standard list
    // NPR5.54/SARA/20200218 CASE 388008 Make Weekdays non editable when Period Type is Daily

    AutoSplitKey = true;
    Caption = 'Active Time Intervals';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Mixed Disc. Time Interv.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Start Time"; Rec."Start Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Start Time field';
                }
                field("End Time"; Rec."End Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the End Time field';
                }
                field("Period Type"; Rec."Period Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Period Type field';
                }
                field(Monday; Rec.Monday)
                {
                    ApplicationArea = All;
                    Editable = Rec."Period Type" = 1;
                    ToolTip = 'Specifies the value of the Monday field';
                }
                field(Tuesday; Rec.Tuesday)
                {
                    ApplicationArea = All;
                    Editable = Rec."Period Type" = 1;
                    ToolTip = 'Specifies the value of the Tuesday field';
                }
                field(Wednesday; Rec.Wednesday)
                {
                    ApplicationArea = All;
                    Editable = Rec."Period Type" = 1;
                    ToolTip = 'Specifies the value of the Wednesday field';
                }
                field(Thursday; Rec.Thursday)
                {
                    ApplicationArea = All;
                    Editable = Rec."Period Type" = 1;
                    ToolTip = 'Specifies the value of the Thursday field';
                }
                field(Friday; Rec.Friday)
                {
                    ApplicationArea = All;
                    Editable = Rec."Period Type" = 1;
                    ToolTip = 'Specifies the value of the Friday field';
                }
                field(Saturday; Rec.Saturday)
                {
                    ApplicationArea = All;
                    Editable = Rec."Period Type" = 1;
                    ToolTip = 'Specifies the value of the Saturday field';
                }
                field(Sunday; Rec.Sunday)
                {
                    ApplicationArea = All;
                    Editable = Rec."Period Type" = 1;
                    ToolTip = 'Specifies the value of the Sunday field';
                }
            }
        }
    }

    actions
    {
    }
}

