page 6150643 "NPR POS Info Links"
{
    // NPR5.26/OSFI/20160810 CASE 246167 Object Created

    Caption = 'POS Info Links';
    PageType = List;
    SourceTable = "NPR POS Info Link Table";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'Group';
                field("POS Info Code"; "POS Info Code")
                {
                    ApplicationArea = All;
                }
                field("When to Use"; "When to Use")
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

