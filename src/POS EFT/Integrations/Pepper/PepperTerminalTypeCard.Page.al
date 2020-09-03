page 6184484 "NPR Pepper Terminal Type Card"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created
    // NPR5.25/BR/20160509  CASE 231481 Added field Force Fixed Currency Check.

    Caption = 'Pepper Terminal Type Card';
    PageType = Card;
    SourceTable = "NPR Pepper Terminal Type";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(ID; ID)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Active; Active)
                {
                    ApplicationArea = All;
                }
                field("Force Fixed Currency Check"; "Force Fixed Currency Check")
                {
                    ApplicationArea = All;
                }
                field(Deprecated; Deprecated)
                {
                    ApplicationArea = All;
                }
            }
            group(ATOS)
            {
                field(Overtender; Overtender)
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

