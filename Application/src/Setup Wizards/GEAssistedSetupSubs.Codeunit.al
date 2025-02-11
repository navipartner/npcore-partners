codeunit 6014490 "NPR GE Assisted Setup Subs"
{
    Access = Internal;
#IF BC17
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assisted Setup", 'OnRegister', '', false, false)]
    local procedure RegisterWizard_OnRegisterAssistedSetup()
    var
        AssistedSetup: Codeunit "Assisted Setup";
    begin
        AssistedSetup.Remove(Page::"NPR GraphApi Setup Wizard");
        AssistedSetup.Remove(Page::"NPR Magento Wizard");
        AddRetailSetupsWizard();
        AddRestaurantSetupsWizard();
        AddAttractionSetupsWizard();
        AddCROFiscalizationSetupsWizard();
        AddRSFiscalizationSetupsWizard();
        AddBGSISFiscalizationSetupsWizard();
        AddSIFiscalizationSetupsWizard();
        AddITFiscalizationSetupsWizard();
        AddATFiscalizationSetupsWizard();
        AddBEFiscalizationSetupsWizard();
        AddRSEInvoiceSetupsWizard();
        AddDEFiscalizationSetupsWizard();
        AddIRLFiscalizationSetupsWizard();
        AddNOFiscalizationSetupsWizard();
        AddSECCFiscalizationSetupsWizard();
        AddHUMSFiscalizationSetupsWizard();
        AddDKFiscalizationSetupsWizard();
        AddFRFiscalizationSetupsWizard();
        AddESFiscalizationSetupsWizard();
    end;

    local procedure AddRetailSetupsWizard()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        POSStoresSetupTxt: Label 'Welcome to POS Stores Setup';
        ProfilesSetupTxt: Label 'Welcome to Profiles Setup';
        POSUnitsSetupTxt: Label 'Welcome to POS Unit Setup';
        POSPayBinsSetupTxt: Label 'Welcome to POS Payment Bins Setup';
        POSPayMethodsSetupTxt: Label 'Welcome to POS Pament Method Setup';
        POSPOstingSetupSetupTxt: Label 'Welcome to POS Posting Setup';
        SalespeopleSetupTxt: Label 'Welcome to Salespeople Setup';
        RetailVouchersSetupTxt: Label 'Welcome to Retail Vouchers Setup';
        AssistedSetupGroup: Enum "Assisted Setup Group";
    begin
        AssistedSetup.Add(GetAppId(), Codeunit::"NPR Welcome Video", POSStoresSetupTxt, AssistedSetupGroup::NPRetail);
        AssistedSetup.Add(GetAppId(), Page::"NPR Download&Import Data", ProfilesSetupTxt, AssistedSetupGroup::NPRetail);
        AssistedSetup.Add(GetAppId(), Page::"NPR Modify Retail Vchr. Types", RetailVouchersSetupTxt, AssistedSetupGroup::NPRetail);
        AssistedSetup.Add(GetAppId(), Page::"NPR Create POS Stores & Units", POSUnitsSetupTxt, AssistedSetupGroup::NPRetail);
        AssistedSetup.Add(GetAppId(), Page::"NPR Modify POS Posting Profile", POSPayBinsSetupTxt, AssistedSetupGroup::NPRetail);
        AssistedSetup.Add(GetAppId(), Page::"NPR Modify POS Payment Methods", POSPayMethodsSetupTxt, AssistedSetupGroup::NPRetail);
        AssistedSetup.Add(GetAppId(), Page::"NPR Modify POS Posting Setup", POSPOstingSetupSetupTxt, AssistedSetupGroup::NPRetail);
        AssistedSetup.Add(GetAppId(), Page::"NPR Modify Salespeople", SalespeopleSetupTxt, AssistedSetupGroup::NPRetail);
    end;

    local procedure AddRestaurantSetupsWizard()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        WelcomeVideoTxt: Label 'Welcome to Restaurant Module';
        FlowStatusSetupTxt: Label 'Welcome to Flow Statuses Setup';
        PrintProdCatSetupTxt: Label 'Welcome to Print/Production Category Setup';
        ItemRtngProfilesSetupTxt: Label 'Welcome to Item Routing Profiles Setup';
        RestServFlowSetupTxt: Label 'Welcome to Restaurant Service Flow Setup';
        RestLayoutSetupTxt: Label 'Welcome to Restaurant Layout Setup';
        KitchenLayoutSetupTxt: Label 'Welcome to Kitchen Layout Setup';
        AssistedSetupGroup: Enum "Assisted Setup Group";
    begin
        AssistedSetup.Add(GetAppId(), Codeunit::"NPR Restaurant Welcome Vid.", WelcomeVideoTxt, AssistedSetupGroup::NPRetail);
        AssistedSetup.Add(GetAppId(), Page::"NPR Download&Import Rest Data", FlowStatusSetupTxt, AssistedSetupGroup::NPRetail);
        AssistedSetup.Add(GetAppId(), Page::"NPR Modify Flow Statuses", FlowStatusSetupTxt, AssistedSetupGroup::NPRetail);
        AssistedSetup.Add(GetAppId(), Page::"NPR Modify Print/Prod Category", PrintProdCatSetupTxt, AssistedSetupGroup::NPRetail);
        AssistedSetup.Add(GetAppId(), Page::"NPR Modify Item Rtng. Profiles", ItemRtngProfilesSetupTxt, AssistedSetupGroup::NPRetail);
        AssistedSetup.Add(GetAppId(), Page::"NPR Create Rest. Serv. Flow", RestServFlowSetupTxt, AssistedSetupGroup::NPRetail);
        AssistedSetup.Add(GetAppId(), Page::"NPR Create Restaurant Layout", RestLayoutSetupTxt, AssistedSetupGroup::NPRetail);
        AssistedSetup.Add(GetAppId(), Page::"NPR Create Kitchen Layout", KitchenLayoutSetupTxt, AssistedSetupGroup::NPRetail);
    end;

    local procedure AddAttractionSetupsWizard()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        WelcomeVideoTxt: Label 'Welcome to Attraction Module';
        ImportTicketRapidPackagesTxt: Label 'Download and Import Ticketing Data';
        ImportMembershipRapidPackagesTxt: Label 'Download and Import Membership Data';
        CreateTickesAndTicketItemsTxt: Label 'Create Tickets & Ticket Items';
        TicketSetupWizardTxt: Label 'Welcome to Ticket Setup Wizard';
        MembershipSetupWizardTxt: Label 'Welcome to Membership Setup Wizard';
        AssistedSetupGroup: Enum "Assisted Setup Group";
    begin
        AssistedSetup.Add(GetAppId(), Codeunit::"NPR Attraction Welcome Video", WelcomeVideoTxt, AssistedSetupGroup::NPRetail);
        AssistedSetup.Add(GetAppId(), Page::"NPR TM Ticket Rapid Packages", ImportTicketRapidPackagesTxt, AssistedSetupGroup::NPRetail);
        AssistedSetup.Add(GetAppId(), Page::"NPR MM Membership Rapid Pckg.", ImportMembershipRapidPackagesTxt, AssistedSetupGroup::NPRetail);
        AssistedSetup.Add(GetAppId(), Page::"NPR Create Tickets&TicketItems", CreateTickesAndTicketItemsTxt, AssistedSetupGroup::NPRetail);
        AssistedSetup.Add(GetAppId(), Page::"NPR Ticket Setup Wizard", TicketSetupWizardTxt, AssistedSetupGroup::NPRetail);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup Membership Wizard", MembershipSetupWizardTxt, AssistedSetupGroup::NPRetail);
    end;

    local procedure AddCROFiscalizationSetupsWizard()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        CROFiscalizationSetupTxt: Label 'Welcome to Croatian Fiscalization Setup';
        CROPOSAuditProfileSetupTxt: Label 'Welcome to CRO POS Audit Profile Setup';
        CROSalespeopleSetupTxt: Label 'Welcome to CRO Salespeople Setup';
        CROPOSPaymMethodSetupTxt: Label 'Welcome to CRO POS Payment Method Setup';
        CROPaymMethodSetupTxt: Label 'Welcome to CRO Payment Method Setup';
    begin
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup CRO Fiscal", CROFiscalizationSetupTxt, AssistedSetupGroup::NPRCROFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup CRO Audit Profile", CROPOSAuditProfileSetupTxt, AssistedSetupGroup::NPRCROFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup CRO Salespeople", CROSalespeopleSetupTxt, AssistedSetupGroup::NPRCROFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup CRO POS Paym. Meth.", CROPOSPaymMethodSetupTxt, AssistedSetupGroup::NPRCROFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup CRO Paym. Meth.", CROPaymMethodSetupTxt, AssistedSetupGroup::NPRCROFiscal);
    end;

    local procedure AddRSFiscalizationSetupsWizard()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        RSFiscalizationSetupTxt: Label 'Welcome to Serbian Fiscalization Setup';
        RSPOSAuditProfileSetupTxt: Label 'Welcome to RS POS Audit Profile Setup';
        RSPOSPaymMethodSetupTxt: Label 'Welcome to RS POS Payment Method Setup';
        RSPaymMethodSetupTxt: Label 'Welcome to RS Payment Method Setup';
        RSVATPostingSetupTxt: Label 'Welcome to RS VAT Posting Setup';
    begin
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup RS Fiscal", RSFiscalizationSetupTxt, AssistedSetupGroup::NPRRSFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup RS Audit Profile", RSPOSAuditProfileSetupTxt, AssistedSetupGroup::NPRRSFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup RS POS Paym. Meth.", RSPOSPaymMethodSetupTxt, AssistedSetupGroup::NPRRSFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup RS Payment Methods", RSPaymMethodSetupTxt, AssistedSetupGroup::NPRRSFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup RS VAT Posting", RSVATPostingSetupTxt, AssistedSetupGroup::NPRRSFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup RS POS Unit", RSVATPostingSetupTxt, AssistedSetupGroup::NPRRSFiscal);
    end;

    local procedure AddSIFiscalizationSetupsWizard()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        SIFiscalizationSetupTxt: Label 'Welcome to Slovenian Fiscalization Setup';
        SIPOSAuditProfileSetupTxt: Label 'Welcome to SI POS Audit Profile Setup';
        SISalespeopleSetupTxt: Label 'Welcome to SI Salespeople Setup';
        SIPOSStoreSetupTxt: Label 'Welcome to SI POS Store Setup';
    begin
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup SI Fiscal", SIFiscalizationSetupTxt, AssistedSetupGroup::NPRSIFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup SI Audit Profile", SIPOSAuditProfileSetupTxt, AssistedSetupGroup::NPRSIFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup SI Salespeople", SISalespeopleSetupTxt, AssistedSetupGroup::NPRSIFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup SI POS Store", SIPOSStoreSetupTxt, AssistedSetupGroup::NPRSIFiscal);
    end;

    local procedure AddBGSISFiscalizationSetupsWizard()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        BGSISFiscalizationSetupTxt: Label 'Welcome to Bulgarian SIS Fiscalization Setup';
    begin
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup BG SIS Fiscal", BGSISFiscalizationSetupTxt, AssistedSetupGroup::NPRBGSISFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup BG SIS POS Aud Prof", BGSISFiscalizationSetupTxt, AssistedSetupGroup::NPRBGSISFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup BG SIS POS Unit", BGSISFiscalizationSetupTxt, AssistedSetupGroup::NPRBGSISFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup BG SIS VAT PostSetup", BGSISFiscalizationSetupTxt, AssistedSetupGroup::NPRBGSISFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup BG SIS POS Pay Meth", BGSISFiscalizationSetupTxt, AssistedSetupGroup::NPRBGSISFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup BG SIS Return Reason", BGSISFiscalizationSetupTxt, AssistedSetupGroup::NPRBGSISFiscal);
    end;

    local procedure AddITFiscalizationSetupsWizard()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        ITFiscalizationSetupTxt: Label 'Welcome to Italian Fiscalization Setup';
        ITSetupPOSUnitTxt: Label 'Welcome to IT POS Unit Mapping Setup';
        ITSetupPOSPaymMethTxt: Label 'Welcome to IT POS Payment Method Mapping Setup';
    begin
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup IT Fiscal", ITFiscalizationSetupTxt, AssistedSetupGroup::NPRITFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup IT POS Unit Mapping", ITSetupPOSUnitTxt, AssistedSetupGroup::NPRITFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup IT POS Paym. Meth.", ITSetupPOSPaymMethTxt, AssistedSetupGroup::NPRITFiscal);
    end;

    local procedure AddATFiscalizationSetupsWizard()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        ATFiscalizationSetupTxt: Label 'Welcome to Austrian Fiscalization Setup';
    begin
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup AT Fiscal", ATFiscalizationSetupTxt, AssistedSetupGroup::NPRATFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup AT Fiskaly", ATFiscalizationSetupTxt, AssistedSetupGroup::NPRATFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup AT POS Audit Profile", ATFiscalizationSetupTxt, AssistedSetupGroup::NPRATFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup AT VAT Posting Setup", ATFiscalizationSetupTxt, AssistedSetupGroup::NPRATFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup AT POS Paym. Meth.", ATFiscalizationSetupTxt, AssistedSetupGroup::NPRATFiscal);
    end;

    local procedure AddRSEInvoiceSetupsWizard()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        RSEInvoiceSetupTxt: Label 'Welcome to RS E-Invoice Setup';
        RSEIVATPostingSetupTxt: Label 'Welcome to RS E-Invoice VAT Posting Setup';
        RSEITaxExReasonsSetupTxt: Label 'Welcome to RS E-Invoice Tax Exemption Reasons Setup';
        RSEIPaymMethodSetupTxt: Label 'Welcome to RS E-Invoice Payment Method Setup';
        RSEIUOMMappingSetupTxt: Label 'Welcome to RS E-Invoice UOM Mapping Setup';
    begin
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup RS E-Invoice", RSEInvoiceSetupTxt, AssistedSetupGroup::NPRRSEInvoice);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup RS EI VAT Posting", RSEIVATPostingSetupTxt, AssistedSetupGroup::NPRRSEInvoice);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup RS EI Tax Ex. Reason", RSEITaxExReasonsSetupTxt, AssistedSetupGroup::NPRRSEInvoice);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup RS EI Paym. Meth.", RSEIPaymMethodSetupTxt, AssistedSetupGroup::NPRRSEInvoice);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup RS EI UOM Mapping", RSEIUOMMappingSetupTxt, AssistedSetupGroup::NPRRSEInvoice);
    end;

    local procedure AddHUMSFiscalizationSetupsWizard()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        HUMSFiscalSetupTxt: Label 'Welcome to HU MS Fiscal Setup';
        HUMSPOSAuditProfileSetupTxt: Label 'Welcome to HU MS Audit Profile Setup';
        HUMSSetupPOSPaymMethTxt: Label 'Welcome to HU MS POS Payment Method Mapping Setup';
    begin
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup HU MS Fiscal", HUMSFiscalSetupTxt, AssistedSetupGroup::NPRHUMultiSoftEInv);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup HU MS Audit Profile", HUMSPOSAuditProfileSetupTxt, AssistedSetupGroup::NPRHUMultiSoftEInv);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup HU MS POS Paym Meth", HUMSSetupPOSPaymMethTxt, AssistedSetupGroup::NPRHUMultiSoftEInv);
    end;

    local procedure AddDEFiscalizationSetupsWizard()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        DEFiscalizationSetupTxt: Label 'Welcome to Germany Fiscalization Setup';
    begin
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup DE Fiscal", DEFiscalizationSetupTxt, AssistedSetupGroup::NPRATFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup DE POS Audit Profile", DEFiscalizationSetupTxt, AssistedSetupGroup::NPRATFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup DE VAT Posting Setup", DEFiscalizationSetupTxt, AssistedSetupGroup::NPRATFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup DE POS Paym. Meth.", DEFiscalizationSetupTxt, AssistedSetupGroup::NPRATFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup DE Fiskaly", DEFiscalizationSetupTxt, AssistedSetupGroup::NPRATFiscal);
    end;

    local procedure AddBEFiscalizationSetupsWizard()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        BEFiscalizationSetupTxt: Label 'Welcome to Belgian Fiscalization Setup';
    begin
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup BE Fiscal", BEFiscalizationSetupTxt, AssistedSetupGroup::NPRBEFiscal);
    end;

    local procedure AddIRLFiscalizationSetupsWizard()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        IRLFiscalizationSetupTxt: Label 'Welcome to Ireland Fiscalization Setup';
    begin
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup IRL Fiscal", IRLFiscalizationSetupTxt, AssistedSetupGroup::NPRIRLFiscal);
    end;

    local procedure AddNOFiscalizationSetupsWizard()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        NOFiscalSetupTxt: Label 'Welcome to NO Fiscal Setup';
        NOPOSAuditProfileSetupTxt: Label 'Welcome to NO Audit Profile Setup';
    begin
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup NO Fiscal", NOFiscalSetupTxt, AssistedSetupGroup::NPRNOFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup NO Audit Profile", NOPOSAuditProfileSetupTxt, AssistedSetupGroup::NPRNOFiscal);
    end;

    local procedure AddSECCFiscalizationSetupsWizard()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        SECCFiscalSetupTxt: Label 'Welcome to SE CleanCash Fiscal Setup';
        SECCSetupTxt: Label 'Welcome to SE CleanCash Setup';
    begin
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup SE Fiscal", SECCFiscalSetupTxt, AssistedSetupGroup::NPRSECleanCash);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup SE CleanCash", SECCSetupTxt, AssistedSetupGroup::NPRSECleanCash);
    end;

    local procedure AddDKFiscalizationSetupsWizard()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        DKFiscalSetupTxt: Label 'Welcome to DK Fiscal Setup';
        DKPOSAuditProfileSetupTxt: Label 'Welcome to DK Audit Profile Setup';
    begin
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup DK Fiscal", DKFiscalSetupTxt, AssistedSetupGroup::NPRDKFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup DK Audit Profile", DKPOSAuditProfileSetupTxt, AssistedSetupGroup::NPRDKFiscal);
    end;

    local procedure AddFRFiscalizationSetupsWizard()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        FRAuditNoSeriesTxt: Label 'Welcome to FR Audit No Series Setup';
        FRAuditTxt: Label 'Welcome to FR Audit Setup';
        FRPOSAuditProfileTxt: Label 'Welcome to FR POS Audit Profile Setup';
        FREoDProfileTxt: Label 'Welcome to FR End of Day Profile Setup';
        FRCompanyInfoTxt: Label 'Welcome to FR Company Information Setup';
    begin
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup FR Audit No Series", FRAuditNoSeriesTxt, AssistedSetupGroup::NPRFRFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup FR Audit", FRAuditTxt, AssistedSetupGroup::NPRFRFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup FR POS Audit Prof", FRPOSAuditProfileTxt, AssistedSetupGroup::NPRFRFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup FR EoD Profile", FREoDProfileTxt, AssistedSetupGroup::NPRFRFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup FR Company Info", FRCompanyInfoTxt, AssistedSetupGroup::NPRFRFiscal);
    end;

    local procedure AddESFiscalizationSetupsWizard()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        ESFiscalizationSetupTxt: Label 'Welcome to Spain Fiscalization Setup';
    begin
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup ES Fiscal", ESFiscalizationSetupTxt, AssistedSetupGroup::NPRESFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup ES Fiskaly", ESFiscalizationSetupTxt, AssistedSetupGroup::NPRESFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup ES POS Audit Profile", ESFiscalizationSetupTxt, AssistedSetupGroup::NPRESFiscal);
        AssistedSetup.Add(GetAppId(), Page::"NPR Setup ES Return Reason Map", ESFiscalizationSetupTxt, AssistedSetupGroup::NPRESFiscal);
    end;

    procedure GetAppId(): Guid
    var
        EmptyGuid: Guid;
        Info: ModuleInfo;
    begin
        if Info.Id() = EmptyGuid then
            NavApp.GetCurrentModuleInfo(Info);
        exit(Info.Id());
    end;
