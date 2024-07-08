codeunit 6059887 "NPR UPG FR Audit Setup 2"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG FR Audit Setup 2', 'OnUpgradePerCompany');

        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG FR Audit Setup 2")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpgradeCertificateToBase64();
        UpgradePOSAuditLogGrandTotalType();

        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG FR Audit Setup 2"));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradeCertificateToBase64()
    var
        FRCertificationSetup: Record "NPR FR Audit Setup";
        Base64Convert: Codeunit "Base64 Convert";
#IF BC17
        RegEx: Codeunit DotNet_Regex;
#ELSE
        Regex: Codeunit Regex;
#ENDIF
        InStr: InStream;
        OutStream: OutStream;
        Base64Cert: Text;
        Base64RegexCheckLbl: Label '^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)?$', Locked = true;
    begin
        FRCertificationSetup.SetAutoCalcFields("Signing Certificate");
        if not FRCertificationSetup.Get() then
            exit;
        if not FRCertificationSetup."Signing Certificate".HasValue() then
            exit;
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

    local procedure UpgradePOSAuditLogGrandTotalType()
    var
        POSAuditLog: Record "NPR POS Audit Log";
    begin
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::GRANDTOTAL);
        POSAuditLog.SetRange("Handled by External Impl.", true);
        POSAuditLog.SetFilter("External Implementation", '%1', 'FR_NF525*');

        if not POSAuditLog.FindSet(true) then
            exit;

        repeat
            case POSAuditLog."External Description" of
                'Period Grand Total':
                    POSAuditLog."Action Custom Subtype" := 'GRANDTOTAL_ZREPORT';
                'Yearly Grand Total':
                    POSAuditLog."Action Custom Subtype" := 'GRANDTOTAL_YEAR';
                'Monthly Grand Total':
                    POSAuditLog."Action Custom Subtype" := 'GRANDTOTAL_MONTH';
                'Ticket Grand Total':
                    POSAuditLog."Action Custom Subtype" := 'GRANDTOTAL_TICKET';
            end;
            POSAuditLog.Modify();
        until POSAuditLog.Next() = 0;

    end;
}
