page 6151336 "NPR Retail Admin Act - Memb"
{
    // #343621/ZESO/20190725  CASE 343621 Object created.

    Caption = 'NP Retail - Members';
    PageType = CardPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    RefreshOnActivate = true;
    SourceTable = "NPR Retail Admin Cue";

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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Setup field';
                }
                field("Membership Sales Setup"; "Membership Sales Setup")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Sales Setup field';
                }
                field("Member Alteration"; "Member Alteration")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR MM Membership Alter.";
                    ToolTip = 'Specifies the value of the Member Alteration field';
                }
                field("Member Community"; "Member Community")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member Community field';
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

