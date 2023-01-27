#if not BC17
codeunit 6060003 "NPR Entertainment Checklist"
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteReason = 'Not used anymore.';
#if BC18 or BC19
    [EventSubscriber(ObjectType::Codeunit, Codeunit::LogInManagement, 'OnBeforeLogInStart', '', false, false)]
    local procedure OnBeforeLogInStart();
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", 'OnAfterLogin', '', false, false)]
    local procedure OnAfterLogin();
#endif
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not (Session.CurrentClientType() in [ClientType::Web, ClientType::Windows, ClientType::Desktop]) then
            exit;
        if UpgradeTag.HasUpgradeTag(GetUpgradeTag()) then
            exit;

        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Codeunit, Codeunit::"NPR Entertainment Welcome Vid.");

        UpgradeTag.SetUpgradeTag(GetUpgradeTag());
    end;

    local procedure GetUpgradeTag(): Code[250]
    begin
        //For Any change, increase version
        exit('NPR-Checklist-Entertainment-v1.3');
    end;

    var
        GuidedExperience: Codeunit "Guided Experience";
}
#endif