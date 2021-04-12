page 6150643 "NPR POS Info Links"
{
    // NPR5.26/OSFI/20160810 CASE 246167 Object Created

    Caption = 'POS Info Links';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Info Link Table";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'Group';
                field("POS Info Code"; Rec."POS Info Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Info Code field';
                }
                field("When to Use"; Rec."When to Use")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the When to Use field';
                }
            }
        }
    }

    actions
    {
    }
}

