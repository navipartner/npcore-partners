#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
codeunit 6248723 "NPR Ret.Pol.: SpfyWebhookNotif" implements "NPR IRetention Policy V2"
{
    Access = Internal;

    internal procedure DeleteExpiredRecords(RetentionPolicy: Record "NPR Retention Policy"; ReferenceDateTime: DateTime)
    var
        SpfyWebhookNotification: Record "NPR Spfy Webhook Notification";
        ExpirationDateTime: DateTime;
        ExpirationDate: Date;
        RetentionPeriod: DateFormula;
    begin
        RetentionPeriod := RetentionPolicy.GetActiveRetentionPeriod(Enum::"NPR Retention Period Type"::"Period 1");

        ExpirationDate := CalcDate(RetentionPeriod, DT2Date(ReferenceDateTime));
        ExpirationDateTime := CreateDateTime(ExpirationDate, DT2Time(ReferenceDateTime));

        SpfyWebhookNotification.SetRange(Status, SpfyWebhookNotification.Status::New, SpfyWebhookNotification.Status::Error);
        SpfyWebhookNotification.SetFilter(SystemCreatedAt, '<%1', ExpirationDateTime);
        if not SpfyWebhookNotification.IsEmpty() then
            SpfyWebhookNotification.DeleteAll();

        Clear(SpfyWebhookNotification);
        RetentionPeriod := RetentionPolicy.GetActiveRetentionPeriod(Enum::"NPR Retention Period Type"::"Period 2");

        ExpirationDate := CalcDate(RetentionPeriod, DT2Date(ReferenceDateTime));
        ExpirationDateTime := CreateDateTime(ExpirationDate, DT2Time(ReferenceDateTime));

        SpfyWebhookNotification.SetRange(Status, SpfyWebhookNotification.Status::Processed, SpfyWebhookNotification.Status::Cancelled);
        SpfyWebhookNotification.SetFilter(SystemCreatedAt, '<%1', ExpirationDateTime);
        if not SpfyWebhookNotification.IsEmpty() then
            SpfyWebhookNotification.DeleteAll();
    end;

    internal procedure GetDefaultRetentionPeriod(PeriodType: Enum "NPR Retention Period Type") PeriodDateFormula: DateFormula
    var
        EmptyDateFormula: DateFormula;
    begin
        case PeriodType of
            Enum::"NPR Retention Period Type"::"Period 1":
                Evaluate(PeriodDateFormula, '<-3M>');
            Enum::"NPR Retention Period Type"::"Period 2":
                Evaluate(PeriodDateFormula, '<-1M>');
            else
                exit(EmptyDateFormula);
        end;
    end;

    internal procedure ShowSetup(RetentionPolicy: Record "NPR Retention Policy"; PolicyEditable: Boolean)
    var
        RetentionPolicyMgmt: Codeunit "NPR Retention Policy Mgmt.";
        PeriodDescriptions: Dictionary of [Enum "NPR Retention Period Type", Text];
        Period1DescLbl: Label 'Status is New or Error';
        Period2DescLbl: Label 'Status is Processed or Cancelled';
    begin
        PeriodDescriptions.Add(Enum::"NPR Retention Period Type"::"Period 1", Period1DescLbl);
        PeriodDescriptions.Add(Enum::"NPR Retention Period Type"::"Period 2", Period2DescLbl);
        RetentionPolicyMgmt.ShowDefaultNPSetup(RetentionPolicy, PolicyEditable, PeriodDescriptions);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Retention Policy", OnDiscoverRetentionPolicyTables, '', true, true)]
    local procedure AddNPRSpfyWebhookNotificationOnDiscoverRetentionPolicyTables()
    var
        RetentionPolicy: Codeunit "NPR Retention Policy";
        RetentionPolicyMgmt: Codeunit "NPR Retention Policy Mgmt.";
        RetentionPolicyImpl: Enum "NPR Retention Policy V2";
    begin
        RetentionPolicyImpl := RetentionPolicyImpl::"NPR Spfy Webhook Notification";
        RetentionPolicy.OnBeforeAddTableOnDiscoverRetentionPolicyTablesV2(Database::"NPR Spfy Webhook Notification", RetentionPolicyImpl);
        RetentionPolicyMgmt.UpsertTablePolicy(Database::"NPR Spfy Webhook Notification", RetentionPolicyImpl);
    end;
}
#endif