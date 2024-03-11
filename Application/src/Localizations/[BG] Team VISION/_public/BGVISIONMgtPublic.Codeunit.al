codeunit 6184784 "NPR BG VISION Mgt. Public"
{
    var
        BGSISPOSAuditLogAux: Record "NPR BG SIS POS Audit Log Aux.";
        BGVISIONLocalisationMgt: Codeunit "NPR BG VISION Local. Mgt.";

    procedure GetCustomerVATRegistrationNo(DocumentNo: Text[20]): Text[30]
    begin
        if not BGVISIONLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        BGSISPOSAuditLogAux.SetLoadFields("Customer VAT Registration No.", "Extended Receipt");
        BGSISPOSAuditLogAux.SetRange("Source Document No.", DocumentNo);
        if not BGSISPOSAuditLogAux.FindFirst() then
            exit;
        if not BGSISPOSAuditLogAux."Extended Receipt" then
            exit;
        exit(BGSISPOSAuditLogAux."Customer VAT Registration No.");
    end;

    procedure GetCustomerName(DocumentNo: Text[20]): Text[30]
    begin
        if not BGVISIONLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        BGSISPOSAuditLogAux.SetLoadFields("Customer Name", "Extended Receipt");
        BGSISPOSAuditLogAux.SetRange("Source Document No.", DocumentNo);
        if not BGSISPOSAuditLogAux.FindFirst() then
            exit;
        if not BGSISPOSAuditLogAux."Extended Receipt" then
            exit;
        exit(BGSISPOSAuditLogAux."Customer Name");
    end;

    procedure GetExtendedReceiptCounter(DocumentNo: Text[20]): Code[20]
    begin
        if not BGVISIONLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        BGSISPOSAuditLogAux.SetLoadFields("Extended Receipt Counter", "Extended Receipt");
        BGSISPOSAuditLogAux.SetRange("Source Document No.", DocumentNo);
        if not BGSISPOSAuditLogAux.FindFirst() then
            exit;
        if not BGSISPOSAuditLogAux."Extended Receipt" then
            exit;
        exit(BGSISPOSAuditLogAux."Extended Receipt Counter");
    end;
}
