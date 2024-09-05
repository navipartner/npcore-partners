page 6184740 "NPR BE Enable Fiscal Step"
{
    Extensible = false;
    PageType = CardPart;
    UsageCategory = None;
    SourceTable = "NPR BE Fiscalisation Setup";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            group(Enabling)
            {
                field("BE Fiscal Enabled"; Rec."Enable BE Fiscal")
                {
                    ApplicationArea = NPRRetail;
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
        BEFiscalizationSetup: Record "NPR BE Fiscalisation Setup";

    internal procedure CopyToTemp()
    begin
        if not BEFiscalizationSetup.Get() then
            exit;

        Rec.TransferFields(BEFiscalizationSetup);
        if not Rec.Insert() then
            Rec.Modify();
    end;

    internal procedure IsDataPopulated(): Boolean
    begin
        exit(Rec."Enable BE Fiscal");
    end;

    internal procedure CreateFiscalSetupData()
    begin
        if not Rec.Get() then
            exit;

        if not BEFiscalizationSetup.Get() then
            BEFiscalizationSetup.Init();

        BEFiscalizationSetup."Enable BE Fiscal" := Rec."Enable BE Fiscal";
        if not BEFiscalizationSetup.Insert() then
            BEFiscalizationSetup.Modify();

        EnableApplicationArea();
    end;

    internal procedure EnableApplicationArea()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if Rec."Enable BE Fiscal" then
            ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
    end;
}