#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
codeunit 6248698 "NPR Ret.Pol.: HL Webhook Req." implements "NPR IRetention Policy"
{
    Access = Internal;

    internal procedure DeleteExpiredRecords(RetentionPolicy: Record "NPR Retention Policy"; ReferenceDateTime: DateTime)
    var
        HLWebhookRequest: Record "NPR HL Webhook Request";
        ExpirationDateTime: DateTime;
        ExpirationDate: Date;
    begin
        ExpirationDate := CalcDate('<-1M>', DT2Date(ReferenceDateTime));
        ExpirationDateTime := CreateDateTime(ExpirationDate, DT2Time(ReferenceDateTime));

        HLWebhookRequest.SetRange("Processing Status", HLWebhookRequest."Processing Status"::Processed);
        HLWebhookRequest.SetFilter(SystemCreatedAt, '<%1', ExpirationDateTime);
        if not HLWebhookRequest.IsEmpty() then
            HLWebhookRequest.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Retention Policy", OnDiscoverRetentionPolicyTables, '', true, true)]
    local procedure AddNPRHLWebhookRequestOnDiscoverRetentionPolicyTables()
    var
        HLWebhookRequest: Record "NPR HL Webhook Request";
        HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";
        RetentionPolicy: Codeunit "NPR Retention Policy";
        RetentionPolicyMgmt: Codeunit "NPR Retention Policy Mgmt.";
        RetentionPolicyImpl: Enum "NPR Retention Policy";
    begin
        if not HLIntegrationMgt.IsEnabled("NPR HL Integration Area"::Members) then
            if HLWebhookRequest.IsEmpty() then
                exit;

        RetentionPolicyImpl := RetentionPolicyImpl::"NPR HL Webhook Request";
        RetentionPolicy.OnBeforeAddTableOnDiscoverRetentionPolicyTables(Database::"NPR HL Webhook Request", RetentionPolicyImpl);
        RetentionPolicyMgmt.AddTablePolicy(Database::"NPR HL Webhook Request", RetentionPolicyImpl);
    end;
}
#endif