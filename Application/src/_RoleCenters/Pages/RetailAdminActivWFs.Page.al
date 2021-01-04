page 6014693 "NPR Retail Admin Activ. - WFs"
{
    // NPR5.51/ZESO/20190725  CASE 343621 Object created.

    Caption = 'Retail Admin Activities - WFs';
    PageType = CardPart;
    UsageCategory = Administration;
    RefreshOnActivate = true;
    SourceTable = "NPR Retail Admin Cue";

    layout
    {
        area(content)
        {
            cuegroup("POS Sales Workflow Steps")
            {
                Caption = 'POS Sales Workflow Steps';
                field("Workflow Steps Enabled"; "Workflow Steps Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Workflow Steps Enabled field';
                }
                field("Workflow Steps Not Enabled"; "Workflow Steps Not Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Workflow Steps Not Enabled field';
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

