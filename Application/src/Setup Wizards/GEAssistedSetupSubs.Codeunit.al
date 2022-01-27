codeunit 6014490 "NPR GE Assisted Setup Subs"
{
    Access = Internal;
#IF BC17
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assisted Setup", 'OnRegister', '', false, false)]
    local procedure RegisterWizard_OnRegisterAssistedSetup()
    begin
        AddGraphAPIWizard();
        AddRetailWizard();
        AddMagentoWizard();
    end;

    local procedure AddGraphAPIWizard()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        SetupTxt: Label 'Set up GraphAPI Setup';
        AssistedSetupGroup: Enum "Assisted Setup Group";
    begin
        AssistedSetup.Add(GetAppId(), Page::"NPR GraphApi Setup Wizard", SetupTxt, AssistedSetupGroup::NPRetail);
    end;

    local procedure AddRetailWizard()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        SetupTxt: Label 'Set up Retail Setup';
        AssistedSetupGroup: Enum "Assisted Setup Group";
    begin
        AssistedSetup.Add(GetAppId(), Page::"NPR Retail Wizard", SetupTxt, AssistedSetupGroup::NPRetail);
    end;

    local procedure AddMagentoWizard()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        SetupTxt: Label 'Set up Magento Setup';
        AssistedSetupGroup: Enum "Assisted Setup Group";
    begin
        AssistedSetup.Add(GetAppId(), Page::"NPR Magento Wizard", SetupTxt, AssistedSetupGroup::NPRetail);
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
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterAssistedSetup', '', false, false)]
    local procedure RegisterWizard_OnRegisterAssistedSetup()
    begin
        AddMagentoWizard();
        AddRetailWizard();
        AddGraphAPIWizard();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnAfterRunAssistedSetup', '', false, false)]
    local procedure UpdateSetupStatus_OnUpdateAssistedSetupStatusp(ExtensionID: Guid; ObjectID: Integer; ObjectType: ObjectType)
    begin
        UpdateMagentoWizardStatus();
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Retail Wizard", 'OnAfterFinishStep', '', false, false)]
    local procedure UpdateAssistedSetupStatus_OnAfterFinishStep(AnyDataToCreate: Boolean)
    begin
        if AnyDataToCreate then
            UpdateRetailWizardStatus();
    end;

    /* MAGENTO WIZARD */
    local procedure AddMagentoWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        GuidedExperienceType: Enum "Guided Experience Type";
        WizardNameLbl: Label 'Set up Magento Integration';
        SetupDescriptionTxt: Label 'Set General Information for Webshop Integration.';
    begin
        if GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Magento Wizard") then
            GuidedExperience.Remove(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Magento Wizard");

        GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                100,
                                                ObjectType::Page,
                                                Page::"NPR Magento Wizard",
                                                AssistedSetupGroup::NPRetail,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure UpdateMagentoWizardStatus()
    var
        MagentoSetup: Record "NPR Magento Setup";
        GuidedExperience: Codeunit "Guided Experience";
    begin
        if not MagentoSetup.IsEmpty then
            GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Magento Wizard");
    end;

    /* RETAIL WIZARD */
    local procedure AddRetailWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Set up Retail Integration';
        SetupDescriptionTxt: Label 'Set General Information for Retail Integration.';
    begin
        if GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Retail Wizard") then
            GuidedExperience.Remove(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"NPR Retail Wizard");

        GuidedExperience.InsertAssistedSetup(WizardNameLbl,
                                                WizardNameLbl,
                                                SetupDescriptionTxt,
                                                100,
                                                ObjectType::Page,
                                                Page::"NPR Retail Wizard",
                                                AssistedSetupGroup::NPRetail,
                                                '',
                                                VideoCategory::ReadyForBusiness,
                                                '');
    end;

    local procedure UpdateRetailWizardStatus()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"NPR Retail Wizard");
    end;

    /* GRAPHAPI WIZARD */

    local procedure AddGraphAPIWizard()
    var
        AssistedSetup: Codeunit "Guided Experience";
        Language: Codeunit Language;
        CurrentGlobalLanguage: Integer;
        SetupTxt: Label 'Set up GraphAPI Setup';

    begin
        CurrentGlobalLanguage := GlobalLanguage;
        AssistedSetup.InsertAssistedSetup(SetupTxt, SetupTxt, SetupTxt, 1000, ObjectType::Page, Page::"NPR GraphApi Setup Wizard",
                        "Assisted Setup Group"::GettingStarted, '',
                        "Video Category"::Uncategorized,
                        'https://navipartner.com');

        GlobalLanguage(Language.GetDefaultApplicationLanguageId());
        AssistedSetup.AddTranslationForSetupObjectDescription(Enum::"Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR GraphApi Setup Wizard", Language.GetDefaultApplicationLanguageId(), SetupTxt);
        GlobalLanguage(CurrentGlobalLanguage);
    end;
#endif
}
