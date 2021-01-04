page 6014576 "NPR POS Customer Loc."
{
    // NPR5.22/MMV/20160408 CASE 232067 Created page

    Caption = 'POS Customer Location';
    PageType = List;
    SourceTable = "NPR POS Customer Location";
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
                    ToolTip = 'Specifies the value of the No. field';
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

