page 6014693 "Retail Admin Activities - WFs"
{
    // #343621/ZESO/20190725  CASE 343621 Object created.

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
                CueGroupLayout = Columns;
                field("Workflow Steps Enabled";"Workflow Steps Enabled")
                {
                }
                field("Workflow Steps Not Enabled";"Workflow Steps Not Enabled")
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

