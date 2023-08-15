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
        AssistedSetupGroup: Enum "Assisted Setup Group";
    begin
        AssistedSetup.Add(GetAppId(), Codeunit::"NPR Welcome Video", POSStoresSetupTxt, AssistedSetupGroup::NPRetail);
        AssistedSetup.Add(GetAppId(), Page::"NPR Download&Import Data", ProfilesSetupTxt, AssistedSetupGroup::NPRetail);
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
    end;

    #region Retail
    //This region contains functions for creating Retail Setup Wizards and Checklist
    local procedure RetailSetups()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        Modul: Option Retail,Restaurant;
    begin
        if not (Session.CurrentClientType() in [ClientType::Web, ClientType::Windows, ClientType::Desktop]) then
            exit;
        if UpgradeTag.HasUpgradeTag(GetAssistedSetupUpgradeTag(Modul::Retail)) then
            exit;

        RemoveRetailGuidedExperience();

        AddRetailSetupsWizard();
        CreateRetailChecklistItems();

        UpgradeTag.SetUpgradeTag(GetAssistedSetupUpgradeTag(Modul::Retail));
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
    end;

    local procedure AddRetailSetupsWizard()
    begin
        CreateWelcomeVideoExperience();
        DownloadAndImportDataWizard();
        CreatePOSstoresAndUnitsWizard();
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
        Checklist.Insert("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Modify POS Posting Profile", 1103, TempAllProfile, false);
        Checklist.Insert("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Modify POS Payment Methods", 1104, TempAllProfile, false);
        Checklist.Insert("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Modify POS Posting Setup", 1105, TempAllProfile, false);
        Checklist.Insert("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Modify Salespeople", 1106, TempAllProfile, false);
        Checklist.InitializeGuidedExperienceItems();
    end;
    #endregion

    #region Restaurant
    //This region contains functions for creating Restaurant Setup Wizards and Checklist
    local procedure AddRestaurantSetupsWizard()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        Modul: Option Retail,Restaurant;
    begin

        if UpgradeTag.HasUpgradeTag(GetAssistedSetupUpgradeTag(Modul::Restaurant)) then
            exit;


        WelcomeVideoRestaurantExperience();
        DownloadAndImportRestDataWizard();
        CreateFlowStatusesWizard();
        CreatePrintProductionCategoriesWizard();
        CreateItemRoutingProfilesWizard();
        CreateRestServiceFlowProfilesWizard();
        CreateRestaurantLayoutWizard();
        CreateKitchenLayoutWizard();

        UpgradeTag.SetUpgradeTag(GetAssistedSetupUpgradeTag(Modul::Restaurant));
    end;

    local procedure RestaurantSetups()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        Modul: Option Retail,Restaurant;
    begin
        if not (Session.CurrentClientType() in [ClientType::Web, ClientType::Windows, ClientType::Desktop]) then
            exit;
        if UpgradeTag.HasUpgradeTag(GetChecklistUpgradeTag(Modul::Restaurant)) then
            exit;

        AddRestaurantSetupsWizard();
        CreateRestaurantChecklistItems();

        UpgradeTag.SetUpgradeTag(GetChecklistUpgradeTag(Modul::Restaurant));
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
    #endregion

    #region Common Functions
    //This region contains common functions used by all Setup Wizards and Checklists
    local procedure GetChecklistUpgradeTag(Modul: Option Retail,Restaurant): Code[250]
    begin
        case Modul of
            Modul::Retail:
                //For Any change, increase version
                exit('NPR-Checklist-v1.4');
            Modul::Restaurant:
                //For Any change, increase version
                exit('NPR-Checklist-Restaurant-v1.5');
        end;
    end;

    local procedure GetAssistedSetupUpgradeTag(Modul: Option Retail,Restaurant): Code[250]
    begin
        case Modul of
            Modul::Retail:
                //For Any change, increase version
                exit('NPR-AssistedSetup-v1.1');
            Modul::Restaurant:
                //For Any change, increase version
                exit('NPR-AssistedSetup-Restaurant-v1.5');
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
    #endregion

#if not (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC2200)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Checklist Banner", 'OnBeforeUpdateBannerLabels', '', false, false)]
    local procedure ChecklistBannerOnBeforeUpdateBannerLabels(var IsHandled: Boolean; var DescriptionTxt: Text; var TitleTxt: Text; var HeaderTxt: Text)
    var
        HeaderTextLbl: Label 'Welcome to NP Retail!';
        TitleTextLbl: Label 'Get Started';
        DescriptionTextLbl: Label 'We''ve prepared activities to quickly get you and your team started. Explore key features and benefits of our solution. Success awaits—let''s get started!';
    begin
        IsHandled := true;
        TitleTxt := TitleTextLbl;
        DescriptionTxt := DescriptionTextLbl;
        HeaderTxt := HeaderTextLbl;
    end;
#endif

    var
        Checklist: Codeunit Checklist;
#endif
}
