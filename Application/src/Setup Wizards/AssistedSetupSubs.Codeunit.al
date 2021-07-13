codeunit 6014431 "NPR Assisted Setup Subs"
{
#if BC17
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assisted Setup", 'OnRegister', '', false, false)]
    local procedure RegisterWizard_OnRegisterAssistedSetup()
    begin
        AddMagentoWizard();
        AddRetailWizard();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assisted Setup", 'OnAfterRun', '', false, false)]
    local procedure UpdateSetupStatus_OnUpdateAssistedSetupStatusp(PageID: Integer)
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
        AssistedSetup: Codeunit "Assisted Setup";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Set up Magento Integration';
        SetupDescriptionTxt: Label 'Set General Information for Webshop Integration.';
    begin
        if AssistedSetup.Exists(Page::"NPR Magento Wizard") then
            AssistedSetup.Remove(Page::"NPR Magento Wizard");

        AssistedSetup.Add(CreateGuid(),
                            Page::"NPR Magento Wizard",
                            WizardNameLbl,
                            AssistedSetupGroup::NPRetail,
                            '',
                            VideoCategory::ReadyForBusiness,
                            '',
                            SetupDescriptionTxt);
    end;

    local procedure UpdateMagentoWizardStatus()
    var
        MagentoSetup: Record "NPR Magento Setup";
        AssistedSetup: Codeunit "Assisted Setup";
    begin
        if not MagentoSetup.IsEmpty then
            AssistedSetup.Complete(Page::"NPR Magento Wizard");
    end;

    /* RETAIL WIZARD */
    local procedure AddRetailWizard()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        WizardNameLbl: Label 'Set up Retail Integration';
        SetupDescriptionTxt: Label 'Set General Information for Retail Integration.';
    begin
        if AssistedSetup.Exists(Page::"NPR Retail Wizard") then
            AssistedSetup.Remove(Page::"NPR Retail Wizard");

        AssistedSetup.Add(CreateGuid(),
                            Page::"NPR Retail Wizard",
                            WizardNameLbl,
                            AssistedSetupGroup::NPRetail,
                            '',
                            VideoCategory::ReadyForBusiness,
                            '',
                            SetupDescriptionTxt);
    end;

    local procedure UpdateRetailWizardStatus()
    var
        AssistedSetup: Codeunit "Assisted Setup";
    begin
        AssistedSetup.Complete(Page::"NPR Retail Wizard");
    end;
#endif
}