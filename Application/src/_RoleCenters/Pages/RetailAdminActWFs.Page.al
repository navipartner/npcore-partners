page 6151247 "NPR Retail Admin Act - WFs"
{
    // #343621/ZESO/20190725  CASE 343621 Object created.

    Caption = 'NP Retail - POS Workflow Setups';
    PageType = CardPart;
    UsageCategory = Administration;
    RefreshOnActivate = true;
    SourceTable = "NPR NP Retail Admin Cue";

    layout
    {
        area(content)
        {
            cuegroup(" ")
            {
                Caption = ' ';
                ShowCaption = false;
                field("NPR POS Sales Workflow"; "NPR POS Sales Workflow")
                {
                    ApplicationArea = All;
                }

                field("EAN SETUPr"; "EAN SETUP")
                {
                    ApplicationArea = All;
                    Caption = 'EAN BOX SETUP';
                    ShowCaption = true;
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

