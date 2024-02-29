page 6150820 "NPR BG VISION Local. Setup"
{
    ApplicationArea = NPRRetail;
    Caption = 'BG VISION Localisation Setup';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR BG Vision Local. Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General Settings';

                field("Enable BG VISION Local"; Rec."Enable BG VISION Local")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Enable BG VISION Localisation field.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
