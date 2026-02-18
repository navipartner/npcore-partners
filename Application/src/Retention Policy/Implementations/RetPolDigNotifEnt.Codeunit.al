#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
codeunit 6150993 "NPR Ret.Pol.: Dig.Notif.Ent" implements "NPR IRetention Policy"
{
    Access = Internal;

    internal procedure DeleteExpiredRecords(RetentionPolicy: Record "NPR Retention Policy"; ReferenceDateTime: DateTime)
    var
        DigitalNotificationEntry: Record "NPR Digital Notification Entry";
        ExpirationDateTime: DateTime;
        ExpirationDate: Date;
    begin
        ExpirationDate := CalcDate('<-1M>', DT2Date(ReferenceDateTime));
        ExpirationDateTime := CreateDateTime(ExpirationDate, DT2Time(ReferenceDateTime));

        DigitalNotificationEntry.SetFilter(SystemCreatedAt, '<%1', ExpirationDateTime);
        if not DigitalNotificationEntry.IsEmpty() then
            DigitalNotificationEntry.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Retention Policy", OnDiscoverRetentionPolicyTables, '', true, true)]
    local procedure AddNPRDigitalNotificationEntryOnDiscoverRetentionPolicyTables()
    var
        RetentionPolicy: Codeunit "NPR Retention Policy";
        RetentionPolicyMgmt: Codeunit "NPR Retention Policy Mgmt.";
        RetentionPolicyImpl: Enum "NPR Retention Policy";
    begin
        RetentionPolicyImpl := RetentionPolicyImpl::"NPR Digital Notification Entry";
        RetentionPolicy.OnBeforeAddTableOnDiscoverRetentionPolicyTables(Database::"NPR Digital Notification Entry", RetentionPolicyImpl);
        RetentionPolicyMgmt.AddTablePolicy(Database::"NPR Digital Notification Entry", RetentionPolicyImpl);
    end;
}
#endif
