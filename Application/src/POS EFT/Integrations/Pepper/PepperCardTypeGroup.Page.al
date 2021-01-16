page 6184487 "NPR Pepper Card Type Group"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created

    Caption = 'Pepper Card Type Group';
    PageType = List;
    SourceTable = "NPR Pepper Card Type Group";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
        }
    }

    actions
    {
    }
}

