#if not BC17
codeunit 6248536 "NPR Spfy M/F Hdl.-Clnt Attrib."
{
    Access = Internal;

    var
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";

    internal procedure InitStoreCustomerLinkMetafields(SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link")
    var
        Membership: Record "NPR MM Membership";
        NPRAttributeKey: Record "NPR Attribute Key";
        NPRAttributeValueSet: Record "NPR Attribute Value Set";
    begin
        if SpfyStoreCustomerLink.Type <> SpfyStoreCustomerLink.Type::Customer then
            exit;

        Membership.SetRange("Customer No.", SpfyStoreCustomerLink."No.");
        Membership.SetRange(Blocked, false);
        Membership.SetLoadFields("Entry No.");
        if not Membership.FindFirst() then
            exit;

        NPRAttributeKey.SetCurrentKey("Table ID", "MDR Code PK");
        NPRAttributeKey.SetRange("Table ID", Database::"NPR MM Membership");
        NPRAttributeKey.SetRange("MDR Code PK", Format(Membership."Entry No.", 9));
        if NPRAttributeKey.FindSet() then
            repeat
                NPRAttributeValueSet.SetRange("Attribute Set ID", NPRAttributeKey."Attribute Set ID");
                NPRAttributeValueSet.SetFilter("Attribute Code", '<>%1', '');
                if NPRAttributeValueSet.FindSet() then
                    repeat
                        ProcessClientAttributeValueChange(NPRAttributeValueSet, SpfyStoreCustomerLink."No.", SpfyStoreCustomerLink."Shopify Store Code", false);
                    until NPRAttributeValueSet.Next() = 0;
            until NPRAttributeKey.Next() = 0;
    end;

    internal procedure ProcessMetafieldMappingChange(SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping"; var SpfyEntityMetafield: Record "NPR Spfy Entity Metafield"; xMetafieldID: Text[30]; Removed: Boolean)
    begin
        if SpfyMetafieldMapping."Table No." <> Database::"NPR Attribute" then
            exit;
        ProcessClientAttributeMetafieldMappingChange(SpfyMetafieldMapping, SpfyEntityMetafield, xMetafieldID, Removed);
    end;

    internal procedure DoBCMetafieldUpdate(SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping"; SpfyEntityMetafieldParam: Record "NPR Spfy Entity Metafield"; CustomerNo: Code[20]; var Updated: Boolean)
    var
        NPRAttribute: Record "NPR Attribute";
    begin
        if (SpfyMetafieldMapping."Table No." <> Database::"NPR Attribute") or (CustomerNo = '') then
            exit;
        if not NPRAttribute.Get(SpfyMetafieldMapping."BC Record ID") then
            exit;
        SpfyMetafieldMgt.SetEntityMetafieldValue(SpfyEntityMetafieldParam, true, true);
        SetClientAttributeValue(NPRAttribute, CustomerNo, SpfyEntityMetafieldParam.GetMetafieldValue(false));
        Updated := true;
    end;

    local procedure ProcessClientAttributeMetafieldMappingChange(SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping"; var SpfyEntityMetafield: Record "NPR Spfy Entity Metafield"; xMetafieldID: Text[30]; Removed: Boolean)
    var
        Membership: Record "NPR MM Membership";
        NPRAttribute: Record "NPR Attribute";
        NPRAttributeValueSet: Record "NPR Attribute Value Set";
        AttributeCodeWhereUsed: Query "NPR Attribute Code Where-Used";
        RecRef: RecordRef;
        MembershipEntryNo: Integer;
    begin
        RecRef := SpfyMetafieldMapping."BC Record ID".GetRecord();
        RecRef.SetTable(NPRAttribute);

        AttributeCodeWhereUsed.SetRange(AttributeCode, NPRAttribute.Code);
        AttributeCodeWhereUsed.SetRange(TableID, Database::"NPR MM Membership");
        AttributeCodeWhereUsed.TopNumberOfRows(1);
        if not (AttributeCodeWhereUsed.Open() and AttributeCodeWhereUsed.Read()) then begin
            if xMetafieldID <> '' then
                if not SpfyEntityMetafield.IsEmpty() then
                    SpfyEntityMetafield.DeleteAll();
            exit;
        end;
        AttributeCodeWhereUsed.Close();

        if xMetafieldID <> '' then begin
            //Mapping changed from one metafield ID to another. Update the ID for stored values. No need to recalculate metafield values for all entities
            SpfyMetafieldMgt.UpdateMetafieldIDInExistingSpfyEntityMetafieldEntries(SpfyEntityMetafield, SpfyMetafieldMapping."Metafield ID");
            exit;
        end;

        AttributeCodeWhereUsed.SetRange(AttributeCode, NPRAttribute.Code);
        AttributeCodeWhereUsed.SetRange(TableID, Database::"NPR MM Membership");
        AttributeCodeWhereUsed.TopNumberOfRows(0);
        AttributeCodeWhereUsed.Open();
        while AttributeCodeWhereUsed.Read() do
            if Evaluate(MembershipEntryNo, AttributeCodeWhereUsed.MDRCodePK, 9) then
                if Membership.Get(MembershipEntryNo) and (Membership."Customer No." <> '') then begin
                    NPRAttributeValueSet."Attribute Set ID" := AttributeCodeWhereUsed.AttributeSetID;
                    NPRAttributeValueSet."Attribute Code" := AttributeCodeWhereUsed.AttributeCode;
                    NPRAttributeValueSet."Text Value" := AttributeCodeWhereUsed.TextValue;
                    ProcessClientAttributeValueChange(NPRAttributeValueSet, Membership."Customer No.", '', Removed);
                end;
    end;

    local procedure ProcessClientAttributeValueChange(NPRAttributeValueSet: Record "NPR Attribute Value Set"; ShopifyStoreCode: Code[20]; Removed: Boolean)
    var
        Membership: Record "NPR MM Membership";
        NPRAttributeKey: Record "NPR Attribute Key";
        MembershipEntryNo: Integer;
    begin
        if not NPRAttributeKey.Get(NPRAttributeValueSet."Attribute Set ID") or (NPRAttributeKey."Table ID" <> Database::"NPR MM Membership") then
            exit;
        if not Evaluate(MembershipEntryNo, NPRAttributeKey."MDR Code PK", 9) then
            exit;
        if not Membership.Get(MembershipEntryNo) or (Membership."Customer No." = '') then
            exit;
        ProcessClientAttributeValueChange(NPRAttributeValueSet, Membership."Customer No.", ShopifyStoreCode, Removed);
    end;

    local procedure ProcessClientAttributeValueChange(NPRAttributeValueSet: Record "NPR Attribute Value Set"; CustomerNo: Code[20]; ShopifyStoreCode: Code[20]; Removed: Boolean)
    var
        NPRAttribute: Record "NPR Attribute";
        SpfyEntityMetafieldParam: Record "NPR Spfy Entity Metafield";
        SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping";
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfySendCustomer: Codeunit "NPR Spfy Send Customers";
        ShopifyMetafieldValue: Text;
    begin
        NPRAttribute.Code := NPRAttributeValueSet."Attribute Code";
        SpfyMetafieldMgt.FilterMetafieldMapping(NPRAttribute.RecordId(), 0, ShopifyStoreCode, SpfyMetafieldMapping."Owner Type"::CUSTOMER, SpfyMetafieldMapping);
        if SpfyMetafieldMapping.IsEmpty() then
            exit;
        SpfyMetafieldMapping.FindSet();
        repeat
            if SpfySendCustomer.GetStoreCustomerLink(CustomerNo, SpfyMetafieldMapping."Shopify Store Code", false, SpfyStoreCustomerLink) then begin
                if Removed or (NPRAttributeValueSet."Text Value" = '') then
                    ShopifyMetafieldValue := ''
                else
                    ShopifyMetafieldValue := NPRAttributeValueSet."Text Value";

                SpfyEntityMetafieldParam."BC Record ID" := SpfyStoreCustomerLink.RecordId();
                SpfyEntityMetafieldParam."Owner Type" := SpfyMetafieldMapping."Owner Type";
                SpfyEntityMetafieldParam."Metafield ID" := SpfyMetafieldMapping."Metafield ID";
                SpfyEntityMetafieldParam.SetMetafieldValue(ShopifyMetafieldValue);
                SpfyMetafieldMgt.SetEntityMetafieldValue(SpfyEntityMetafieldParam, false, false);
            end;
        until SpfyMetafieldMapping.Next() = 0;
    end;

    local procedure SetClientAttributeValue(NPRAttribute: Record "NPR Attribute"; CustomerNo: Code[20]; NewAttributeValueTxt: Text)
    var
        Membership: Record "NPR MM Membership";
        NPRAttributeKey: Record "NPR Attribute Key";
    begin
        Membership.SetRange("Customer No.", CustomerNo);
        Membership.SetRange(Blocked, false);
        Membership.SetLoadFields("Entry No.");
        if not Membership.FindFirst() then
            exit;

        NPRAttributeKey.SetCurrentKey("Table ID", "MDR Code PK");
        NPRAttributeKey.SetRange("Table ID", Database::"NPR MM Membership");
        NPRAttributeKey.SetRange("MDR Code PK", Format(Membership."Entry No.", 9));
        if NPRAttributeKey.FindSet() then
            repeat
                SetMembershipClientAttributeValue(Membership."Entry No.", NPRAttributeKey."Attribute Set ID", NPRAttribute.Code, CopyStr(NewAttributeValueTxt, 1, 250));
            until NPRAttributeKey.Next() = 0;
    end;

    local procedure SetMembershipClientAttributeValue(MembershipEntryNo: Integer; AttributeSetID: Integer; AttributeCode: Code[20]; NewAttributeValueTxt: Text[250])
    var
        NPRAttributeID: Record "NPR Attribute ID";
        NPRAttributeValueSet: Record "NPR Attribute Value Set";
        NPRAttrManagement: Codeunit "NPR Attribute Management";
    begin
        if NewAttributeValueTxt = '' then begin
            NPRAttributeValueSet."Attribute Set ID" := AttributeSetID;
            NPRAttributeValueSet."Attribute Code" := AttributeCode;
            if NPRAttributeValueSet.Find() then
                NPRAttributeValueSet.Delete(true)
            else
                exit;
        end;

        if NPRAttributeID.Get(Database::"NPR MM Membership", AttributeCode) then
            NPRAttrManagement.SetEntryAttributeValue(NPRAttributeID."Table ID", NPRAttributeID."Shortcut Attribute ID", MembershipEntryNo, NewAttributeValueTxt);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR Attribute Value Set", 'OnAfterInsertEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR Attribute Value Set", OnAfterInsertEvent, '', false, false)]
#endif
    local procedure ShopifyMatafieldSyncOnClientAttributeMappingAssign(var Rec: Record "NPR Attribute Value Set"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;
        ProcessClientAttributeValueChange(Rec, '', false);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR Attribute Value Set", 'OnAfterModifyEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR Attribute Value Set", OnAfterModifyEvent, '', false, false)]
#endif
    local procedure ShopifyMatafieldSyncOnClientAttributeMappingChange(var Rec: Record "NPR Attribute Value Set"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;
        ProcessClientAttributeValueChange(Rec, '', false);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR Attribute Value Set", 'OnAfterDeleteEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR Attribute Value Set", OnAfterDeleteEvent, '', false, false)]
#endif
    local procedure ShopifyMatafieldSyncOnClientAttributeMappingRemove(var Rec: Record "NPR Attribute Value Set"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;
        ProcessClientAttributeValueChange(Rec, '', true);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR Attribute", 'OnAfterDeleteEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR Attribute", OnAfterDeleteEvent, '', false, false)]
#endif
    local procedure DeleteMetafieldMappings(var Rec: Record "NPR Attribute"; RunTrigger: Boolean)
    var
        SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping";
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;

        SpfyMetafieldMapping.SetRange("Table No.", Database::"NPR Attribute");
        SpfyMetafieldMapping.SetRange("BC Record ID", Rec.RecordId());
        if not SpfyMetafieldMapping.IsEmpty() then
            SpfyMetafieldMapping.DeleteAll(true);
    end;
}
#endif