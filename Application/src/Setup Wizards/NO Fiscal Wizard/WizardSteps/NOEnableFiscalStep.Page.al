page 6184790 "NPR NO Enable Fiscal Step"
{
    Caption = 'NO Enable Fiscal';
    PageType = CardPart;
    SourceTable = "NPR NO Fiscalization Setup";
    SourceTableTemporary = true;
    Extensible = false;
    UsageCategory = None;
    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'Enable Norwegian Fiscalization';
                field("Enable NO Fiscal"; Rec."Enable NO Fiscal")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Enable or disable Norwegian fiscalization.';
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

    internal procedure CopyRealToTemp()
    begin
        if not NOFiscalizationSetup.Get() then
            exit;
        Rec.TransferFields(NOFiscalizationSetup);
        if not Rec.Insert() then
            Rec.Modify();
    end;

    internal procedure CreateNOFiscalEnableData()
    begin
        if not Rec.FindFirst() then
            exit;
        if not NOFiscalizationSetup.Get() then
            NOFiscalizationSetup.Init();
        if Rec."Enable NO Fiscal" <> xRec."Enable NO Fiscal" then
            NOFiscalizationSetup."Enable NO Fiscal" := Rec."Enable NO Fiscal";
        if not NOFiscalizationSetup.Insert() then
            NOFiscalizationSetup.Modify();
    end;

    local procedure CheckIsDataPopulated(): Boolean
    begin
        if not Rec.Get() then
            exit(false);
        exit(Rec."Enable NO Fiscal");
    end;

    internal procedure IsDataPopulated(): Boolean
    begin
        exit(CheckIsDataPopulated());
    end;

    var
        NOFiscalizationSetup: Record "NPR NO Fiscalization Setup";
}
