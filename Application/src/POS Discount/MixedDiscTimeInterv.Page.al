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

    SourceTable = "NPR Mixed Disc. Time Interv.";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Start Time"; Rec."Start Time")
                {

                    ToolTip = 'Specifies the value of the Start Time field';
                    ApplicationArea = NPRRetail;
                }
                field("End Time"; Rec."End Time")
                {

                    ToolTip = 'Specifies the value of the End Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Period Type"; Rec."Period Type")
                {

                    ToolTip = 'Specifies the value of the Period Type field';
                    ApplicationArea = NPRRetail;
                }
                field(Monday; Rec.Monday)
                {

                    Editable = Rec."Period Type" = 1;
                    ToolTip = 'Specifies the value of the Monday field';
                    ApplicationArea = NPRRetail;
                }
                field(Tuesday; Rec.Tuesday)
                {

                    Editable = Rec."Period Type" = 1;
                    ToolTip = 'Specifies the value of the Tuesday field';
                    ApplicationArea = NPRRetail;
                }
                field(Wednesday; Rec.Wednesday)
                {

                    Editable = Rec."Period Type" = 1;
                    ToolTip = 'Specifies the value of the Wednesday field';
                    ApplicationArea = NPRRetail;
                }
                field(Thursday; Rec.Thursday)
                {

                    Editable = Rec."Period Type" = 1;
                    ToolTip = 'Specifies the value of the Thursday field';
                    ApplicationArea = NPRRetail;
                }
                field(Friday; Rec.Friday)
                {

                    Editable = Rec."Period Type" = 1;
                    ToolTip = 'Specifies the value of the Friday field';
                    ApplicationArea = NPRRetail;
                }
                field(Saturday; Rec.Saturday)
                {

                    Editable = Rec."Period Type" = 1;
                    ToolTip = 'Specifies the value of the Saturday field';
                    ApplicationArea = NPRRetail;
                }
                field(Sunday; Rec.Sunday)
                {

                    Editable = Rec."Period Type" = 1;
                    ToolTip = 'Specifies the value of the Sunday field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