#ELSE
#if BC18 or BC19
    [EventSubscriber(ObjectType::Codeunit, Codeunit::LogInManagement, 'OnBeforeLogInStart', '', false, false)]
    local procedure OnBeforeLogInStart();
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", 'OnAfterLogin', '', false, false)]
    local procedure OnAfterLogin();
#endif
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR GraphApi Setup Wizard");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Magento Wizard");
        RetailSetups();
        RestaurantSetups();
        AttractionSetups();
        CROFiscalizationSetups();
        RSFiscalizationSetups();
        SIFiscalizationSetups();
        BGSISFiscalizationSetups();
        ITFiscalizationSetups();
        ATFiscalizationSetups();
        BEFiscalizationSetups();
        RSEInvoiceSetups();
        DEFiscalizationSetups();
        IRLFiscalizationSetups();
        NOFiscalizationSetups();
        HUMSFiscalizationSetups();
        SECCFiscalizationSetups();
        DKFiscalizationSetups();
        FRFiscalizationSetups();
        ESFiscalizationSetups();
#if not BC18
        if Checklist.IsChecklistVisible() then
            HideChecklistIfPOSEntryExist();
#endif
    end;

    #region Retail
    //This region contains functions for creating Retail Setup Wizards and Checklist
    local procedure RetailSetups()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not (Session.CurrentClientType() in [ClientType::Web, ClientType::Windows, ClientType::Desktop]) then
            exit;
        if UpgradeTag.HasUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::Retail)) then
            exit;

        RemoveRetailGuidedExperience();

        AddRetailSetupsWizard();
        CreateRetailChecklistItems();

        UpgradeTag.SetUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::Retail));
    end;

    local procedure RemoveRetailGuidedExperience()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Download&Import Data");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Create POS Stores & Units");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Modify POS Posting Profile");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Modify POS Payment Methods");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Modify POS Posting Setup");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Modify Salespeople");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Modify Retail Vchr. Types");
    end;

    local procedure AddRetailSetupsWizard()
    begin
        CreateWelcomeVideoExperience();
        DownloadAndImportDataWizard();
        CreatePOSstoresAndUnitsWizard();
        ModifyRetailVouchersTypesWizard();
        ModifyPOSPostingProfileWizard();
        ModifyPOSpaymentMethodsWizard();
        ModifyPOSPostingSetupWizard();
        ModifySalesPeopleWizard();
    end;

    local procedure CreateWelcomeVideoExperience()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Welcome Video Retail', Locked = true;
        SetupDescriptionTxt: Label 'Welcome Video Retail', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Codeunit, Codeunit::"NPR Welcome Video") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Codeunit,
                                                Codeunit::"NPR Welcome Video",
                                                AssistedSetupGroup::NPRetail,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure DownloadAndImportDataWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Download & Import Data', Locked = true;
        SetupDescriptionTxt: Label 'Download & Import Data', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Download&Import Data") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Download&Import Data",
                                                AssistedSetupGroup::NPRetail,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Download&Import Data", 'OnAfterFinishStep', '', false, false)]
    local procedure DownloadAndImportPrintTemplatesWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateDownloadAndImportPrintTemplatesWizardStatus();
    end;

    local procedure UpdateDownloadAndImportPrintTemplatesWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Download&Import Data");
    end;

    local procedure CreatePOSstoresAndUnitsWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Create POS Stores & Units', Locked = true;
        SetupDescriptionTxt: Label 'Create POS Stores & Units', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Create POS Stores & Units") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Create POS Stores & Units",
                                                AssistedSetupGroup::NPRetail,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Create POS Stores & Units", 'OnAfterFinishStep', '', false, false)]
    local procedure CreatePOSstoresAndUnitsWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateCreatePOSstoresAndUnitsWizardStatus();
    end;

    local procedure UpdateCreatePOSstoresAndUnitsWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Create POS Stores & Units");
    end;

    local procedure ModifyPOSPostingProfileWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Modify POS Posting Profile', Locked = true;
        SetupDescriptionTxt: Label 'Modify POS Posting Profile', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Modify POS Posting Profile") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Modify POS Posting Profile",
                                                AssistedSetupGroup::NPRetail,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Modify POS Posting Profile", 'OnAfterFinishStep', '', false, false)]
    local procedure CreateProfilesWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateCreateProfilesWizardStatus();
    end;

    local procedure UpdateCreateProfilesWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Modify POS Posting Profile");
    end;

    local procedure ModifyPOSpaymentMethodsWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Modify POS Payment Methods', Locked = true;
        SetupDescriptionTxt: Label 'Modify POS Payment Methods', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Modify POS Payment Methods") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Modify POS Payment Methods",
                                                AssistedSetupGroup::NPRetail,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Modify POS Payment Methods", 'OnAfterFinishStep', '', false, false)]
    local procedure ModifyPOSpaymentMethodsWizard_OnAfterFinishStep(AnyDataToModify: Boolean)
    begin
        if AnyDataToModify then
            UpdateModifyPOSpaymentMethodsWizardStatus();
    end;

    local procedure UpdateModifyPOSpaymentMethodsWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Modify POS Payment Methods");
    end;

    local procedure ModifyPOSPostingSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Modify POS Posting Setup', Locked = true;
        SetupDescriptionTxt: Label 'Modify POS Posting Setup', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Modify POS Posting Setup") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Modify POS Posting Setup",
                                                AssistedSetupGroup::NPRetail,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Modify POS Posting Setup", 'OnAfterFinishStep', '', false, false)]
    local procedure CreatePOSPostingSetupWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateCreatePOSPostingSetupWizardStatus();
    end;

    local procedure UpdateCreatePOSPostingSetupWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Modify POS Posting Setup");
    end;

    local procedure ModifySalesPeopleWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Modify Salespeople', Locked = true;
        SetupDescriptionTxt: Label 'Modify Salespeople', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Modify Salespeople") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Modify Salespeople",
                                                AssistedSetupGroup::NPRetail,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Modify Salespeople", 'OnAfterFinishStep', '', false, false)]
    local procedure ModifySalesPeopleWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateModifySalesPeopleWizardStatus();
    end;

    local procedure UpdateModifySalesPeopleWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Modify Salespeople");
    end;

    local procedure CreateRetailChecklistItems()
    var
        TempAllProfile: Record "All Profile" temporary;
    begin
        AddRoleToList(TempAllProfile, Page::"NPR Retail Setup RC");
        AddRoleToList(TempAllProfile, Page::"NPR Retail Manager Role Center");

        AddRetailChecklistItems(TempAllProfile);

        Checklist.MarkChecklistSetupAsDone();
