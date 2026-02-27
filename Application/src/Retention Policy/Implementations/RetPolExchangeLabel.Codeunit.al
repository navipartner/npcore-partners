#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
codeunit 6248697 "NPR Ret.Pol.: Exchange Label" implements "NPR IRetention Policy"
{
    Access = Internal;

    internal procedure DeleteExpiredRecords(RetentionPolicy: Record "NPR Retention Policy"; ReferenceDateTime: DateTime)
    var
        ExchangeLabel: Record "NPR Exchange Label";
        IRLFiscalizationSetup: Record "NPR IRL Fiscalization Setup";
        ExpirationDateTime: DateTime;
        ExpirationDate: Date;
    begin
        ExpirationDate := CalcDate('<-5Y>', DT2Date(ReferenceDateTime));
        if IRLFiscalizationSetup.Get() then
            if IRLFiscalizationSetup."IRL Ret. Policy Extended" then
                ExpirationDate := CalcDate('<-6Y>', DT2Date(ReferenceDateTime));
        ExpirationDateTime := CreateDateTime(ExpirationDate, DT2Time(ReferenceDateTime));

        ExchangeLabel.SetFilter(SystemCreatedAt, '<%1', ExpirationDateTime);
        if not ExchangeLabel.IsEmpty() then
            ExchangeLabel.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Retention Policy", OnDiscoverRetentionPolicyTables, '', true, true)]
    local procedure AddNPRExchangeLabelOnDiscoverRetentionPolicyTables()
    var
        RetentionPolicy: Codeunit "NPR Retention Policy";
        RetentionPolicyMgmt: Codeunit "NPR Retention Policy Mgmt.";
        RetentionPolicyImpl: Enum "NPR Retention Policy";
    begin
        RetentionPolicyImpl := RetentionPolicyImpl::"NPR Exchange Label";
        RetentionPolicy.OnBeforeAddTableOnDiscoverRetentionPolicyTables(Database::"NPR Exchange Label", RetentionPolicyImpl);
        RetentionPolicyMgmt.UpsertTablePolicy(Database::"NPR Exchange Label", RetentionPolicyImpl);
    end;
}
#endif