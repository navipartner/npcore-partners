#if not BC17
codeunit 6248535 "NPR Spfy M/F Hdl.-Item Categ."
{
    Access = Internal;

    var
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";

    internal procedure InitStoreItemLinkMetafields(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link")
    var
        Item: Record Item;
    begin
        if SpfyStoreItemLink.Type = SpfyStoreItemLink.Type::Item then begin
            Item.SetLoadFields("Item Category Code");
            if Item.Get(SpfyStoreItemLink."Item No.") then
                ProcessItemCategoryChange(Item, SpfyStoreItemLink."Shopify Store Code", false);
        end;
    end;

    internal procedure ProcessMetafieldMappingChange(SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping"; var SpfyEntityMetafield: Record "NPR Spfy Entity Metafield"; xMetafieldID: Text[30]; Removed: Boolean)
    var
        SpfyStore: Record "NPR Spfy Store";
    begin
        if (SpfyMetafieldMapping."Table No." <> Database::"NPR Spfy Store") or
           (SpfyMetafieldMapping."Field No." <> SpfyStore.FieldNo("Item Category as Metafield"))
        then
            exit;
        ProcessItemCategoryMetafieldMappingChange(SpfyMetafieldMapping, SpfyEntityMetafield, xMetafieldID, Removed);
    end;

    internal procedure DoBCMetafieldUpdate(SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping"; SpfyEntityMetafieldParam: Record "NPR Spfy Entity Metafield"; ItemNo: Code[20]; var Updated: Boolean)
    begin
        if SpfyMetafieldMapping."Table No." <> Database::"NPR Spfy Store" then
            exit;
        SpfyMetafieldMgt.SetEntityMetafieldValue(SpfyEntityMetafieldParam, true, true);
        SetItemCategory(ItemNo, SpfyEntityMetafieldParam.GetMetafieldValue(false));
        Updated := true;
    end;

    local procedure ProcessItemCategoryMetafieldMappingChange(SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping"; var SpfyEntityMetafield: Record "NPR Spfy Entity Metafield"; xMetafieldID: Text[30]; Removed: Boolean)
    var
        Item: Record Item;
        ItemCategory: Record "Item Category";
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SpfyStoreItemCatLink: Record "NPR Spfy Store-Item Cat. Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        ShopifyAssignedID.SetRange("Table No.", Database::"NPR Spfy Store-Item Cat. Link");
        ShopifyAssignedID.SetRange("Shopify ID Type", "NPR Spfy ID Type"::"Entry ID");
        if not ShopifyAssignedID.IsEmpty() then begin
            ItemCategory.SetLoadFields(Code);
            if ItemCategory.FindSet() then
                repeat
                    SpfyStoreItemCatLink."Item Category Code" := ItemCategory.Code;
                    SpfyStoreItemCatLink."Shopify Store Code" := SpfyMetafieldMapping."Shopify Store Code";
                    SpfyAssignedIDMgt.RemoveAssignedShopifyID(SpfyStoreItemCatLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
                until ItemCategory.Next() = 0;
        end;

        Item.SetFilter("Item Category Code", '<>%1', '');
        if Item.IsEmpty() then begin
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

        Item.FindSet();
        repeat
            ProcessItemCategoryChange(Item, '', Removed);
        until Item.Next() = 0;
    end;

    local procedure ProcessItemCategoryChange(Item: Record Item; ShopifyStoreCode: Code[20]; Removed: Boolean)
    var
        SpfyEntityMetafieldParam: Record "NPR Spfy Entity Metafield";
        SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping";
        SpfyStore: Record "NPR Spfy Store";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SendItemAndInventory: Codeunit "NPR Spfy Send Items&Inventory";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        ShopifyMetafieldValue: Text;
    begin
        SpfyMetafieldMgt.FilterMetafieldMapping(Database::"NPR Spfy Store", SpfyStore.FieldNo("Item Category as Metafield"), ShopifyStoreCode, SpfyMetafieldMapping."Owner Type"::PRODUCT, SpfyMetafieldMapping);
        if SpfyMetafieldMapping.IsEmpty() then
            exit;
        SpfyMetafieldMapping.FindSet();
        repeat
            if SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Item Categories", SpfyMetafieldMapping."Shopify Store Code") then begin
                if SendItemAndInventory.GetStoreItemLink(Item."No.", SpfyMetafieldMapping."Shopify Store Code", false, SpfyStoreItemLink) then begin
                    if Removed then
                        ShopifyMetafieldValue := ''
                    else
                        GenerateItemCategoryMetafieldValueArray(Item."Item Category Code", SpfyMetafieldMapping."Shopify Store Code").WriteTo(ShopifyMetafieldValue);

                    SpfyEntityMetafieldParam."BC Record ID" := SpfyStoreItemLink.RecordId();
                    SpfyEntityMetafieldParam."Owner Type" := SpfyMetafieldMapping."Owner Type";
                    SpfyEntityMetafieldParam."Metafield ID" := SpfyMetafieldMapping."Metafield ID";
                    SpfyEntityMetafieldParam.SetMetafieldValue(ShopifyMetafieldValue);
                    SpfyMetafieldMgt.SetEntityMetafieldValue(SpfyEntityMetafieldParam, false, false);
                end;
            end;
        until SpfyMetafieldMapping.Next() = 0;
    end;

    local procedure SetItemCategory(ItemNo: Code[20]; NewSetOfCategoriesTxt: Text)
    begin
        //We have decided not to update the item category on the item card based on the data received from Shopify.
        //We might decide to do so later. This is the place to do it.
        //Adding the following lines for now to avoid the pipeline errors for unused parameters.
        if (ItemNo = '') and (NewSetOfCategoriesTxt = '') then
            exit;
    end;

    local procedure GenerateItemCategoryMetafieldValueArray(ItemCategoryCode: Code[20]; ShopifyStoreCode: Code[20]) ItemCategories: JsonArray
    var
        ItemCategory: Record "Item Category";
        SpfyStoreItemCatLink: Record "NPR Spfy Store-Item Cat. Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        AssignedID: Text[30];
        NoIDAssignedErr: Label 'No Shopify metaobject ID has been assigned to the item category %1 from Shopify store %2. Please ensure that the item category has been synchronized with the Shopify store.', Comment = '%1 - item category code, %2 - Shopify store code';
    begin
        ItemCategories.ReadFrom('[]');
        if ItemCategoryCode = '' then
            exit;
        if not ItemCategory.Get(ItemCategoryCode) then
            exit;
        repeat
            SpfyStoreItemCatLink."Item Category Code" := ItemCategory.Code;
            SpfyStoreItemCatLink."Shopify Store Code" := ShopifyStoreCode;
            AssignedID := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemCatLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
            If AssignedID = '' then
                AssignedID := UpsertItemCategoryMetaobject(ItemCategory, ShopifyStoreCode);
            If AssignedID = '' then
                Error(NoIDAssignedErr, ItemCategory.Code, ShopifyStoreCode);
            ItemCategories.Add(StrSubstNo('gid://shopify/Metaobject/%1', AssignedID));
            ItemCategory.Mark(true);  //prevent infinite loop
        until not ItemCategory.Get(ItemCategory."Parent Category") or ItemCategory.Mark();
    end;

    internal procedure GetItemCategoryMetafieldDefinitionID(ShopifyStoreCode: Code[20]; WithDialog: Boolean; var ItemCategoryMetafieldID: Text[30])
    var
        Window: Dialog;
        MetaobjectDefinitionGID: Text;
    begin
        if WithDialog then
            WithDialog := GuiAllowed();
        if WithDialog then
            Window.Open(SpfyMetafieldMgt.QueryingShopifyLbl());

        MetaobjectDefinitionGID := GetMetaobjectDefinitionGID(ShopifyStoreCode);
        SpfyMetafieldMgt.GetMetaobjectRelatedMetafieldDefinitionID(ShopifyStoreCode, MetaobjectDefinitionGID, ItemCategoryMetafieldID);
        if ItemCategoryMetafieldID = '' then
            ItemCategoryMetafieldID := SpfyMetafieldMgt.CreateMetafieldDefinition(ShopifyStoreCode, ItemCategoryShopifyMetafieldDefinitionCreateQuery(MetaobjectDefinitionGID));
        if WithDialog then
            Window.Close();
    end;

    local procedure GetMetaobjectDefinitionGID(ShopifyStoreCode: Code[20]): Text
    var
        MetaobjectDefinitionGID: Text;
    begin
        MetaobjectDefinitionGID := SpfyMetafieldMgt.GetMetaobjectDefinitionGID(ShopifyStoreCode, ItemCategoryShopifyMetaobjectDefinitionGetByTypeQuery());
        if MetaobjectDefinitionGID = '' then begin
            MetaobjectDefinitionGID := SpfyMetafieldMgt.CreateMetaobjectDefinition(ShopifyStoreCode, ItemCategoryShopifyMetaobjectDefinitionCreateQuery());
            SpfyMetafieldMgt.UpdateMetaobjectDefinition(ShopifyStoreCode, ItemCategoryShopifyMetaobjectDefinitionUpdateQuery(MetaobjectDefinitionGID));
        end;
        exit(MetaobjectDefinitionGID);
    end;

    local procedure ItemCategoryShopifyMetaobjectDefinitionGetByTypeQuery(): JsonObject
    var
        JsonBuilder: Codeunit "NPR Json Builder";
        QueryTok: Label 'query GetMetaobjectDefinition($type: String!){metaobjectDefinitionByType(type: $type){id}}', Locked = true;
    begin
        JsonBuilder.StartObject()
            .AddProperty('query', QueryTok)
            .StartObject('variables')
                .AddProperty('type', ItemCategoryShopifyMetaobjectType())
            .EndObject()
        .EndObject();

        exit(JsonBuilder.Build());
    end;

    local procedure ItemCategoryShopifyMetaobjectDefinitionCreateQuery(): JsonObject
    var
        JsonBuilder: Codeunit "NPR Json Builder";
        QueryTok: Label 'mutation CreateMetaobjectDefinition($definition: MetaobjectDefinitionCreateInput!) {metaobjectDefinitionCreate(definition: $definition) {metaobjectDefinition{id} userErrors {field message code}}}', Locked = true;
    begin
        JsonBuilder.StartObject()
            .AddProperty('query', QueryTok)
            .StartObject('variables')
                .StartObject('definition')
                    .AddProperty('name', 'BC Item Category')
                    .AddProperty('description', 'The item category from Business Central')
                    .AddProperty('type', ItemCategoryShopifyMetaobjectType())
                    .AddProperty('displayNameKey', 'name')
                    .StartObject('access')
                        .AddProperty('admin', 'MERCHANT_READ_WRITE')
                        .AddProperty('storefront', 'PUBLIC_READ')
                    .EndObject()
                    .StartObject('capabilities')
                        .StartObject('publishable')
                            .AddProperty('enabled', true)
                        .EndObject()
                        .StartObject('translatable')
                            .AddProperty('enabled', true)
                        .EndObject()
                    .EndObject()
                    .StartArray('fieldDefinitions')
                        .StartObject()
                            .AddProperty('key', 'category_id')
                            .AddProperty('name', 'UID')
                            .AddProperty('description', 'BC item category unique ID')
                            .AddProperty('type', 'single_line_text_field')
                            .AddProperty('required', true)
                        .EndObject()
                        .StartObject()
                            .AddProperty('key', 'name')
                            .AddProperty('name', 'Name')
                            .AddProperty('description', 'BC item category name')
                            .AddProperty('type', 'single_line_text_field')
                            .AddProperty('required', true)
                        .EndObject()
                        .StartObject()
                            .AddProperty('key', 'description')
                            .AddProperty('name', 'Description')
                            .AddProperty('description', 'BC item category detailed description')
                            .AddProperty('type', 'multi_line_text_field')
                            .AddProperty('required', false)
                        .EndObject()
                        .StartObject()
                            .AddProperty('key', 'position')
                            .AddProperty('name', 'Position')
                            .AddProperty('description', 'Position of the BC item category in the list')
                            .AddProperty('type', 'number_integer')
                            .AddProperty('required', true)
                            .StartArray('validations')
                                .StartObject()
                                    .AddProperty('name', 'min')
                                    .AddProperty('value', '1')
                                .EndObject()
                            .EndArray()
                        .EndObject()
                    .EndArray()
                .EndObject()
            .EndObject()
        .EndObject();

        exit(JsonBuilder.Build());
    end;

    local procedure ItemCategoryShopifyMetaobjectDefinitionUpdateQuery(MetaobjectDefinitionGID: Text): JsonObject
    var
        JsonBuilder: Codeunit "NPR Json Builder";
        QueryTok: Label 'mutation UpdateMetaobjectDefinition($id: ID!, $definition: MetaobjectDefinitionUpdateInput!) {metaobjectDefinitionUpdate(id: $id, definition : $definition) {metaobjectDefinition{id} userErrors {field message code}}}', Locked = true;
    begin
        JsonBuilder.StartObject()
            .AddProperty('query', QueryTok)
            .StartObject('variables')
                .AddProperty('id', MetaobjectDefinitionGID)
                .StartObject('definition')
                    .StartArray('fieldDefinitions')
                        .StartObject()
                            .StartObject('create')
                                .AddProperty('key', 'parent_id')
                                .AddProperty('name', 'Parent ID')
                                .AddProperty('description', 'ID of the parent BC item category')
                                .AddProperty('type', 'metaobject_reference')
                                .AddProperty('required', false)
                                .StartArray('validations')
                                    .StartObject()
                                        .AddProperty('name', 'metaobject_definition_id')
                                        .AddProperty('value', MetaobjectDefinitionGID)
                                    .EndObject()
                                .EndArray()
                            .EndObject()
                        .EndObject()
                    .EndArray()
                .EndObject()
            .EndObject()
        .EndObject();

        exit(JsonBuilder.Build());
    end;

    local procedure ItemCategoryShopifyMetafieldDefinitionCreateQuery(MetaobjectDefinitionGID: Text): JsonObject
    var
        JsonBuilder: Codeunit "NPR Json Builder";
        QueryTok: Label 'mutation CreateMetafieldDefinition($definition: MetafieldDefinitionInput!) {metafieldDefinitionCreate(definition: $definition) {createdDefinition {id name} userErrors {field message code}}}', Locked = true;
    begin
        JsonBuilder.StartObject()
            .AddProperty('query', QueryTok)
            .StartObject('variables')
                .StartObject('definition')
                    .AddProperty('name', 'BC Item Category')
                    .AddProperty('description', 'Item categories from Business Central')
                    .AddProperty('namespace', '$app')
                    .AddProperty('key', 'bc_item_category')
                    .AddProperty('type', SpfyMetafieldMgt.MetaobjectReferenceShopifyMetafieldType())
                    .AddProperty('ownerType', SpfyMetafieldMgt.OwnerTypeEnumValueName(Enum::"NPR Spfy Metafield Owner Type"::PRODUCT))
                    .AddProperty('pin', true)
                    .StartArray('validations')
                        .StartObject()
                            .AddProperty('name', 'metaobject_definition_id')
                            .AddProperty('value', MetaobjectDefinitionGID)
                        .EndObject()
                    .EndArray()
                    .StartObject('access')
                        .AddProperty('admin', 'MERCHANT_READ_WRITE')
                        .AddProperty('storefront', 'PUBLIC_READ')
                        .AddProperty('customerAccount', 'READ')
                    .EndObject()
                    .StartObject('capabilities')
                        .StartObject('smartCollectionCondition')
                            .AddProperty('enabled', true)
                        .EndObject()
                        .StartObject('adminFilterable')
                            .AddProperty('enabled', true)
                        .EndObject()
                    .EndObject()
                .EndObject()
            .EndObject()
        .EndObject();

        exit(JsonBuilder.Build());
    end;

    internal procedure SyncItemCategories(var ItemCategory: Record "Item Category"; var ShopifyStore: Record "NPR Spfy Store"; ResyncExisting: Boolean; Silent: Boolean)
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SyncedCategories: List of [Code[20]];
        Window: Dialog;
        RecNo: Integer;
        TotalRecNo: Integer;
        IntegrationNotEnabledMsg: Label 'Item category integration has not been enabled for Shopify store "%1". The sync process has been skipped for this store.', Comment = '%1 - Shopify store code';
        NothingToDoErr: Label 'The supplied filters do not include any item categories or Shopify stores.\Shopify store filters: %1.\Item category filters: %2.', Comment = '%1 - Shopify store table filters, %2 - Item category table filters';
        SuccessMsg: Label 'Item category synchronization completed successfully.\Shopify store filters: %1.\Item category filters: %2.', Comment = '%1 - Shopify store table filters, %2 - Item category table filters';
        WindowTxt01: Label 'Sending item categories to Shopify...\\';
        WindowTxt02: Label 'Shopify Store #1#######\';
        WindowTxt03: Label 'Progress      @2@@@@@@@';
    begin
        if ItemCategory.IsEmpty() or ShopifyStore.IsEmpty() then
            Error(NothingToDoErr, ShopifyStore.GetFilters(), ItemCategory.GetFilters());
        if not Silent then begin
            Window.Open(WindowTxt01 + WindowTxt02 + WindowTxt03);
            TotalRecNo := ItemCategory.Count();
        end;

        ShopifyStore.SetLoadFields(Code);
        ShopifyStore.FindSet();
        repeat
            if not Silent then begin
                Window.Update(1, ShopifyStore.Code);
                Window.Update(2, 0);
                RecNo := 0;
            end;

            if SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Item Categories", ShopifyStore.Code) then begin
                Clear(SyncedCategories);
                ItemCategory.FindSet();
                repeat
                    SyncItemCategory(ItemCategory, ShopifyStore.Code, ResyncExisting, 1, SyncedCategories);
                    Commit();
                    if not Silent then begin
                        RecNo += 1;
                        Window.Update(2, Round(RecNo / TotalRecNo * 10000, 1));
                    end;
                until ItemCategory.Next() = 0;
            end else
                if not Silent then
                    Message(IntegrationNotEnabledMsg, ShopifyStore.Code);
        until ShopifyStore.Next() = 0;

        if not Silent then begin
            Window.Close();
            Message(SuccessMsg, ShopifyStore.GetFilters(), ItemCategory.GetFilters());
        end;
    end;

    local procedure SyncItemCategory(ItemCategory: Record "Item Category"; ShopifyStoreCode: Code[20]; ResyncExisting: Boolean; CallLevel: Integer; var SyncedCategories: List of [Code[20]])
    var
        ParentItemCategory: Record "Item Category";
        SpfyStoreItemCatLink: Record "NPR Spfy Store-Item Cat. Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SyncRec: Boolean;
        PossibleCircularReferenceErr: Label 'The number of parent category levels reached 50 at the item category "%1". Further processing has been stopped due to a possible circular reference.', Comment = '%1 - Item category code';
    begin
        if SyncedCategories.Contains(ItemCategory.Code) then
            exit;
        SyncedCategories.Add(ItemCategory.Code);

        if ItemCategory."Parent Category" <> '' then begin
            if CallLevel >= 50 then
                Error(PossibleCircularReferenceErr, ItemCategory.Code);
            ParentItemCategory.Get(ItemCategory."Parent Category");
            SyncItemCategory(ParentItemCategory, ShopifyStoreCode, ResyncExisting, CallLevel + 1, SyncedCategories);
        end;

        SpfyStoreItemCatLink."Item Category Code" := ItemCategory.Code;
        SpfyStoreItemCatLink."Shopify Store Code" := ShopifyStoreCode;
        if not ResyncExisting then
            SyncRec := SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemCatLink.RecordId(), "NPR Spfy ID Type"::"Entry ID") = '';
        if SyncRec or ResyncExisting then
            UpsertItemCategoryMetaobject(ItemCategory, ShopifyStoreCode);
    end;

    local procedure UpsertItemCategoryMetaobject(ItemCategory: Record "Item Category"; ShopifyStoreCode: Code[20]) MetaobjectValueID: Text[30]
    var
        SpfyStoreItemCatLink: Record "NPR Spfy Store-Item Cat. Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        MetaobjectValueID := SpfyMetafieldMgt.UpsertMetaobject(ShopifyStoreCode, StrSubstNo('%1 "%2"', ItemCategory.TableCaption(), ItemCategory.Code), ItemCategoryShopifyMetaobjectUpsertQuery(ItemCategory, ShopifyStoreCode));

        SpfyStoreItemCatLink."Item Category Code" := ItemCategory.Code;
        SpfyStoreItemCatLink."Shopify Store Code" := ShopifyStoreCode;
        SpfyAssignedIDMgt.AssignShopifyID(SpfyStoreItemCatLink.RecordId(), "NPR Spfy ID Type"::"Entry ID", MetaobjectValueID, false);
    end;

    local procedure ItemCategoryShopifyMetaobjectUpsertQuery(ItemCategory: Record "Item Category"; ShopifyStoreCode: Code[20]): JsonObject
    var
        JsonBuilder: Codeunit "NPR Json Builder";
        QueryTok: Label 'mutation metaobjectUpsert($handle: MetaobjectHandleInput!, $metaobject: MetaobjectUpsertInput!) {metaobjectUpsert(handle: $handle, metaobject: $metaobject) {metaobject {id handle} userErrors {field message code}}}', Locked = true;
    begin
        if ItemCategory."Presentation Order" < 1 then
            ItemCategory."Presentation Order" := 1;

        JsonBuilder.StartObject()
            .AddProperty('query', QueryTok)
            .StartObject('variables')
                .StartObject('handle')
                    .AddProperty('type', ItemCategoryShopifyMetaobjectType())
                    .AddProperty('handle', CalculateItemCategoryHandle(ItemCategory))
                .EndObject()
                .StartObject('metaobject')
                    .StartArray('fields')
                        .StartObject()
                            .AddProperty('key', 'category_id')
                            .AddProperty('value', ItemCategory.Code)
                        .EndObject()
                        .StartObject()
                            .AddProperty('key', 'name')
                            .AddProperty('value', StrSubstNo('%1:%2', ItemCategory.Code, ItemCategory.Description))
                        .EndObject()
                        .StartObject()
                            .AddProperty('key', 'description')
                            .AddProperty('value', ItemCategory.Description)
                        .EndObject()
                        .StartObject()
                            .AddProperty('key', 'position')
                            .AddProperty('value', Format(ItemCategory."Presentation Order", 0, 9))
                        .EndObject()
                        .StartObject()
                            .AddProperty('key', 'parent_id')
                            .AddProperty('value', ItemCategory.NPRGetSpfyParentGID(ShopifyStoreCode))
                        .EndObject()
                    .EndArray()
                    .StartObject('capabilities')
                        .StartObject('publishable')
                            .AddProperty('status', 'ACTIVE')
                        .EndObject()
                    .EndObject()
                .EndObject()
            .EndObject()
        .EndObject();

        exit(JsonBuilder.Build());
    end;

    local procedure CalculateItemCategoryHandle(ItemCategory: Record "Item Category") Handle: Text
    begin
        Handle := '';
        if ItemCategory.Code = '' then
            exit;
        repeat
            if ItemCategory."NPR Spfy Handle" = '' then begin
                ItemCategory."NPR Spfy Handle" := LowerCase(ItemCategory.Code);
                ItemCategory.Modify(true);
            end;
            if Handle <> '' then
                Handle := '-' + Handle;
            Handle := ItemCategory."NPR Spfy Handle" + Handle;
            ItemCategory.Mark(true);  //prevent infinite loop
        until not ItemCategory.Get(ItemCategory."Parent Category") or ItemCategory.Mark();
    end;

    local procedure ItemCategoryShopifyMetaobjectType(): Text
    begin
        exit('$app:bc-item-category');
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeModifyEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::Item, OnBeforeModifyEvent, '', false, false)]
#endif
    local procedure RefreshxRec(var Rec: Record Item; var xRec: Record Item)
    begin
        if Rec.IsTemporary() then
            exit;

#if not (BC18 or BC19 or BC20 or BC21)
        xRec.ReadIsolation := IsolationLevel::ReadCommitted;
#endif
        if not xRec.Find() then
            Clear(xRec);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterModifyEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::Item, OnAfterModifyEvent, '', false, false)]
#endif
    local procedure RecalcItemCategoryMetafieldValueOnItemModify(var Rec: Record Item; var xRec: Record Item; RunTrigger: Boolean)
    var
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
    begin
        if Rec.IsTemporary() then
            exit;
        if Rec."Item Category Code" = xRec."Item Category Code" then
            exit;
        SpfyStoreItemLink.SetRange(Type, SpfyStoreItemLink.Type::Item);
        SpfyStoreItemLink.SetRange("Item No.", Rec."No.");
        if not SpfyStoreItemLink.FindSet() then
            exit;
        repeat
            ProcessItemCategoryChange(Rec, SpfyStoreItemLink."Shopify Store Code", Rec."Item Category Code" = '');
        until SpfyStoreItemLink.Next() = 0;
    end;
}
#endif