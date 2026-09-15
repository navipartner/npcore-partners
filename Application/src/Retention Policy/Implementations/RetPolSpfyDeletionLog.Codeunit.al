#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
codeunit 6151232 "NPR Ret.Pol.: SpfyDeletionLog" implements "NPR IRetention Policy V2"
{
    Access = Internal;

    // Mandatory filter is enforced in CODE here: only terminal-state rows (Cancelled / Processed) are ever eligible
    // for deletion. A Pending row is the deletes-only outbox cursor and a pruned Pending row would be an unrecoverable
    // orphaned remote delete, so this implementation can never see it regardless of the admin's period setup.
    internal procedure DeleteExpiredRecords(RetentionPolicy: Record "NPR Retention Policy"; ReferenceDateTime: DateTime)
    var
        SpfyDeletionLog: Record "NPR Spfy Deletion Log";
        ExpirationDateTime: DateTime;
        ExpirationDate: Date;
        RetentionPeriod: DateFormula;
    begin
        RetentionPeriod := RetentionPolicy.GetActiveRetentionPeriod(Enum::"NPR Retention Period Type"::"Period 1");

        ExpirationDate := CalcDate(RetentionPeriod, DT2Date(ReferenceDateTime));
        ExpirationDateTime := CreateDateTime(ExpirationDate, DT2Time(ReferenceDateTime));

        SpfyDeletionLog.SetRange(Status, SpfyDeletionLog.Status::Cancelled, SpfyDeletionLog.Status::Processed);
        SpfyDeletionLog.SetFilter(SystemModifiedAt, '<%1', ExpirationDateTime);
        if not SpfyDeletionLog.IsEmpty() then
            SpfyDeletionLog.DeleteAll();
    end;

    internal procedure GetDefaultRetentionPeriod(PeriodType: Enum "NPR Retention Period Type") PeriodDateFormula: DateFormula
    var
        EmptyDateFormula: DateFormula;
    begin
        case PeriodType of
            Enum::"NPR Retention Period Type"::"Period 1":
                Evaluate(PeriodDateFormula, '<-3M>');
            else
                exit(EmptyDateFormula);
        end;
    end;

    internal procedure ShowSetup(RetentionPolicy: Record "NPR Retention Policy"; PolicyEditable: Boolean)
    var
        RetentionPolicyMgmt: Codeunit "NPR Retention Policy Mgmt.";
        PeriodDescriptions: Dictionary of [Enum "NPR Retention Period Type", Text];
        Period1DescLbl: Label 'Status is Cancelled or Processed';
    begin
        PeriodDescriptions.Add(Enum::"NPR Retention Period Type"::"Period 1", Period1DescLbl);
        RetentionPolicyMgmt.ShowDefaultNPSetup(RetentionPolicy, PolicyEditable, PeriodDescriptions);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Retention Policy", OnDiscoverRetentionPolicyTables, '', true, true)]
    local procedure AddNPRSpfyDeletionLogOnDiscoverRetentionPolicyTables()
    var
        RetentionPolicy: Codeunit "NPR Retention Policy";
        RetentionPolicyMgmt: Codeunit "NPR Retention Policy Mgmt.";
        RetentionPolicyImpl: Enum "NPR Retention Policy V2";
    begin
        RetentionPolicyImpl := RetentionPolicyImpl::"NPR Spfy Deletion Log";
        RetentionPolicy.OnBeforeAddTableOnDiscoverRetentionPolicyTablesV2(Database::"NPR Spfy Deletion Log", RetentionPolicyImpl);
        RetentionPolicyMgmt.UpsertTablePolicy(Database::"NPR Spfy Deletion Log", RetentionPolicyImpl);
    end;
}
#endif
