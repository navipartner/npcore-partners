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
                }
                field("Start Time"; "Start Time")
                {
                    ApplicationArea = All;
                }
                field("End Time"; "End Time")
                {
                    ApplicationArea = All;
                }
                field(Weekday; Weekday)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}