#if not BC18
        Checklist.SetChecklistVisibility(true);
#endif
    end;

    local procedure AddRetailChecklistItems(var TempAllProfile: Record "All Profile" temporary)
    begin
        Checklist.Insert("Guided Experience Type"::"Assisted Setup", ObjectType::Codeunit, Codeunit::"NPR Welcome Video", 1100, TempAllProfile, false);
        Checklist.Insert("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Download&Import Data", 1101, TempAllProfile, false);
        Checklist.Insert("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Create POS Stores & Units", 1102, TempAllProfile, false);
        Checklist.Insert("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Modify Retail Vchr. Types", 1103, TempAllProfile, false);
        Checklist.Insert("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Modify POS Posting Profile", 1104, TempAllProfile, false);
        Checklist.Insert("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Modify POS Payment Methods", 1105, TempAllProfile, false);
        Checklist.Insert("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Modify POS Posting Setup", 1106, TempAllProfile, false);
        Checklist.Insert("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Modify Salespeople", 1107, TempAllProfile, false);
        Checklist.InitializeGuidedExperienceItems();
    end;
    #endregion

    #region Restaurant
    //This region contains functions for creating Restaurant Setup Wizards and Checklist
    local procedure AddRestaurantSetupsWizard()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin

        if UpgradeTag.HasUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::Restaurant)) then
            exit;

        WelcomeVideoRestaurantExperience();
        DownloadAndImportRestDataWizard();
        CreateFlowStatusesWizard();
        CreatePrintProductionCategoriesWizard();
        CreateItemRoutingProfilesWizard();
        CreateRestServiceFlowProfilesWizard();
        CreateRestaurantLayoutWizard();
        CreateKitchenLayoutWizard();

        UpgradeTag.SetUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::Restaurant));
    end;

    local procedure RestaurantSetups()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not (Session.CurrentClientType() in [ClientType::Web, ClientType::Windows, ClientType::Desktop]) then
            exit;
        if UpgradeTag.HasUpgradeTag(GetChecklistUpgradeTag(ThisModul::Restaurant)) then
            exit;

        AddRestaurantSetupsWizard();
        CreateRestaurantChecklistItems();

        UpgradeTag.SetUpgradeTag(GetChecklistUpgradeTag(ThisModul::Restaurant));
    end;

    local procedure WelcomeVideoRestaurantExperience()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Welcome Video Restaurant', Locked = true;
        SetupDescriptionTxt: Label 'Welcome Video Restaurant', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Codeunit, Codeunit::"NPR Restaurant Welcome Vid.") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Codeunit,
                                                Codeunit::"NPR Restaurant Welcome Vid.",
                                                AssistedSetupGroup::NPRestaurant,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure DownloadAndImportRestDataWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Download & Import Predefined Setups', Locked = true;
        SetupDescriptionTxt: Label 'Download & Import Predefined Setups', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Download&Import Rest Data") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Download&Import Rest Data",
                                                AssistedSetupGroup::NPRetail,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Download&Import Rest Data", 'OnAfterFinishStep', '', false, false)]
    local procedure DownloadAndImportRestDataWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateDownloadAndImportRestDataWizardStatus();
    end;

    local procedure UpdateDownloadAndImportRestDataWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Download&Import Rest Data");
    end;

    local procedure CreateFlowStatusesWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup Flow Statuses', Locked = true;
        SetupDescriptionTxt: Label 'Setup Flow Statuses', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Modify Flow Statuses") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                5,
                                                ObjectType::Page,
                                                Page::"NPR Modify Flow Statuses",
                                                AssistedSetupGroup::NPRestaurant,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Modify Flow Statuses", 'OnAfterFinishStep', '', false, false)]
    local procedure CreateFlowStatusesWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateCreateFlowStatusesWizardStatus();
    end;

    local procedure UpdateCreateFlowStatusesWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Modify Flow Statuses");
    end;

    local procedure CreatePrintProductionCategoriesWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup Print/Production Categories', Locked = true;
        SetupDescriptionTxt: Label 'Setup Print/Production Categories', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Modify Print/Prod Category") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                5,
                                                ObjectType::Page,
                                                Page::"NPR Modify Print/Prod Category",
                                                AssistedSetupGroup::NPRestaurant,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Modify Print/Prod Category", 'OnAfterFinishStep', '', false, false)]
    local procedure CreatePrintProductionCategoriesWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateCreatePrintProductionCategoriesWizardStatus();
    end;

    local procedure UpdateCreatePrintProductionCategoriesWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Modify Print/Prod Category");
    end;

    local procedure CreateItemRoutingProfilesWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup Item Routing Profiles', Locked = true;
        SetupDescriptionTxt: Label 'Setup  Item Routing Profiles', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Modify Item Rtng. Profiles") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                5,
                                                ObjectType::Page,
                                                Page::"NPR Modify Item Rtng. Profiles",
                                                AssistedSetupGroup::NPRestaurant,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Modify Item Rtng. Profiles", 'OnAfterFinishStep', '', false, false)]
    local procedure CreateItemRoutingProfilesWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateCreateItemRoutingProfilesWizardStatus();
    end;

    local procedure UpdateCreateItemRoutingProfilesWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Modify Item Rtng. Profiles");
    end;

    local procedure CreateRestServiceFlowProfilesWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup Restaurant Service Flow Profiles', Locked = true;
        SetupDescriptionTxt: Label 'Setup Restaurant Service Flow Profiles', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Create Rest. Serv. Flow") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                5,
                                                ObjectType::Page,
                                                Page::"NPR Create Rest. Serv. Flow",
                                                AssistedSetupGroup::NPRestaurant,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Create Rest. Serv. Flow", 'OnAfterFinishStep', '', false, false)]
    local procedure CreateRestServiceFlowProfilesWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateCreateRestServiceFlowProfilesWizardStatus();
    end;

    local procedure UpdateCreateRestServiceFlowProfilesWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Create Rest. Serv. Flow");
    end;

    local procedure CreateRestaurantLayoutWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup Restaurant Layout', Locked = true;
        SetupDescriptionTxt: Label 'Setup Restaurant Layout', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Create Restaurant Layout") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                5,
                                                ObjectType::Page,
                                                Page::"NPR Create Restaurant Layout",
                                                AssistedSetupGroup::NPRestaurant,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Create Restaurant Layout", 'OnAfterFinishStep', '', false, false)]
    local procedure CreateRestaurantLayoutWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateCreateRestaurantLayoutWizardStatus();
    end;

    local procedure UpdateCreateRestaurantLayoutWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Create Restaurant Layout");
    end;

    local procedure CreateKitchenLayoutWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup Kitchen Layout', Locked = true;
        SetupDescriptionTxt: Label 'Setup Kitchen Layout', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Create Kitchen Layout") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                5,
                                                ObjectType::Page,
                                                Page::"NPR Create Kitchen Layout",
                                                AssistedSetupGroup::NPRestaurant,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Create Kitchen Layout", 'OnAfterFinishStep', '', false, false)]
    local procedure CreateKitchenLayoutWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateCreateKitchenLayoutWizardStatus();
    end;

    local procedure UpdateCreateKitchenLayoutWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Create Restaurant Layout");
    end;

    local procedure CreateRestaurantChecklistItems()
    var
        TempAllProfile: Record "All Profile" temporary;
    begin
        AddRoleToList(TempAllProfile, Page::"NPR Retail Restaurant RC");
        AddRestaurantChecklistItems(TempAllProfile);

        Checklist.MarkChecklistSetupAsDone();
#if not BC18
        Checklist.SetChecklistVisibility(true);
