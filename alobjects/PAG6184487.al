page 6184487 "Pepper Card Type Group"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created

    Caption = 'Pepper Card Type Group';
    PageType = List;
    SourceTable = "Pepper Card Type Group";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
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

