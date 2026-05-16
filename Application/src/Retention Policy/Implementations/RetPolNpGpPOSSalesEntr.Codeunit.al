#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
codeunit 6248705 "NPR Ret.Pol.: NpGpPOSSalesEntr" implements "NPR IRetention Policy V2"
{
    Access = Internal;

    internal procedure DeleteExpiredRecords(RetentionPolicy: Record "NPR Retention Policy"; ReferenceDateTime: DateTime)
    var
        NpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry";
        ExpirationDateTime: DateTime;
        ExpirationDate: Date;
        RetentionPeriod: DateFormula;
    begin
        RetentionPeriod := RetentionPolicy.GetActiveRetentionPeriod(Enum::"NPR Retention Period Type"::"Period 1");

        ExpirationDate := CalcDate(RetentionPeriod, DT2Date(ReferenceDateTime));
        ExpirationDateTime := CreateDateTime(ExpirationDate, DT2Time(ReferenceDateTime));

        NpGpPOSSalesEntry.SetFilter(SystemCreatedAt, '<%1', ExpirationDateTime);
        if not NpGpPOSSalesEntry.IsEmpty() then
            NpGpPOSSalesEntry.DeleteAll();
    end;

    internal procedure GetDefaultRetentionPeriod(PeriodType: Enum "NPR Retention Period Type") PeriodDateFormula: DateFormula
    var
        IRLFiscalizationSetup: Record "NPR IRL Fiscalization Setup";
        EmptyDateFormula: DateFormula;
    begin
        case PeriodType of
            Enum::"NPR Retention Period Type"::"Period 1":
                begin
                    Evaluate(PeriodDateFormula, '<-5Y>');
                    if IRLFiscalizationSetup.Get() then
                        if IRLFiscalizationSetup."IRL Ret. Policy Extended" then
                            Evaluate(PeriodDateFormula, '<-6Y>');
                end;
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
    local procedure AddNPRNpGpPOSSalesEntryOnDiscoverRetentionPolicyTables()
    var
        RetentionPolicy: Codeunit "NPR Retention Policy";
        RetentionPolicyMgmt: Codeunit "NPR Retention Policy Mgmt.";
        RetentionPolicyImpl: Enum "NPR Retention Policy V2";
    begin
        RetentionPolicyImpl := RetentionPolicyImpl::"NPR NpGp POS Sales Entry";
        RetentionPolicy.OnBeforeAddTableOnDiscoverRetentionPolicyTablesV2(Database::"NPR NpGp POS Sales Entry", RetentionPolicyImpl);
        RetentionPolicyMgmt.UpsertTablePolicy(Database::"NPR NpGp POS Sales Entry", RetentionPolicyImpl);
    end;
}
#endif