#endif
    end;

    local procedure AddRestaurantChecklistItems(var TempAllProfile: Record "All Profile" temporary)
    begin
        Checklist.Insert("Guided Experience Type"::"Assisted Setup", ObjectType::Codeunit, Codeunit::"NPR Restaurant Welcome Vid.", 1200, TempAllProfile, false);
        Checklist.Insert("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Download&Import Rest Data", 1201, TempAllProfile, false);
        Checklist.Insert("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Modify Flow Statuses", 1202, TempAllProfile, false);
        Checklist.Insert("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Modify Print/Prod Category", 1203, TempAllProfile, false);
        Checklist.Insert("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Modify Item Rtng. Profiles", 1204, TempAllProfile, false);
        Checklist.Insert("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Create Rest. Serv. Flow", 1205, TempAllProfile, false);
        Checklist.Insert("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Create Restaurant Layout", 1206, TempAllProfile, false);
        Checklist.Insert("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Create Kitchen Layout", 1207, TempAllProfile, false);
        Checklist.InitializeGuidedExperienceItems();
    end;

    local procedure ModifyRetailVouchersTypesWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Modify Retail Voucher Types', Locked = true;
        SetupDescriptionTxt: Label 'Modify Retail Voucher Types', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Modify Retail Vchr. Types") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Modify Retail Vchr. Types",
                                                AssistedSetupGroup::NPRetail,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Modify Retail Vchr. Types", 'OnAfterFinishStep', '', false, false)]
    local procedure CreateRetailVchrTypesWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateRetailVouchersTypesWizardStatus();
    end;

    local procedure UpdateRetailVouchersTypesWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Modify Retail Vchr. Types");
    end;

    #endregion

    #region Attraction

    local procedure AttractionSetups()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not (Session.CurrentClientType() in [ClientType::Web, ClientType::Windows, ClientType::Desktop]) then
            exit;
        if UpgradeTag.HasUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::Attraction)) then
            exit;

        RemoveAttractionGuidedExperience();

        AddAttractionSetupsWizard();

        UpgradeTag.SetUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::Attraction));
    end;

    local procedure RemoveAttractionGuidedExperience()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR MM Membership Rapid Pckg.");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR TM Ticket Rapid Packages");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Create Tickets&TicketItems");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup Membership Wizard");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Ticket Setup Wizard");
    end;

    local procedure AddAttractionSetupsWizard()
    begin
        CreateAttractionWelcomeVideo();
        ImportTicketingDataWizard();
        ImportMembershipDataWizard();
        CreateTicketsAndTicketItemsWizard();
        RunTicketWizard();
        SetupMemberAndMemberships();
    end;

    local procedure CreateAttractionWelcomeVideo()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Welcome Video Attraction', Locked = true;
        SetupDescriptionTxt: Label 'Welcome Video Attraction', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Codeunit, Codeunit::"NPR Attraction Welcome Video") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Codeunit,
                                                Codeunit::"NPR Attraction Welcome Video",
                                                AssistedSetupGroup::NPRAttraction,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure ImportTicketingDataWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Download and Import Ticketing Data', Locked = true;
        SetupDescriptionTxt: Label 'Download & Import Data', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR TM Ticket Rapid Packages") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR TM Ticket Rapid Packages",
                                                AssistedSetupGroup::NPRAttraction,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure ImportMembershipDataWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Download and Import Membership Data', Locked = true;
        SetupDescriptionTxt: Label 'Download & Import Data', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR MM Membership Rapid Pckg.") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR MM Membership Rapid Pckg.",
                                                AssistedSetupGroup::NPRAttraction,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure CreateTicketsAndTicketItemsWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Create Tickets & Ticket Items', Locked = true;
        SetupDescriptionTxt: Label 'Create Tickets and Ticket Items', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Create Tickets&TicketItems") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Create Tickets&TicketItems",
                                                AssistedSetupGroup::NPRAttraction,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Create Tickets&TicketItems", 'OnAfterFinishStep', '', false, false)]
    local procedure CreateTicketsAndTicketItemsWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateCreateTicketsAndTicketItemsWizardStatus();
    end;

    local procedure UpdateCreateTicketsAndTicketItemsWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Create Tickets&TicketItems");
    end;

    local procedure RunTicketWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Ticket Wizard', Locked = true;
        SetupDescriptionTxt: Label 'Ticket Setup Wizard', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Ticket Setup Wizard") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Ticket Setup Wizard",
                                                AssistedSetupGroup::NPRAttraction,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Ticket Setup Wizard", 'OnAfterFinishStep', '', false, false)]
    local procedure TicketSetupWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateTicketSetupWizardStatus();
    end;

    local procedure UpdateTicketSetupWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Ticket Setup Wizard");
    end;

    local procedure SetupMemberAndMemberships()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup Memberships', Locked = true;
        SetupDescriptionTxt: Label 'Setup Memberships', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup Membership Wizard") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Setup Membership Wizard",
                                                AssistedSetupGroup::NPRAttraction,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup Membership Wizard", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupMembershipWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupMembershipWizardStatus();
    end;

    local procedure UpdateSetupMembershipWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup Membership Wizard");
    end;
    #endregion

    #region BG SIS Fiscalization Wizards
    local procedure BGSISFiscalizationSetups()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not (Session.CurrentClientType() in [ClientType::Web, ClientType::Windows, ClientType::Desktop]) then
            exit;

        if UpgradeTag.HasUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::BGSISFiscalization)) then
            exit;

        RemoveBGSISFiscalizationSetupGuidedExperience();

        AddBGSISFiscalizationSetupsWizard();

        UpgradeTag.SetUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::BGSISFiscalization));
    end;

    local procedure RemoveBGSISFiscalizationSetupGuidedExperience()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup BG SIS Fiscal");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup BG SIS POS Aud Prof");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup BG SIS POS Unit");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup BG SIS VAT PostSetup");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup BG SIS POS Pay Meth");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup BG SIS Return Reason");
    end;

    local procedure AddBGSISFiscalizationSetupsWizard()
    begin
        EnableBGSISFiscalSetupWizard();
        EnableBGSISAuditProfileSetupWizard();
        EnableBGSISPOSUnitSetupWizard();
        EnableBGSISVATPostingSetupWizard();
        EnableBGSISPOSPaymentMethodSetupWizard();
        EnableBGSISReturnReasonSetupWizard();
    end;

    local procedure EnableBGSISFiscalSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Enable Fiscalization', Locked = true;
        SetupDescriptionTxt: Label 'Enable Fiscalization', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup BG SIS Fiscal") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                3,
                                                ObjectType::Page,
                                                Page::"NPR Setup BG SIS Fiscal",
                                                AssistedSetupGroup::NPRBGSISFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableBGSISAuditProfileSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup POS Audit Profile', Locked = true;
        SetupDescriptionTxt: Label 'Setup POS Audit Profile', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup BG SIS POS Aud Prof") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Setup BG SIS POS Aud Prof",
                                                AssistedSetupGroup::NPRBGSISFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableBGSISPOSUnitSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup POS Units', Locked = true;
        SetupDescriptionTxt: Label 'Setup POS Units', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup BG SIS POS Unit") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                3,
                                                ObjectType::Page,
                                                Page::"NPR Setup BG SIS POS Unit",
                                                AssistedSetupGroup::NPRBGSISFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableBGSISVATPostingSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup VAT Posting Setups', Locked = true;
        SetupDescriptionTxt: Label 'Setup VAT Posting Setups', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup BG SIS VAT PostSetup") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                5,
                                                ObjectType::Page,
                                                Page::"NPR Setup BG SIS VAT PostSetup",
                                                AssistedSetupGroup::NPRBGSISFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableBGSISPOSPaymentMethodSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup POS Payment Methods', Locked = true;
        SetupDescriptionTxt: Label 'Setup POS Payment Methods', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup BG SIS POS Pay Meth") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                3,
                                                ObjectType::Page,
                                                Page::"NPR Setup BG SIS POS Pay Meth",
                                                AssistedSetupGroup::NPRBGSISFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableBGSISReturnReasonSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup Return Reasons', Locked = true;
        SetupDescriptionTxt: Label 'Setup Return Reasons', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup BG SIS Return Reason") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Setup BG SIS Return Reason",
                                                AssistedSetupGroup::NPRBGSISFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup BG SIS Fiscal", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupBGSISFiscalWizard_OnAfterFinishStep(DataPopulated: Boolean)
    begin
        if DataPopulated then
            UpdateSetupBGSISFiscalWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup BG SIS POS Aud Prof", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupBGSISAuditProfileWizard_OnAfterFinishStep(DataPopulated: Boolean)
    begin
        if DataPopulated then
            UpdateSetupBGSISAuditProfileWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup BG SIS POS Unit", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupBGSISPOSUnitWizard_OnAfterFinishStep(DataPopulated: Boolean)
    begin
        if DataPopulated then
            UpdateSetupBGSISPOSUnitWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup BG SIS VAT PostSetup", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupBGSISVATPostSetupWizard_OnAfterFinishStep(DataPopulated: Boolean)
    begin
        if DataPopulated then
            UpdateSetupBGSISVATPostSetupWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup BG SIS POS Pay Meth", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupBGSISPOSPayMethWizard_OnAfterFinishStep(DataPopulated: Boolean)
    begin
        if DataPopulated then
            UpdateSetupBGSISPOSPayMethWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup BG SIS Return Reason", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupBGSISReturnReasonWizard_OnAfterFinishStep(DataPopulated: Boolean)
    begin
        if DataPopulated then
            UpdateSetupBGSISReturnReasonWizardStatus();
    end;

    local procedure UpdateSetupBGSISFiscalWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup BG SIS Fiscal");
    end;

    local procedure UpdateSetupBGSISAuditProfileWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup BG SIS POS Aud Prof");
    end;

    local procedure UpdateSetupBGSISPOSUnitWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup BG SIS POS Unit");
    end;

    local procedure UpdateSetupBGSISVATPostSetupWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup BG SIS VAT PostSetup");
    end;

    local procedure UpdateSetupBGSISPOSPayMethWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup BG SIS POS Pay Meth");
    end;

    local procedure UpdateSetupBGSISReturnReasonWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup BG SIS Return Reason");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR BG Fiscalization Setup", 'OnAfterValidateEvent', 'BG SIS Fiscal Enabled', false, false)]
    local procedure ResetBGFiscalWizard_OnAfterValidateBGSISFiscalEnabled(var Rec: Record "NPR BG Fiscalization Setup"; var xRec: Record "NPR BG Fiscalization Setup"; CurrFieldNo: Integer)
    begin
        if (Rec."BG SIS Fiscal Enabled" <> xRec."BG SIS Fiscal Enabled") and not Rec."BG SIS Fiscal Enabled" then
            ResetSetupFiscalWizardStatus(Enum::"Assisted Setup Group"::NPRBGSISFiscal);
    end;
    #endregion

    #region ES Fiscalization Wizards
    local procedure ESFiscalizationSetups()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not (Session.CurrentClientType() in [ClientType::Web, ClientType::Windows, ClientType::Desktop]) then
            exit;

        if UpgradeTag.HasUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::ESFiscalization)) then
            exit;

        RemoveESFiscalizationSetupGuidedExperience();

        AddESFiscalizationSetupsWizard();

        UpgradeTag.SetUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::ESFiscalization));
    end;

    local procedure RemoveESFiscalizationSetupGuidedExperience()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup ES Fiscal");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup ES Fiskaly");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup ES POS Audit Profile");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup ES Return Reason Map");
    end;

    local procedure AddESFiscalizationSetupsWizard()
    begin
        EnableESFiscalSetupWizard();
        EnableESFiskalySetupWizard();
        EnableESAuditProfileSetupWizard();
        EnableESReturnReasonsSetupWizard();
    end;

    local procedure EnableESFiscalSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Enable Fiscalization', Locked = true;
        SetupDescriptionTxt: Label 'Enable Fiscalization', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup ES Fiscal") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                3,
                                                ObjectType::Page,
                                                Page::"NPR Setup ES Fiscal",
                                                AssistedSetupGroup::NPRESFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableESFiskalySetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup Integration with Fiskaly', Locked = true;
        SetupDescriptionTxt: Label 'Setup Integration with Fiskaly', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup ES Fiskaly") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                5,
                                                ObjectType::Page,
                                                Page::"NPR Setup ES Fiskaly",
                                                AssistedSetupGroup::NPRESFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableESAuditProfileSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup POS Audit Profile', Locked = true;
        SetupDescriptionTxt: Label 'Setup POS Audit Profile', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup ES POS Audit Profile") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Setup ES POS Audit Profile",
                                                AssistedSetupGroup::NPRESFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableESReturnReasonsSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup Return Reasons', Locked = true;
        SetupDescriptionTxt: Label 'Setup Return Reasons', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup ES Return Reason Map") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Setup ES Return Reason Map",
                                                AssistedSetupGroup::NPRESFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup ES Fiscal", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupESFiscalWizard_OnAfterFinishStep(DataPopulated: Boolean)
    begin
        if DataPopulated then
            UpdateSetupESFiscalWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup ES Fiskaly", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupESFiskalyWizard_OnAfterFinishStep(DataPopulated: Boolean)
    begin
        if DataPopulated then
            UpdateSetupESFiskalyWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup ES POS Audit Profile", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupESPOSAuditProfileWizard_OnAfterFinishStep(DataPopulated: Boolean)
    begin
        if DataPopulated then
            UpdateSetupESAuditProfileWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup ES Return Reason Map", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupESReturnReasonMapWizard_OnAfterFinishStep(DataPopulated: Boolean)
    begin
        if DataPopulated then
            UpdateSetupESReturnReasonMapWizardStatus();
    end;

    local procedure UpdateSetupESFiscalWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup ES Fiscal");
    end;

    local procedure UpdateSetupESFiskalyWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup ES Fiskaly");
    end;

    local procedure UpdateSetupESAuditProfileWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup ES POS Audit Profile");
    end;

    local procedure UpdateSetupESReturnReasonMapWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup ES Return Reason Map");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR ES Fiscalization Setup", 'OnAfterValidateEvent', 'ES Fiscal Enabled', false, false)]
    local procedure ResetESFiscalWizard_OnAfterValidateESFiscalEnabled(var Rec: Record "NPR ES Fiscalization Setup"; var xRec: Record "NPR ES Fiscalization Setup"; CurrFieldNo: Integer)
    begin
        if (Rec."ES Fiscal Enabled" <> xRec."ES Fiscal Enabled") and not Rec."ES Fiscal Enabled" then
            ResetSetupFiscalWizardStatus(Enum::"Assisted Setup Group"::NPRESFiscal);
    end;
    #endregion

    #region Common Functions
    //This region contains common functions used by all Setup Wizards and Checklists
    local procedure GetChecklistUpgradeTag(Modul: Option Retail,Restaurant,Attraction,CROFiscalizationSetup,RSFiscalizationSetup,BGSISFiscalization,SIFiscalizationSetup,ITFiscalizationSetup,ATFiscalization,RSEInvoiceSetup,DEFiscalization,BEFiscalization,IRLFiscalization,NOFiscalization,HUMSFiscalization,SECCFiscalization,DKFiscalization,FRFiscalization,ESFiscalization): Code[250]
    begin
        case Modul of
            Modul::Retail:
                //For Any change, increase version
                exit('NPR-Checklist-v1.6');
            Modul::Restaurant:
                //For Any change, increase version
                exit('NPR-Checklist-Restaurant-v1.5');
            Modul::Attraction:
                //For Any change, increase version
                exit('NPR-Checklist-Attraction-v1.0');
        end;
    end;

    local procedure GetAssistedSetupUpgradeTag(Modul: Option Retail,Restaurant,Attraction,CROFiscalizationSetup,RSFiscalizationSetup,BGSISFiscalization,SIFiscalizationSetup,ITFiscalizationSetup,ATFiscalization,RSEInvoiceSetup,DEFiscalization,BEFiscalization,IRLFiscalization,NOFiscalization,HUMSFiscalization,SECCFiscalization,DKFiscalization,FRFiscalization,ESFiscalization): Code[250]
    begin
        case Modul of
            Modul::Retail:
                //For Any change, increase version
                exit('NPR-AssistedSetup-v1.3');
            Modul::Restaurant:
                //For Any change, increase version
                exit('NPR-AssistedSetup-Restaurant-v1.5');
            Modul::Attraction:
                //For Any change, increase version
                exit('NPR-AssistedSetup-Attraction-v1.0');
            Modul::CROFiscalizationSetup:
                //For Any change, increase version
                exit('NPR-AssistedSetup-CROFiscalization-v1.0');
            Modul::RSFiscalizationSetup:
                //For Any change, increase version
                exit('NPR-AssistedSetup-RSFiscalization-v1.0');
            Modul::BGSISFiscalization:
                // For Any change, increase version
                exit('NPR-AssistedSetup-BGSISFiscalization-v1.0');
            Modul::SIFiscalizationSetup:
                // For Any change, increase version
                exit('NPR-AssistedSetup-SIFiscalization-v1.0');
            Modul::ITFiscalizationSetup:
                // For Any change, increase version
                exit('NPR-AssistedSetup-ITFiscalization-v1.0');
            Modul::ATFiscalization:
                // For Any change, increase version
                exit('NPR-AssistedSetup-ATFiscalization-v1.0');
            Modul::RSEInvoiceSetup:
                // For Any change, increase version
                exit('NPR-AssistedSetup-RSEInvoice-v1.0');
            Modul::DEFiscalization:
                // For Any change, increase version
                exit('NPR-AssistedSetup-DEFiscalization-v1.1');
            Modul::BEFiscalization:
                // For Any change, increase version
                exit('NPR-AssistedSetup-BEFiscalization-v1.0');
            Modul::IRLFiscalization:
                // For Any change, increase version
                exit('NPR-AssistedSetup-IRLFiscalization-v1.0');
            Modul::NOFiscalization:
                // For Any change, increase version
                exit('NPR-AssistedSetup-NOFiscalization-v1.0');
            Modul::SECCFiscalization:
                // For Any change, increase version
                exit('NPR-AssistedSetup-SECCFiscalization-v1.0');
            Modul::HUMSFiscalization:
                // For Any change, increase version
                exit('NPR-AssistedSetup-HUFiscalization-v1.0');
            Modul::DKFiscalization:
                // For Any change, increase version
                exit('NPR-AssistedSetup-DKFiscalization-v1.0');
            Modul::FRFiscalization:
                // For Any change, increase version
                exit('NPR-AssistedSetup-FRFiscalization-v1.0');
            Modul::ESFiscalization:
                // For Any change, increase version
                exit('NPR-AssistedSetup-ESFiscalization-v1.0');
        end;
    end;

    local procedure AddRoleToList(var TempAllProfile: Record "All Profile" temporary; RoleCenterID: Integer)
    var
        AllProfile: Record "All Profile";
    begin
        AllProfile.SetRange("Role Center ID", RoleCenterID);
        AddRoleToList(AllProfile, TempAllProfile);
    end;

    local procedure AddRoleToList(var AllProfile: Record "All Profile"; var TempAllProfile: Record "All Profile" temporary)
    begin
        if AllProfile.FindFirst() then begin
            TempAllProfile.TransferFields(AllProfile);
            TempAllProfile.Insert();
        end;
    end;

