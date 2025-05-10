codeunit 6248396 "NPR POS Audit Log Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTagDefinitions: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR POS Audit Log Upgrade', 'OnUpgradeDataPerCompany');

        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetUpgradeTag(Codeunit::"NPR POS Audit Log Upgrade", 'update-additional-information-in-pos-audit-log')) then begin
            UpdateAdditionalInformationInPOSAuditLog();
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetUpgradeTag(Codeunit::"NPR POS Audit Log Upgrade", 'update-additional-information-in-pos-audit-log'));
        end;

        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdateAdditionalInformationInPOSAuditLog()
    begin
        UpdateAdditionalInformationInPOSAuditLogForNorway();
        UpdateAdditionalInformationInPOSAuditLogForDenmark();
    end;

    local procedure UpdateAdditionalInformationInPOSAuditLogForNorway()
    var
        POSAuditLog: Record "NPR POS Audit Log";
        NOFiscalizationSetup: Record "NPR NO Fiscalization Setup";
        WholeNumber: Text;
        FractionalPart: Text;
        NewAdditionalInformation: Text;
    begin
        if not NOFiscalizationSetup.Get() then
            exit;

        if not NOFiscalizationSetup."Enable NO Fiscal" then
            exit;

        POSAuditLog.SetFilter("Action Type", '%1|%2', POSAuditLog."Action Type"::DELETE_POS_SALE_LINE, POSAuditLog."Action Type"::CANCEL_POS_SALE_LINE);
        POSAuditLog.SetFilter("Additional Information", '<>%1', '');
        if POSAuditLog.FindSet(true) then
            repeat
                if POSAuditLog."Additional Information" <> '0' then
                    NewAdditionalInformation := POSAuditLog."Additional Information"
                else
                    NewAdditionalInformation := '0.00';

                NewAdditionalInformation := RemoveNonNumericChars(NewAdditionalInformation);
                NewAdditionalInformation := NewAdditionalInformation.Replace(',', '.');
                if StrLen(NewAdditionalInformation) > 4 then begin
                    WholeNumber := CopyStr(NewAdditionalInformation, 1, StrLen(NewAdditionalInformation) - 3);
                    FractionalPart := CopyStr(NewAdditionalInformation, StrLen(NewAdditionalInformation) - 2);
                    NewAdditionalInformation := WholeNumber.Replace('.', '') + FractionalPart;
                    if POSAuditLog."Additional Information" <> NewAdditionalInformation then begin
                        POSAuditLog."Additional Information" := CopyStr(NewAdditionalInformation, 1, MaxStrLen(POSAuditLog."Additional Information"));
                        POSAuditLog.Modify();
                    end;
                end;
            until POSAuditLog.Next() = 0;
    end;

    local procedure UpdateAdditionalInformationInPOSAuditLogForDenmark()
    var
        POSAuditLog: Record "NPR POS Audit Log";
        DKFiscalizationSetup: Record "NPR DK Fiscalization Setup";
        WholeNumber: Text;
        FractionalPart: Text;
        NewAdditionalInformation: Text;
    begin
        if not DKFiscalizationSetup.Get() then
            exit;

        if not DKFiscalizationSetup."Enable DK Fiscal" then
            exit;

        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::CANCEL_POS_SALE_LINE);
        POSAuditLog.SetFilter("Additional Information", '<>%1', '');
        if POSAuditLog.FindSet(true) then
            repeat
                if POSAuditLog."Additional Information" <> '0' then
                    NewAdditionalInformation := POSAuditLog."Additional Information"
                else
                    NewAdditionalInformation := '0.00';

                NewAdditionalInformation := RemoveNonNumericChars(NewAdditionalInformation);
                NewAdditionalInformation := NewAdditionalInformation.Replace(',', '.');
                if StrLen(NewAdditionalInformation) > 4 then begin
                    WholeNumber := CopyStr(NewAdditionalInformation, 1, StrLen(NewAdditionalInformation) - 3);
                    FractionalPart := CopyStr(NewAdditionalInformation, StrLen(NewAdditionalInformation) - 2);
                    NewAdditionalInformation := WholeNumber.Replace('.', '') + FractionalPart;
                    if POSAuditLog."Additional Information" <> NewAdditionalInformation then begin
                        POSAuditLog."Additional Information" := CopyStr(NewAdditionalInformation, 1, MaxStrLen(POSAuditLog."Additional Information"));
                        POSAuditLog.Modify();
                    end;
                end;
            until POSAuditLog.Next() = 0;
    end;

    local procedure RemoveNonNumericChars(SourceValue: Text) NewValue: Text
    var
        StrPos: Integer;
    begin
        for StrPos := 1 to StrLen(SourceValue) do
            if CopyStr(SourceValue, StrPos, 1) in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.', ',', '-'] then
                NewValue += CopyStr(SourceValue, StrPos, 1);
    end;
}
