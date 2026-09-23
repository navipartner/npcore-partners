#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
codeunit 6151468 "NPR Ret.Pol.: Spfy Task" implements "NPR IRetention Policy V2"
{
    Access = Internal;

    internal procedure DeleteExpiredRecords(RetentionPolicy: Record "NPR Retention Policy"; ReferenceDateTime: DateTime)
    var
        SpfyTask: Record "NPR Spfy Task";
        ExpirationDateTime: DateTime;
        ExpirationDate: Date;
        RetentionPeriod: DateFormula;
    begin
        RetentionPeriod := RetentionPolicy.GetActiveRetentionPeriod(Enum::"NPR Retention Period Type"::"Period 1");

        ExpirationDate := CalcDate(RetentionPeriod, DT2Date(ReferenceDateTime));
        ExpirationDateTime := CreateDateTime(ExpirationDate, DT2Time(ReferenceDateTime));

        SpfyTask.SetRange(State, SpfyTask.State::Completed);
        SpfyTask.SetFilter("Completed At", '<%1', ExpirationDateTime);
        if not SpfyTask.IsEmpty() then
            SpfyTask.DeleteAll(true);

        Clear(SpfyTask);
        RetentionPeriod := RetentionPolicy.GetActiveRetentionPeriod(Enum::"NPR Retention Period Type"::"Period 2");

        ExpirationDate := CalcDate(RetentionPeriod, DT2Date(ReferenceDateTime));
        ExpirationDateTime := CreateDateTime(ExpirationDate, DT2Time(ReferenceDateTime));

        // Modified, not created: a requeue and a re-quarantine reuse the row, so only the former measures quarantine age.
        SpfyTask.SetRange(State, SpfyTask.State::Quarantined);
        SpfyTask.SetFilter(SystemModifiedAt, '<%1', ExpirationDateTime);
        if not SpfyTask.IsEmpty() then
            SpfyTask.DeleteAll(true);
    end;

    internal procedure GetDefaultRetentionPeriod(PeriodType: Enum "NPR Retention Period Type") PeriodDateFormula: DateFormula
    var
        EmptyDateFormula: DateFormula;
    begin
        case PeriodType of
            Enum::"NPR Retention Period Type"::"Period 1":
                Evaluate(PeriodDateFormula, '<-14D>');
            Enum::"NPR Retention Period Type"::"Period 2":
                Evaluate(PeriodDateFormula, '<-1Y>');
            else
                exit(EmptyDateFormula);
        end;
    end;

    internal procedure ShowSetup(RetentionPolicy: Record "NPR Retention Policy"; PolicyEditable: Boolean)
    var
        RetentionPolicyMgmt: Codeunit "NPR Retention Policy Mgmt.";
        PeriodDescriptions: Dictionary of [Enum "NPR Retention Period Type", Text];
        Period1DescLbl: Label 'Completed tasks';
        Period2DescLbl: Label 'Quarantined tasks';
    begin
        PeriodDescriptions.Add(Enum::"NPR Retention Period Type"::"Period 1", Period1DescLbl);
        PeriodDescriptions.Add(Enum::"NPR Retention Period Type"::"Period 2", Period2DescLbl);
        RetentionPolicyMgmt.ShowDefaultNPSetup(RetentionPolicy, PolicyEditable, PeriodDescriptions);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Retention Policy", OnDiscoverRetentionPolicyTables, '', true, true)]
    local procedure AddNPRSpfyTaskOnDiscoverRetentionPolicyTables()
    var
        RetentionPolicy: Codeunit "NPR Retention Policy";
        RetentionPolicyMgmt: Codeunit "NPR Retention Policy Mgmt.";
        RetentionPolicyImpl: Enum "NPR Retention Policy V2";
    begin
        RetentionPolicyImpl := RetentionPolicyImpl::"NPR Spfy Task";
        RetentionPolicy.OnBeforeAddTableOnDiscoverRetentionPolicyTablesV2(Database::"NPR Spfy Task", RetentionPolicyImpl);
        RetentionPolicyMgmt.UpsertTablePolicy(Database::"NPR Spfy Task", RetentionPolicyImpl);
    end;
}
#endif
