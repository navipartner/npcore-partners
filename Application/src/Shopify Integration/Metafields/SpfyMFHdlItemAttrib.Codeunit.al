#if not BC17
codeunit 6248508 "NPR Spfy M/F Hdl.-Item Attrib."
{
    Access = Internal;

    var
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";

    internal procedure InitStoreItemLinkMetafields(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link")
    var
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
    begin
        ItemAttributeValueMapping.SetRange("Table ID", Database::Item);
        ItemAttributeValueMapping.SetRange("No.", SpfyStoreItemLink."Item No.");
        if ItemAttributeValueMapping.FindSet() then
            repeat
                ProcessItemAttributeValueChange(ItemAttributeValueMapping, SpfyStoreItemLink."Shopify Store Code", false);
            until ItemAttributeValueMapping.Next() = 0;
    end;

    internal procedure ProcessMetafieldMappingChange(SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping"; var SpfyEntityMetafield: Record "NPR Spfy Entity Metafield"; xMetafieldID: Text[30]; Removed: Boolean)
    begin
        if SpfyMetafieldMapping."Table No." <> Database::"Item Attribute" then
            exit;
        ProcessItemAttributeMetafieldMappingChange(SpfyMetafieldMapping, SpfyEntityMetafield, xMetafieldID, Removed);
    end;

    internal procedure DoBCMetafieldUpdate(SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping"; SpfyEntityMetafieldParam: Record "NPR Spfy Entity Metafield"; ItemNo: Code[20]; var Updated: Boolean)
    var
        ItemAttribute: Record "Item Attribute";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        if (SpfyMetafieldMapping."Table No." <> Database::"Item Attribute") or (ItemNo = '') then
            exit;
        if not ItemAttribute.Get(SpfyMetafieldMapping."BC Record ID") then
            exit;
        SpfyMetafieldMgt.SetEntityMetafieldValue(SpfyEntityMetafieldParam, true, true);
        SetItemAttributeValue(ItemAttribute, ItemNo, SpfyIntegrationMgt.GetLanguageCode(SpfyMetafieldMapping."Shopify Store Code"), SpfyEntityMetafieldParam.GetMetafieldValue(false));
        Updated := true;
    end;

    local procedure ProcessItemAttributeMetafieldMappingChange(SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping"; var SpfyEntityMetafield: Record "NPR Spfy Entity Metafield"; xMetafieldID: Text[30]; Removed: Boolean)
    var
        ItemAttribute: Record "Item Attribute";
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
    begin
        ItemAttribute.Get(SpfyMetafieldMapping."BC Record ID");
        ItemAttributeValueMapping.SetRange("Table ID", Database::Item);
        ItemAttributeValueMapping.SetRange("Item Attribute ID", ItemAttribute.ID);
        if ItemAttributeValueMapping.IsEmpty() then begin
            if xMetafieldID <> '' then
                if not SpfyEntityMetafield.IsEmpty() then
                    SpfyEntityMetafield.DeleteAll();
            exit;
        end;

        if xMetafieldID <> '' then begin
            //Mapping changed from one metafield ID to another. Update the ID for stored values. No need to recalculate metafield values for all entities
            SpfyMetafieldMgt.UpdateMetafieldIDInExistingSpfyEntityMetafieldEntries(SpfyEntityMetafield, SpfyMetafieldMapping."Metafield ID");
            exit;
        end;

        ItemAttributeValueMapping.FindSet();
        repeat
            ProcessItemAttributeValueChange(ItemAttributeValueMapping, '', Removed);
        until ItemAttributeValueMapping.Next() = 0;
    end;

    local procedure ProcessItemAttributeValueChange(ItemAttributeValueMapping: Record "Item Attribute Value Mapping"; ShopifyStoreCode: Code[20]; Removed: Boolean)
    var
        ItemAttribute: Record "Item Attribute";
        ItemAttributeValue: Record "Item Attribute Value";
        SpfyEntityMetafieldParam: Record "NPR Spfy Entity Metafield";
        SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SendItemAndInventory: Codeunit "NPR Spfy Send Items&Inventory";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        ShopifyMetafieldValue: Text;
        ValueAsInteger: Integer;
    begin
        if not (ItemAttributeValueMapping."Table ID" in [Database::Item]) then
            exit;
        ItemAttribute.ID := ItemAttributeValueMapping."Item Attribute ID";
        SpfyMetafieldMgt.FilterMetafieldMapping(ItemAttribute.RecordId(), 0, ShopifyStoreCode, SpfyMetafieldMapping."Owner Type"::" ", SpfyMetafieldMapping);
        if SpfyMetafieldMapping.IsEmpty() then
            exit;
        ItemAttribute.Find();
        SpfyMetafieldMapping.FindSet();
        repeat
            if SendItemAndInventory.GetStoreItemLink(ItemAttributeValueMapping."No.", SpfyMetafieldMapping."Shopify Store Code", false, SpfyStoreItemLink) then begin
                if Removed or (ItemAttributeValueMapping."Item Attribute Value ID" = 0) then
                    ShopifyMetafieldValue := ''
                else begin
                    ItemAttributeValue.Get(ItemAttributeValueMapping."Item Attribute ID", ItemAttributeValueMapping."Item Attribute Value ID");
                    case ItemAttribute.Type of
                        ItemAttribute.Type::Date:
                            ShopifyMetafieldValue := Format(ItemAttributeValue."Date Value", 0, 9);
                        ItemAttribute.Type::Decimal:
                            if ItemAttributeValue.Value <> '' then
                                ShopifyMetafieldValue := Format(ItemAttributeValue."Numeric Value", 0, 9);
                        ItemAttribute.Type::Integer:
                            if ItemAttributeValue.Value <> '' then
                                if Evaluate(ValueAsInteger, ItemAttributeValue.Value) then
                                    ShopifyMetafieldValue := Format(ValueAsInteger, 0, 9);
                        else
                            ShopifyMetafieldValue := ItemAttributeValue.GetTranslatedNameByLanguageCode(SpfyIntegrationMgt.GetLanguageCode(SpfyStoreItemLink."Shopify Store Code"));
                    end;
                    if ShopifyMetafieldValue = '' then
                        ShopifyMetafieldValue := ItemAttributeValue.Value;
                end;

                SpfyEntityMetafieldParam."BC Record ID" := SpfyStoreItemLink.RecordId();
                SpfyEntityMetafieldParam."Owner Type" := SpfyMetafieldMapping."Owner Type";
                SpfyEntityMetafieldParam."Metafield ID" := SpfyMetafieldMapping."Metafield ID";
                SpfyEntityMetafieldParam.SetMetafieldValue(ShopifyMetafieldValue);
                SpfyMetafieldMgt.SetEntityMetafieldValue(SpfyEntityMetafieldParam, false, false);
            end;
        until SpfyMetafieldMapping.Next() = 0;
    end;

    local procedure SetItemAttributeValue(ItemAttribute: Record "Item Attribute"; ItemNo: Code[20]; LanguageCode: Code[10]; NewAttributeValueTxt: Text)
    var
        ItemAttributeValue: Record "Item Attribute Value";
        xItemAttributeValue: Record "Item Attribute Value";
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
        ItemAttrValueTranslation: Record "Item Attr. Value Translation";
        TempItemAttributeValueSelection: Record "Item Attribute Value Selection" temporary;
        IntegerValue: Integer;
        DecimalValue: Decimal;
        DateValue: Date;
        NewAttributeValueFilter: Text;
        ItemAttribValueFound: Boolean;
        xItemAttribValueFound: Boolean;
        ItemAttribValueMappingExists: Boolean;
    begin
        ItemAttributeValueMapping."Table ID" := Database::Item;
        ItemAttributeValueMapping."No." := ItemNo;
        ItemAttributeValueMapping."Item Attribute ID" := ItemAttribute.ID;
        ItemAttribValueMappingExists := ItemAttributeValueMapping.Find();
        if ItemAttribValueMappingExists then begin
            xItemAttribValueFound := xItemAttributeValue.Get(ItemAttributeValueMapping."Item Attribute ID", ItemAttributeValueMapping."Item Attribute Value ID");
        end else begin
            if NewAttributeValueTxt = '' then
                exit;
            ItemAttributeValueMapping.Init();
        end;

        if NewAttributeValueTxt <> '' then begin
            TempItemAttributeValueSelection."Attribute ID" := ItemAttribute.ID;
            TempItemAttributeValueSelection."Attribute Name" := ItemAttribute.Name;
            TempItemAttributeValueSelection."Attribute Type" := ItemAttribute.Type;
            TempItemAttributeValueSelection."Unit of Measure" := ItemAttribute."Unit of Measure";
            TempItemAttributeValueSelection."Inherited-From Table ID" := Database::Item;
            TempItemAttributeValueSelection."Inherited-From Key Value" := ItemNo;

#if not (BC18 or BC19 or BC20 or BC21)
            ItemAttributeValue.ReadIsolation := IsolationLevel::ReadUncommitted;
#endif
            case ItemAttribute.Type of
                ItemAttribute.Type::Date:
                    if Evaluate(DateValue, NewAttributeValueTxt, 9) then begin
                        NewAttributeValueTxt := Format(DateValue);
                        ItemAttributeValue.SetRange("Attribute ID", ItemAttribute.ID);
                        ItemAttributeValue.SetRange("Date Value", DateValue);
                        ItemAttribValueFound := ItemAttributeValue.FindFirst();
                    end else
                        NewAttributeValueTxt := '';
                ItemAttribute.Type::Decimal:
                    if Evaluate(DecimalValue, NewAttributeValueTxt, 9) then begin
                        NewAttributeValueTxt := Format(DecimalValue);
                        ItemAttributeValue.SetRange("Attribute ID", ItemAttribute.ID);
                        ItemAttributeValue.SetRange("Numeric Value", DecimalValue);
                        ItemAttribValueFound := ItemAttributeValue.FindFirst();
                    end else
                        NewAttributeValueTxt := '';
                ItemAttribute.Type::Integer:
                    if Evaluate(IntegerValue, NewAttributeValueTxt, 9) then begin
                        NewAttributeValueTxt := Format(IntegerValue);
                        ItemAttributeValue.SetRange("Attribute ID", ItemAttribute.ID);
                        ItemAttributeValue.SetRange("Numeric Value", DecimalValue);
                        ItemAttribValueFound := ItemAttributeValue.FindFirst();
                    end else
                        NewAttributeValueTxt := '';
                else begin
                    NewAttributeValueFilter := NewAttributeValueTxt.Replace('''', '?');
#if not (BC18 or BC19 or BC20 or BC21)
                    ItemAttrValueTranslation.ReadIsolation := IsolationLevel::ReadUncommitted;
#endif
                    ItemAttrValueTranslation.SetRange("Attribute ID", ItemAttribute.ID);
                    ItemAttrValueTranslation.SetRange("Language Code", LanguageCode);
                    ItemAttrValueTranslation.SetFilter(Name, StrSubstNo('''%1''', NewAttributeValueFilter));
                    if ItemAttrValueTranslation.IsEmpty() then
                        ItemAttrValueTranslation.SetFilter(Name, StrSubstNo('''@%1''', NewAttributeValueFilter));
                    if ItemAttrValueTranslation.FindFirst() then
                        ItemAttribValueFound := ItemAttributeValue.Get(ItemAttrValueTranslation."Attribute ID", ItemAttrValueTranslation.ID)
                    else begin
                        ItemAttributeValue.SetRange("Attribute ID", ItemAttribute.ID);
                        ItemAttributeValue.SetFilter(Value, StrSubstNo('''%1''', NewAttributeValueFilter));
                        if ItemAttributeValue.IsEmpty() then
                            ItemAttributeValue.SetFilter(Value, StrSubstNo('''@%1''', NewAttributeValueFilter));
                        ItemAttribValueFound := ItemAttributeValue.FindFirst();
                    end;
                end;
            end;
        end;
        if not ItemAttribValueFound then begin
            if NewAttributeValueTxt = '' then begin
                if ItemAttribValueMappingExists then begin
                    ItemAttributeValueMapping.Delete();
                    if xItemAttribValueFound then
                        if not xItemAttributeValue.HasBeenUsed() then
                            xItemAttributeValue.Delete();
                end;
                exit;
            end;
            TempItemAttributeValueSelection.Value := CopyStr(NewAttributeValueTxt, 1, MaxStrLen(TempItemAttributeValueSelection.Value));
            if not TempItemAttributeValueSelection.FindAttributeValue(ItemAttributeValue) then
                TempItemAttributeValueSelection.InsertItemAttributeValue(ItemAttributeValue, TempItemAttributeValueSelection);
        end;
        if ItemAttribValueMappingExists and (ItemAttributeValueMapping."Item Attribute Value ID" = ItemAttributeValue.ID) then
            exit;
        ItemAttributeValueMapping."Item Attribute Value ID" := ItemAttributeValue.ID;
        if not ItemAttribValueMappingExists then
            ItemAttributeValueMapping.Insert()
        else
            ItemAttributeValueMapping.Modify();
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"Item Attribute Value Mapping", 'OnAfterInsertEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"Item Attribute Value Mapping", OnAfterInsertEvent, '', false, false)]
#endif
    local procedure ShopifyMatafieldSyncOnItemAttributeMappingAssign(var Rec: Record "Item Attribute Value Mapping"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;
        ProcessItemAttributeValueChange(Rec, '', false);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"Item Attribute Value Mapping", 'OnAfterModifyEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"Item Attribute Value Mapping", OnAfterModifyEvent, '', false, false)]
#endif
    local procedure ShopifyMatafieldSyncOnItemAttributeMappingChange(var Rec: Record "Item Attribute Value Mapping"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;
        ProcessItemAttributeValueChange(Rec, '', false);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"Item Attribute Value Mapping", 'OnAfterDeleteEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"Item Attribute Value Mapping", OnAfterDeleteEvent, '', false, false)]
#endif
    local procedure ShopifyMatafieldSyncOnItemAttributeMappingRemove(var Rec: Record "Item Attribute Value Mapping"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;
        ProcessItemAttributeValueChange(Rec, '', true);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"Item Attribute", 'OnAfterDeleteEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"Item Attribute", OnAfterDeleteEvent, '', false, false)]
#endif
    local procedure DeleteMetafieldMappings(var Rec: Record "Item Attribute"; RunTrigger: Boolean)
    var
        SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping";
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;

        SpfyMetafieldMapping.SetRange("Table No.", Database::"Item Attribute");
        SpfyMetafieldMapping.SetRange("BC Record ID", Rec.RecordId());
        if not SpfyMetafieldMapping.IsEmpty() then
            SpfyMetafieldMapping.DeleteAll(true);
    end;
}
#endif