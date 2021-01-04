page 6151217 "NPR NpCs Open.Hour Set S.page"
{
    AutoSplitKey = true;
    Caption = 'Opening Hours';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR NpCs Open. Hour Entry";

    layout
    {
        area(content)
        {
            group(Control6014416)
            {
                ShowCaption = false;
                repeater(Group)
                {
                    field("Entry Type"; "Entry Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Opening Type field';
                    }
                    field("Start Time"; "Start Time")
                    {
                        ApplicationArea = All;
                        Editable = "Entry Type" = 0;
                        ToolTip = 'Specifies the value of the Start Time field';
                    }
                    field("End Time"; "End Time")
                    {
                        ApplicationArea = All;
                        Editable = "Entry Type" = 0;
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
                    group(Control6014420)
                    {
                        ShowCaption = false;
                        Visible = ("Period Type" = 2) OR ("Period Type" = 3);
                        field("Entry Date"; "Entry Date")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Entry Date field';
                        }
                    }
                }
            }
        }
    }
}

