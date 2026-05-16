#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
codeunit 6248694 "NPR Ret.Pol.: EFT Receipt" implements "NPR IRetention Policy V2"
{
    Access = Internal;

    internal procedure DeleteExpiredRecords(RetentionPolicy: Record "NPR Retention Policy"; ReferenceDateTime: DateTime)
    var
        EFTReceipt: Record "NPR EFT Receipt";
        ExpirationDateTime: DateTime;
        ExpirationDate: Date;
        RetentionPeriod: DateFormula;
    begin
        RetentionPeriod := RetentionPolicy.GetActiveRetentionPeriod(Enum::"NPR Retention Period Type"::"Period 1");

        ExpirationDate := CalcDate(RetentionPeriod, DT2Date(ReferenceDateTime));
        ExpirationDateTime := CreateDateTime(ExpirationDate, DT2Time(ReferenceDateTime));

        EFTReceipt.SetCurrentKey(SystemCreatedAt);
        EFTReceipt.SetFilter(SystemCreatedAt, '<%1', ExpirationDateTime);
        if not EFTReceipt.IsEmpty() then
            BatchProcessRetention(EFTReceipt);
    end;

    local procedure BatchProcessRetention(var EFTReceipt: Record "NPR EFT Receipt")
    var
        EFTReceiptBatch: Record "NPR EFT Receipt";
        DataArchive: Codeunit "Data Archive";
        RecRef: RecordRef;
        DataArchiveProviderExists: Boolean;
        RetentionPolicyDeletionDataArchiveDescriptionTxt: Label 'Retention Policy Deletion - %1 - %2', Comment = '%1 - Table Caption, %2 - Today''s date';
    begin
        DataArchiveProviderExists := DataArchive.DataArchiveProviderExists();
        if DataArchiveProviderExists then
            DataArchive.Create(StrSubstNo(RetentionPolicyDeletionDataArchiveDescriptionTxt, EFTReceipt.TableCaption(), Today()));

        EFTReceipt.FindFirst();
        EFTReceipt.Next(10000);
        repeat
            EFTReceiptBatch.SetFilter(SystemCreatedAt, '<=%1', EFTReceipt.SystemCreatedAt);
            EFTReceiptBatch.FindSet();
            if DataArchiveProviderExists then begin
                RecRef.GetTable(EFTReceiptBatch);
                DataArchive.SaveRecords(RecRef);
            end;
            EFTReceiptBatch.DeleteAll();
            Commit();
            Clear(EFTReceiptBatch);
        until EFTReceipt.Next(10000) = 0;

        if DataArchiveProviderExists then
            DataArchive.Save();
    end;

    internal procedure GetDefaultRetentionPeriod(PeriodType: Enum "NPR Retention Period Type") PeriodDateFormula: DateFormula
    var
        EmptyDateFormula: DateFormula;
    begin
        case PeriodType of
            Enum::"NPR Retention Period Type"::"Period 1":
                Evaluate(PeriodDateFormula, '<-6M>');
            else
                exit(EmptyDateFormula);
        end;
    end;

    internal procedure ShowSetup(RetentionPolicy: Record "NPR Retention Policy"; PolicyEditable: Boolean)
    var
        RetentionPolicyMgmt: Codeunit "NPR Retention Policy Mgmt.";
    begin
        RetentionPolicyMgmt.ShowDefaultNPSetup(RetentionPolicy, PolicyEditable);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Retention Policy", OnDiscoverRetentionPolicyTables, '', true, true)]
    local procedure AddNPREFTReceiptOnDiscoverRetentionPolicyTables()
    var
        RetentionPolicy: Codeunit "NPR Retention Policy";
        RetentionPolicyMgmt: Codeunit "NPR Retention Policy Mgmt.";
        RetentionPolicyImpl: Enum "NPR Retention Policy V2";
    begin
        RetentionPolicyImpl := RetentionPolicyImpl::"NPR EFT Receipt";
        RetentionPolicy.OnBeforeAddTableOnDiscoverRetentionPolicyTablesV2(Database::"NPR EFT Receipt", RetentionPolicyImpl);
        RetentionPolicyMgmt.UpsertTablePolicy(Database::"NPR EFT Receipt", RetentionPolicyImpl);
    end;
}
#endif