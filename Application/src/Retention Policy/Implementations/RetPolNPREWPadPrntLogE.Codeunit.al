#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
codeunit 6248708 "NPR Ret.Pol.: NPREWPadPrntLogE" implements "NPR IRetention Policy"
{
    Access = Internal;

    internal procedure DeleteExpiredRecords(RetentionPolicy: Record "NPR Retention Policy"; ReferenceDateTime: DateTime)
    var
        WaiterPadPrintLogEntry: Record "NPR NPRE W.Pad Prnt LogEntry";
        ExpirationDateTime: DateTime;
        ExpirationDate: Date;
    begin
        ExpirationDate := CalcDate('<-3M>', DT2Date(ReferenceDateTime));
        ExpirationDateTime := CreateDateTime(ExpirationDate, DT2Time(ReferenceDateTime));

        WaiterPadPrintLogEntry.SetRange("Waiter Pad Line Exists", false);
        WaiterPadPrintLogEntry.SetFilter(SystemCreatedAt, '<%1', ExpirationDateTime);
        if not WaiterPadPrintLogEntry.IsEmpty() then
            WaiterPadPrintLogEntry.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Retention Policy", OnDiscoverRetentionPolicyTables, '', true, true)]
    local procedure AddNPRNPREWPadPrntLogEntryOnDiscoverRetentionPolicyTables()
    var
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        RetentionPolicy: Codeunit "NPR Retention Policy";
        RetentionPolicyMgmt: Codeunit "NPR Retention Policy Mgmt.";
        RetentionPolicyImpl: Enum "NPR Retention Policy";
    begin
        if RestaurantSetup.IsEmpty() then
            exit;

        RetentionPolicyImpl := RetentionPolicyImpl::"NPR NPRE W.Pad Prnt LogEntry";
        RetentionPolicy.OnBeforeAddTableOnDiscoverRetentionPolicyTables(Database::"NPR NPRE W.Pad Prnt LogEntry", RetentionPolicyImpl);
        RetentionPolicyMgmt.AddTablePolicy(Database::"NPR NPRE W.Pad Prnt LogEntry", RetentionPolicyImpl);
    end;
}
#endif