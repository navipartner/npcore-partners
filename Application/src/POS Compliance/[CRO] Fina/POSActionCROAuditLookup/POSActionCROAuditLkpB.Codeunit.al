codeunit 6184556 "NPR POS Action: CROAudit Lkp-B"
{
    Access = Internal;
    internal procedure ProcessRequest(ParameterShow: Option All,AllFiscalised,AllNonFiscalised,LastTransaction)
    begin
        case ParameterShow of
            ParameterShow::All:
                ShowAllCROAuditLog(ParameterShow);
            ParameterShow::AllFiscalised:
                ShowAllCROAuditLog(ParameterShow);
            ParameterShow::AllNonFiscalised:
                ShowAllCROAuditLog(ParameterShow);
            ParameterShow::LastTransaction:
                ShowLastCROAuditLog();
        end;
    end;

    local procedure ShowAllCROAuditLog(ParameterShow: Option All,AllFiscalised,AllNonFiscalised,LastTransaction)
    var
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
    begin
        case ParameterShow of
            ParameterShow::AllFiscalised:
                CROPOSAuditLogAuxInfo.SetRange("Receipt Fiscalized", true);
            ParameterShow::AllNonFiscalised:
                CROPOSAuditLogAuxInfo.SetRange("Receipt Fiscalized", false);
        end;
        CROPOSAuditLogAuxInfo.FindLast();
        Page.Run(Page::"NPR CRO POS Aud. Log Aux. Info", CROPOSAuditLogAuxInfo);
    end;

    local procedure ShowLastCROAuditLog()
    var
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
        CROPOSAuditLogAuxInfo2: Record "NPR CRO POS Aud. Log Aux. Info";
        CROPOSAuditLogAuxInfoPage: Page "NPR CRO POS Aud. Log Aux. Info";
    begin
        CROPOSAuditLogAuxInfo.SetLoadFields("Audit Entry Type", "Audit Entry No.");
        CROPOSAuditLogAuxInfo.SetRange("Receipt Fiscalized", true);
        CROPOSAuditLogAuxInfo.FindLast();
        CROPOSAuditLogAuxInfo2.SetRange("Audit Entry Type", CROPOSAuditLogAuxInfo."Audit Entry Type");
        CROPOSAuditLogAuxInfo2.SetRange("Audit Entry No.", CROPOSAuditLogAuxInfo."Audit Entry No.");
        CROPOSAuditLogAuxInfoPage.SetTableView(CROPOSAuditLogAuxInfo2);
        CROPOSAuditLogAuxInfoPage.Run();
    end;
}
