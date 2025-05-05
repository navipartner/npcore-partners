#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248417 "NPR Simple Billing Events"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Session", OnInitializationComplete, '', false, false)]
    local procedure POSSessionOnInitializationComplete(FrontEnd: Codeunit "NPR POS Front End Management")
    var
        BillingClient: Codeunit "NPR Event Billing Client";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
        MetadataBuilder: Codeunit "NPR Json Builder";
        POSUnit: Record "NPR POS Unit";
    begin
        FrontEnd.GetSession(POSSession);
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);

        MetadataBuilder.Initialize()
            .StartObject()
                .AddProperty('posUnitNo', POSUnit."No.")
                .AddProperty('posUnitName', POSUnit.Name)
                .AddProperty('posStoreCode', POSUnit."POS Store Code")
                .AddProperty('posDim1Code', POSUnit."Global Dimension 1 Code")
                .AddProperty('posDim2Code', POSUnit."Global Dimension 2 Code")
                .AddProperty('posType', POSUnit."POS Type")
                .AddProperty('posTypeString', Format(POSUnit."POS Type"))
                .AddProperty('restaurantCode', POSSetup.RestaurantCode())
            .EndObject();

        BillingClient.RegisterEvent(CreateGuid(), Enum::"NPR Billing Event Type"::POSLogin, 1, MetadataBuilder.BuildAsJsonToken());
    end;
}
#endif