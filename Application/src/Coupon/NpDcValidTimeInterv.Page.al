page 6151603 "NPR NpDc Valid Time Interv."
{
    AutoSplitKey = true;
    Caption = 'Valid Time Intervals';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;
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
                        field("Start Time"; "Start Time")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Start Time field';
                        }
                        field("End Time"; "End Time")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the End Time field';
                        }
                        field("Period Type"; "Period Type")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Period Type field';
                        }
                        field("Period Description"; "Period Description")
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
                        Visible = ("Period Type" = 1);
                        field(Monday; Monday)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Monday field';
                        }
                        field(Tuesday; Tuesday)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Tuesday field';
                        }
                        field(Wednesday; Wednesday)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Wednesday field';
                        }
                        field(Thursday; Thursday)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Thursday field';
                        }
                        field(Friday; Friday)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Friday field';
                        }
                        field(Saturday; Saturday)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Saturday field';
                        }
                        field(Sunday; Sunday)
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

