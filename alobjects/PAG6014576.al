page 6014576 "POS Customer Location"
{
    // NPR5.22/MMV/20160408 CASE 232067 Created page

    Caption = 'POS Customer Location';
    PageType = List;
    SourceTable = "POS Customer Location";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
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

