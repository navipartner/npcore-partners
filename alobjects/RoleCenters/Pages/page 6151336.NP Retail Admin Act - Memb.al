page 6151336 "NP Retail Admin Act - Memb"
{
    // #343621/ZESO/20190725  CASE 343621 Object created.

    Caption = 'NP Retail - Members';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "NP Retail Admin Cue";

    layout
    {
        area(content)
        {
            cuegroup(" ")
            {
                Caption = ' ';
                ShowCaption = false;
                field("Membership Setup"; "Membership Setup")
                {
                }
                field("Membership Sales Setup"; "Membership Sales Setup")
                {
                }
                field("Member Alteration"; "Member Alteration")
                {
                    DrillDownPageID = "MM Membership Alteration";
                }
                field("Member Community"; "Member Community")
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

