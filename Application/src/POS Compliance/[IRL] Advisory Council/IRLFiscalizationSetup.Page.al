page 6184791 "NPR IRL Fiscalization Setup"
{
    ApplicationArea = NPRRetail;
    Caption = 'IRL Fiscalization Setup';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR IRL Fiscalization Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            field("Enable IRL Fiscal"; Rec."Enable IRL Fiscal")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the Enable IRL Fiscalization field.';
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