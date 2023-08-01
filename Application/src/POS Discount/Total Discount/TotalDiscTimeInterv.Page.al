page 6150899 "NPR Total Disc. Time Interv."
{
    Extensible = False;
    AutoSplitKey = true;
    Caption = 'Active Time Intervals';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR Total Disc. Time Interv.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Start Time"; Rec."Start Time")
                {

                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines the Start Time of the Total Discount. The discount is going to be applied to POS Sales made after the specified Start Time.';
                }
                field("End Time"; Rec."End Time")
                {

                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines the End Time of the Total Discount. The discount is going to be applied to POS Sales made before the specified End Time.';
                }
                field("Period Type"; Rec."Period Type")
                {

                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines the Period Type of the Total Discount. Every Day - the discount is going to be active on all days of the week. Weekly - you can specify on which days of the week the Total Discount is going to be active.';
                }
                field(Monday; Rec.Monday)
                {

                    Editable = Rec."Period Type" = Rec."Period Type"::Weekly;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'If the Period Type field is set to Weekly you can specify if the Total Discount is going to be active on Mondays in this field.';
                }
                field(Tuesday; Rec.Tuesday)
                {

                    Editable = Rec."Period Type" = Rec."Period Type"::Weekly;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'If the Period Type field is set to Weekly you can specify if the Total Discount is going to be active on Tuesdays in this field.';
                }
                field(Wednesday; Rec.Wednesday)
                {

                    Editable = Rec."Period Type" = Rec."Period Type"::Weekly;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'If the Period Type field is set to Weekly you can specify if the Total Discount is going to be active on Wednesdays in this field.';
                }
                field(Thursday; Rec.Thursday)
                {

                    Editable = Rec."Period Type" = Rec."Period Type"::Weekly;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'If the Period Type field is set to Weekly you can specify if the Total Discount is going to be active on Thursdays in this field.';
                }
                field(Friday; Rec.Friday)
                {

                    Editable = Rec."Period Type" = Rec."Period Type"::Weekly;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'If the Period Type field is set to Weekly you can specify if the Total Discount is going to be active on Fridays in this field.';
                }
                field(Saturday; Rec.Saturday)
                {

                    Editable = Rec."Period Type" = Rec."Period Type"::Weekly;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'If the Period Type field is set to Weekly you can specify if the Total Discount is going to be active on Saturdays in this field.';
                }
                field(Sunday; Rec.Sunday)
                {

                    Editable = Rec."Period Type" = Rec."Period Type"::Weekly;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'If the Period Type field is set to Weekly you can specify if the Total Discount is going to be active on Sundays in this field.';
                }
            }
        }
    }
}

