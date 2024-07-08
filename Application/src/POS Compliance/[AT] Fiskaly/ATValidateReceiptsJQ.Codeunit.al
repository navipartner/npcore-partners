codeunit 6184909 "NPR AT Validate Receipts JQ"
{
    Access = Internal;

    trigger OnRun()
    var
        ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info";
        ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
    begin
        ATPOSAuditLogAuxInfo.SetFilter("Receipt Type", '%1|%2|%3|%4|%5', Enum::"NPR AT Receipt Type"::INITIALIZATION, Enum::"NPR AT Receipt Type"::DECOMMISSION, Enum::"NPR AT Receipt Type"::MONTHLY_CLOSE, Enum::"NPR AT Receipt Type"::YEARLY_CLOSE, Enum::"NPR AT Receipt Type"::SIGNATURE_CREATION_UNIT_FAULT_CLEARANCE);
        ATPOSAuditLogAuxInfo.SetFilter("FON Receipt Validation Status", '<>%1', Enum::"NPR AT FON Rcpt. Valid. Status"::SUCCESS);
        if ATPOSAuditLogAuxInfo.IsEmpty() then
            exit;

        ATPOSAuditLogAuxInfo.FindSet(true);

        repeat
            ATFiskalyCommunication.ValidateReceipt(ATPOSAuditLogAuxInfo);
        until ATPOSAuditLogAuxInfo.Next() = 0;
    end;
}