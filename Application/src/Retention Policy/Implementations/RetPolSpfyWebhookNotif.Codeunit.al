#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
codeunit 6248723 "NPR Ret.Pol.: SpfyWebhookNotif" implements "NPR IRetention Policy"
{
    Access = Internal;

    internal procedure DeleteExpiredRecords(RetentionPolicy: Record "NPR Retention Policy"; ReferenceDateTime: DateTime)
    var
        SpfyWebhookNotification: Record "NPR Spfy Webhook Notification";
        ExpirationDateTime: DateTime;
        ExpirationDate: Date;
    begin
        ExpirationDate := CalcDate('<-3M>', DT2Date(ReferenceDateTime));
        ExpirationDateTime := CreateDateTime(ExpirationDate, DT2Time(ReferenceDateTime));

        SpfyWebhookNotification.SetRange(Status, SpfyWebhookNotification.Status::New, SpfyWebhookNotification.Status::Error);
        SpfyWebhookNotification.SetFilter(SystemCreatedAt, '<%1', ExpirationDateTime);
        if not SpfyWebhookNotification.IsEmpty() then
            SpfyWebhookNotification.DeleteAll();

        Clear(SpfyWebhookNotification);
        ExpirationDate := CalcDate('<-1M>', DT2Date(ReferenceDateTime));
        ExpirationDateTime := CreateDateTime(ExpirationDate, DT2Time(ReferenceDateTime));

        SpfyWebhookNotification.SetRange(Status, SpfyWebhookNotification.Status::Processed, SpfyWebhookNotification.Status::Cancelled);
        SpfyWebhookNotification.SetFilter(SystemCreatedAt, '<%1', ExpirationDateTime);
        if not SpfyWebhookNotification.IsEmpty() then
            SpfyWebhookNotification.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Retention Policy", OnDiscoverRetentionPolicyTables, '', true, true)]
    local procedure AddNPRSpfyWebhookNotificationOnDiscoverRetentionPolicyTables()
    var
        RetentionPolicy: Codeunit "NPR Retention Policy";
        RetentionPolicyMgmt: Codeunit "NPR Retention Policy Mgmt.";
        RetentionPolicyImpl: Enum "NPR Retention Policy";
    begin
        RetentionPolicyImpl := RetentionPolicyImpl::"NPR Spfy Webhook Notification";
        RetentionPolicy.OnBeforeAddTableOnDiscoverRetentionPolicyTables(Database::"NPR Spfy Webhook Notification", RetentionPolicyImpl);
        RetentionPolicyMgmt.AddTablePolicy(Database::"NPR Spfy Webhook Notification", RetentionPolicyImpl);
    end;
}
#endif