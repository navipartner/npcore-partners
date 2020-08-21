page 6151217 "NpCs Open. Hour Set Subpage"
{
    // NPR5.51/MHA /20190719  CASE 362443 Object created - Collect Store Opening Hour Sets
    // NPR5.52/MHA /20191021  CASE 362443 Adjusted caption of Period Group to signal intentional spaces to control width
    // NPR5.55/MHA /20200731  CASE 417003 Updated layout for better BC WebClient experience

    AutoSplitKey = true;
    Caption = 'Opening Hours';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "NpCs Open. Hour Entry";

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

    actions
    {
    }
}

