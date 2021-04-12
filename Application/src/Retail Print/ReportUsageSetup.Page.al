page 6014487 "NPR Report Usage Setup"
{
    // NPR5.48/TJ  /20181108 CASE 324444 New object

    Caption = 'Report Usage Setup';
    PageType = Card;
    SourceTable = "NPR Report Usage Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enabled field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}

