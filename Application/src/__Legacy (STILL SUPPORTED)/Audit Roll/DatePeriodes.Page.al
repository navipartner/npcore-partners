page 6060102 "NPR Date Periodes"
{
    Caption = 'Date Periodes';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Periodes";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Period Code"; "Period Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Period Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Start Date"; "Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Start Date field';
                }
                field("End Date"; "End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the End Date field';
                }
                field("Start Date Last Year"; "Start Date Last Year")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Start Date Last Year field';
                }
                field("End Date Last Year"; "End Date Last Year")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the End Date Last Year field';
                }
            }
        }
    }

    actions
    {
    }
}

