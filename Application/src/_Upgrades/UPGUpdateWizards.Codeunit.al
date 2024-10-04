codeunit 6150647 "NPR UPG Update Wizards"
{
    Subtype = Upgrade;
    Access = Internal;

    trigger OnUpgradePerCompany()
    begin
        CheckAuditHandlerAndEnableFiscalization();
    end;

    local procedure CheckAuditHandlerAndEnableFiscalization()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Update Wizards', 'UpdateWizardFiscalization');

        if not UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpdateWizardFiscalization')) then begin
            CheckAndEnableFiscalization();
            UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpdateWizardFiscalization'));
            exit;
        end;

        LogMessageStopwatch.LogFinish();
    end;

    var
        EnabledApplicationArea: Boolean;

    Internal procedure CheckAndEnableFiscalization()
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
        DEAuditMgt: Codeunit "NPR DE Audit Mgt.";
        SEAuditMgt: Codeunit "NPR CleanCash XCCSP Protocol";
        BEAuditMgt: Codeunit "NPR BE Audit Mgt.";
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
        SIAuditMgt: Codeunit "NPR SI Audit Mgt.";
        CROAuditMgt: Codeunit "NPR CRO Audit Mgt.";
        NOAuditMgt: Codeunit "NPR NO Audit Mgt.";
        BGAuditMgt: Codeunit "NPR BG SIS Audit Mgt.";
        ITAuditMgt: Codeunit "NPR IT Audit Mgt.";
        DKAuditMgt: Codeunit "NPR DK Audit Mgt.";
        HUAuditMgt: Codeunit "NPR HU MS Audit Mgt.";
        ATAuditMgt: Codeunit "NPR AT Audit Mgt.";
    begin
        EnabledApplicationArea := false;
        POSAuditProfile.SetFilter("Audit Handler", '<>%1', '');
        if POSAuditProfile.FindSet() then
            repeat
                case POSAuditProfile."Audit Handler" of
                    DEAuditMgt.HandlerCode():
                        EnableDEFiskalyFiscalization();
                    UpperCase(SEAuditMgt.HandlerCode()):
                        EnableSECleanCashFiscalization();
                    BEAuditMgt.HandlerCode():
                        EnableBEFiscalization();
                    RSAuditMgt.HandlerCode():
                        EnableRSFiscalization();
                    SIAuditMgt.HandlerCode():
                        EnableSIFiscalization();
                    CROAuditMgt.HandlerCode():
                        EnableCROFiscalization();
                    NOAuditMgt.HandlerCode():
                        EnableNOFiscalization();
                    BGAuditMgt.HandlerCode():
                        EnableBGFiscalization();
                    ITAuditMgt.HandlerCode():
                        EnableITFiscalization();
                    DKAuditMgt.HandlerCode():
                        EnableDKFiscalization();
                    HUAuditMgt.HandlerCode():
                        EnableHUMSFiscalization();
                    ATAuditMgt.HandlerCode():
                        EnableATFiskalyFiscalization();
                end;
            until POSAuditProfile.Next() = 0;

        if EnabledApplicationArea then
            EnableApplicationArea();
    end;

    local procedure EnableDEFiskalyFiscalization()
    var
        DEFiscalizationSetup: Record "NPR DE Fiscalization Setup";
    begin
        if not DEFiscalizationSetup.Get() then
            DEFiscalizationSetup.Init();
        DEFiscalizationSetup."Enable DE Fiscal" := true;

        if not DEFiscalizationSetup.Insert() then
            DEFiscalizationSetup.Modify(true);

        EnableApplicationArea();
    end;


    local procedure EnableSECleanCashFiscalization()
    var
        SECleanCashFiscalizationSetup: Record "NPR SE Fiscalization Setup.";
    begin
        if not SECleanCashFiscalizationSetup.Get() then
            SECleanCashFiscalizationSetup.Init();
        SECleanCashFiscalizationSetup."Enable SE Fiscal" := true;

        if not SECleanCashFiscalizationSetup.Insert() then
            SECleanCashFiscalizationSetup.Modify(true);

        EnabledApplicationArea := true;
    end;

    local procedure EnableBEFiscalization()
    var
        BEFiscalizationSetup: Record "NPR BE Fiscalisation Setup";
    begin
        if not BEFiscalizationSetup.Get() then
            BEFiscalizationSetup.Init();
        BEFiscalizationSetup."Enable BE Fiscal" := true;

        if not BEFiscalizationSetup.Insert() then
            BEFiscalizationSetup.Modify(true);

        EnabledApplicationArea := true;
    end;


    local procedure EnableRSFiscalization()
    var
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
    begin
        if not RSFiscalizationSetup.Get() then
            RSFiscalizationSetup.Init();
        RSFiscalizationSetup."Enable RS Fiscal" := true;

        if not RSFiscalizationSetup.Insert() then
            RSFiscalizationSetup.Modify(true);

        EnabledApplicationArea := true;
    end;

    local procedure EnableSIFiscalization()
    var
        SIFiscalizationSetup: Record "NPR SI Fiscalization Setup";
    begin
        if not SIFiscalizationSetup.Get() then
            SIFiscalizationSetup.Init();
        SIFiscalizationSetup."Enable SI Fiscal" := true;

        if not SIFiscalizationSetup.Insert() then
            SIFiscalizationSetup.Modify(true);

        EnabledApplicationArea := true;
    end;

    local procedure EnableCROFiscalization()
    var
        CROFiscalizationSetup: Record "NPR CRO Fiscalization Setup";
    begin
        if not CROFiscalizationSetup.Get() then
            CROFiscalizationSetup.Init();
        CROFiscalizationSetup."Enable CRO Fiscal" := true;

        if not CROFiscalizationSetup.Insert() then
            CROFiscalizationSetup.Modify(true);

        EnabledApplicationArea := true;
    end;


    local procedure EnableNOFiscalization()
    var
        NOFiscalizationSetup: Record "NPR NO Fiscalization Setup";
    begin
        if not NOFiscalizationSetup.Get() then
            NOFiscalizationSetup.Init();
        NOFiscalizationSetup."Enable NO Fiscal" := true;

        if not NOFiscalizationSetup.Insert() then
            NOFiscalizationSetup.Modify(true);

        EnabledApplicationArea := true;
    end;

    local procedure EnableBGFiscalization()
    var
        BGFiscalizationSetup: Record "NPR BG Fiscalization Setup";
    begin
        if not BGFiscalizationSetup.Get() then
            BGFiscalizationSetup.Init();
        BGFiscalizationSetup."Enable BG Fiscal" := true;

        if not BGFiscalizationSetup.Insert() then
            BGFiscalizationSetup.Modify(true);

        EnabledApplicationArea := true;
    end;

    local procedure EnableITFiscalization()
    var
        ITFiscalizationSetup: Record "NPR IT Fiscalization Setup";
    begin
        if not ITFiscalizationSetup.Get() then
            ITFiscalizationSetup.Init();
        ITFiscalizationSetup."Enable IT Fiscal" := true;

        if not ITFiscalizationSetup.Insert() then
            ITFiscalizationSetup.Modify(true);

        EnabledApplicationArea := true;
    end;

    local procedure EnableDKFiscalization()
    var
        DKFiscalizationSetup: Record "NPR DK Fiscalization Setup";
    begin
        if not DKFiscalizationSetup.Get() then
            DKFiscalizationSetup.Init();
        DKFiscalizationSetup."Enable DK Fiscal" := true;

        if not DKFiscalizationSetup.Insert() then
            DKFiscalizationSetup.Modify(true);

        EnabledApplicationArea := true;
    end;

    local procedure EnableHUMSFiscalization()
    var
        HUMSFiscalizationSetup: Record "NPR HU MS Fiscalization Setup";
    begin
        if not HUMSFiscalizationSetup.Get() then
            HUMSFiscalizationSetup.Init();
        HUMSFiscalizationSetup."Enable HU Fiscal" := true;

        if not HUMSFiscalizationSetup.Insert() then
            HUMSFiscalizationSetup.Modify(true);

        EnabledApplicationArea := true;
    end;

    local procedure EnableATFiskalyFiscalization()
    var
        ATFiskalySetup: Record "NPR AT Fiscalization Setup";
    begin
        if not ATFiskalySetup.Get() then
            ATFiskalySetup.Init();
        ATFiskalySetup."AT Fiscal Enabled" := true;

        if not ATFiskalySetup.Insert() then
            ATFiskalySetup.Modify(true);

        EnabledApplicationArea := true;
    end;

    internal procedure EnableApplicationArea()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR UPG Update Wizards");
    end;
}