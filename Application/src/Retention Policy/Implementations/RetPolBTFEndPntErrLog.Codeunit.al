#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
codeunit 6248689 "NPR Ret.Pol.: BTFEndPntErrLog" implements "NPR IRetention Policy"
{
    Access = Internal;

    internal procedure DeleteExpiredRecords(RetentionPolicy: Record "NPR Retention Policy"; ReferenceDateTime: DateTime)
    var
        BTFEndPointErrorLog: Record "NPR BTF EndPoint Error Log";
        ExpirationDateTime: DateTime;
        ExpirationDate: Date;
    begin
        ExpirationDate := CalcDate('<-1M>', DT2Date(ReferenceDateTime));
        ExpirationDateTime := CreateDateTime(ExpirationDate, DT2Time(ReferenceDateTime));

        BTFEndPointErrorLog.SetFilter(SystemCreatedAt, '<%1', ExpirationDateTime);
        if not BTFEndPointErrorLog.IsEmpty() then
            BTFEndPointErrorLog.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Retention Policy", OnDiscoverRetentionPolicyTables, '', true, true)]
    local procedure AddNPRBTFEndPointErrorLogOnDiscoverRetentionPolicyTables()
    var
        RetentionPolicy: Codeunit "NPR Retention Policy";
        RetentionPolicyMgmt: Codeunit "NPR Retention Policy Mgmt.";
        RetentionPolicyImpl: Enum "NPR Retention Policy";
    begin
        RetentionPolicyImpl := RetentionPolicyImpl::"NPR BTF EndPoint Error Log";
        RetentionPolicy.OnBeforeAddTableOnDiscoverRetentionPolicyTables(Database::"NPR BTF EndPoint Error Log", RetentionPolicyImpl);
        RetentionPolicyMgmt.AddTablePolicy(Database::"NPR BTF EndPoint Error Log", RetentionPolicyImpl);
    end;
}
#endif