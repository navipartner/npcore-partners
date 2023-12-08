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
        EnableLocalizationApplicationAreas(TempApplicationAreaSetup);
        EnableFiscalisationApplicationAreas(TempApplicationAreaSetup);
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

    local procedure EnableLocalizationApplicationAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        TempApplicationAreaSetup."NPR RS Local" := IsRSLocalizationEnabled();
        TempApplicationAreaSetup."NPR RS R Local" := IsRSRLocalizationEnabled();
    end;

    local procedure EnableFiscalisationApplicationAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        TempApplicationAreaSetup."NPR RS Fiscal" := IsRSFiscalisationEnabled();
        TempApplicationAreaSetup."NPR NO Fiscal" := IsNOFiscalisationEnabled();
        TempApplicationAreaSetup."NPR SI Fiscal" := IsSIFiscalisationEnabled();
        TempApplicationAreaSetup."NPR CRO Fiscal" := IsCROFiscalizationEnabled();
        TempApplicationAreaSetup."NPR BG SIS Fiscal" := IsBGSISFiscalizationEnabled();
        TempApplicationAreaSetup."NPR IT Fiscal" := IsITFiscalizationEnabled();
        TempApplicationAreaSetup."NPR DK Fiscal" := IsDKFiscalisationEnabled();
    end;

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

    local procedure IsRSFiscalisationEnabled(): Boolean
    var
        RSFiscalisationSetup: Record "NPR RS Fiscalisation Setup";
    begin
        if not RSFiscalisationSetup.Get() then
            exit(false);

        exit(RSFiscalisationSetup."Enable RS Fiscal");
    end;

    local procedure IsNOFiscalisationEnabled(): Boolean
    var
        NOFiscalisationSetup: Record "NPR NO Fiscalization Setup";
    begin
        if not NOFiscalisationSetup.Get() then
            exit(false);

        exit(NOFiscalisationSetup."Enable NO Fiscal");
    end;

    local procedure IsDKFiscalisationEnabled(): Boolean
    var
        DKFiscalisationSetup: Record "NPR DK Fiscalization Setup";
    begin
        if not DKFiscalisationSetup.Get() then
            exit(false);

        exit(DKFiscalisationSetup."Enable DK Fiscal");
    end;

    local procedure IsSIFiscalisationEnabled(): Boolean
    var
        SIFiscalisationSetup: Record "NPR SI Fiscalization Setup";
    begin
        if not SIFiscalisationSetup.Get() then
            exit(false);

        exit(SIFiscalisationSetup."Enable SI Fiscal");
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
}