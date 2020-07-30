page 6151247 "NP Retail Admin Act - WFs"
{
    // #343621/ZESO/20190725  CASE 343621 Object created.

    Caption = 'NP Retail - POS Workflow Setups';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "NP Retail Admin Cue";

    layout
    {
        area(content)
        {
            cuegroup(" ")
            {
                /* group("1st group")
                 {
                     */
                Caption = ' ';
                // CueGroupLayout = Columns;
                ShowCaption = false;
                field("Workflow Steps Enabled"; "Workflow Steps Enabled")
                {
                }
                field("Workflow Steps Not Enabled"; "Workflow Steps Not Enabled")
                {
                }

                field("EAN SETUPr"; "EAN SETUP")
                {
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

