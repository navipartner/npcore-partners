page 6150710 "NPR POS View List"
{
    Caption = 'POS View List';
    CardPageID = "NPR POS View Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR POS View";
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

