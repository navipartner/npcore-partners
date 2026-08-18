// Identifies Microsoft-provisioned demo tenants: MDX (Microsoft Demo Experience), formerly known as
// CDX (Customer Digital Experiences). Both acronyms are kept in these comments so a search for either finds this code.
// Tenant-level only: a real customer environment can hold a CRONUS/demo company, so company-level
// markers (IsDemoCompany, Evaluation Company) must never be used here.
// SingleInstance so the Graph lookup behind GetAadTenantDomainName() happens once per session.
codeunit 6151265 "NPR Demo Tenant Mgt."
{
    Access = Internal;
    SingleInstance = true;

    var
        _MdxEnvironmentChecked: Boolean;
        _IsMdxEnvironment: Boolean;

    internal procedure IsMdxEnvironment(): Boolean
    var
        EnvInfo: Codeunit "Environment Information";
        DomainName: Text;
    begin
        if _MdxEnvironmentChecked then
            exit(_IsMdxEnvironment);

        // On failure we stay 'not MDX', so callers default to the regular-customer behaviour. That failure is invisible
        // to callers - a genuine MDX tenant becomes indistinguishable from a customer - so only this codeunit can report it.
        if EnvInfo.IsSaaSInfrastructure() then
            if TryGetAadTenantDomainName(DomainName) then
                _IsMdxEnvironment := IsMdxTenantDomain(DomainName)
            else
                LogMdxCheckFailed(GetLastErrorText());

        _MdxEnvironmentChecked := true;
        exit(_IsMdxEnvironment);
    end;

    local procedure LogMdxCheckFailed(ErrorText: Text)
    var
        CustomDimensions: Dictionary of [Text, Text];
        CheckFailedTok: Label 'NPR MDX demo tenant check failed in company %1, treating the tenant as a regular customer. Error: %2', Locked = true;
    begin
        // The SingleInstance cache above rate-limits this to once per session.
        CustomDimensions.Add('NPR_Company', CompanyName());
        CustomDimensions.Add('NPR_ErrorText', ErrorText);
        Session.LogMessage('NPR_MdxTenantCheckFailed', StrSubstNo(CheckFailedTok, CompanyName(), ErrorText), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;

    [TryFunction]
    local procedure TryGetAadTenantDomainName(var DomainName: Text)
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
    begin
        // Graph call - errors when Graph is unreachable, so it must stay inside a TryFunction.
        DomainName := AzureADTenant.GetAadTenantDomainName();
    end;

    // internal rather than local: this is the classification that gates license enforcement, and both failure
    // directions are silent (false positive leaves a customer unenforced, false negative re-breaks demos), so the
    // Test app covers the prefix matrix directly.
    internal procedure IsMdxTenantDomain(DomainNameParam: Text): Boolean
    var
        OnMicrosoftSuffixTok: Label '.onmicrosoft.com', Locked = true;
        DomainName: Text;
        TenantName: Text;
    begin
        DomainName := LowerCase(DomainNameParam);
        if not DomainName.EndsWith(OnMicrosoftSuffixTok) then
            exit(false);

        // MDX (formerly CDX) tenants are machine-named <prefix><fixed digit count>.onmicrosoft.com.
        // Prefixes measured empirically (~1000 getuserrealm.srf probes, 2026-07); re-run the sweep before extending.
        TenantName := CopyStr(DomainName, 1, StrLen(DomainName) - StrLen(OnMicrosoftSuffixTok));
        exit(
            IsPrefixedNumberedName(TenantName, 'm365x', 6) or
            IsPrefixedNumberedName(TenantName, 'm365x', 8) or
            IsPrefixedNumberedName(TenantName, 'crmbc', 6) or
            IsPrefixedNumberedName(TenantName, 'm365b', 6) or
            IsPrefixedNumberedName(TenantName, 'm365edu', 6) or
            IsPrefixedNumberedName(TenantName, 'msdx', 6));
    end;

    local procedure IsPrefixedNumberedName(TenantName: Text; Prefix: Text; DigitCount: Integer): Boolean
    var
        Digits: Text;
    begin
        if StrLen(TenantName) <> StrLen(Prefix) + DigitCount then
            exit(false);
        if not TenantName.StartsWith(Prefix) then
            exit(false);

        Digits := CopyStr(TenantName, StrLen(Prefix) + 1);
        exit(DelChr(Digits, '=', '0123456789') = '');
    end;
}
