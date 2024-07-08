codeunit 6059888 "NPR POS Audit Log Verify"
{
    TableNo = "NPR POS Audit Log";
    Access = Internal;

    var
        _Error: Boolean;

    trigger OnRun()
    var
        Handled: Boolean;
        ERROR_NO_LOG_VALIDATION: Label 'No log validation routine found';
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
    begin
        POSAuditLogMgt.OnValidateLogRecords(Rec, Handled, _Error);
        if not Handled then
            Error(ERROR_NO_LOG_VALIDATION);
    end;

    procedure VerificationError(): Boolean
    begin
        exit(_Error);
    end;

}