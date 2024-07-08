codeunit 6059936 "NPR RS Fiscal BG Comm. Batch"
{
    Access = Internal;

    trigger OnRun()
    var
        RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
        RSAuxSalesInvHeader: Record "NPR RS Aux Sales Inv. Header";
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
        RSTaxCommunicationMgt: Codeunit "NPR RS Tax Communication Mgt.";
    begin
        RSPOSAuditLogAuxInfo.SetFilter(Signature, '%1', '');
        if RSPOSAuditLogAuxInfo.IsEmpty() then
            exit;
        RSPOSAuditLogAuxInfo.FindSet();
        repeat
            case RSPOSAuditLogAuxInfo."RS Invoice Type" of
                RSPOSAuditLogAuxInfo."RS Invoice Type"::NORMAL,
                RSPOSAuditLogAuxInfo."RS Invoice Type"::TRAINING:
                    begin
                        if RSPOSAuditLogAuxInfo."RS Transaction Type" in [RSPOSAuditLogAuxInfo."RS Transaction Type"::SALE] then
                            RSTaxCommunicationMgt.CreateNormalSale(RSPOSAuditLogAuxInfo);
                        if RSPOSAuditLogAuxInfo."RS Transaction Type" in [RSPOSAuditLogAuxInfo."RS Transaction Type"::REFUND] then
                            RSTaxCommunicationMgt.CreateNormalRefund(RSPOSAuditLogAuxInfo);
                    end;
            end;
        until RSPOSAuditLogAuxInfo.Next() = 0;

        RSAuxSalesInvHeader.SetRange("NPR RS Audit Entry", RSAuxSalesInvHeader."NPR RS Audit Entry"::" ");
        RSAuxSalesInvHeader.SetFilter("NPR RS POS Unit", '<>%1', '');
        if RSAuxSalesInvHeader.IsEmpty() then
            exit;
        RSAuxSalesInvHeader.FindSet();
        repeat
            if RSAuditMgt.IsDataSetOnSalesInvoiceDoc(RSAuxSalesInvHeader) then
                RSTaxCommunicationMgt.CreateNormalSale(RSAuxSalesInvHeader."Sales Invoice Header No.");
        until RSAuxSalesInvHeader.Next() = 0;
    end;
}