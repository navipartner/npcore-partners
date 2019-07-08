page 6150667 "NPRE Seating Location"
{
    // NPR5.34/ANEN  /2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN /20170821 CASE 283376 Solution rename to NP Restaurant

    Caption = 'Seating Locations';
    PageType = List;
    SourceTable = "NPRE Seating Location";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field(Seatings;Seatings)
                {
                    Editable = false;
                }
                field(Seats;Seats)
                {
                    Editable = false;
                }
                field("POS Store";"POS Store")
                {
                }
            }
        }
    }

    actions
    {
    }
}

