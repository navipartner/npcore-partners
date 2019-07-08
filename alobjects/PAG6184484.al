page 6184484 "Pepper Terminal Type Card"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created
    // NPR5.25/BR/20160509  CASE 231481 Added field Force Fixed Currency Check.

    Caption = 'Pepper Terminal Type Card';
    PageType = Card;
    SourceTable = "Pepper Terminal Type";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(ID;ID)
                {
                }
                field(Description;Description)
                {
                }
                field(Active;Active)
                {
                }
                field("Force Fixed Currency Check";"Force Fixed Currency Check")
                {
                }
                field(Deprecated;Deprecated)
                {
                }
            }
            group(ATOS)
            {
                field(Overtender;Overtender)
                {
                }
            }
        }
    }

    actions
    {
    }
}

