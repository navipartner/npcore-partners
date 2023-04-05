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
        AssistedSetup.Remove(Page::"NPR Retail Wizard");
        AssistedSetup.Remove(Page::"NPR Magento Wizard");
    end;
#ELSE
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterAssistedSetup', '', false, false)]
    local procedure RegisterWizard_OnRegisterAssistedSetup()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Magento Wizard");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR Retail Wizard");
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"NPR GraphApi Setup Wizard");
    end;
#endif
}
