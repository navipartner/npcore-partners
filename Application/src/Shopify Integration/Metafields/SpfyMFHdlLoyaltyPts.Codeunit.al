#if not BC17
codeunit 6248558 "NPR Spfy M/F Hdl.-Loyalty Pts"
{
    Access = Internal;

    var
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";

    internal procedure InitStoreCustomerLinkMetafields(SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link")
    var
        Membership: Record "NPR MM Membership";
    begin
        if SpfyStoreCustomerLink.Type <> SpfyStoreCustomerLink.Type::Customer then
            exit;

        Membership.SetRange("Customer No.", SpfyStoreCustomerLink."No.");
        Membership.SetRange(Blocked, false);
        Membership.SetLoadFields("Customer No.");
        Membership.SetAutoCalcFields("Remaining Points");
        if not Membership.FindFirst() then
            exit;
        ProcessLoyaltyPointBalanceChange(Membership, SpfyStoreCustomerLink."Shopify Store Code", false);
    end;

    internal procedure ProcessMetafieldMappingChange(SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping"; var SpfyEntityMetafield: Record "NPR Spfy Entity Metafield"; xMetafieldID: Text[30]; Removed: Boolean)
    var
        SpfyStore: Record "NPR Spfy Store";
    begin
        if (SpfyMetafieldMapping."Table No." <> Database::"NPR Spfy Store") or
           (SpfyMetafieldMapping."Field No." <> SpfyStore.FieldNo("Loyalty Points as Metafield"))
        then
            exit;
        ProcessLoyaltyPointsMetafieldMappingChange(SpfyMetafieldMapping, SpfyEntityMetafield, xMetafieldID, Removed);
    end;

    internal procedure DoBCMetafieldUpdate(SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping"; SpfyEntityMetafieldParam: Record "NPR Spfy Entity Metafield"; ItemNo: Code[20]; var Updated: Boolean)
    begin
        if SpfyMetafieldMapping."Table No." <> Database::"NPR Spfy Store" then
            exit;
        SpfyMetafieldMgt.SetEntityMetafieldValue(SpfyEntityMetafieldParam, true, true);
        Updated := true;
    end;

    local procedure ProcessLoyaltyPointsMetafieldMappingChange(SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping"; var SpfyEntityMetafield: Record "NPR Spfy Entity Metafield"; xMetafieldID: Text[30]; Removed: Boolean)
    var
        Membership: Record "NPR MM Membership";
    begin
        if xMetafieldID <> '' then begin
            //Mapping changed from one metafield ID to another. Update the ID for stored values. No need to recalculate metafield values for all entities
            SpfyMetafieldMgt.UpdateMetafieldIDInExistingSpfyEntityMetafieldEntries(SpfyEntityMetafield, SpfyMetafieldMapping."Metafield ID");
            exit;
        end;

        Membership.SetCurrentKey("Customer No.");
        Membership.SetFilter("Customer No.", '<>%1', '');
        if Membership.IsEmpty() then
            exit;
        Membership.SetLoadFields("Customer No.");
        Membership.SetAutoCalcFields("Remaining Points");
        Membership.FindSet();
        repeat
            ProcessLoyaltyPointBalanceChange(Membership, '', Removed);
        until Membership.Next() = 0;
    end;

    local procedure ProcessLoyaltyPointBalanceChange(Membership: Record "NPR MM Membership"; ShopifyStoreCode: Code[20]; Removed: Boolean)
    var
        SpfyEntityMetafieldParam: Record "NPR Spfy Entity Metafield";
        SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping";
        SpfyStore: Record "NPR Spfy Store";
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SendCustomers: Codeunit "NPR Spfy Send Customers";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        ShopifyMetafieldValue: Text;
    begin
        SpfyMetafieldMgt.FilterMetafieldMapping(Database::"NPR Spfy Store", SpfyStore.FieldNo("Loyalty Points as Metafield"), ShopifyStoreCode, SpfyMetafieldMapping."Owner Type"::CUSTOMER, SpfyMetafieldMapping);
        if SpfyMetafieldMapping.IsEmpty() then
            exit;
        SpfyMetafieldMapping.FindSet();
        repeat
            if SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Loyalty Points", SpfyMetafieldMapping."Shopify Store Code") then begin
                if SendCustomers.GetStoreCustomerLink(Membership."Customer No.", SpfyMetafieldMapping."Shopify Store Code", false, SpfyStoreCustomerLink) then begin
                    if Removed then
                        ShopifyMetafieldValue := ''
                    else
                        ShopifyMetafieldValue := Format(Membership."Remaining Points", 0, 9);

                    SpfyEntityMetafieldParam."BC Record ID" := SpfyStoreCustomerLink.RecordId();
                    SpfyEntityMetafieldParam."Owner Type" := SpfyMetafieldMapping."Owner Type";
                    SpfyEntityMetafieldParam."Metafield ID" := SpfyMetafieldMapping."Metafield ID";
                    SpfyEntityMetafieldParam.SetMetafieldValue(ShopifyMetafieldValue);
                    SpfyMetafieldMgt.SetEntityMetafieldValue(SpfyEntityMetafieldParam, false, false);
                end;
            end;
        until SpfyMetafieldMapping.Next() = 0;
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR MM Membership Events", 'OnAfterMembershipPointsUpdate', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR MM Membership Events", OnAfterMembershipPointsUpdate, '', false, false)]
#endif
    local procedure RecalcItemCategoryMetafieldValueOnItemModify(MembershipEntryNo: Integer)
    var
        Membership: Record "NPR MM Membership";
    begin
        if MembershipEntryNo = 0 then
            exit;
        Membership.SetLoadFields("Customer No.");
        Membership.SetAutoCalcFields("Remaining Points");
        if not Membership.Get(MembershipEntryNo) then
            exit;
        ProcessLoyaltyPointBalanceChange(Membership, '', false);
    end;
}
#endif