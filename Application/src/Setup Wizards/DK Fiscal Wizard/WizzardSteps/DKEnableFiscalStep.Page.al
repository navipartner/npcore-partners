page 6184801 "NPR DK Enable Fiscal Step"
{
    Caption = 'DK Enable Fiscal';
    PageType = CardPart;
    SourceTable = "NPR DK Fiscalization Setup";
    SourceTableTemporary = true;
    Extensible = false;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'Enable Danish Fiscalization';
                field("Enable DK Fiscal"; Rec."Enable DK Fiscal")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Enable or disable Danish fiscalization.';
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
        if not DKFiscalizationSetup.Get() then
            exit;
        Rec.TransferFields(DKFiscalizationSetup);
        if not Rec.Insert() then
            Rec.Modify();
    end;

    internal procedure CreateDKFiscalEnableData()
    begin
        if not Rec.Get() then
            exit;
        if not DKFiscalizationSetup.Get() then
            DKFiscalizationSetup.Init();
        if Rec."Enable DK Fiscal" <> xRec."Enable DK Fiscal" then
            DKFiscalizationSetup."Enable DK Fiscal" := Rec."Enable DK Fiscal";
        if not DKFiscalizationSetup.Insert() then
            DKFiscalizationSetup.Modify();
    end;

    local procedure CheckIsDataPopulated(): Boolean
    begin
        if not Rec.Get() then
            exit(false);
        exit(Rec."Enable DK Fiscal");
    end;

    internal procedure IsDataPopulated(): Boolean
    begin
        exit(CheckIsDataPopulated());
    end;

    var
        DKFiscalizationSetup: Record "NPR DK Fiscalization Setup";
}
