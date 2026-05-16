#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
codeunit 6248706 "NPR Ret.Pol.: NPRE KitchenOrd." implements "NPR IRetention Policy V2"
{
    Access = Internal;

    internal procedure DeleteExpiredRecords(RetentionPolicy: Record "NPR Retention Policy"; ReferenceDateTime: DateTime)
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        ExpirationDateTime: DateTime;
        ExpirationDate: Date;
        RetentionPeriod: DateFormula;
    begin
        RetentionPeriod := RetentionPolicy.GetActiveRetentionPeriod(Enum::"NPR Retention Period Type"::"Period 1");

        ExpirationDate := CalcDate(RetentionPeriod, DT2Date(ReferenceDateTime));
        ExpirationDateTime := CreateDateTime(ExpirationDate, DT2Time(ReferenceDateTime));

        KitchenOrder.SetRange("On Hold", false);
        KitchenOrder.SetRange("Order Status", KitchenOrder."Order Status"::"Ready for Serving", KitchenOrder."Order Status"::Planned);
        KitchenOrder.SetFilter(SystemCreatedAt, '<%1', ExpirationDateTime);
        if not KitchenOrder.IsEmpty() then
            KitchenOrder.DeleteAll(true);

        Clear(KitchenOrder);
        RetentionPeriod := RetentionPolicy.GetActiveRetentionPeriod(Enum::"NPR Retention Period Type"::"Period 2");

        ExpirationDate := CalcDate(RetentionPeriod, DT2Date(ReferenceDateTime));
        ExpirationDateTime := CreateDateTime(ExpirationDate, DT2Time(ReferenceDateTime));

        KitchenOrder.SetRange("On Hold", false);
        KitchenOrder.SetRange("Order Status", KitchenOrder."Order Status"::Finished, KitchenOrder."Order Status"::Cancelled);
        KitchenOrder.SetFilter(SystemCreatedAt, '<%1', ExpirationDateTime);
        if not KitchenOrder.IsEmpty() then
            KitchenOrder.DeleteAll(true);
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
        Period1DescLbl: Label 'Active orders (not on hold; status is Ready for Serving, In-Production, Released or Planned)';
        Period2DescLbl: Label 'Completed orders (not on hold; status is Finished or Cancelled)';
    begin
        PeriodDescriptions.Add(Enum::"NPR Retention Period Type"::"Period 1", Period1DescLbl);
        PeriodDescriptions.Add(Enum::"NPR Retention Period Type"::"Period 2", Period2DescLbl);
        RetentionPolicyMgmt.ShowDefaultNPSetup(RetentionPolicy, PolicyEditable, PeriodDescriptions);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Retention Policy", OnDiscoverRetentionPolicyTables, '', true, true)]
    local procedure AddNPREKitchenOrderOnDiscoverRetentionPolicyTables()
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        RestaurantSetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
        RetentionPolicy: Codeunit "NPR Retention Policy";
        RetentionPolicyMgmt: Codeunit "NPR Retention Policy Mgmt.";
        RetentionPolicyImpl: Enum "NPR Retention Policy V2";
    begin
        if not RestaurantSetupProxy.KDSActivatedForAnyRestaurant() then
            if KitchenOrder.IsEmpty() then
                exit;

        RetentionPolicyImpl := RetentionPolicyImpl::"NPR NPRE Kitchen Order";
        RetentionPolicy.OnBeforeAddTableOnDiscoverRetentionPolicyTablesV2(Database::"NPR NPRE Kitchen Order", RetentionPolicyImpl);
        RetentionPolicyMgmt.UpsertTablePolicy(Database::"NPR NPRE Kitchen Order", RetentionPolicyImpl);
    end;
}
#endif