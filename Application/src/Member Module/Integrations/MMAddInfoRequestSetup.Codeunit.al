codeunit 6185129 "NPR MM Add. Info. Req. Setup"
{
    Access = Internal;

#if BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", 'OnClearCompanyConfig', '', false, false)]
#elif not BC17 and not BC18
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", OnClearCompanyConfig, '', false, false)]
#endif
#if not BC17 and not BC18
    local procedure SetVippsEnvTestingOnClearCompanyConfig(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    var
        VippsMPCommSetup: Record "NPR MM VippsMP Login Setup";
    begin
        if DestinationEnv <> DestinationEnv::Sandbox then
            exit;

        VippsMPCommSetup.ChangeCompany(CompanyName);
        if VippsMPCommSetup.Get() then begin
            VippsMPCommSetup.Environment := VippsMPCommSetup.Environment::Testing;
            VippsMPCommSetup.Modify();
        end;
    end;
#endif

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Report, Report::"Copy Company", 'OnAfterCreatedNewCompanyByCopyCompany', '', false, false)]
#else
    [EventSubscriber(ObjectType::Report, Report::"Copy Company", OnAfterCreatedNewCompanyByCopyCompany, '', false, false)]
#endif
    local procedure SetVippsEnvTestingOnAfterCreatedNewCompanyByCopyCompany(NewCompanyName: Text[30])
    var
        VippsMPCommSetup: Record "NPR MM VippsMP Login Setup";
    begin
        VippsMPCommSetup.ChangeCompany(NewCompanyName);
        if VippsMPCommSetup.Get() then begin
            VippsMPCommSetup.Environment := VippsMPCommSetup.Environment::Testing;
            VippsMPCommSetup.Modify();
        end;
    end;
}