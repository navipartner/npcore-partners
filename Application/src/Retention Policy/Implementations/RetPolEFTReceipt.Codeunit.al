#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
codeunit 6248694 "NPR Ret.Pol.: EFT Receipt" implements "NPR IRetention Policy"
{
    Access = Internal;

    internal procedure DeleteExpiredRecords(RetentionPolicy: Record "NPR Retention Policy"; ReferenceDateTime: DateTime)
    var
        EFTReceipt: Record "NPR EFT Receipt";
        RecRef: RecordRef;
        RetenPolDataArchive: Codeunit "NPR Reten. Pol. Data Archive";
        ExpirationDateTime: DateTime;
        ExpirationDate: Date;
    begin
        ExpirationDate := CalcDate('<-6M>', DT2Date(ReferenceDateTime));
        ExpirationDateTime := CreateDateTime(ExpirationDate, DT2Time(ReferenceDateTime));

        EFTReceipt.SetFilter(SystemCreatedAt, '<%1', ExpirationDateTime);
        if not EFTReceipt.IsEmpty() then begin
            RecRef.GetTable(EFTReceipt);
            RetenPolDataArchive.CreateDataArchive(RecRef);
            RetenPolDataArchive.SaveDataArchive();
            EFTReceipt.DeleteAll();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Retention Policy", OnDiscoverRetentionPolicyTables, '', true, true)]
    local procedure AddNPREFTReceiptOnDiscoverRetentionPolicyTables()
    var
        RetentionPolicy: Codeunit "NPR Retention Policy";
        RetentionPolicyMgmt: Codeunit "NPR Retention Policy Mgmt.";
        RetentionPolicyImpl: Enum "NPR Retention Policy";
    begin
        RetentionPolicyImpl := RetentionPolicyImpl::"NPR EFT Receipt";
        RetentionPolicy.OnBeforeAddTableOnDiscoverRetentionPolicyTables(Database::"NPR EFT Receipt", RetentionPolicyImpl);
        RetentionPolicyMgmt.UpsertTablePolicy(Database::"NPR EFT Receipt", RetentionPolicyImpl);
    end;
}
#endif