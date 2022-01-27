page 6150742 "NPR POS Admin. Template Scopes"
{
    Extensible = False;
    // NPR5.51/VB  /20190719  CASE 352582 POS Administrative Templates feature

    Caption = 'POS Admin. Template Scopes';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR POS Admin. Template Scope";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Applies To"; Rec."Applies To")
                {

                    ToolTip = 'Specifies the value of the Applies To field';
                    ApplicationArea = NPRRetail;
                }
                field("Applies To Code"; Rec."Applies To Code")
                {

                    ToolTip = 'Specifies the value of the Applies To Code field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

