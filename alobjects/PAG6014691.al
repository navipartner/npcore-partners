page 6014691 "Retail Admin Activities - Memb"
{
    // NPR5.51/ZESO/20190725  CASE 343621 Object created.

    Caption = 'Retail Admin Activities - Memb';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "Retail Admin Cue";

    layout
    {
        area(content)
        {
            cuegroup(Members)
            {
                Caption = 'Members';
                field("Membership Setup";"Membership Setup")
                {
                }
                field("Membership Sales Setup";"Membership Sales Setup")
                {
                }
                field("Member Alteration";"Member Alteration")
                {
                }
                field("Member Community";"Member Community")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
          Init;
          Insert;
        end;
    end;
}

