#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
codeunit 6248702 "NPR Ret.Pol.: Nc Task" implements "NPR IRetention Policy"
{
    Access = Internal;

    internal procedure DeleteExpiredRecords(RetentionPolicy: Record "NPR Retention Policy"; ReferenceDateTime: DateTime)
    var
        NcTask: Record "NPR Nc Task";
        ExpirationDateTime: DateTime;
        ExpirationDate: Date;
    begin
        ExpirationDate := CalcDate('<-1M>', DT2Date(ReferenceDateTime));
        ExpirationDateTime := CreateDateTime(ExpirationDate, DT2Time(ReferenceDateTime));

        NcTask.SetRange(Processed, false);
        NcTask.SetRange("Process Error", true);
        NcTask.SetFilter(SystemCreatedAt, '<%1', ExpirationDateTime);
        if not NcTask.IsEmpty() then
            NcTask.DeleteAll(true);

        Clear(NcTask);
        ExpirationDate := CalcDate('<-14D>', DT2Date(ReferenceDateTime));
        ExpirationDateTime := CreateDateTime(ExpirationDate, DT2Time(ReferenceDateTime));

        NcTask.SetRange(Processed, true);
        NcTask.SetFilter(SystemCreatedAt, '<%1', ExpirationDateTime);
        if not NcTask.IsEmpty() then
            NcTask.DeleteAll(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Retention Policy", OnDiscoverRetentionPolicyTables, '', true, true)]
    local procedure AddNPRNcTaskOnDiscoverRetentionPolicyTables()
    var
        RetentionPolicy: Codeunit "NPR Retention Policy";
        RetentionPolicyMgmt: Codeunit "NPR Retention Policy Mgmt.";
        RetentionPolicyImpl: Enum "NPR Retention Policy";
    begin
        RetentionPolicyImpl := RetentionPolicyImpl::"NPR Nc Task";
        RetentionPolicy.OnBeforeAddTableOnDiscoverRetentionPolicyTables(Database::"NPR Nc Task", RetentionPolicyImpl);
        RetentionPolicyMgmt.UpsertTablePolicy(Database::"NPR Nc Task", RetentionPolicyImpl);
    end;
}
#endif