page 6151218 "NpCs Open. Hour Calendar"
{
    // NPR5.51/MHA /20190719  CASE 362443 Object created - Collect Store Opening Hour Sets

    Caption = 'Collect Store Opening Hour Calendar';
    PageType = List;
    SourceTable = "NpCs Open. Hour Calendar Entry";

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

    actions
    {
    }
}

