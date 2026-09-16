#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
codeunit 6151277 "NPR Ret.Pol.: Change Quarant." implements "NPR IRetention Policy V2"
{
    Access = Internal;

    internal procedure DeleteExpiredRecords(RetentionPolicy: Record "NPR Retention Policy"; ReferenceDateTime: DateTime)
    var
        ChangeQuarantine: Record "NPR Change Quarantine";
        ExpirationDateTime: DateTime;
        ExpirationDate: Date;
        RetentionPeriod: DateFormula;
    begin
        RetentionPeriod := RetentionPolicy.GetActiveRetentionPeriod(Enum::"NPR Retention Period Type"::"Period 1");

        ExpirationDate := CalcDate(RetentionPeriod, DT2Date(ReferenceDateTime));
        ExpirationDateTime := CreateDateTime(ExpirationDate, DT2Time(ReferenceDateTime));

        ChangeQuarantine.SetFilter(SystemModifiedAt, '<%1', ExpirationDateTime);
        if not ChangeQuarantine.IsEmpty() then
            ChangeQuarantine.DeleteAll();
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
        Period1DescLbl: Label 'All quarantined changes';
    begin
        PeriodDescriptions.Add(Enum::"NPR Retention Period Type"::"Period 1", Period1DescLbl);
        RetentionPolicyMgmt.ShowDefaultNPSetup(RetentionPolicy, PolicyEditable, PeriodDescriptions);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Retention Policy", OnDiscoverRetentionPolicyTables, '', true, true)]
    local procedure AddNPRChangeQuarantineOnDiscoverRetentionPolicyTables()
    var
        RetentionPolicy: Codeunit "NPR Retention Policy";
        RetentionPolicyMgmt: Codeunit "NPR Retention Policy Mgmt.";
        RetentionPolicyImpl: Enum "NPR Retention Policy V2";
    begin
        RetentionPolicyImpl := RetentionPolicyImpl::"NPR Change Quarantine";
        RetentionPolicy.OnBeforeAddTableOnDiscoverRetentionPolicyTablesV2(Database::"NPR Change Quarantine", RetentionPolicyImpl);
        RetentionPolicyMgmt.UpsertTablePolicy(Database::"NPR Change Quarantine", RetentionPolicyImpl);
    end;
}
#endif
