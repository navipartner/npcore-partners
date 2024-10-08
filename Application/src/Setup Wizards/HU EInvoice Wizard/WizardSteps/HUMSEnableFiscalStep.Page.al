page 6184775 "NPR HU MS Enable Fiscal Step"
{
    Caption = 'HU MS Enable Fiscal Setup';
    Extensible = false;
    PageType = CardPart;
    SourceTable = "NPR HU MS Fiscalization Setup";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(Enabling)
            {
                Caption = 'Enable Fiscalization';
                ShowCaption = false;

                field("Enable HU Fiscal"; Rec."Enable HU Fiscal")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the HU MS Fiscalization is enabled.';
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
        if not HUMSFiscalizationSetup.Get() then
            exit;
        Rec.TransferFields(HUMSFiscalizationSetup);
        if not Rec.Insert() then
            Rec.Modify();
    end;

    internal procedure HUMSSetupToCreate(): Boolean
    begin
        exit(Rec."Enable HU Fiscal");
    end;

    internal procedure CreateHUMSFiscalEnableData()
    begin
        Rec.Get();
        if not HUMSFiscalizationSetup.Get() then
            HUMSFiscalizationSetup.Init();
        HUMSFiscalizationSetup."Enable HU Fiscal" := Rec."Enable HU Fiscal";
        if not HUMSFiscalizationSetup.Insert() then
            HUMSFiscalizationSetup.Modify();
        EnableApplicationArea();
    end;

    internal procedure EnableApplicationArea()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if Rec."Enable HU Fiscal" then
            ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
    end;

    var
        HUMSFiscalizationSetup: Record "NPR HU MS Fiscalization Setup";
}

