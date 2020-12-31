page 6184890 "NPR Server Overview"
{
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

