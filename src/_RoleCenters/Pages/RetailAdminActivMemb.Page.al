page 6014691 "NPR Retail Admin Activ. - Memb"
{
    // NPR5.51/ZESO/20190725  CASE 343621 Object created.

    Caption = 'Retail Admin Activities - Memb';
    PageType = CardPart;
    UsageCategory = Administration;
    RefreshOnActivate = true;
    SourceTable = "NPR Retail Admin Cue";

    layout
    {
        area(content)
        {
            cuegroup(Members)
            {
                Caption = 'Members';
                field("Membership Setup"; "Membership Setup")
                {
                    ApplicationArea = All;
                }
                field("Membership Sales Setup"; "Membership Sales Setup")
                {
                    ApplicationArea = All;
                }
                field("Member Alteration"; "Member Alteration")
                {
                    ApplicationArea = All;
                }
                field("Member Community"; "Member Community")
                {
                    ApplicationArea = All;
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

