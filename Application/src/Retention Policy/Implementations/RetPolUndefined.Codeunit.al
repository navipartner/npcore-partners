#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
codeunit 6248685 "NPR Ret.Pol.: Undefined" implements "NPR IRetention Policy"
{
    Access = Internal;

    internal procedure DeleteExpiredRecords(RetentionPolicy: Record "NPR Retention Policy")
    begin
        ThrowNoHandlerError(RetentionPolicy);
    end;

    local procedure ThrowNoHandlerError(RetentionPolicy: Record "NPR Retention Policy")
    var
        NoHandlerErr: Label 'No retention policy handler has been registered for table %1 %2.';
    begin
        RetentionPolicy.CalcFields("Table Caption");
        Error(NoHandlerErr, RetentionPolicy."Table Id", RetentionPolicy."Table Caption");
    end;
}
#endif