page 6014691 "NPR Retail Admin Activ. - Memb"
{
    Caption = 'Retail Admin Activities - Memb';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "NPR Retail Admin Cue";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            cuegroup(Members)
            {
                Caption = 'Members';
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

