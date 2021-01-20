page 6151336 "NPR Retail Admin Act - Memb"
{
    Caption = 'NP Retail - Members';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "NPR Retail Admin Cue";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            cuegroup(Cue)
            {
                ShowCaption = false;
                field("Membership Setup"; Rec."Membership Setup")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Setup field';
                }
                field("Membership Sales Setup"; Rec."Membership Sales Setup")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Sales Setup field';
                }
                field("Member Alteration"; Rec."Member Alteration")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR MM Membership Alter.";
                    ToolTip = 'Specifies the value of the Member Alteration field';
                }
                field("Member Community"; Rec."Member Community")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member Community field';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset;
        if not Rec.Get then begin
            Rec.Init;
            Rec.Insert;
        end;
    end;
}

