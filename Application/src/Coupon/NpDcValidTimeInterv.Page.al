page 6151603 "NPR NpDc Valid Time Interv."
{
    AutoSplitKey = true;
    Caption = 'Valid Time Intervals';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR NpDc Valid Time Interval";

    layout
    {
        area(content)
        {
            grid(Control6014404)
            {
                ShowCaption = false;
                group(Control6014416)
                {
                    ShowCaption = false;
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
                        field("Period Description"; Rec."Period Description")
                        {
                            ApplicationArea = All;
                            Editable = false;
                            ToolTip = 'Specifies the value of the Period Description field';
                        }
                    }
                }
                group(Period)
                {
                    Caption = 'Period';
                    group(Control6014409)
                    {
                        ShowCaption = false;
                        Visible = (Rec."Period Type" = 1);
                        field(Monday; Rec.Monday)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Monday field';
                        }
                        field(Tuesday; Rec.Tuesday)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Tuesday field';
                        }
                        field(Wednesday; Rec.Wednesday)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Wednesday field';
                        }
                        field(Thursday; Rec.Thursday)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Thursday field';
                        }
                        field(Friday; Rec.Friday)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Friday field';
                        }
                        field(Saturday; Rec.Saturday)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Saturday field';
                        }
                        field(Sunday; Rec.Sunday)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Sunday field';
                        }
                    }
                }
            }
        }
    }
}

