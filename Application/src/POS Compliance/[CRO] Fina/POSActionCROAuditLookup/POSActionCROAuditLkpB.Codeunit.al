codeunit 6184556 "NPR POS Action: CROAudit Lkp-B"
{
    Access = Internal;
    internal procedure ProcessRequest(ParameterShow: Option All,AllFiscalised,AllNonFiscalised,LastTransaction)
    var
        CROPOSAuditLogAuxInfo, CROPOSAuditLogAuxInfo2 : Record "NPR CRO POS Aud. Log Aux. Info";
        CROPOSAuditLogAuxInfoPage: Page "NPR CRO POS Aud. Log Aux. Info";
    begin
        CROPOSAuditLogAuxInfo.FilterGroup(10);

        case ParameterShow of
            ParameterShow::AllFiscalised:
                CROPOSAuditLogAuxInfo.SetRange("Receipt Fiscalized", true);
            ParameterShow::AllNonFiscalised:
                CROPOSAuditLogAuxInfo.SetRange("Receipt Fiscalized", false);
            ParameterShow::LastTransaction:
                begin
                    CROPOSAuditLogAuxInfo2.SetLoadFields("Audit Entry Type", "Audit Entry No.");
                    CROPOSAuditLogAuxInfo2.SetRange("Receipt Fiscalized", true);
                    CROPOSAuditLogAuxInfo2.FindLast();

                    CROPOSAuditLogAuxInfo.SetRange("Audit Entry Type", CROPOSAuditLogAuxInfo2."Audit Entry Type");
                    CROPOSAuditLogAuxInfo.SetRange("Audit Entry No.", CROPOSAuditLogAuxInfo2."Audit Entry No.");
                end;
        end;

        CROPOSAuditLogAuxInfo.FilterGroup(0);
        CROPOSAuditLogAuxInfoPage.SetTableView(CROPOSAuditLogAuxInfo);
        CROPOSAuditLogAuxInfoPage.Run();
    end;
}
