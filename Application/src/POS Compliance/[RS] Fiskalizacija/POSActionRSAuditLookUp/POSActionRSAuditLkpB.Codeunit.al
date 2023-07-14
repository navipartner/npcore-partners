codeunit 6151358 "NPR POS Action: RSAudit Lkp-B"
{
    Access = Internal;
    internal procedure ProcessRequest(ParameterShow: Option All,AllFiscalised,AllNonFiscalised,LastTransaction)
    begin
        case ParameterShow of
            ParameterShow::All:
                ShowAllRSAuditLog(ParameterShow);
            ParameterShow::AllFiscalised:
                ShowAllRSAuditLog(ParameterShow);
            ParameterShow::AllNonFiscalised:
                ShowAllRSAuditLog(ParameterShow);
            ParameterShow::LastTransaction:
                ShowLastRSAuditLog();
        end;
    end;

    local procedure ShowAllRSAuditLog(ParameterShow: Option All,AllFiscalised,AllNonFiscalised,LastTransaction)
    var
        RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
        RSPOSAuditLogAuxInfoPage: Page "NPR RS POS Audit Log Aux. Info";
    begin
        case ParameterShow of
            ParameterShow::AllFiscalised:
                RSPOSAuditLogAuxInfo.SetFilter(Signature, '<>%1', '');
            ParameterShow::AllNonFiscalised:
                RSPOSAuditLogAuxInfo.SetFilter(Signature, '%1', '');
        end;
        RSPOSAuditLogAuxInfoPage.SetTableView(RSPOSAuditLogAuxInfo);
        RSPOSAuditLogAuxInfoPage.RunModal();
    end;

    local procedure ShowLastRSAuditLog()
    var
        RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
        RSPOSAuditLogAuxInfo2: Record "NPR RS POS Audit Log Aux. Info";
        RSPOSAuditLogAuxInfoPage: Page "NPR RS POS Audit Log Aux. Info";
    begin
        RSPOSAuditLogAuxInfo.SetLoadFields("Audit Entry Type", "Audit Entry No.");
        RSPOSAuditLogAuxInfo.SetFilter(Signature, '<>%1', '');
        RSPOSAuditLogAuxInfo.FindLast();
        RSPOSAuditLogAuxInfo2.SetRange("Audit Entry Type", RSPOSAuditLogAuxInfo."Audit Entry Type");
        RSPOSAuditLogAuxInfo2.SetRange("Audit Entry No.", RSPOSAuditLogAuxInfo."Audit Entry No.");
        RSPOSAuditLogAuxInfoPage.SetTableView(RSPOSAuditLogAuxInfo2);
        RSPOSAuditLogAuxInfoPage.RunModal();
    end;
}
