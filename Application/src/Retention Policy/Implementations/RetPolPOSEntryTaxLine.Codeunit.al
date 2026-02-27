#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
codeunit 6248714 "NPR Ret.Pol.: POSEntryTaxLine" implements "NPR IRetention Policy"
{
    Access = Internal;

    internal procedure DeleteExpiredRecords(RetentionPolicy: Record "NPR Retention Policy"; ReferenceDateTime: DateTime)
    var
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        IRLFiscalizationSetup: Record "NPR IRL Fiscalization Setup";
        ExpirationDateTime: DateTime;
        ExpirationDate: Date;
    begin
        ExpirationDate := CalcDate('<-5Y>', DT2Date(ReferenceDateTime));
        if IRLFiscalizationSetup.Get() then
            if IRLFiscalizationSetup."IRL Ret. Policy Extended" then
                ExpirationDate := CalcDate('<-6Y>', DT2Date(ReferenceDateTime));
        ExpirationDateTime := CreateDateTime(ExpirationDate, DT2Time(ReferenceDateTime));

        POSEntryTaxLine.SetFilter(SystemCreatedAt, '<%1', ExpirationDateTime);
        if not POSEntryTaxLine.IsEmpty() then
            POSEntryTaxLine.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Retention Policy", OnDiscoverRetentionPolicyTables, '', true, true)]
    local procedure AddNPRPOSEntryTaxLineOnDiscoverRetentionPolicyTables()
    var
        RetentionPolicy: Codeunit "NPR Retention Policy";
        RetentionPolicyMgmt: Codeunit "NPR Retention Policy Mgmt.";
        RetentionPolicyImpl: Enum "NPR Retention Policy";
    begin
        RetentionPolicyImpl := RetentionPolicyImpl::"NPR POS Entry Tax Line";
        RetentionPolicy.OnBeforeAddTableOnDiscoverRetentionPolicyTables(Database::"NPR POS Entry Tax Line", RetentionPolicyImpl);
        RetentionPolicyMgmt.UpsertTablePolicy(Database::"NPR POS Entry Tax Line", RetentionPolicyImpl);
    end;
}
#endif