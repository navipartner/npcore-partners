codeunit 6184784 "NPR BG VISION Mgt. Public"
{
    var
        BGVISIONLocalisationMgt: Codeunit "NPR BG VISION Local. Mgt.";

    procedure GetCustomerVATRegistrationNo(DocumentNo: Text[20]): Text[30]
    var
        BGSISPOSAuditLogAux: Record "NPR BG SIS POS Audit Log Aux.";
    begin
        if not BGVISIONLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        BGSISPOSAuditLogAux.SetLoadFields("Customer VAT Registration No.");
        BGSISPOSAuditLogAux.SetRange("Source Document No.", DocumentNo);
        BGSISPOSAuditLogAux.SetRange("Extended Receipt", true);
        if not BGSISPOSAuditLogAux.FindFirst() then
            exit;
        exit(BGSISPOSAuditLogAux."Customer VAT Registration No.");
    end;

    procedure GetCustomerName(DocumentNo: Text[20]): Text[30]
    var
        BGSISPOSAuditLogAux: Record "NPR BG SIS POS Audit Log Aux.";
    begin
        if not BGVISIONLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        BGSISPOSAuditLogAux.SetLoadFields("Customer Name");
        BGSISPOSAuditLogAux.SetRange("Source Document No.", DocumentNo);
        BGSISPOSAuditLogAux.SetRange("Extended Receipt", true);
        if not BGSISPOSAuditLogAux.FindFirst() then
            exit;
        exit(BGSISPOSAuditLogAux."Customer Name");
    end;

    procedure GetExtendedReceiptCounter(DocumentNo: Text[20]): Code[20]
    var
        BGSISPOSAuditLogAux: Record "NPR BG SIS POS Audit Log Aux.";
    begin
        if not BGVISIONLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        BGSISPOSAuditLogAux.SetLoadFields("Extended Receipt Counter");
        BGSISPOSAuditLogAux.SetRange("Source Document No.", DocumentNo);
        BGSISPOSAuditLogAux.SetRange("Extended Receipt", true);
        if not BGSISPOSAuditLogAux.FindFirst() then
            exit;
        exit(BGSISPOSAuditLogAux."Extended Receipt Counter");
    end;

    procedure GetShouldChangeDocumentTypeSale(SourceDocumentNo: Code[20]): Boolean
    var
        BGSISPOSAuditLogAux: Record "NPR BG SIS POS Audit Log Aux.";
    begin
        if not BGVISIONLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        BGSISPOSAuditLogAux.SetRange("Source Document No.", SourceDocumentNo);
        BGSISPOSAuditLogAux.SetRange("Extended Receipt", true);
        BGSISPOSAuditLogAux.SetFilter("Transaction Type", Format(BGSISPOSAuditLogAux."Transaction Type"::Sale));
        if not BGSISPOSAuditLogAux.IsEmpty() then
            exit(true);
    end;

    procedure GetShouldChangeDocumentTypeRefund(SourceDocumentNo: Code[20]): Boolean
    var
        BGSISPOSAuditLogAux: Record "NPR BG SIS POS Audit Log Aux.";
    begin
        if not BGVISIONLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        BGSISPOSAuditLogAux.SetRange("Source Document No.", SourceDocumentNo);
        BGSISPOSAuditLogAux.SetRange("Extended Receipt", true);
        BGSISPOSAuditLogAux.SetFilter("Transaction Type", Format(BGSISPOSAuditLogAux."Transaction Type"::Refund));
        if not BGSISPOSAuditLogAux.IsEmpty() then
            exit(true);
    end;
}
