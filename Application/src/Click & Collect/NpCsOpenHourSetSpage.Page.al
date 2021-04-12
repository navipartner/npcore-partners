page 6151217 "NPR NpCs Open.Hour Set S.page"
{
    AutoSplitKey = true;
    Caption = 'Opening Hours';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    field("Entry Type"; Rec."Entry Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Opening Type field';
                    }
                    field("Start Time"; Rec."Start Time")
                    {
                        ApplicationArea = All;
                        Editable = Rec."Entry Type" = 0;
                        ToolTip = 'Specifies the value of the Start Time field';
                    }
                    field("End Time"; Rec."End Time")
                    {
                        ApplicationArea = All;
                        Editable = Rec."Entry Type" = 0;
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
                    group(Control6014420)
                    {
                        ShowCaption = false;
                        Visible = (Rec."Period Type" = 2) OR (Rec."Period Type" = 3);
                        field("Entry Date"; Rec."Entry Date")
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