#if not BC18
    local procedure HideChecklistIfPOSEntryExist()
    var
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.SetRange("System Entry", false);
        if POSEntry.Count() > 10 then
            Checklist.SetChecklistVisibility(false);
    end;
#endif
    #endregion

    #region CRO Fiscalization Wizards
    local procedure CROFiscalizationSetups()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not (Session.CurrentClientType() in [ClientType::Web, ClientType::Windows, ClientType::Desktop]) then
            exit;
        if UpgradeTag.HasUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::CROFiscalizationSetup)) then
            exit;

        RemoveCROFiscalizationSetupGuidedExperience();

        AddCROFiscalizationSetupSteps();

        UpgradeTag.SetUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::CROFiscalizationSetup));
    end;

    local procedure RemoveCROFiscalizationSetupGuidedExperience()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup CRO Fiscal");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup CRO Audit Profile");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup CRO Salespeople");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup CRO POS Paym. Meth.");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup CRO Paym. Meth.");
    end;

    local procedure AddCROFiscalizationSetupSteps()
    begin
        EnableCROFiscalSetupWizard();
        EnableCROAuditProfileSetupWizard();
        EnableCROSalespeopleSetupWizard();
        EnableCROPOSPaymMethodMappSetupWizard();
        EnableCROPaymentMethodSetupWizard();
    end;

    local procedure EnableCROFiscalSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Enable Fiscalization', Locked = true;
        SetupDescriptionTxt: Label 'Enable Fiscalization', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup CRO Fiscal") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                3,
                                                ObjectType::Page,
                                                Page::"NPR Setup CRO Fiscal",
                                                AssistedSetupGroup::NPRCROFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableCROAuditProfileSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup POS Audit Profile', Locked = true;
        SetupDescriptionTxt: Label 'Setup POS Audit Profile', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup CRO Audit Profile") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Setup CRO Audit Profile",
                                                AssistedSetupGroup::NPRCROFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableCROSalespeopleSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup Salespeople', Locked = true;
        SetupDescriptionTxt: Label 'Setup Salespeople', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup CRO Salespeople") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Setup CRO Salespeople",
                                                AssistedSetupGroup::NPRCROFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableCROPOSPaymMethodMappSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup POS Payment Methods', Locked = true;
        SetupDescriptionTxt: Label 'Setup POS Payment Methods', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup CRO POS Paym. Meth.") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Setup CRO POS Paym. Meth.",
                                                AssistedSetupGroup::NPRCROFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableCROPaymentMethodSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup Payment Methods', Locked = true;
        SetupDescriptionTxt: Label 'Setup Payment Methods', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup CRO Paym. Meth.") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Setup CRO Paym. Meth.",
                                                AssistedSetupGroup::NPRCROFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup CRO Salespeople", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupCROSalespeople_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupCROSalespeopleWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup CRO Fiscal", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupCROFiscalWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupCROFiscalWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup CRO Audit Profile", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupCROAuditProfileSetupWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupCROAuditProfileSetupWizard();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup CRO POS Paym. Meth.", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupCROPOSPaymMethodMappSetupWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupCROPOSPaymMethodMappSetupWizard();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup CRO Paym. Meth.", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupCROPaymMethodMappSetupWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupCROPaymMethodMappSetupWizard();
    end;

    local procedure UpdateSetupCROSalespeopleWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup CRO Salespeople");
    end;

    local procedure UpdateSetupCROFiscalWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup CRO Fiscal");
    end;

    local procedure UpdateSetupCROAuditProfileSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup CRO Audit Profile");
    end;

    local procedure UpdateSetupCROPOSPaymMethodMappSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup CRO POS Paym. Meth.");
    end;

    local procedure UpdateSetupCROPaymMethodMappSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup CRO Paym. Meth.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR CRO Fiscalization Setup", 'OnAfterValidateEvent', 'Enable CRO Fiscal', false, false)]
    local procedure ResetCROFiscalWizard_OnAfterValidateEnableCROFiscal(var Rec: Record "NPR CRO Fiscalization Setup"; var xRec: Record "NPR CRO Fiscalization Setup"; CurrFieldNo: Integer)
    begin
        if (Rec."Enable CRO Fiscal" <> xRec."Enable CRO Fiscal") and not Rec."Enable CRO Fiscal" then
            ResetSetupFiscalWizardStatus(Enum::"Assisted Setup Group"::NPRCROFiscal);
    end;
    #endregion

    #region RS Fiscalization Wizards
    local procedure RSFiscalizationSetups()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not (Session.CurrentClientType() in [ClientType::Web, ClientType::Windows, ClientType::Desktop]) then
            exit;
        if UpgradeTag.HasUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::RSFiscalizationSetup)) then
            exit;

        RemoveRSFiscalizationSetupGuidedExperience();

        AddRSFiscalizationSetupSteps();

        UpgradeTag.SetUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::RSFiscalizationSetup));
    end;

    local procedure RemoveRSFiscalizationSetupGuidedExperience()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup RS Fiscal");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup RS Audit Profile");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup RS POS Paym. Meth.");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup RS Payment Methods");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup RS VAT Posting");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup RS POS Unit");
    end;

    local procedure AddRSFiscalizationSetupSteps()
    begin
        EnableRSFiscalSetupWizard();
        EnableRSAuditProfileSetupWizard();
        EnableRSVATPostingSetupWizard();
        EnableRSPOSPaymMethodMappSetupWizard();
        EnableRSPaymentMethodsSetupWizard();
        EnableRSPOSUnitSetupWizard();
    end;

    local procedure EnableRSFiscalSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Enable Fiscalization', Locked = true;
        SetupDescriptionTxt: Label 'Enable Fiscalization', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup RS Fiscal") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                3,
                                                ObjectType::Page,
                                                Page::"NPR Setup RS Fiscal",
                                                AssistedSetupGroup::NPRRSFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableRSAuditProfileSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup POS Audit Profile', Locked = true;
        SetupDescriptionTxt: Label 'Setup POS Audit Profile', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup RS Audit Profile") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Setup RS Audit Profile",
                                                AssistedSetupGroup::NPRRSFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableRSVATPostingSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup VAT Posting', Locked = true;
        SetupDescriptionTxt: Label 'Setup VAT Posting', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup RS VAT Posting") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Setup RS VAT Posting",
                                                AssistedSetupGroup::NPRRSFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableRSPOSPaymMethodMappSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup POS Payment Methods', Locked = true;
        SetupDescriptionTxt: Label 'Setup POS Payment Methods', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup RS POS Paym. Meth.") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Setup RS POS Paym. Meth.",
                                                AssistedSetupGroup::NPRRSFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableRSPaymentMethodsSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup Payment Methods', Locked = true;
        SetupDescriptionTxt: Label 'Setup Payment Methods', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup RS Payment Methods") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Setup RS Payment Methods",
                                                AssistedSetupGroup::NPRRSFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableRSPOSUnitSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup POS Units', Locked = true;
        SetupDescriptionTxt: Label 'Setup POS Units', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup RS POS Unit") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                3,
                                                ObjectType::Page,
                                                Page::"NPR Setup RS POS Unit",
                                                AssistedSetupGroup::NPRRSFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup RS VAT Posting", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupRSVATPosting_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupRSVATPostingWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup RS Fiscal", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupRSFiscalWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupRSFiscalWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup RS Audit Profile", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupRSAuditProfileSetupWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupRSAuditProfileSetupWizard();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup RS Audit Profile", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupRSPaymMethodsSetupWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupRSPaymMethodMappSetupWizard();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup RS POS Paym. Meth.", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupRSPOSPaymMethodMappSetupWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupRSPOSPaymMethodMappSetupWizard();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup RS POS Unit", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupRSPOSUnitSetupWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupRSPOSUnitSetupWizard();
    end;

    local procedure UpdateSetupRSVATPostingWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup RS VAT Posting");
    end;

    local procedure UpdateSetupRSFiscalWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup RS Fiscal");
    end;

    local procedure UpdateSetupRSAuditProfileSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup RS Audit Profile");
    end;

    local procedure UpdateSetupRSPOSPaymMethodMappSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup RS POS Paym. Meth.");
    end;

    local procedure UpdateSetupRSPaymMethodMappSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup RS Payment Methods");
    end;

    local procedure UpdateSetupRSPOSUnitSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup RS POS Unit");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR RS Fiscalisation Setup", 'OnAfterValidateEvent', 'Enable RS Fiscal', false, false)]
    local procedure ResetRSFiscalWizard_OnAfterValidateEnableRSFiscal(var Rec: Record "NPR RS Fiscalisation Setup"; var xRec: Record "NPR RS Fiscalisation Setup"; CurrFieldNo: Integer)
    begin
        if (Rec."Enable RS Fiscal" <> xRec."Enable RS Fiscal") and not Rec."Enable RS Fiscal" then
            ResetSetupFiscalWizardStatus(Enum::"Assisted Setup Group"::NPRRSFiscal);
    end;
    #endregion

    #region SI Fiscalization Wizard

    local procedure SIFiscalizationSetups()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not (Session.CurrentClientType() in [ClientType::Web, ClientType::Windows, ClientType::Desktop]) then
            exit;
        if UpgradeTag.HasUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::SIFiscalizationSetup)) then
            exit;

        RemoveSIFiscalizationSetupGuidedExperience();

        AddSIFiscalizationSetupSteps();

        UpgradeTag.SetUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::SIFiscalizationSetup));
    end;

    local procedure RemoveSIFiscalizationSetupGuidedExperience()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup SI Fiscal");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup SI Audit Profile");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup SI Salespeople");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup SI POS Store");
    end;

    local procedure AddSIFiscalizationSetupSteps()
    begin
        EnableSIFiscalSetupWizard();
        EnableSIAuditProfileSetupWizard();
        EnableSISalespeopleSetupWizard();
        EnableSIPOSStoreMappSetupWizard();
    end;

    local procedure EnableSIFiscalSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Enable Fiscalization', Locked = true;
        SetupDescriptionTxt: Label 'Enable Fiscalization', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup SI Fiscal") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                3,
                                                ObjectType::Page,
                                                Page::"NPR Setup SI Fiscal",
                                                AssistedSetupGroup::NPRSIFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableSIAuditProfileSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup POS Audit Profile', Locked = true;
        SetupDescriptionTxt: Label 'Setup POS Audit Profile', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup SI Audit Profile") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Setup SI Audit Profile",
                                                AssistedSetupGroup::NPRSIFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableSISalespeopleSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup Salespeople', Locked = true;
        SetupDescriptionTxt: Label 'Setup Salespeople', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup SI Salespeople") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Setup SI Salespeople",
                                                AssistedSetupGroup::NPRSIFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableSIPOSStoreMappSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup POS Store', Locked = true;
        SetupDescriptionTxt: Label 'Setup POS Store', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup SI POS Store") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Setup SI POS Store",
                                                AssistedSetupGroup::NPRSIFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup SI Salespeople", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupSISalespeople_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupSISalespeopleWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup SI Fiscal", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupSIFiscalWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupSIFiscalWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup SI Audit Profile", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupSIAuditProfileSetupWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupSIAuditProfileSetupWizard();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup SI POS Store", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupSIPOSPaymMethodMappSetupWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupSIPOSStoreMappSetupWizard();
    end;

    local procedure UpdateSetupSISalespeopleWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup SI Salespeople");
    end;

    local procedure UpdateSetupSIFiscalWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup SI Fiscal");
    end;

    local procedure UpdateSetupSIAuditProfileSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup SI Audit Profile");
    end;

    local procedure UpdateSetupSIPOSStoreMappSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup SI POS Store");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR SI Fiscalization Setup", 'OnAfterValidateEvent', 'Enable SI Fiscal', false, false)]
    local procedure ResetSIFiscalWizard_OnAfterValidateEnableSIFiscal(var Rec: Record "NPR SI Fiscalization Setup"; var xRec: Record "NPR SI Fiscalization Setup"; CurrFieldNo: Integer)
    begin
        if (Rec."Enable SI Fiscal" <> xRec."Enable SI Fiscal") and not Rec."Enable SI Fiscal" then
            ResetSetupFiscalWizardStatus(Enum::"Assisted Setup Group"::NPRSIFiscal);
    end;
    #endregion

    #region IT Fiscalization Wizards
    local procedure ITFiscalizationSetups()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not (Session.CurrentClientType() in [ClientType::Web, ClientType::Windows, ClientType::Desktop]) then
            exit;
        if UpgradeTag.HasUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::ITFiscalizationSetup)) then
            exit;

        RemoveITFiscalizationSetupGuidedExperience();

        AddITFiscalizationSetupSteps();

        UpgradeTag.SetUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::ITFiscalizationSetup));
    end;

    local procedure RemoveITFiscalizationSetupGuidedExperience()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup IT Fiscal");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup IT Audit Profile");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup IT POS Unit Mapping");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup IT POS Paym. Meth.");
    end;

    local procedure AddITFiscalizationSetupSteps()
    begin
        EnableITFiscalSetupWizard();
        EnableITAuditProfileSetupWizard();
        EnableITPOSPaymMethodMappSetupWizard();
        EnableITPaymentMethodSetupWizard();
    end;

    local procedure EnableITFiscalSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Enable Fiscalization', Locked = true;
        SetupDescriptionTxt: Label 'Enable Fiscalization', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup IT Fiscal") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                3,
                                                ObjectType::Page,
                                                Page::"NPR Setup IT Fiscal",
                                                AssistedSetupGroup::NPRITFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableITAuditProfileSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup POS Audit Profile', Locked = true;
        SetupDescriptionTxt: Label 'Setup POS Audit Profile', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup IT Audit Profile") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Setup IT Audit Profile",
                                                AssistedSetupGroup::NPRITFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableITPOSPaymMethodMappSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup POS Payment Methods', Locked = true;
        SetupDescriptionTxt: Label 'Setup POS Payment Methods', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup IT POS Paym. Meth.") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Setup IT POS Paym. Meth.",
                                                AssistedSetupGroup::NPRITFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableITPaymentMethodSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup POS Units', Locked = true;
        SetupDescriptionTxt: Label 'Setup POS Units', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup IT POS Unit Mapping") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Setup IT POS Unit Mapping",
                                                AssistedSetupGroup::NPRITFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup IT Fiscal", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupITFiscalWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupITFiscalWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup IT Audit Profile", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupITAuditProfileSetupWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupITAuditProfileSetupWizard();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup IT POS Paym. Meth.", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupITPOSPaymMethodMappSetupWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupITPOSPaymMethodMappSetupWizard();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup IT POS Unit Mapping", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupITPaymMethodMappSetupWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupITPOSUnitMappingSetupWizard();
    end;

    local procedure UpdateSetupITFiscalWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup IT Fiscal");
    end;

    local procedure UpdateSetupITAuditProfileSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup IT Audit Profile");
    end;

    local procedure UpdateSetupITPOSPaymMethodMappSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup IT POS Paym. Meth.");
    end;

    local procedure UpdateSetupITPOSUnitMappingSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup IT POS Unit Mapping");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR IT Fiscalization Setup", 'OnAfterValidateEvent', 'Enable IT Fiscal', false, false)]
    local procedure ResetITFiscalWizard_OnAfterValidateEnableITFiscal(var Rec: Record "NPR IT Fiscalization Setup"; var xRec: Record "NPR IT Fiscalization Setup"; CurrFieldNo: Integer)
    begin
        if (Rec."Enable IT Fiscal" <> xRec."Enable IT Fiscal") and not Rec."Enable IT Fiscal" then
            ResetSetupFiscalWizardStatus(Enum::"Assisted Setup Group"::NPRITFiscal);
    end;
    #endregion

    #region AT Fiscalization Wizards
    local procedure ATFiscalizationSetups()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not (Session.CurrentClientType() in [ClientType::Web, ClientType::Windows, ClientType::Desktop]) then
            exit;

        if UpgradeTag.HasUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::ATFiscalization)) then
            exit;

        RemoveATFiscalizationSetupGuidedExperience();

        AddATFiscalizationSetupsWizard();

        UpgradeTag.SetUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::ATFiscalization));
    end;

    local procedure RemoveATFiscalizationSetupGuidedExperience()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup AT Fiscal");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup AT Fiskaly");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup AT POS Audit Profile");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup AT VAT Posting Setup");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup AT POS Paym. Meth.");
    end;

    local procedure AddATFiscalizationSetupsWizard()
    begin
        EnableATFiscalSetupWizard();
        EnableATFiskalySetupWizard();
        EnableATAuditProfileSetupWizard();
        EnableATVATPostingSetupWizard();
        EnableATPOSPaymentMethodSetupWizard();
    end;

    local procedure EnableATFiscalSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Enable Fiscalization', Locked = true;
        SetupDescriptionTxt: Label 'Enable Fiscalization', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup AT Fiscal") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                3,
                                                ObjectType::Page,
                                                Page::"NPR Setup AT Fiscal",
                                                AssistedSetupGroup::NPRATFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableATFiskalySetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup Integration with Fiskaly', Locked = true;
        SetupDescriptionTxt: Label 'Setup Integration with Fiskaly', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup AT Fiskaly") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                5,
                                                ObjectType::Page,
                                                Page::"NPR Setup AT Fiskaly",
                                                AssistedSetupGroup::NPRATFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableATAuditProfileSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup POS Audit Profile', Locked = true;
        SetupDescriptionTxt: Label 'Setup POS Audit Profile', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup AT POS Audit Profile") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Setup AT POS Audit Profile",
                                                AssistedSetupGroup::NPRATFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableATVATPostingSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup VAT Posting Setups', Locked = true;
        SetupDescriptionTxt: Label 'Setup VAT Posting Setups', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup AT VAT Posting Setup") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                5,
                                                ObjectType::Page,
                                                Page::"NPR Setup AT VAT Posting Setup",
                                                AssistedSetupGroup::NPRATFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableATPOSPaymentMethodSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup POS Payment Methods', Locked = true;
        SetupDescriptionTxt: Label 'Setup POS Payment Methods', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup AT POS Paym. Meth.") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                3,
                                                ObjectType::Page,
                                                Page::"NPR Setup AT POS Paym. Meth.",
                                                AssistedSetupGroup::NPRATFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup AT Fiscal", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupATFiscalWizard_OnAfterFinishStep(DataPopulated: Boolean)
    begin
        if DataPopulated then
            UpdateSetupATFiscalWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup AT Fiskaly", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupATFiskalyWizard_OnAfterFinishStep(DataPopulated: Boolean)
    begin
        if DataPopulated then
            UpdateSetupATFiskalyWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup AT POS Audit Profile", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupATPOSAuditProfileWizard_OnAfterFinishStep(DataPopulated: Boolean)
    begin
        if DataPopulated then
            UpdateSetupATAuditProfileWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup AT VAT Posting Setup", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupATVATPostingSetupWizard_OnAfterFinishStep(DataPopulated: Boolean)
    begin
        if DataPopulated then
            UpdateSetupATVATPostingSetupWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup AT POS Paym. Meth.", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupATPOSPaymMethWizard_OnAfterFinishStep(DataPopulated: Boolean)
    begin
        if DataPopulated then
            UpdateSetupATPOSPaymMethWizardStatus();
    end;

    local procedure UpdateSetupATFiscalWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup AT Fiscal");
    end;

    local procedure UpdateSetupATFiskalyWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup AT Fiskaly");
    end;

    local procedure UpdateSetupATAuditProfileWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup AT POS Audit Profile");
    end;

    local procedure UpdateSetupATVATPostingSetupWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup AT VAT Posting Setup");
    end;

    local procedure UpdateSetupATPOSPaymMethWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup AT POS Paym. Meth.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR AT Fiscalization Setup", 'OnAfterValidateEvent', 'AT Fiscal Enabled', false, false)]
    local procedure ResetATFiscalWizard_OnAfterValidateATFiscalEnabled(var Rec: Record "NPR AT Fiscalization Setup"; var xRec: Record "NPR AT Fiscalization Setup"; CurrFieldNo: Integer)
    begin
        if (Rec."AT Fiscal Enabled" <> xRec."AT Fiscal Enabled") and not Rec."AT Fiscal Enabled" then
            ResetSetupFiscalWizardStatus(Enum::"Assisted Setup Group"::NPRATFiscal);
    end;
    #endregion

    #region Helper Procedures
    local procedure ResetSetupFiscalWizardStatus(AssistedSetupGroup: Enum "Assisted Setup Group")
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        case AssistedSetupGroup of
            AssistedSetupGroup::NPRATFiscal:
                GuidedExperience.ResetAssistedSetup(ObjectType::Page, Page::"NPR Setup AT Fiscal");
            AssistedSetupGroup::NPRCROFiscal:
                GuidedExperience.ResetAssistedSetup(ObjectType::Page, Page::"NPR Setup CRO Fiscal");
            AssistedSetupGroup::NPRITFiscal:
                GuidedExperience.ResetAssistedSetup(ObjectType::Page, Page::"NPR Setup IT Fiscal");
            AssistedSetupGroup::NPRRSFiscal:
                GuidedExperience.ResetAssistedSetup(ObjectType::Page, Page::"NPR Setup RS Fiscal");
            AssistedSetupGroup::NPRBGSISFiscal:
                GuidedExperience.ResetAssistedSetup(ObjectType::Page, Page::"NPR Setup BG SIS Fiscal");
            AssistedSetupGroup::NPRSIFiscal:
                GuidedExperience.ResetAssistedSetup(ObjectType::Page, Page::"NPR Setup SI Fiscal");
            AssistedSetupGroup::NPRRSEInvoice:
                GuidedExperience.ResetAssistedSetup(ObjectType::Page, Page::"NPR Setup RS E-Invoice");
            AssistedSetupGroup::NPRBEFiscal:
                GuidedExperience.ResetAssistedSetup(ObjectType::Page, Page::"NPR Setup BE Fiscal");
            AssistedSetupGroup::NPRIRLFiscal:
                GuidedExperience.ResetAssistedSetup(ObjectType::Page, Page::"NPR Setup IRL Fiscal");
            AssistedSetupGroup::NPRNOFiscal:
                GuidedExperience.ResetAssistedSetup(ObjectType::Page, Page::"NPR Setup NO Fiscal");
            AssistedSetupGroup::NPRSECleanCash:
                GuidedExperience.ResetAssistedSetup(ObjectType::Page, Page::"NPR Setup SE Fiscal");
            AssistedSetupGroup::NPRHUMultiSoftEInv:
                GuidedExperience.ResetAssistedSetup(ObjectType::Page, Page::"NPR Setup HU MS Fiscal");
            AssistedSetupGroup::NPRESFiscal:
                GuidedExperience.ResetAssistedSetup(ObjectType::Page, Page::"NPR Setup ES Fiscal");
        end;
    end;

    #endregion

    #region RS E-Invoice Wizards
    local procedure RSEInvoiceSetups()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not (Session.CurrentClientType() in [ClientType::Web, ClientType::Windows, ClientType::Desktop]) then
            exit;

        if UpgradeTag.HasUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::RSEInvoiceSetup)) then
            exit;

        RemoveRSEInvoiceSetupGuidedExperience();

        AddRSEInvoiceSetupsWizard();

        UpgradeTag.SetUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::RSEInvoiceSetup));
    end;

    local procedure RemoveRSEInvoiceSetupGuidedExperience()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup RS E-Invoice");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup RS EI VAT Posting");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup RS EI Tax Ex. Reason");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup RS EI Paym. Meth.");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup RS EI UOM Mapping");
    end;

    local procedure AddRSEInvoiceSetupsWizard()
    begin
        EnableRSEInvoiceSetupWizard();
        EnableRSEIVATPostingSetupWizard();
        EnableRSEITaxExReasonWizard();
        EnableRSEIPaymMethWizard();
        EnableRSEIUOMMappingWizard();
    end;

    local procedure EnableRSEInvoiceSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Enable E-Invoice', Locked = true;
        SetupDescriptionTxt: Label 'Enable E-Invoice', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup RS E-Invoice") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                3,
                                                ObjectType::Page,
                                                Page::"NPR Setup RS E-Invoice",
                                                AssistedSetupGroup::NPRRSEInvoice,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableRSEIVATPostingSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup VAT Posting Setups', Locked = true;
        SetupDescriptionTxt: Label 'Setup VAT Posting Setups', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup RS EI VAT Posting") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                1,
                                                ObjectType::Page,
                                                Page::"NPR Setup RS EI VAT Posting",
                                                AssistedSetupGroup::NPRRSEInvoice,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableRSEITaxExReasonWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup Tax Exemption Reasons', Locked = true;
        SetupDescriptionTxt: Label 'Setup Tax Exemption Reasons', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup RS EI Tax Ex. Reason") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                1,
                                                ObjectType::Page,
                                                Page::"NPR Setup RS EI Tax Ex. Reason",
                                                AssistedSetupGroup::NPRRSEInvoice,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableRSEIPaymMethWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup Payment Methods', Locked = true;
        SetupDescriptionTxt: Label 'Setup Payment Methods', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup RS EI Paym. Meth.") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                1,
                                                ObjectType::Page,
                                                Page::"NPR Setup RS EI Paym. Meth.",
                                                AssistedSetupGroup::NPRRSEInvoice,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableRSEIUOMMappingWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup Units of Measure', Locked = true;
        SetupDescriptionTxt: Label 'Setup Units of Measure', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup RS EI UOM Mapping") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Setup RS EI UOM Mapping",
                                                AssistedSetupGroup::NPRRSEInvoice,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup RS E-Invoice", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupRSEInvoiceWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupRSEInvoiceWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup RS EI VAT Posting", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupRSEIVATPostingWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupRSEIVATPostingWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup RS EI Tax Ex. Reason", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupRSEITaxExReasonWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupRSEITaxExReasonWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup RS EI Paym. Meth.", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupRSEIPaymMethWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupRSEIPaymMethWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup RS EI UOM Mapping", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupRSEIUOMMappingWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupRSEIUOMMappingWizardStatus();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR RS E-Invoice Setup", 'OnAfterValidateEvent', 'Enable RS E-Invoice', false, false)]
    local procedure ResetRSEInvoiceWizard_OnAfterValidateEnableRSEInvoice(var Rec: Record "NPR RS E-Invoice Setup"; var xRec: Record "NPR RS E-Invoice Setup"; CurrFieldNo: Integer)
    begin
        if (Rec."Enable RS E-Invoice" <> xRec."Enable RS E-Invoice") and not Rec."Enable RS E-Invoice" then
            ResetSetupFiscalWizardStatus(Enum::"Assisted Setup Group"::NPRRSEInvoice);
    end;

    local procedure UpdateSetupRSEInvoiceWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup RS E-Invoice");
    end;

    local procedure UpdateSetupRSEIVATPostingWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup RS EI VAT Posting");
    end;

    local procedure UpdateSetupRSEITaxExReasonWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup RS EI Tax Ex. Reason");
    end;

    local procedure UpdateSetupRSEIPaymMethWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup RS EI Paym. Meth.");
    end;

    local procedure UpdateSetupRSEIUOMMappingWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup RS EI UOM Mapping");
    end;
    #endregion
    #region DE Fiscalization Wizards
    local procedure DEFiscalizationSetups()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not (Session.CurrentClientType() in [ClientType::Web, ClientType::Windows, ClientType::Desktop]) then
            exit;

        if UpgradeTag.HasUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::DEFiscalization)) then
            exit;

        RemoveDEFiscalizationSetupGuidedExperience();

        AddDEFiscalizationSetupsWizard();

        UpgradeTag.SetUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::DEFiscalization));
    end;

    Local procedure RemoveDEFiscalizationSetupGuidedExperience()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup DE Fiscal");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup DE POS Audit Profile");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup DE VAT Posting Setup");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup DE POS Paym. Meth.");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup DE Fiskaly");
    end;

    local procedure AddDEFiscalizationSetupsWizard()
    begin
        EnableDEFiscalSetupWizard();
        EnableDEAuditProfileSetupWizard();
        EnableDEVATPostingSetupWizard();
        EnableDEPOSPaymentMethodSetupWizard();
        EnableDEFiskalySetupWizard();
    end;

    local procedure EnableDEFiscalSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Enable Fiscalization', Locked = true;
        SetupDescriptionTxt: Label 'Enable Fiscalization', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup DE Fiscal") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                3,
                                                ObjectType::Page,
                                                Page::"NPR Setup DE Fiscal",
                                                AssistedSetupGroup::NPRDEFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableDEAuditProfileSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup POS Audit Profile', Locked = true;
        SetupDescriptionTxt: Label 'Setup POS Audit Profile', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup DE POS Audit Profile") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Setup DE POS Audit Profile",
                                                AssistedSetupGroup::NPRDEFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableDEVATPostingSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup VAT Posting Setups', Locked = true;
        SetupDescriptionTxt: Label 'Setup VAT Posting Setups', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup DE VAT Posting Setup") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                5,
                                                ObjectType::Page,
                                                Page::"NPR Setup DE VAT Posting Setup",
                                                AssistedSetupGroup::NPRDEFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableDEPOSPaymentMethodSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup POS Payment Methods', Locked = true;
        SetupDescriptionTxt: Label 'Setup POS Payment Methods', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup DE POS Paym. Meth.") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                3,
                                                ObjectType::Page,
                                                Page::"NPR Setup DE POS Paym. Meth.",
                                                AssistedSetupGroup::NPRDEFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableDEFiskalySetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup DE Fiskaly', Locked = true;
        SetupDescriptionTxt: Label 'Setup DE Fiskaly', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup DE Fiskaly") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                8,
                                                ObjectType::Page,
                                                Page::"NPR Setup DE Fiskaly",
                                                AssistedSetupGroup::NPRDEFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup DE Fiscal", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupDEFiscalWizard_OnAfterFinishStep(DataPopulated: Boolean)
    begin
        if DataPopulated then
            UpdateSetupDEFiscalWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup DE POS Audit Profile", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupDEPOSAuditProfileWizard_OnAfterFinishStep(DataPopulated: Boolean)
    begin
        if DataPopulated then
            UpdateSetupDEAuditProfileWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup DE VAT Posting Setup", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupDEVATPostingSetupWizard_OnAfterFinishStep(DataPopulated: Boolean)
    begin
        if DataPopulated then
            UpdateSetupDEVATPostingSetupWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup DE POS Paym. Meth.", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupDEPOSPaymMethWizard_OnAfterFinishStep(DataPopulated: Boolean)
    begin
        if DataPopulated then
            UpdateSetupDEPOSPaymMethWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup DE Fiskaly", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupDEFiskalyWizard_OnAfterFinishStep(DataPopulated: Boolean)
    begin
        if DataPopulated then
            UpdateSetupDEFiskalyWizardStatus();
    end;

    local procedure UpdateSetupDEFiskalyWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup DE Fiskaly");
    end;

    local procedure UpdateSetupDEFiscalWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup DE Fiscal");
    end;

    local procedure UpdateSetupDEAuditProfileWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup DE POS Audit Profile");
    end;

    local procedure UpdateSetupDEVATPostingSetupWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup DE VAT Posting Setup");
    end;

    local procedure UpdateSetupDEPOSPaymMethWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup DE POS Paym. Meth.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR DE Fiscalization Setup", 'OnAfterValidateEvent', 'Enable DE Fiscal', false, false)]
    local procedure ResetDEFiscalWizard_OnAfterValidateATFiscalEnabled(var Rec: Record "NPR DE Fiscalization Setup"; var xRec: Record "NPR DE Fiscalization Setup"; CurrFieldNo: Integer)
    begin
        if (Rec."Enable DE Fiscal" <> xRec."Enable DE Fiscal") and not Rec."Enable DE Fiscal" then
            ResetSetupDEFiscalWizardStatus();
    end;

    local procedure ResetSetupDEFiscalWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.ResetAssistedSetup(ObjectType::Page, Page::"NPR Setup AT Fiscal");
    end;

    #endregion

    #region BE Fiscalization Wizards
    local procedure BEFiscalizationSetups()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not (Session.CurrentClientType() in [ClientType::Web, ClientType::Windows, ClientType::Desktop]) then
            exit;

        if UpgradeTag.HasUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::BEFiscalization)) then
            exit;

        RemoveBEFiscalizationSetupGuidedExperience();

        AddBEFiscalizationSetupsWizard();

        UpgradeTag.SetUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::BEFiscalization));
    end;

    local procedure RemoveBEFiscalizationSetupGuidedExperience()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup BE Fiscal");
    end;

    local procedure AddBEFiscalizationSetupsWizard()
    begin
        EnableBEFiscalSetupWizard();
    end;

    local procedure EnableBEFiscalSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Enable Fiscalization', Locked = true;
        SetupDescriptionTxt: Label 'Enable Fiscalization', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup BE Fiscal") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                1,
                                                ObjectType::Page,
                                                Page::"NPR Setup BE Fiscal",
                                                AssistedSetupGroup::NPRBEFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup BE Fiscal", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupBEFiscalWizard_OnAfterFinishStep()
    begin
        UpdateSetupBEFiscalWizardStatus();
    end;

    local procedure UpdateSetupBEFiscalWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup BE Fiscal");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR BE Fiscalisation Setup", 'OnAfterValidateEvent', 'Enable BE Fiscal', false, false)]
    local procedure ResetBEFiscalWizard_OnAfterValidateBEFiscalEnabled(var Rec: Record "NPR BE Fiscalisation Setup"; var xRec: Record "NPR BE Fiscalisation Setup"; CurrFieldNo: Integer)
    begin
        if (Rec."Enable BE Fiscal" <> xRec."Enable BE Fiscal") and not Rec."Enable BE Fiscal" then
            ResetSetupFiscalWizardStatus(Enum::"Assisted Setup Group"::NPRBEFiscal);
    end;

    #endregion

    #region IRL Fiscalization Wizards
    local procedure IRLFiscalizationSetups()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not (Session.CurrentClientType() in [ClientType::Web, ClientType::Windows, ClientType::Desktop]) then
            exit;

        if UpgradeTag.HasUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::IRLFiscalization)) then
            exit;

        RemoveIRLFiscalizationSetupGuidedExperience();

        AddIRLFiscalizationSetupsWizard();

        UpgradeTag.SetUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::IRLFiscalization));
    end;

    local procedure RemoveIRLFiscalizationSetupGuidedExperience()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup IRL Fiscal");
    end;

    local procedure AddIRLFiscalizationSetupsWizard()
    begin
        EnableIRLFiscalSetupWizard();
    end;

    local procedure EnableIRLFiscalSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Enable Fiscalization', Locked = true;
        SetupDescriptionTxt: Label 'Enable Fiscalization', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup IRL Fiscal") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                1,
                                                ObjectType::Page,
                                                Page::"NPR Setup IRL Fiscal",
                                                AssistedSetupGroup::NPRIRLFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup IRL Fiscal", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupIRLFiscalWizard_OnAfterFinishStep()
    begin
        UpdateSetupIRLFiscalWizardStatus();
    end;

    local procedure UpdateSetupIRLFiscalWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup IRL Fiscal");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR IRL Fiscalization Setup", 'OnAfterValidateEvent', 'Enable IRL Fiscal', false, false)]
    local procedure ResetIRLFiscalWizard_OnAfterValidateIRLFiscalEnabled(var Rec: Record "NPR IRL Fiscalization Setup"; var xRec: Record "NPR IRL Fiscalization Setup"; CurrFieldNo: Integer)
    begin
        if (Rec."Enable IRL Fiscal" <> xRec."Enable IRL Fiscal") and not Rec."Enable IRL Fiscal" then
            ResetSetupFiscalWizardStatus(Enum::"Assisted Setup Group"::NPRIRLFiscal);
    end;
    #endregion

    #region NO MultiSoft Wizards
    local procedure NOFiscalizationSetups()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not (Session.CurrentClientType() in [ClientType::Web, ClientType::Windows, ClientType::Desktop]) then
            exit;

        if UpgradeTag.HasUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::NOFiscalization)) then
            exit;

        RemoveNOFiscalizationSetupGuidedExperience();

        AddNOFiscalizationSetupsWizard();

        UpgradeTag.SetUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::NOFiscalization));
    end;

    local procedure RemoveNOFiscalizationSetupGuidedExperience()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup NO Fiscal");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup NO Audit Profile");
    end;

    local procedure AddNOFiscalizationSetupsWizard()
    begin
        EnableNOFiscalSetupWizard();
        EnableNOFiscalAuditProfileSetupWizard();
    end;

    local procedure EnableNOFiscalSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Enable Fiscalization', Locked = true;
        SetupDescriptionTxt: Label 'Enable Fiscalization', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup NO Fiscal") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                3,
                                                ObjectType::Page,
                                                Page::"NPR Setup NO Fiscal",
                                                AssistedSetupGroup::NPRNOFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableNOFiscalAuditProfileSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup POS Audit Profile', Locked = true;
        SetupDescriptionTxt: Label 'Setup POS Audit Profile', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup NO Audit Profile") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Setup NO Audit Profile",
                                                AssistedSetupGroup::NPRNOFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup NO Fiscal", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupNOFiscalWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupNOFiscalWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup NO Audit Profile", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupNOFiscalAuditProfileWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupNOFiscalAuditProfileWizardStatus();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NO Fiscalization Setup", 'OnAfterValidateEvent', 'Enable NO Fiscal', false, false)]
    local procedure ResetNOFiscalWizard_OnAfterValidateEnableHUFiscal(var Rec: Record "NPR NO Fiscalization Setup"; var xRec: Record "NPR NO Fiscalization Setup")
    begin
        if (Rec."Enable NO Fiscal" <> xRec."Enable NO Fiscal") and not Rec."Enable NO Fiscal" then
            ResetSetupFiscalWizardStatus(Enum::"Assisted Setup Group"::NPRNOFiscal);
    end;

    local procedure UpdateSetupNOFiscalWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup NO Fiscal");
    end;

    local procedure UpdateSetupNOFiscalAuditProfileWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup NO Audit Profile");
    end;
    #endregion
    #region SE CleanCash Wizards
    local procedure SECCFiscalizationSetups()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not (Session.CurrentClientType() in [ClientType::Web, ClientType::Windows, ClientType::Desktop]) then
            exit;

        if UpgradeTag.HasUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::SECCFiscalization)) then
            exit;

        RemoveSECCFiscalizationSetupGuidedExperience();

        AddSECCFiscalizationSetupsWizard();

        UpgradeTag.SetUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::SECCFiscalization));
    end;

    local procedure RemoveSECCFiscalizationSetupGuidedExperience()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup SE Fiscal");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup SE CleanCash");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup SE Audit Profile");
    end;

    local procedure AddSECCFiscalizationSetupsWizard()
    begin
        EnableSECCFiscalSetupWizard();
        EnableSECCFiscalPaymMethWizard();
        EnableSECCPOSAuditProfilehWizard();
    end;

    local procedure EnableSECCFiscalSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Enable Fiscalization', Locked = true;
        SetupDescriptionTxt: Label 'Enable Fiscalization', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup SE Fiscal") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                3,
                                                ObjectType::Page,
                                                Page::"NPR Setup SE Fiscal",
                                                AssistedSetupGroup::NPRSECleanCash,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableSECCFiscalPaymMethWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup CleanCash', Locked = true;
        SetupDescriptionTxt: Label 'Setup CleanCash', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup SE CleanCash") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                1,
                                                ObjectType::Page,
                                                Page::"NPR Setup SE CleanCash",
                                                AssistedSetupGroup::NPRSECleanCash,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableSECCPOSAuditProfilehWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup POS Audit Profile', Locked = true;
        SetupDescriptionTxt: Label 'Setup POS Audit Profile', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup SE Audit Profile") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                1,
                                                ObjectType::Page,
                                                Page::"NPR Setup SE Audit Profile",
                                                AssistedSetupGroup::NPRSECleanCash,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup SE Fiscal", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupSECCFiscalWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupSECCFiscalWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup SE CleanCash", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupSECleanCashWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupSECleanCashWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup SE Audit Profile", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupSEPOSAuditProfileWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupSEPOSAuditProfileWizardStatus();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR SE Fiscalization Setup.", 'OnAfterValidateEvent', 'Enable SE Fiscal', false, false)]
    local procedure ResetSECCFiscalWizard_OnAfterValidateEnableSECCFiscal(var Rec: Record "NPR SE Fiscalization Setup."; var xRec: Record "NPR SE Fiscalization Setup.")
    begin
        if (Rec."Enable SE Fiscal" <> xRec."Enable SE Fiscal") and not Rec."Enable SE Fiscal" then
            ResetSetupFiscalWizardStatus(Enum::"Assisted Setup Group"::NPRSECleanCash);
    end;

    local procedure UpdateSetupSECCFiscalWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup SE Fiscal");
    end;

    local procedure UpdateSetupSECleanCashWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup SE CleanCash");
    end;

    local procedure UpdateSetupSEPOSAuditProfileWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup SE Audit Profile");
    end;
    #endregion

    #region HU MultiSoft Wizards
    local procedure HUMSFiscalizationSetups()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not (Session.CurrentClientType() in [ClientType::Web, ClientType::Windows, ClientType::Desktop]) then
            exit;

        if UpgradeTag.HasUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::HUMSFiscalizationSetup)) then
            exit;

        RemoveHUMSFiscalizationSetupGuidedExperience();

        AddHUMSFiscalizationSetupsWizard();

        UpgradeTag.SetUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::HUMSFiscalizationSetup));
    end;

    local procedure RemoveHUMSFiscalizationSetupGuidedExperience()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup HU MS Fiscal");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup HU MS POS Paym Meth");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup HU MS Audit Profile");
    end;

    local procedure AddHUMSFiscalizationSetupsWizard()
    begin
        EnableHUMSFiscalSetupWizard();
        EnableHUMSFiscalPaymMethWizard();
        EnableHUMSFiscalAuditProfileSetupWizard();
    end;

    local procedure EnableHUMSFiscalSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Enable Fiscalization', Locked = true;
        SetupDescriptionTxt: Label 'Enable Fiscalization', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup HU MS Fiscal") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                3,
                                                ObjectType::Page,
                                                Page::"NPR Setup HU MS Fiscal",
                                                AssistedSetupGroup::NPRHUMultiSoftEInv,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableHUMSFiscalPaymMethWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup Payment Methods', Locked = true;
        SetupDescriptionTxt: Label 'Setup Payment Methods', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup HU MS POS Paym Meth") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                1,
                                                ObjectType::Page,
                                                Page::"NPR Setup HU MS POS Paym Meth",
                                                AssistedSetupGroup::NPRHUMultiSoftEInv,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableHUMSFiscalAuditProfileSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup POS Audit Profile', Locked = true;
        SetupDescriptionTxt: Label 'Setup POS Audit Profile', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup HU MS Audit Profile") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Setup HU MS Audit Profile",
                                                AssistedSetupGroup::NPRHUMultiSoftEInv,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup HU MS Fiscal", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupHUMSFiscalWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupHUMSFiscalWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup HU MS POS Paym Meth", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupHUMSFiscalPaymMethWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupHUMSFiscalPaymMethWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup HU MS Audit Profile", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupHUMSFiscalAuditProfileWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupHUMSFiscalAuditProfileWizardStatus();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR HU MS Fiscalization Setup", 'OnAfterValidateEvent', 'Enable HU Fiscal', false, false)]
    local procedure ResetHUMSFiscalWizard_OnAfterValidateEnableRSEInvoice(var Rec: Record "NPR HU MS Fiscalization Setup"; var xRec: Record "NPR HU MS Fiscalization Setup")
    begin
        if (Rec."Enable HU Fiscal" <> xRec."Enable HU Fiscal") and not Rec."Enable HU Fiscal" then
            ResetSetupFiscalWizardStatus(Enum::"Assisted Setup Group"::NPRHUMultiSoftEInv);
    end;

    local procedure UpdateSetupHUMSFiscalWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup HU MS Fiscal");
    end;

    local procedure UpdateSetupHUMSFiscalPaymMethWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup HU MS POS Paym Meth");
    end;

    local procedure UpdateSetupHUMSFiscalAuditProfileWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup HU MS Audit Profile");
    end;
    #endregion

    #region DK MultiSoft Wizards
    local procedure DKFiscalizationSetups()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not (Session.CurrentClientType() in [ClientType::Web, ClientType::Windows, ClientType::Desktop]) then
            exit;

        if UpgradeTag.HasUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::DKFiscalization)) then
            exit;

        RemoveDKFiscalizationSetupGuidedExperience();

        AddDKFiscalizationSetupsWizard();

        UpgradeTag.SetUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::DKFiscalization));
    end;

    local procedure RemoveDKFiscalizationSetupGuidedExperience()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup DK Fiscal");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup DK Audit Profile");
    end;

    local procedure AddDKFiscalizationSetupsWizard()
    begin
        EnableDKFiscalSetupWizard();
        EnableDKFiscalAuditProfileSetupWizard();
    end;

    local procedure EnableDKFiscalSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Enable Fiscalization', Locked = true;
        SetupDescriptionTxt: Label 'Enable Fiscalization', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup DK Fiscal") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                3,
                                                ObjectType::Page,
                                                Page::"NPR Setup DK Fiscal",
                                                AssistedSetupGroup::NPRDKFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableDKFiscalAuditProfileSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup POS Audit Profile', Locked = true;
        SetupDescriptionTxt: Label 'Setup POS Audit Profile', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup DK Audit Profile") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Setup DK Audit Profile",
                                                AssistedSetupGroup::NPRDKFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup DK Fiscal", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupDKFiscalWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupDKFiscalWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup DK Audit Profile", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupDKFiscalAuditProfileWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupDKFiscalAuditProfileWizardStatus();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR DK Fiscalization Setup", 'OnAfterValidateEvent', 'Enable DK Fiscal', false, false)]
    local procedure ResetDKFiscalWizard_OnAfterValidateEnableDKFiscal(var Rec: Record "NPR DK Fiscalization Setup"; var xRec: Record "NPR DK Fiscalization Setup")
    begin
        if (Rec."Enable DK Fiscal" <> xRec."Enable DK Fiscal") and not Rec."Enable DK Fiscal" then
            ResetSetupFiscalWizardStatus(Enum::"Assisted Setup Group"::NPRDKFiscal);
    end;

    local procedure UpdateSetupDKFiscalWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup DK Fiscal");
    end;

    local procedure UpdateSetupDKFiscalAuditProfileWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup DK Audit Profile");
    end;
    #endregion

    #region FR Fiscalization Wizards
    local procedure FRFiscalizationSetups()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not (Session.CurrentClientType() in [ClientType::Web, ClientType::Windows, ClientType::Desktop]) then
            exit;

        if UpgradeTag.HasUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::FRFiscalizationSetup)) then
            exit;

        RemoveFRFiscalizationSetupGuidedExperience();

        AddFRFiscalizationSetupsWizard();

        UpgradeTag.SetUpgradeTag(GetAssistedSetupUpgradeTag(ThisModul::FRFiscalizationSetup));
    end;

    local procedure RemoveFRFiscalizationSetupGuidedExperience()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup FR Audit No Series");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup FR Audit");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup FR POS Audit Prof");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup FR Company Info");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Setup FR EoD Profile");
    end;

    local procedure AddFRFiscalizationSetupsWizard()
    begin
        EnableFRAuditNoSeriesSetupWizard();
        EnableFRAuditWizard();
        EnableFRPOSAuditProfileWizard();
        EnableFRCompanyInfoWizard();
        EnableFREoDProfileWizard();
    end;

    local procedure EnableFRAuditNoSeriesSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup Audit No Series', Locked = true;
        SetupDescriptionTxt: Label 'Setup Audit No Series', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup FR Audit No Series") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                3,
                                                ObjectType::Page,
                                                Page::"NPR Setup FR Audit No Series",
                                                AssistedSetupGroup::NPRFRFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableFRAuditWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup FR Audit', Locked = true;
        SetupDescriptionTxt: Label 'Setup FR Audit', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup FR Audit") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                1,
                                                ObjectType::Page,
                                                Page::"NPR Setup FR Audit",
                                                AssistedSetupGroup::NPRFRFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableFRPOSAuditProfileWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup POS Audit Profile', Locked = true;
        SetupDescriptionTxt: Label 'Setup POS Audit Profile', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup FR POS Audit Prof") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Setup FR POS Audit Prof",
                                                AssistedSetupGroup::NPRFRFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableFRCompanyInfoWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup Company Information', Locked = true;
        SetupDescriptionTxt: Label 'Setup Company Information', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup FR Company Info") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Setup FR Company Info",
                                                AssistedSetupGroup::NPRFRFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure EnableFREoDProfileWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Setup FR End of Day Profile', Locked = true;
        SetupDescriptionTxt: Label 'Setup FR End of Day Profile', Locked = true;
    begin
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Setup FR EoD Profile") then
            GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                2,
                                                ObjectType::Page,
                                                Page::"NPR Setup FR EoD Profile",
                                                AssistedSetupGroup::NPRFRFiscal,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup FR Audit No Series", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupFRAuditNoSeriesWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupFRAuditNoSeriesWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup FR Audit", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupFRAuditWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupFRAuditWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup FR POS Audit Prof", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupFRPOSAuditProfileWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupFRPOSAuditProfileWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup FR Company Info", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupFRCompanyInfoWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupFRCompanyInfoWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Setup FR EoD Profile", 'OnAfterFinishStep', '', false, false)]
    local procedure SetupFREoDProfileWizard_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateSetupFREoDProfileWizardStatus();
    end;

    local procedure UpdateSetupFRAuditNoSeriesWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup FR Audit No Series");
    end;

    local procedure UpdateSetupFRAuditWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup FR Audit");
    end;

    local procedure UpdateSetupFRPOSAuditProfileWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup FR POS Audit Prof");
    end;

    local procedure UpdateSetupFRCompanyInfoWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup FR Company Info");
    end;

    local procedure UpdateSetupFREoDProfileWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Setup FR EoD Profile");
    end;
    #endregion

