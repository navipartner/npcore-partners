page 6150643 "POS Info Links"
{
    // NPR5.26/OSFI/20160810 CASE 246167 Object Created

    Caption = 'POS Info Links';
    PageType = List;
    SourceTable = "POS Info Link Table";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'Group';
                field("POS Info Code";"POS Info Code")
                {
                }
                field("When to Use";"When to Use")
                {
                }
            }
        }
    }

    actions
    {
    }
}

