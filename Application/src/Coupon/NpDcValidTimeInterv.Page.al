page 6151603 "NPR NpDc Valid Time Interv."
{
    Extensible = False;
    AutoSplitKey = true;
    Caption = 'Valid Time Intervals';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR NpDc Valid Time Interval";
    ApplicationArea = NPRRetail;

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
                        field("Period Description"; Rec."Period Description")
                        {

                            Editable = false;
                            ToolTip = 'Specifies the value of the Period Description field';
                            ApplicationArea = NPRRetail;
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

                            ToolTip = 'Specifies the value of the Monday field';
                            ApplicationArea = NPRRetail;
                        }
                        field(Tuesday; Rec.Tuesday)
                        {

                            ToolTip = 'Specifies the value of the Tuesday field';
                            ApplicationArea = NPRRetail;
                        }
                        field(Wednesday; Rec.Wednesday)
                        {

                            ToolTip = 'Specifies the value of the Wednesday field';
                            ApplicationArea = NPRRetail;
                        }
                        field(Thursday; Rec.Thursday)
                        {

                            ToolTip = 'Specifies the value of the Thursday field';
                            ApplicationArea = NPRRetail;
                        }
                        field(Friday; Rec.Friday)
                        {

                            ToolTip = 'Specifies the value of the Friday field';
                            ApplicationArea = NPRRetail;
                        }
                        field(Saturday; Rec.Saturday)
                        {

                            ToolTip = 'Specifies the value of the Saturday field';
                            ApplicationArea = NPRRetail;
                        }
                        field(Sunday; Rec.Sunday)
                        {

                            ToolTip = 'Specifies the value of the Sunday field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                }
            }
        }
    }
}

