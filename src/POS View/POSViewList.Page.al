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

