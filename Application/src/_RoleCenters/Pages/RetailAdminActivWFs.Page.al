page 6014693 "NPR Retail Admin Activ. - WFs"
{
    Caption = 'Retail Admin Activities - WFs';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "NPR Retail Admin Cue";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            cuegroup("POS Sales Workflow Steps")
            {
                Caption = 'POS Sales Workflow Steps';
                field("Workflow Steps Enabled"; Rec."Workflow Steps Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Workflow Steps Enabled field';
                }
                field("Workflow Steps Not Enabled"; Rec."Workflow Steps Not Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Workflow Steps Not Enabled field';
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

