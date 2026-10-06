codeunit 6184988 "NPR ES Retrieve Pending Inv JQ"
{
    Access = Internal;

    trigger OnRun()
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";
        ESOfflineInvoiceMgt: Codeunit "NPR ES Offline Invoice Mgt.";
        RejectedOfflineInvoices: Integer;
        RejectedOfflineInvoicesErr: Label '%1 invoice(s) issued offline could not be submitted to Fiskaly for a reason other than an outage. Later invoices of the same POS units stay offline until this is fixed. Check %2 on the pending offline invoices in %3.', Comment = '%1 - number of invoices, %2 - Last Submission Error field caption, %3 - ES POS Audit Log Aux. Info table caption';
    begin
        ESOfflineInvoiceMgt.SubmitAllPendingOfflineInvoices(MaxOfflineInvoicesSubmittedPerRun(), RejectedOfflineInvoices);

        ESPOSAuditLogAuxInfo.FilterGroup(-1);
        ESPOSAuditLogAuxInfo.SetRange("Invoice Registration State", ESPOSAuditLogAuxInfo."Invoice Registration State"::PENDING);
        ESPOSAuditLogAuxInfo.SetRange("Invoice Cancellation State", ESPOSAuditLogAuxInfo."Invoice Cancellation State"::PENDING);
        ESPOSAuditLogAuxInfo.FilterGroup(0);

        if ESPOSAuditLogAuxInfo.FindSet(true) then
            repeat
                ESFiskalyCommunication.RetrieveInvoice(ESPOSAuditLogAuxInfo);
            until ESPOSAuditLogAuxInfo.Next() = 0;

        if RejectedOfflineInvoices > 0 then begin
            Commit(); // keep what the retrieve loop updated
            Error(RejectedOfflineInvoicesErr, RejectedOfflineInvoices, ESPOSAuditLogAuxInfo.FieldCaption("Last Submission Error"), ESPOSAuditLogAuxInfo.TableCaption());
        end;
    end;

    local procedure MaxOfflineInvoicesSubmittedPerRun(): Integer
    begin
        exit(200);
    end;
}
