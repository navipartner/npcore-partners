#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
codeunit 6248706 "NPR Ret.Pol.: NPRE KitchenOrd." implements "NPR IRetention Policy"
{
    Access = Internal;

    internal procedure DeleteExpiredRecords(RetentionPolicy: Record "NPR Retention Policy"; ReferenceDateTime: DateTime)
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        ExpirationDateTime: DateTime;
        ExpirationDate: Date;
    begin
        ExpirationDate := CalcDate('<-3M>', DT2Date(ReferenceDateTime));
        ExpirationDateTime := CreateDateTime(ExpirationDate, DT2Time(ReferenceDateTime));

        KitchenOrder.SetRange("On Hold", false);
        KitchenOrder.SetRange("Order Status", KitchenOrder."Order Status"::"Ready for Serving", KitchenOrder."Order Status"::Planned);
        KitchenOrder.SetFilter(SystemCreatedAt, '<%1', ExpirationDateTime);
        if not KitchenOrder.IsEmpty() then
            KitchenOrder.DeleteAll(true);

        Clear(KitchenOrder);
        ExpirationDate := CalcDate('<-14D>', DT2Date(ReferenceDateTime));
        ExpirationDateTime := CreateDateTime(ExpirationDate, DT2Time(ReferenceDateTime));

        KitchenOrder.SetRange("On Hold", false);
        KitchenOrder.SetRange("Order Status", KitchenOrder."Order Status"::Finished, KitchenOrder."Order Status"::Cancelled);
        KitchenOrder.SetFilter(SystemCreatedAt, '<%1', ExpirationDateTime);
        if not KitchenOrder.IsEmpty() then
            KitchenOrder.DeleteAll(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Retention Policy", OnDiscoverRetentionPolicyTables, '', true, true)]
    local procedure AddNPREKitchenOrderOnDiscoverRetentionPolicyTables()
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        RestaurantSetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
        RetentionPolicy: Codeunit "NPR Retention Policy";
        RetentionPolicyMgmt: Codeunit "NPR Retention Policy Mgmt.";
        RetentionPolicyImpl: Enum "NPR Retention Policy";
    begin
        if not RestaurantSetupProxy.KDSActivatedForAnyRestaurant() then
            if KitchenOrder.IsEmpty() then
                exit;

        RetentionPolicyImpl := RetentionPolicyImpl::"NPR NPRE Kitchen Order";
        RetentionPolicy.OnBeforeAddTableOnDiscoverRetentionPolicyTables(Database::"NPR NPRE Kitchen Order", RetentionPolicyImpl);
        RetentionPolicyMgmt.UpsertTablePolicy(Database::"NPR NPRE Kitchen Order", RetentionPolicyImpl);
    end;
}
#endif