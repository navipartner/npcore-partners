codeunit 6151349 "NPR Enable Application Areas"
{
    Access = Internal;

    var
        Feature: Enum "NPR Feature";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt. Facade", 'OnGetEssentialExperienceAppAreas', '', false, false)]
    local procedure HandleOnGetEssentialExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        EnableRetailApplicationAreas(TempApplicationAreaSetup);
        EnableTicketingApplicationAreas(TempApplicationAreaSetup);
        EnableNaviConnectApplicationAreas(TempApplicationAreaSetup);
        EnableMembershipApplicationAreas(TempApplicationAreaSetup);
        EnableHeyLoyaltyApplicationAreas(TempApplicationAreaSetup);
#if not BC17
        EnableShopifyApplicationAreas(TempApplicationAreaSetup);
#endif
        EnableLocalizationApplicationAreas(TempApplicationAreaSetup);
        EnableFiscalizationApplicationAreas(TempApplicationAreaSetup);
        EnableInternalPOSScenariosAndHideOldRelatedPages(TempApplicationAreaSetup);
        EnableOnlyNewPOSEditorAndHideOldRelatedPages(TempApplicationAreaSetup);
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        EnableNPEmail(TempApplicationAreaSetup);
#endif
    end;

    local procedure EnableRetailApplicationAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        TempApplicationAreaSetup."NPR Retail" := IsFeatureEnabled(Feature::Retail);
    end;

    local procedure EnableTicketingApplicationAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        TempApplicationAreaSetup."NPR Ticket Essential" := IsFeatureEnabled(Feature::"Ticket Essential");
        TempApplicationAreaSetup."NPR Ticket Advanced" := IsFeatureEnabled(Feature::"Ticket Advanced");
        TempApplicationAreaSetup."NPR Ticket Wallet" := IsFeatureEnabled(Feature::"Ticket Wallet");
        TempApplicationAreaSetup."NPR Ticket Dynamic Price" := IsFeatureEnabled(Feature::"Ticket Dynamic Price");
    end;

    local procedure EnableNaviConnectApplicationAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        TempApplicationAreaSetup."NPR NaviConnect" := IsFeatureEnabled(Feature::NaviConnect);
    end;

    local procedure EnableMembershipApplicationAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        TempApplicationAreaSetup."NPR Membership Essential" := IsFeatureEnabled(Feature::"Membership Essential");
        TempApplicationAreaSetup."NPR Membership Advanced" := IsFeatureEnabled(Feature::"Membership Advanced");
    end;

    local procedure EnableHeyLoyaltyApplicationAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        TempApplicationAreaSetup."NPR HeyLoyalty" := IsFeatureEnabled(Feature::HeyLoyalty);
    end;

#if not BC17
    local procedure EnableShopifyApplicationAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        TempApplicationAreaSetup."NPR Shopify" := IsFeatureEnabled(Feature::Shopify);
    end;
#endif

    local procedure EnableLocalizationApplicationAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        TempApplicationAreaSetup."NPR RS Local" := IsRSLocalizationEnabled();
        TempApplicationAreaSetup."NPR RS R Local" := IsRSRLocalizationEnabled();
    end;

    local procedure EnableFiscalizationApplicationAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        TempApplicationAreaSetup."NPR RS Fiscal" := IsRSFiscalizationEnabled();
        TempApplicationAreaSetup."NPR NO Fiscal" := IsNOFiscalizationEnabled();
        TempApplicationAreaSetup."NPR SI Fiscal" := IsSIFiscalizationEnabled();
        TempApplicationAreaSetup."NPR CRO Fiscal" := IsCROFiscalizationEnabled();
        TempApplicationAreaSetup."NPR BG SIS Fiscal" := IsBGSISFiscalizationEnabled();
        TempApplicationAreaSetup."NPR IT Fiscal" := IsITFiscalizationEnabled();
        TempApplicationAreaSetup."NPR DK Fiscal" := IsDKFiscalizationnEnabled();
        TempApplicationAreaSetup."NPR HU MultiSoft EInv" := IsHUMultiSoftEInvEnabled();
        TempApplicationAreaSetup."NPR SE CleanCash" := IsSEFiscalizationEnabled();
        TempApplicationAreaSetup."NPR AT Fiscal" := IsATFiscalizationEnabled();
        TempApplicationAreaSetup."NPR ES Fiscal" := IsESFiscalizationEnabled();
        TempApplicationAreaSetup."NPR RS EInvoice" := IsRSEInvoiceEnabled();
        TempApplicationAreaSetup."NPR DE Fiscal" := IsDEFiscalizationEnabled();
        TempApplicationAreaSetup."NPR BE Fiscal" := IsBEFiscalizationEnabled();
    end;

    local procedure EnableInternalPOSScenariosAndHideOldRelatedPages(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        TempApplicationAreaSetup."NPR Obsolete POS Scenarios" := not IsFeatureEnabled(Feature::"POS Scenarios Obsoleted");
    end;

    local procedure EnableOnlyNewPOSEditorAndHideOldRelatedPages(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        TempApplicationAreaSetup."NPR New POS Editor" := not IsFeatureEnabled(Feature::"New POS Editor");
    end;

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    local procedure EnableNPEmail(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        TempApplicationAreaSetup."NPR NP Email" := IsFeatureEnabled(Feature::"NP Email");
    end;
#endif

    local procedure IsFeatureEnabled(FeatureToCheck: Enum "NPR Feature"): Boolean
    var
        FeatureManagement: Interface "NPR Feature Management";
    begin
        FeatureManagement := FeatureToCheck;
        exit(FeatureManagement.IsFeatureEnabled());
    end;

    local procedure IsRSLocalizationEnabled(): Boolean
    var
        RSLocalisationSetup: Record "NPR RS Localisation Setup";
    begin
        if not RSLocalisationSetup.Get() then
            exit(false);

        exit(RSLocalisationSetup."Enable RS Local");
    end;

    local procedure IsRSRLocalizationEnabled(): Boolean
    var
        RSRLocalizationSetup: Record "NPR RS R Localization Setup";
    begin
        if not RSRLocalizationSetup.Get() then
            exit(false);

        exit(RSRLocalizationSetup."Enable RS Retail Localization");
    end;

    local procedure IsRSFiscalizationEnabled(): Boolean
    var
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
    begin
        if not RSFiscalizationSetup.Get() then
            exit(false);

        exit(RSFiscalizationSetup."Enable RS Fiscal");
    end;

    local procedure IsNOFiscalizationEnabled(): Boolean
    var
        NOFiscalizationSetup: Record "NPR NO Fiscalization Setup";
    begin
        if not NOFiscalizationSetup.Get() then
            exit(false);

        exit(NOFiscalizationSetup."Enable NO Fiscal");
    end;

    local procedure IsDKFiscalizationnEnabled(): Boolean
    var
        DKFiscalizationSetup: Record "NPR DK Fiscalization Setup";
    begin
        if not DKFiscalizationSetup.Get() then
            exit(false);

        exit(DKFiscalizationSetup."Enable DK Fiscal");
    end;

    local procedure IsHUMultiSoftEInvEnabled(): Boolean
    var
        HUMSFiscalizationSetup: Record "NPR HU MS Fiscalization Setup";
    begin
        if not HUMSFiscalizationSetup.Get() then
            exit(false);

        exit(HUMSFiscalizationSetup."Enable HU Fiscal");
    end;

    local procedure IsSIFiscalizationEnabled(): Boolean
    var
        SIFiscalizationSetup: Record "NPR SI Fiscalization Setup";
    begin
        if not SIFiscalizationSetup.Get() then
            exit(false);

        exit(SIFiscalizationSetup."Enable SI Fiscal");
    end;

    local procedure IsCROFiscalizationEnabled(): Boolean
    var
        CROFiscalizationSetup: Record "NPR CRO Fiscalization Setup";
    begin
        if not CROFiscalizationSetup.Get() then
            exit(false);

        exit(CROFiscalizationSetup."Enable CRO Fiscal");
    end;

    local procedure IsBGSISFiscalizationEnabled(): Boolean
    var
        BGFiscalizationSetup: Record "NPR BG Fiscalization Setup";
    begin
        if not BGFiscalizationSetup.Get() then
            exit(false);

        exit(BGFiscalizationSetup."BG SIS Fiscal Enabled");
    end;

    local procedure IsITFiscalizationEnabled(): Boolean
    var
        ITFiscalizationSetup: Record "NPR IT Fiscalization Setup";
    begin
        if not ITFiscalizationSetup.Get() then
            exit(false);

        exit(ITFiscalizationSetup."Enable IT Fiscal");
    end;

    local procedure IsSEFiscalizationEnabled(): Boolean
    var
        SEFiscalizationSetup: Record "NPR SE Fiscalization Setup.";
    begin
        if not SEFiscalizationSetup.Get() then
            exit(false);

        exit(SEFiscalizationSetup."Enable SE Fiscal");
    end;

    local procedure IsATFiscalizationEnabled(): Boolean
    var
        ATFiscalizationSetup: Record "NPR AT Fiscalization Setup";
    begin
        if not ATFiscalizationSetup.Get() then
            exit(false);

        exit(ATFiscalizationSetup."AT Fiscal Enabled");
    end;

    local procedure IsESFiscalizationEnabled(): Boolean
    var
        ESFiscalizationSetup: Record "NPR ES Fiscalization Setup";
    begin
        if not ESFiscalizationSetup.Get() then
            exit(false);

        exit(ESFiscalizationSetup."ES Fiscal Enabled");
    end;

    local procedure IsRSEinvoiceEnabled(): Boolean
    var
        RSEInvoiceSetup: Record "NPR RS E-Invoice Setup";
    begin
        if not RSEInvoiceSetup.Get() then
            exit(false);

        exit(RSEInvoiceSetup."Enable RS E-Invoice");
    end;

    local procedure IsDEFiscalizationEnabled(): Boolean
    var
        DEFiscalizationSetup: Record "NPR DE Fiscalization Setup";
    begin
        if not DEFiscalizationSetup.Get() then
            exit(false);

        exit(DEFiscalizationSetup."Enable DE Fiscal");
    end;

    local procedure IsBEFiscalizationEnabled(): Boolean
    var
        BEFiscalizationSetup: Record "NPR BE Fiscalisation Setup";
    begin
        if not BEFiscalizationSetup.Get() then
            exit(false);

        exit(BEFiscalizationSetup."Enable BE Fiscal");
    end;

    internal procedure IsNPRRetailApplicationAreaEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if ApplicationAreaMgmtFacade.GetApplicationAreaSetupRecFromCompany(ApplicationAreaSetup, CompanyName()) then
            exit(ApplicationAreaSetup."NPR Retail");
    end;
}