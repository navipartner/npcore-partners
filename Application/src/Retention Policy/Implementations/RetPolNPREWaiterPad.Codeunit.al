#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
codeunit 6248707 "NPR Ret.Pol.: NPRE Waiter Pad" implements "NPR IRetention Policy"
{
    Access = Internal;

    internal procedure DeleteExpiredRecords(RetentionPolicy: Record "NPR Retention Policy"; ReferenceDateTime: DateTime)
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        ExpirationDateTime: DateTime;
        ExpirationDate: Date;
    begin
        ExpirationDate := CalcDate('<-3M>', DT2Date(ReferenceDateTime));
        ExpirationDateTime := CreateDateTime(ExpirationDate, DT2Time(ReferenceDateTime));

        WaiterPad.SetRange(Closed, false);
        WaiterPad.SetFilter(SystemCreatedAt, '<%1', ExpirationDateTime);
        if not WaiterPad.IsEmpty() then
            WaiterPad.DeleteAll(true);

        Clear(WaiterPad);
        ExpirationDate := CalcDate('<-14D>', DT2Date(ReferenceDateTime));
        ExpirationDateTime := CreateDateTime(ExpirationDate, DT2Time(ReferenceDateTime));

        WaiterPad.SetRange(Closed, true);
        WaiterPad.SetFilter(SystemCreatedAt, '<%1', ExpirationDateTime);
        if not WaiterPad.IsEmpty() then
            WaiterPad.DeleteAll(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Retention Policy", OnDiscoverRetentionPolicyTables, '', true, true)]
    local procedure AddNPREWaiterPadOnDiscoverRetentionPolicyTables()
    var
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        RetentionPolicy: Codeunit "NPR Retention Policy";
        RetentionPolicyMgmt: Codeunit "NPR Retention Policy Mgmt.";
        RetentionPolicyImpl: Enum "NPR Retention Policy";
    begin
        if RestaurantSetup.IsEmpty() then
            exit;

        RetentionPolicyImpl := RetentionPolicyImpl::"NPR NPRE Waiter Pad";
        RetentionPolicy.OnBeforeAddTableOnDiscoverRetentionPolicyTables(Database::"NPR NPRE Waiter Pad", RetentionPolicyImpl);
        RetentionPolicyMgmt.UpsertTablePolicy(Database::"NPR NPRE Waiter Pad", RetentionPolicyImpl);
    end;
}
#endif