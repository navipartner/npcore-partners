codeunit 6014431 "NPR Assisted Setup Subs"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assisted Setup", 'OnRegister', '', false, false)]
    local procedure RegisterWizard_OnRegisterAssistedSetup()
    begin
        AddMagentoWizard();
        AddRetailWizard();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assisted Setup", 'OnAfterRun', '', false, false)]
    procedure UpdateSetupStatus_OnUpdateAssistedSetupStatusp(PageID: Integer)
    begin
        UpdateRetailWizardStatus();
        UpdateMagentoWizardStatus();
    end;

    /* MAGENTO WIZARD */
    local procedure AddMagentoWizard()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        MagentoWizardName: Label 'Setup General information for Webshop integration';
    begin
        if AssistedSetup.Exists(Page::"NPR Magento Wizard") then
            AssistedSetup.Remove(Page::"NPR Magento Wizard");

        AssistedSetup.Add(CreateGuid(),
                            Page::"NPR Magento Wizard",
                            MagentoWizardName,
                            AssistedSetupGroup::"NP Retail");
    end;

    local procedure UpdateMagentoWizardStatus()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if not MagentoSetup.IsEmpty then
            AssistedSetup.Complete(Page::"NPR Magento Wizard");
    end;

    /* RETAIL WIZARD */
    local procedure AddRetailWizard()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        RetailWizardName: Label 'Setup General information for NP Retail';
    begin
        if AssistedSetup.Exists(Page::"NPR Retail Wizard") then
            AssistedSetup.Remove(Page::"NPR Retail Wizard");

        AssistedSetup.Add(CreateGuid(),
                            Page::"NPR Retail Wizard",
                            RetailWizardName,
                            AssistedSetupGroup::"NP Retail");
    end;

    local procedure UpdateRetailWizardStatus()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        RetailSetup: Record "NPR Retail Setup";
    begin
        if not RetailSetup.IsEmpty then
            AssistedSetup.Complete(Page::"NPR Retail Wizard");
    end;
}