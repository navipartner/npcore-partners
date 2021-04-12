page 6151218 "NPR NpCs Open. Hour Calendar"
{
    Caption = 'Collect Store Opening Hour Calendar';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR NpCs Open. Hour Cal. Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Calendar Date"; Rec."Calendar Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date field';
                }
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
                field(Weekday; Rec.Weekday)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Weekday field';
                }
            }
        }
    }
}

