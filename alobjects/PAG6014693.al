page 6014693 "Retail Admin Activities - WFs"
{
    // NPR5.51/ZESO/20190725  CASE 343621 Object created.

    Caption = 'Retail Admin Activities - WFs';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "Retail Admin Cue";

    layout
    {
        area(content)
        {
            cuegroup("POS Sales Workflow Steps")
            {
                Caption = 'POS Sales Workflow Steps';
                field("Workflow Steps Enabled"; "Workflow Steps Enabled")
                {
                }
                field("Workflow Steps Not Enabled"; "Workflow Steps Not Enabled")
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

