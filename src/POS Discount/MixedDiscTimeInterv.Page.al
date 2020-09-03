page 6014448 "NPR Mixed Disc. Time Interv."
{
    // NPR5.45/MHA /20180820  CASE 323568 Object created
    // NPR5.51/MAOT/20190614 CASE 352650 Fixed scaling error by changing grid layout to standard list
    // NPR5.54/SARA/20200218 CASE 388008 Make Weekdays non editable when Period Type is Daily

    AutoSplitKey = true;
    Caption = 'Active Time Intervals';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "NPR Mixed Disc. Time Interv.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Start Time"; "Start Time")
                {
                    ApplicationArea = All;
                }
                field("End Time"; "End Time")
                {
                    ApplicationArea = All;
                }
                field("Period Type"; "Period Type")
                {
                    ApplicationArea = All;
                }
                field(Monday; Monday)
                {
                    ApplicationArea = All;
                    Editable = "Period Type" = 1;
                }
                field(Tuesday; Tuesday)
                {
                    ApplicationArea = All;
                    Editable = "Period Type" = 1;
                }
                field(Wednesday; Wednesday)
                {
                    ApplicationArea = All;
                    Editable = "Period Type" = 1;
                }
                field(Thursday; Thursday)
                {
                    ApplicationArea = All;
                    Editable = "Period Type" = 1;
                }
                field(Friday; Friday)
                {
                    ApplicationArea = All;
                    Editable = "Period Type" = 1;
                }
                field(Saturday; Saturday)
                {
                    ApplicationArea = All;
                    Editable = "Period Type" = 1;
                }
                field(Sunday; Sunday)
                {
                    ApplicationArea = All;
                    Editable = "Period Type" = 1;
                }
            }
        }
    }

    actions
    {
    }
}

