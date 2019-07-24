page 6151218 "NpCs Open. Hour Calendar"
{
    // #362443/MHA /20190719  CASE 362443 Object created - Collect Store Opening Hour Sets

    Caption = 'Collect Store Opening Hour Calendar';
    PageType = List;
    SourceTable = "NpCs Open. Hour Calendar Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Calendar Date";"Calendar Date")
                {
                }
                field("Start Time";"Start Time")
                {
                }
                field("End Time";"End Time")
                {
                }
                field(Weekday;Weekday)
                {
                }
            }
        }
    }

    actions
    {
    }
}

