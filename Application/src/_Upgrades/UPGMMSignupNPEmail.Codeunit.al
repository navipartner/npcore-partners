codeunit 6184806 "NPR UPG MM Signup NP Email"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG MM Signup NP Email', 'OnUpgradePerCompany');

        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG MM Signup NP Email")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        CopySignupNPEmailTemplates();

        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG MM Signup NP Email"));

        LogMessageStopwatch.LogFinish();
    end;

    internal procedure CopySignupNPEmailTemplates()
    var
        RegistrationSetup: Record "NPR MM AzureMemberRegSetup";
        NPEmailTemplate: Record "NPR NPEmailTemplate";
    begin
        RegistrationSetup.SetFilter(EmailTemplate, '<>%1', '');
        if (not RegistrationSetup.FindSet()) then
            exit;

        repeat
            if ((RegistrationSetup.NPEmailTemplate = '') and (NPEmailTemplate.Get(RegistrationSetup.EmailTemplate))) then
                if (NPEmailTemplate.DataProvider = NPEmailTemplate.DataProvider::MEMBER_NOTIFICATION) then begin
                    RegistrationSetup.NPEmailTemplate := RegistrationSetup.EmailTemplate;
                    RegistrationSetup.Modify();
                end;
        until (RegistrationSetup.Next() = 0);
    end;
}
