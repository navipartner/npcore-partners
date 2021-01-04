page 6151218 "NPR NpCs Open. Hour Calendar"
{
    Caption = 'Collect Store Opening Hour Calendar';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR NpCs Open. Hour Cal. Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Calendar Date"; "Calendar Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date field';
                }
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
                field(Weekday; Weekday)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Weekday field';
                }
            }
        }
    }
}

