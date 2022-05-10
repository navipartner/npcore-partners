codeunit 6014670 "NPR UPG FR Audit Setup"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG FR Audit Setup', 'OnUpgradePerCompany');

        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG FR Audit Setup")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;
        UpgradeData();
#if not BC17 and not BC18
        UpgradeCertificateToBase64();
#endif
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG FR Audit Setup"));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradeData()
    var
        FRAuditSetup: Record "NPR FR Audit Setup";
    begin
        if not FRAuditSetup.Get() then
            exit;

        if FRAuditSetup."Item VAT Identifier Filter" = '' then
            exit;

        FRAuditSetup.SetVATIDFilter(FRAuditSetup."Item VAT Identifier Filter");
        FRAuditSetup.Modify();
    end;

#if not BC17 and not BC18
    local procedure UpgradeCertificateToBase64()
    var
        FRCertificationSetup: Record "NPR FR Audit Setup";
        Base64Convert: Codeunit "Base64 Convert";
        Regex: Codeunit Regex;
        InStr: InStream;
        OutStream: OutStream;
        Base64Cert: Text;
        Base64RegexCheckLbl: Label '^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)?$', Locked = true;
    begin
        FRCertificationSetup.SetAutoCalcFields("Signing Certificate");
        FRCertificationSetup.Get();
        FRCertificationSetup."Signing Certificate".CreateInStream(InStr, TextEncoding::UTF8);
        InStr.ReadText(Base64Cert);
        if not Regex.IsMatch(Base64Cert, Base64RegexCheckLbl) then begin
            Base64Cert := Base64Convert.ToBase64(Base64Cert);
            Clear(FRCertificationSetup."Signing Certificate");
            FRCertificationSetup."Signing Certificate".CreateOutStream(OutStream, TextEncoding::UTF8);
            OutStream.WriteText(Base64Cert);
            FRCertificationSetup.Modify(true);
        end;
    end;
#endif

}