#if not (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Checklist Banner", 'OnBeforeUpdateBannerLabels', '', false, false)]
    local procedure ChecklistBannerOnBeforeUpdateBannerLabels(var IsHandled: Boolean; var DescriptionTxt: Text; var TitleTxt: Text; var HeaderTxt: Text)
    var
        ProfileRole: Record "All Profile";
        HeaderTextLbl: Label 'Welcome to NP Retail!';
        TitleTextLbl: Label 'Get Started';
        DescriptionTextLbl: Label 'We''ve prepared activities to quickly get you and your team started. Explore key features and benefits of our solution. Success awaits—let''s get started!';
        SessionSettings: SessionSettings;
    begin
        SessionSettings.Init();
        ProfileRole.SetRange("Profile ID", SessionSettings.ProfileId());
        if not ProfileRole.FindFirst() then
            exit;
        if (ProfileRole."Role Center ID" = Page::"NPR Retail Manager Role Center") or (ProfileRole."Role Center ID" = Page::"NPR Retail Setup RC") or (ProfileRole."Role Center ID" = Page::"NPR Entertainment RC") then begin
            IsHandled := true;
            TitleTxt := TitleTextLbl;
            DescriptionTxt := DescriptionTextLbl;
            HeaderTxt := HeaderTextLbl;
        end
    end;
#endif

    var
        Checklist: Codeunit Checklist;
        ThisModul: Option Retail,Restaurant,Attraction,CROFiscalizationSetup,RSFiscalizationSetup,BGSISFiscalization,SIFiscalizationSetup,ITFiscalizationSetup,ATFiscalization,RSEInvoiceSetup,DEFiscalization,BEFiscalization,IRLFiscalization,NOFiscalization,SECCFiscalization,HUMSFiscalizationSetup,DKFiscalization,FRFiscalizationSetup,ESFiscalization;
#endif
}