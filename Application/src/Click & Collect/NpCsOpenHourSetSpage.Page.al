page 6151217 "NPR NpCs Open.Hour Set S.page"
{
    Extensible = False;
    AutoSplitKey = true;
    Caption = 'Opening Hours';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = None;
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

                        ToolTip = 'Specifies the value of the Opening Type field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Start Time"; Rec."Start Time")
                    {

                        Editable = Rec."Entry Type" = 0;
                        ToolTip = 'Specifies the value of the Start Time field';
                        ApplicationArea = NPRRetail;
                    }
                    field("End Time"; Rec."End Time")
                    {

                        Editable = Rec."Entry Type" = 0;
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
                    group(Control6014420)
                    {
                        ShowCaption = false;
                        Visible = (Rec."Period Type" = 2) OR (Rec."Period Type" = 3);
                        field("Entry Date"; Rec."Entry Date")
                        {

                            ToolTip = 'Specifies the value of the Entry Date field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                }
            }
        }
    }
}

