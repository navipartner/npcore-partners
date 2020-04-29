page 6150710 "POS View List"
{
    Caption = 'POS View List';
    CardPageID = "POS View Card";
    Editable = false;
    PageType = List;
    SourceTable = "POS View";
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
            }
        }
    }

    actions
    {
    }
}

