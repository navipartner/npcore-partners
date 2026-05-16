#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
codeunit 6248707 "NPR Ret.Pol.: NPRE Waiter Pad" implements "NPR IRetention Policy V2"
{
    Access = Internal;

    internal procedure DeleteExpiredRecords(RetentionPolicy: Record "NPR Retention Policy"; ReferenceDateTime: DateTime)
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        ExpirationDateTime: DateTime;
        ExpirationDate: Date;
        RetentionPeriod: DateFormula;
    begin
        RetentionPeriod := RetentionPolicy.GetActiveRetentionPeriod(Enum::"NPR Retention Period Type"::"Period 1");

        ExpirationDate := CalcDate(RetentionPeriod, DT2Date(ReferenceDateTime));
        ExpirationDateTime := CreateDateTime(ExpirationDate, DT2Time(ReferenceDateTime));

        WaiterPad.SetRange(Closed, false);
        WaiterPad.SetFilter(SystemCreatedAt, '<%1', ExpirationDateTime);
        if not WaiterPad.IsEmpty() then
            WaiterPad.DeleteAll(true);

        Clear(WaiterPad);
        RetentionPeriod := RetentionPolicy.GetActiveRetentionPeriod(Enum::"NPR Retention Period Type"::"Period 2");

        ExpirationDate := CalcDate(RetentionPeriod, DT2Date(ReferenceDateTime));
        ExpirationDateTime := CreateDateTime(ExpirationDate, DT2Time(ReferenceDateTime));

        WaiterPad.SetRange(Closed, true);
        WaiterPad.SetFilter(SystemCreatedAt, '<%1', ExpirationDateTime);
        if not WaiterPad.IsEmpty() then
            WaiterPad.DeleteAll(true);
    end;

    internal procedure GetDefaultRetentionPeriod(PeriodType: Enum "NPR Retention Period Type") PeriodDateFormula: DateFormula
    var
        EmptyDateFormula: DateFormula;
    begin
        case PeriodType of
            Enum::"NPR Retention Period Type"::"Period 1":
                Evaluate(PeriodDateFormula, '<-3M>');
            Enum::"NPR Retention Period Type"::"Period 2":
                Evaluate(PeriodDateFormula, '<-14D>');
            else
                exit(EmptyDateFormula);
        end;
    end;

    internal procedure ShowSetup(RetentionPolicy: Record "NPR Retention Policy"; PolicyEditable: Boolean)
    var
        RetentionPolicyMgmt: Codeunit "NPR Retention Policy Mgmt.";
        PeriodDescriptions: Dictionary of [Enum "NPR Retention Period Type", Text];
        Period1DescLbl: Label 'Open waiter pads';
        Period2DescLbl: Label 'Closed waiter pads';
    begin
        PeriodDescriptions.Add(Enum::"NPR Retention Period Type"::"Period 1", Period1DescLbl);
        PeriodDescriptions.Add(Enum::"NPR Retention Period Type"::"Period 2", Period2DescLbl);
        RetentionPolicyMgmt.ShowDefaultNPSetup(RetentionPolicy, PolicyEditable, PeriodDescriptions);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Retention Policy", OnDiscoverRetentionPolicyTables, '', true, true)]
    local procedure AddNPREWaiterPadOnDiscoverRetentionPolicyTables()
    var
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        RetentionPolicy: Codeunit "NPR Retention Policy";
        RetentionPolicyMgmt: Codeunit "NPR Retention Policy Mgmt.";
        RetentionPolicyImpl: Enum "NPR Retention Policy V2";
    begin
        if RestaurantSetup.IsEmpty() then
            exit;

        RetentionPolicyImpl := RetentionPolicyImpl::"NPR NPRE Waiter Pad";
        RetentionPolicy.OnBeforeAddTableOnDiscoverRetentionPolicyTablesV2(Database::"NPR NPRE Waiter Pad", RetentionPolicyImpl);
        RetentionPolicyMgmt.UpsertTablePolicy(Database::"NPR NPRE Waiter Pad", RetentionPolicyImpl);
    end;
}
#endif