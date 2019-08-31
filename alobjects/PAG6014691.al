page 6014691 "Retail Admin Activities - Memb"
{
    // #343621/ZESO/20190725  CASE 343621 Object created.

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

