codeunit 6014490 "NPR GE Assisted Setup Subs"
{
#if not BC17
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterAssistedSetup', '', false, false)]
    local procedure RegisterWizard_OnRegisterAssistedSetup()
    begin
        AddMagentoWizard();
        AddRetailWizard();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnAfterRunAssistedSetup', '', false, false)]
    procedure UpdateSetupStatus_OnUpdateAssistedSetupStatusp(ExtensionID: Guid; ObjectID: Integer; ObjectType: ObjectType)
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
                                                AssistedSetupGroup::"NP Retail",
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
                                                AssistedSetupGroup::"NP Retail",
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
#endif
}