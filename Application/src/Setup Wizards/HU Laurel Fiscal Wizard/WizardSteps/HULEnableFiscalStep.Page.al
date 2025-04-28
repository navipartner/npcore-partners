page 6185002 "NPR HU L Enable Fiscal Step"
{
    Caption = 'HU Laurel Enable Fiscal Setup';
    Extensible = false;
    PageType = CardPart;
    SourceTable = "NPR HU L Fiscalization Setup";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(Enabling)
            {
                Caption = 'Enable Fiscalization';
                field("HU Laurel Fiscal Enabled"; Rec."HU Laurel Fiscal Enabled")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Fiscalization Enabled';
                    ToolTip = 'Specifies whether Laurel fiscal integration is enabled.';
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
        HULFiscalizationSetup: Record "NPR HU L Fiscalization Setup";

    internal procedure CopyToTemp()
    begin
        if not HULFiscalizationSetup.Get() then
            exit;

        Rec.TransferFields(HULFiscalizationSetup);
        if not Rec.Insert() then
            Rec.Modify();
    end;

    internal procedure IsDataPopulated(): Boolean
    begin
        exit(Rec."HU Laurel Fiscal Enabled");
    end;

    internal procedure CreateFiscalSetupData()
    begin
        if not Rec.Get() then
            exit;

        if not HULFiscalizationSetup.Get() then
            HULFiscalizationSetup.Init();

        HULFiscalizationSetup."HU Laurel Fiscal Enabled" := Rec."HU Laurel Fiscal Enabled";
        if not HULFiscalizationSetup.Insert() then
            HULFiscalizationSetup.Modify();

        EnableApplicationArea();
    end;

    internal procedure EnableApplicationArea()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if Rec."HU Laurel Fiscal Enabled" then
            ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
    end;
}