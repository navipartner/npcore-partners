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
        AddRetailSetupsWizard()
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
        AddRetailSetupsWizard();
        SetupRetailChecklist();
    end;

    local procedure AddRetailSetupsWizard()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin

        if UpgradeTag.HasUpgradeTag(GetAssistedSetupUpgradeTag()) then
            exit;

        CreateWelcomeVideoExperience();
        DownloadAndImportDataWizard();
        CreatePOSstoresAndUnitsWizard();
        ModifyPOSPostingProfileWizard();
        ModifyPOSpaymentMethodsWizard();
        ModifyPOSPostingSetupWizard();
        ModifySalesPeopleWizard();

        UpgradeTag.SetUpgradeTag(GetAssistedSetupUpgradeTag());
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
        WizardNameLbl: Label 'Download & Import Data.', Locked = true;
        SetupDescriptionTxt: Label 'Download & Import Data.', Locked = true;
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
        WizardNameLbl: Label 'Create POS Stores & Units.', Locked = true;
        SetupDescriptionTxt: Label 'Create POS Stores & Units.', Locked = true;
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
        WizardNameLbl: Label 'Modify POS Posting Profile.', Locked = true;
        SetupDescriptionTxt: Label 'Modify POS Posting Profile.', Locked = true;
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
        WizardNameLbl: Label 'Modify POS Payment Methods.', Locked = true;
        SetupDescriptionTxt: Label 'Modify POS Payment Methods.', Locked = true;
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
        WizardNameLbl: Label 'Modify POS Posting Setup.', Locked = true;
        SetupDescriptionTxt: Label 'Modify POS Posting Setup.', Locked = true;
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
        WizardNameLbl: Label 'Modify Salespeople.', Locked = true;
        SetupDescriptionTxt: Label 'Modify Salespeople.', Locked = true;
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

    local procedure SetupRetailChecklist()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not (Session.CurrentClientType() in [ClientType::Web, ClientType::Windows, ClientType::Desktop]) then
            exit;
        if UpgradeTag.HasUpgradeTag(GetChecklistUpgradeTag()) then
            exit;

        CreateChecklistItems();

        UpgradeTag.SetUpgradeTag(GetChecklistUpgradeTag());
    end;

    local procedure GetChecklistUpgradeTag(): Code[250]
    begin
        //For Any change, increase version
        exit('NPR-Checklist-v1.3');
    end;

    local procedure GetAssistedSetupUpgradeTag(): Code[250]
    begin
        //For Any change, increase version
        exit('NPR-AssistedSetup-v1.0');
    end;


    local procedure CreateChecklistItems()
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

    var
        Checklist: Codeunit Checklist;
#endif
}
