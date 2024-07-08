codeunit 6184603 "NPR POS Action: SIAudit Lkp-B"
{
    Access = Internal;
    internal procedure ProcessRequest(ParameterShow: Option All,AllFiscalised,AllNonFiscalised,LastTransaction)
    begin
        case ParameterShow of
            ParameterShow::All:
                ShowAllSIAuditLog(ParameterShow);
            ParameterShow::AllFiscalised:
                ShowAllSIAuditLog(ParameterShow);
            ParameterShow::AllNonFiscalised:
                ShowAllSIAuditLog(ParameterShow);
            ParameterShow::LastTransaction:
                ShowLastSIAuditLog();
        end;
    end;

    local procedure ShowAllSIAuditLog(ParameterShow: Option All,AllFiscalised,AllNonFiscalised,LastTransaction)
    var
        SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info";
        SIPOSAuditLogAuxInfoPage: Page "NPR SI POS Audit Log Aux. Info";
    begin
        case ParameterShow of
            ParameterShow::AllFiscalised:
                SIPOSAuditLogAuxInfo.SetRange("Receipt Fiscalized", true);
            ParameterShow::AllNonFiscalised:
                SIPOSAuditLogAuxInfo.SetRange("Receipt Fiscalized", false);
        end;
        SIPOSAuditLogAuxInfoPage.SetTableView(SIPOSAuditLogAuxInfo);
        SIPOSAuditLogAuxInfoPage.RunModal();
    end;

    local procedure ShowLastSIAuditLog()
    var
        SIPOSAuditLogAuxInfo: Record "NPR SI POS Audit Log Aux. Info";
        SIPOSAuditLogAuxInfo2: Record "NPR SI POS Audit Log Aux. Info";
        SIPOSAuditLogAuxInfoPage: Page "NPR SI POS Audit Log Aux. Info";
    begin
        SIPOSAuditLogAuxInfo.SetLoadFields("Audit Entry Type", "Audit Entry No.");
        SIPOSAuditLogAuxInfo.SetRange("Receipt Fiscalized", true);
        SIPOSAuditLogAuxInfo.FindLast();
        SIPOSAuditLogAuxInfo2.SetRange("Audit Entry Type", SIPOSAuditLogAuxInfo."Audit Entry Type");
        SIPOSAuditLogAuxInfo2.SetRange("Audit Entry No.", SIPOSAuditLogAuxInfo."Audit Entry No.");
        SIPOSAuditLogAuxInfoPage.SetTableView(SIPOSAuditLogAuxInfo2);
        SIPOSAuditLogAuxInfoPage.RunModal();
    end;
}
