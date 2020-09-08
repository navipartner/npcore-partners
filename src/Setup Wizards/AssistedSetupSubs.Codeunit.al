codeunit 6014431 "NPR Assisted Setup Subs"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assisted Setup", 'OnRegister', '', false, false)]
    local procedure RegisterWizard_OnRegisterAssistedSetup()
    begin
        AddMagentoWizard();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assisted Setup", 'OnAfterRun', '', false, false)]
    procedure UpdateSetupStatus_OnUpdateAssistedSetupStatusp(PageID: Integer)
    begin
        UpdateMagentoWizardStatus();
    end;

    /* MAGENTO WIZARD */
    local procedure AddMagentoWizard()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        MagentoWizardName: Label 'NP Magento Setup Wizard';
    begin
        if not AssistedSetup.Exists(Page::"NPR Magento Wizard") then
            AssistedSetup.Add(CreateGuid(),
                              Page::"NPR Magento Wizard",
                              MagentoWizardName,
                              AssistedSetupGroup::GettingStarted);
    end;

    local procedure UpdateMagentoWizardStatus()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if not MagentoSetup.IsEmpty then
            AssistedSetup.Complete(Page::"NPR Magento Wizard");
    end;
}