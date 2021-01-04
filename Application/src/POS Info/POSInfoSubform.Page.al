page 6150641 "NPR POS Info Subform"
{
    // NPR5.26/OSFI/20160810 CASE 246167 Object Created

    Caption = 'POS Info Subform';
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR POS Info Subcode";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'Group';
                field(Subcode; Subcode)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Subcode field';
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

