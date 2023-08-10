page 6151108 "NPR RS Localisation Setup"
{
    ApplicationArea = NPRRetail;
    Caption = 'RS Localisation Setup';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR RS Localisation Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General Settings';
                field("Enable RS Local"; Rec."Enable RS Local")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Enable RS Localisation field.';
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