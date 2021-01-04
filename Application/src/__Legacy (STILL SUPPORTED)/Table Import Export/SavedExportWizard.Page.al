page 6014568 "NPR Saved Export Wizard"
{
    // NPR5.23/THRO/20160404 CASE 234161 Table for saving template setup

    Caption = 'Saved Export Wizard';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Saved Export Wizard";

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

