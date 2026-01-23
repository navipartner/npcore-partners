#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
codeunit 6248719 "NPR Ret.Pol.: SalesPrcMntLog" implements "NPR IRetention Policy"
{
    Access = Internal;

    internal procedure DeleteExpiredRecords(RetentionPolicy: Record "NPR Retention Policy"; ReferenceDateTime: DateTime)
    var
        SalesPriceMaintLog: Record "NPR Sales Price Maint. Log";
        ExpirationDateTime: DateTime;
        ExpirationDate: Date;
    begin
        ExpirationDate := CalcDate('<-1M>', DT2Date(ReferenceDateTime));
        ExpirationDateTime := CreateDateTime(ExpirationDate, DT2Time(ReferenceDateTime));

        SalesPriceMaintLog.SetRange(Processed, true);
        SalesPriceMaintLog.SetFilter(SystemCreatedAt, '<%1', ExpirationDateTime);
        if not SalesPriceMaintLog.IsEmpty() then
            SalesPriceMaintLog.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Retention Policy", OnDiscoverRetentionPolicyTables, '', true, true)]
    local procedure AddNPRSalesPriceMaintLogOnDiscoverRetentionPolicyTables()
    var
        RetentionPolicy: Codeunit "NPR Retention Policy";
        RetentionPolicyMgmt: Codeunit "NPR Retention Policy Mgmt.";
        RetentionPolicyImpl: Enum "NPR Retention Policy";
    begin
        RetentionPolicyImpl := RetentionPolicyImpl::"NPR Sales Price Maint. Log";
        RetentionPolicy.OnBeforeAddTableOnDiscoverRetentionPolicyTables(Database::"NPR Sales Price Maint. Log", RetentionPolicyImpl);
        RetentionPolicyMgmt.AddTablePolicy(Database::"NPR Sales Price Maint. Log", RetentionPolicyImpl);
    end;
}
#endif