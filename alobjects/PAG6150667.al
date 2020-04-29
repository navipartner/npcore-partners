page 6150667 "NPRE Seating Location"
{
    // NPR5.34/ANEN/2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN/20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.52/ALPO/20190813 CASE 360258 Location specific setting of 'Auto print kitchen order'
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant

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
                field("Restaurant Code";"Restaurant Code")
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
                field("Auto Send Kitchen Order";"Auto Send Kitchen Order")
                {
                }
            }
        }
    }

    actions
    {
    }
}

