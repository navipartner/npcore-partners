page 6151603 "NPR NpDc Valid Time Interv."
{
    // NPR5.35/MHA /20170809  CASE 286355 Object created
    // NPR5.37/MHA /20171010  CASE 292171 Added Period Type and Weekday fields

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
                        }
                        field("End Time"; "End Time")
                        {
                            ApplicationArea = All;
                        }
                        field("Period Type"; "Period Type")
                        {
                            ApplicationArea = All;
                        }
                        field("Period Description"; "Period Description")
                        {
                            ApplicationArea = All;
                            Editable = false;
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
                        }
                        field(Tuesday; Tuesday)
                        {
                            ApplicationArea = All;
                        }
                        field(Wednesday; Wednesday)
                        {
                            ApplicationArea = All;
                        }
                        field(Thursday; Thursday)
                        {
                            ApplicationArea = All;
                        }
                        field(Friday; Friday)
                        {
                            ApplicationArea = All;
                        }
                        field(Saturday; Saturday)
                        {
                            ApplicationArea = All;
                        }
                        field(Sunday; Sunday)
                        {
                            ApplicationArea = All;
                        }
                    }
                }
            }
        }
    }

    actions
    {
    }
}

