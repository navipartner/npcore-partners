page 6151214 "NpCs Store Opening Hours"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store

    Caption = 'Collect Store Opening Hours';
    PageType = List;
    SourceTable = "NpCs Store Opening Hours Entry";

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

