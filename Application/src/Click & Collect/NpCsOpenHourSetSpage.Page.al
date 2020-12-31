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
                    }
                    field("Start Time"; "Start Time")
                    {
                        ApplicationArea = All;
                        Editable = "Entry Type" = 0;
                    }
                    field("End Time"; "End Time")
                    {
                        ApplicationArea = All;
                        Editable = "Entry Type" = 0;
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
                    group(Control6014420)
                    {
                        ShowCaption = false;
                        Visible = ("Period Type" = 2) OR ("Period Type" = 3);
                        field("Entry Date"; "Entry Date")
                        {
                            ApplicationArea = All;
                        }
                    }
                }
            }
        }
    }
}

