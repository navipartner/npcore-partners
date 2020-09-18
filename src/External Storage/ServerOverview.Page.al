page 6184890 "NPR Server Overview"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created

    Caption = 'Server Overview';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = File;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Path; Path)
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field(Size; Size)
                {
                    ApplicationArea = All;
                }
                field("Date"; Date)
                {
                    ApplicationArea = All;
                }
                field("Time"; Time)
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

