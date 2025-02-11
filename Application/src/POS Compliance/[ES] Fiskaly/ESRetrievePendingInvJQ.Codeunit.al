codeunit 6184988 "NPR ES Retrieve Pending Inv JQ"
{
    Access = Internal;

    trigger OnRun()
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";
    begin
        ESPOSAuditLogAuxInfo.FilterGroup(-1);
        ESPOSAuditLogAuxInfo.SetRange("Invoice Registration State", ESPOSAuditLogAuxInfo."Invoice Registration State"::PENDING);
        ESPOSAuditLogAuxInfo.SetRange("Invoice Cancellation State", ESPOSAuditLogAuxInfo."Invoice Cancellation State"::PENDING);
        ESPOSAuditLogAuxInfo.FilterGroup(0);

        if ESPOSAuditLogAuxInfo.FindSet(true) then
            repeat
                ESFiskalyCommunication.RetrieveInvoice(ESPOSAuditLogAuxInfo);
            until ESPOSAuditLogAuxInfo.Next() = 0;
    end;
}