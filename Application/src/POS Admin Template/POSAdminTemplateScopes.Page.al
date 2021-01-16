page 6150742 "NPR POS Admin. Template Scopes"
{
    // NPR5.51/VB  /20190719  CASE 352582 POS Administrative Templates feature

    Caption = 'POS Admin. Template Scopes';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Admin. Template Scope";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Applies To"; "Applies To")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Applies To field';
                }
                field("Applies To Code"; "Applies To Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Applies To Code field';
                }
            }
        }
    }

    actions
    {
    }
}

