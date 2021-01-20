page 6151247 "NPR Retail Admin Act - WFs"
{
    Caption = 'NP Retail - POS Workflow Setups';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "NPR NP Retail Admin Cue";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            cuegroup(Cue)
            {
                ShowCaption = false;
                field("NPR POS Sales Workflow"; Rec."NPR POS Sales Workflow")
                {
                    ApplicationArea = All;
                    Caption = 'POS Sales Workflows';
                    ShowCaption = true;
                    ToolTip = 'Specifies the value of the POS Sales Workflows field';
                }

                field("EAN SETUPr"; Rec."EAN SETUP")
                {
                    ApplicationArea = All;
                    Caption = 'EAN BOX SETUP';
                    ShowCaption = true;
                    ToolTip = 'Specifies the value of the EAN BOX SETUP field';
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

