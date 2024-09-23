page 6184811 "NPR DE Enable Fiscal Step"
{
    Extensible = false;
    PageType = CardPart;
    UsageCategory = None;
    SourceTable = "NPR DE Fiscalization Setup";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            group(Enabling)
            {
                field("DE Fiscal Enabled"; Rec."Enable DE Fiscal")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Enable DE Fiscalization';
                    ToolTip = 'Specifies whether fiscal integration is enabled.';
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

    var
        DEFiscalizationSetup: Record "NPR DE Fiscalization Setup";

    internal procedure CopyToTemp()
    begin
        if not DEFiscalizationSetup.Get() then
            exit;

        Rec.TransferFields(DEFiscalizationSetup);
        if not Rec.Insert() then
            Rec.Modify();
    end;

    internal procedure IsDataPopulated(): Boolean
    begin
        exit(Rec."Enable DE Fiscal");
    end;

    internal procedure CreateFiscalSetupData()
    begin
        if not Rec.Get() then
            exit;

        if not DEFiscalizationSetup.Get() then
            DEFiscalizationSetup.Init();

        DEFiscalizationSetup."Enable DE Fiscal" := Rec."Enable DE Fiscal";
        if not DEFiscalizationSetup.Insert() then
            DEFiscalizationSetup.Modify();

        EnableApplicationArea();
    end;

    internal procedure EnableApplicationArea()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if Rec."Enable DE Fiscal" then
            ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
    end;
}