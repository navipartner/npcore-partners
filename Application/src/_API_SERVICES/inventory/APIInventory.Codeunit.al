#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248290 "NPR API Inventory" implements "NPR API Request Handler"
{
    Access = Internal;

    procedure Handle(var Request: Codeunit "NPR API Request"): Codeunit "NPR API Response"
    begin
        case true of
            Request.Match('GET', '/inventory/item/:id'):
                exit(GetItem(Request));
            Request.Match('GET', '/inventory/item'):
                exit(ListItems(Request));
            Request.Match('GET', '/inventory/itemledgerentry'):
                exit(GetItemLedgerEntry(Request));
            Request.Match('GET', '/inventory/itemvariant'):
                exit(GetItemVariant(Request));
            Request.Match('GET', '/inventory/itemcategory'):
                exit(GetItemCategory(Request));
            Request.Match('GET', '/inventory/barcode'):
                exit(GetBarcode(Request));
            Request.Match('GET', '/inventory/itemtranslation'):
                exit(GetTranslation(Request));
            Request.Match('GET', '/inventory/variety'):
                exit(GetVariety(Request));
            Request.Match('GET', '/inventory/varietytable'):
                exit(GetVarietyTable(Request));
            Request.Match('GET', '/inventory/varietyvalue'):
                exit(GetVarietyValue(Request));
        end;
    end;

    procedure GetItem(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Item: Record Item;
        EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
        JsonBuilder: Codeunit "NPR Json Builder";
        ItemId: Text;
        WithAttributes: Boolean;
        WithVariants: Boolean;
        EntriaEnabled: Boolean;
    begin
        ItemId := Request.Paths().Get(3);
        Item.ReadIsolation := IsolationLevel::ReadCommitted;
        Item.SetAutoCalcFields(Inventory, "NPR Has Variants");
        if not Item.GetBySystemId(ItemId) then
            exit(Response.RespondResourceNotFound());

        if (Request.QueryParams().ContainsKey('withAttributes')) then
            WithAttributes := (Request.QueryParams().Get('withAttributes').ToLower() = 'true');

        if (Request.QueryParams().ContainsKey('withVariants')) then
            WithVariants := (Request.QueryParams().Get('withVariants').ToLower() = 'true');

        EntriaEnabled := EntriaIntegrationMgt.HasEnabledStore();
        exit(Response.RespondOK(ItemToJson(JsonBuilder, Item, WithAttributes, WithVariants, true, EntriaEnabled).Build()));
    end;

    procedure ListItems(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Item: Record "Item";
        EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
        RecRef: RecordRef;
        JsonBuilder: Codeunit "NPR Json Builder";
        Parameters: Dictionary of [Text, Text];
        JsonObject: JsonObject;
        PageKey: Text;
        Limit: Integer;
        EntryCount: Integer;
        PageContinuation: Boolean;
        DataFound: Boolean;
        MoreRecords: Boolean;
        WithAttributes: Boolean;
        WithVariants: Boolean;
        Sync: Boolean;
        EntriaEnabled: Boolean;
        WithVariantsSyncErr: Label 'withVariants cannot be combined with sync=true. Use /inventory/itemvariant with sync=true to keep variants up to date.', Locked = true;
    begin
        Parameters := Request.QueryParams();

        if (Parameters.ContainsKey('withAttributes')) then
            WithAttributes := (Parameters.Get('withAttributes').ToLower() = 'true');

        if (Parameters.ContainsKey('withVariants')) then
            WithVariants := (Parameters.Get('withVariants').ToLower() = 'true');

        if Parameters.ContainsKey('itemCode') then
            Item.SetRange("No.", Parameters.Get('itemCode'));

        RecRef.GetTable(Item);

        if (Parameters.ContainsKey('pageSize')) then
            Evaluate(Limit, Parameters.Get('pageSize'));
        if WithVariants then begin
            if (Limit < 1) or (Limit > 1000) then
                Limit := 1000;
        end else
            if (Limit < 1) or (Limit > 20000) then
                Limit := 20000;

        if (Parameters.ContainsKey('pageKey')) then begin
            Request.ApplyPageKey(Parameters.Get('pageKey'), RecRef);
            PageContinuation := true;
        end;

        if Parameters.ContainsKey('sync') then begin
            Evaluate(Sync, Parameters.Get('sync'));
            if Sync then begin
                // Error if table is missing a key that starts with rowVersion for efficient data replication.
                Request.SetKeyToRowVersion(RecRef);
            end;

            if Parameters.ContainsKey('lastRowVersion') then begin
                RecRef.Field(0).SetFilter('>%1', Parameters.Get('lastRowVersion'));
            end;
        end;

        if WithVariants and Sync then
            exit(Response.RespondBadRequest(WithVariantsSyncErr));

        RecRef.SetTable(Item);
        Item.ReadIsolation := IsolationLevel::ReadCommitted;

        JsonBuilder.StartArray();

        if PageContinuation then
            DataFound := Item.Find('>')
        else
            DataFound := Item.Find('-');

        EntriaEnabled := EntriaIntegrationMgt.HasEnabledStore();
        if DataFound then
            repeat
                JsonBuilder.AddObject(ItemToJson(JsonBuilder, Item, WithAttributes, WithVariants, false, Sync, EntriaEnabled));
                EntryCount += 1;
                if (EntryCount = Limit) then begin
                    RecRef.GetTable(Item);
                    PageKey := Request.GetPageKey(RecRef);
                end;
                MoreRecords := Item.Next() <> 0;
            until (not MoreRecords) or (EntryCount = Limit);

        JsonBuilder.EndArray();

        JsonObject.Add('morePages', MoreRecords);
        JsonObject.Add('nextPageKey', PageKey);
        JsonObject.Add('nextPageURL', Request.GetNextPageUrl(PageKey));
        JsonObject.Add('data', JsonBuilder.BuildAsArray());

        exit(Response.RespondOK(JsonObject));
    end;

    local procedure ItemToJson(var JsonBuilder: Codeunit "NPR Json Builder"; var Item: Record Item; WithAttributes: Boolean; WithVariants: Boolean; SingleItem: Boolean; EntriaEnabled: Boolean): Codeunit "NPR Json Builder"
    begin
        exit(ItemToJson(JsonBuilder, Item, WithAttributes, WithVariants, SingleItem, true, EntriaEnabled));
    end;

    local procedure ItemToJson(var JsonBuilder: Codeunit "NPR Json Builder"; var Item: Record Item; WithAttributes: Boolean; WithVariants: Boolean; SingleItem: Boolean; Sync: Boolean; EntriaEnabled: Boolean): Codeunit "NPR Json Builder"
    begin
        JsonBuilder.StartObject().AddProperty('id', Format(Item.SystemId, 0, 4).ToLower())
                                 .AddProperty('code', Item."No.")
                                 .AddProperty('description', Item.Description)
                                 .AddProperty('description2', Item."Description 2")
                                 .AddProperty('baseUnitOfMeasure', Item."Base Unit of Measure")
                                 .AddProperty('itemDiscGroup', Item."Item Disc. Group")
                                 .AddProperty('itemCategoryCode', Item."Item Category Code")
                                 .AddProperty('vatProdPostingGroup', Item."VAT Prod. Posting Group")
                                 .AddProperty('unitPrice', Item."Unit Price")
                                 .AddProperty('vendorNo', Item."Vendor No.")
                                 .AddProperty('vendorItemNo', Item."Vendor Item No.")
                                 .AddProperty('variety1', Item."NPR Variety 1")
                                 .AddProperty('variety1Table', Item."NPR Variety 1 Table")
                                 .AddProperty('variety2', Item."NPR Variety 2")
                                 .AddProperty('variety2Table', Item."NPR Variety 2 Table")
                                 .AddProperty('variety3', Item."NPR Variety 3")
                                 .AddProperty('variety3Table', Item."NPR Variety 3 Table")
                                 .AddProperty('variety4', Item."NPR Variety 4")
                                 .AddProperty('variety4Table', Item."NPR Variety 4 Table")
                                 .AddProperty('varietyGroup', Item."NPR Variety Group")
                                 .AddProperty('crossVarietyNo', CrossVarietyNoName(Item."NPR Cross Variety No."));

        if EntriaEnabled then
            JsonBuilder.AddProperty('entriaProduct', Item."NPR Entria Product");

        if SingleItem then
            JsonBuilder.AddProperty('inventory', Item.Inventory)
                       .AddProperty('hasVariants', Item."NPR Has Variants");
        if Sync then
            JsonBuilder.AddProperty('rowVersion', Format(Item.SystemRowVersion, 0, 9));

        if WithAttributes then begin
            JsonBuilder.StartObject('attributes');
            JsonBuilder.AddObject(AddItemAttributes(JsonBuilder, Item."No."));
            JsonBuilder.EndObject();
        end;

        if WithVariants then begin
            JsonBuilder.StartArray('variants');
            JsonBuilder.AddArray(AddItemVariants(JsonBuilder, Item."No."));
            JsonBuilder.EndArray();
        end;

        JsonBuilder.EndObject();
        exit(JsonBuilder);
    end;

    local procedure CrossVarietyNoName(CrossVarietyNo: Integer): Text
    var
        Item: Record Item;
        RecRef: RecordRef;
    begin
        RecRef.Open(Database::Item);
        exit(RecRef.Field(Item.FieldNo("NPR Cross Variety No.")).GetEnumValueNameFromOrdinalValue(CrossVarietyNo));
    end;

    local procedure AddItemVariants(var JsonBuilder: Codeunit "NPR Json Builder"; ItemNo: Code[20]): Codeunit "NPR Json Builder"
    var
        ItemVariant: Record "Item Variant";
    begin
        ItemVariant.SetRange("Item No.", ItemNo);
        ItemVariant.SetLoadFields(Description, "Description 2", Blocked,
            "NPR Variety 1", "NPR Variety 1 Table", "NPR Variety 1 Value",
            "NPR Variety 2", "NPR Variety 2 Table", "NPR Variety 2 Value",
            "NPR Variety 3", "NPR Variety 3 Table", "NPR Variety 3 Value",
            "NPR Variety 4", "NPR Variety 4 Table", "NPR Variety 4 Value");
        ItemVariant.ReadIsolation := IsolationLevel::ReadCommitted;
        if ItemVariant.FindSet() then
            repeat
                JsonBuilder.StartObject().AddProperty('id', Format(ItemVariant.SystemId, 0, 4).ToLower())
                                         .AddProperty('variantCode', ItemVariant.Code)
                                         .AddProperty('description', ItemVariant.Description)
                                         .AddProperty('description2', ItemVariant."Description 2")
                                         .AddProperty('blocked', ItemVariant.Blocked)
                                         .AddProperty('variety1', ItemVariant."NPR Variety 1")
                                         .AddProperty('variety1Table', ItemVariant."NPR Variety 1 Table")
                                         .AddProperty('variety1Value', ItemVariant."NPR Variety 1 Value")
                                         .AddProperty('variety2', ItemVariant."NPR Variety 2")
                                         .AddProperty('variety2Table', ItemVariant."NPR Variety 2 Table")
                                         .AddProperty('variety2Value', ItemVariant."NPR Variety 2 Value")
                                         .AddProperty('variety3', ItemVariant."NPR Variety 3")
                                         .AddProperty('variety3Table', ItemVariant."NPR Variety 3 Table")
                                         .AddProperty('variety3Value', ItemVariant."NPR Variety 3 Value")
                                         .AddProperty('variety4', ItemVariant."NPR Variety 4")
                                         .AddProperty('variety4Table', ItemVariant."NPR Variety 4 Table")
                                         .AddProperty('variety4Value', ItemVariant."NPR Variety 4 Value")
                                         .EndObject();
            until ItemVariant.Next() = 0;
        exit(JsonBuilder);
    end;

    local procedure AddItemAttributes(var JsonBuilder: Codeunit "NPR Json Builder"; ItemNo: Code[20]): Codeunit "NPR Json Builder"
    var
        ItemAttribute: Record "Item Attribute";
        ItemAttributeValue: Record "Item Attribute Value";
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
        IntegerValue: Integer;
    begin
        ItemAttributeValueMapping.SetRange("Table ID", Database::Item);
        ItemAttributeValueMapping.SetRange("No.", ItemNo);
        if ItemAttributeValueMapping.FindSet() then begin
            repeat
                if ItemAttribute.Get(ItemAttributeValueMapping."Item Attribute ID") then
                    if ItemAttributeValue.Get(ItemAttributeValueMapping."Item Attribute ID", ItemAttributeValueMapping."Item Attribute Value ID") then begin
                        case ItemAttribute."Type" of
                            ItemAttribute."Type"::Text,
                            ItemAttribute."Type"::Option:
                                JsonBuilder.AddProperty(ItemAttribute.Name, ItemAttributeValue."Value");
                            ItemAttribute."Type"::Decimal:
                                JsonBuilder.AddProperty(ItemAttribute.Name, ItemAttributeValue."Numeric Value");
                            ItemAttribute."Type"::Integer:
                                begin
                                    IntegerValue := ItemAttributeValue."Numeric Value";
                                    JsonBuilder.AddProperty(ItemAttribute.Name, IntegerValue);
                                end;
                            ItemAttribute."Type"::Date:
                                JsonBuilder.AddProperty(ItemAttribute.Name, ItemAttributeValue."Date Value");
                        end;
                    end;
            until ItemAttributeValueMapping.Next() = 0;
        end;
        exit(JsonBuilder);
    end;

    procedure GetItemLedgerEntry(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        Fields: Dictionary of [Integer, Text];
    begin
        if Request.QueryParams().ContainsKey('itemCode') then begin
            ItemledgerEntry.SetFilter("Item No.", '=%1', Request.QueryParams().Get('itemCode'));
        end;
        if Request.QueryParams().ContainsKey('documentNo') then begin
            ItemledgerEntry.SetFilter("Document No.", '=%1', Request.QueryParams().Get('documentNo'));
        end;

        Fields.Add(ItemLedgerEntry.FieldNo("Entry No."), 'entryNo');
        Fields.Add(ItemLedgerEntry.FieldNo("Item No."), 'itemCode');
        Fields.Add(ItemLedgerEntry.FieldNo("Posting Date"), 'postingDate');
        Fields.Add(ItemLedgerEntry.FieldNo("Entry Type"), 'entryType');
        Fields.Add(ItemLedgerEntry.FieldNo("Source No."), 'sourceNo');
        Fields.Add(ItemLedgerEntry.FieldNo("Document No."), 'documentNo');
        Fields.Add(ItemLedgerEntry.FieldNo("Global Dimension 1 Code"), 'globalDimension1Code');
        Fields.Add(ItemLedgerEntry.FieldNo("Global Dimension 2 Code"), 'globalDimension2Code');
        Fields.Add(ItemLedgerEntry.FieldNo("Location Code"), 'locationCode');
        Fields.Add(ItemLedgerEntry.FieldNo("Drop Shipment"), 'dropShipment');
        Fields.Add(ItemLedgerEntry.FieldNo("Variant Code"), 'variantCode');
        Fields.Add(ItemLedgerEntry.FieldNo("Lot No."), 'lotNo');
        Fields.Add(ItemLedgerEntry.FieldNo("Serial No."), 'serialNo');
        Fields.Add(ItemLedgerEntry.FieldNo("Unit of Measure Code"), 'unitOfMeasureCode');
        Fields.Add(ItemLedgerEntry.FieldNo("Package No."), 'packageNo');
        Fields.Add(ItemLedgerEntry.FieldNo(Quantity), 'quantity');
        Fields.Add(ItemLedgerEntry.FieldNo(Description), 'description');
        Fields.Add(ItemLedgerEntry.FieldNo("External Document No."), 'externalDocumentNo');
        Fields.Add(ItemLedgerEntry.FieldNo(Open), 'open');

        exit(Response.RespondOK(Request.GetData(ItemLedgerEntry, Fields)));
    end;

    local procedure GetItemVariant(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        ItemVariant: Record "Item Variant";
        Fields: Dictionary of [Integer, Text];
    begin
        if Request.QueryParams().ContainsKey('itemCode') then begin
            ItemVariant.SetFilter("Item No.", '=%1', Request.QueryParams().Get('itemCode'));
        end;

        Fields.Add(ItemVariant.FieldNo(Code), 'variantCode');
        Fields.Add(ItemVariant.FieldNo("Item No."), 'itemCode');
        Fields.Add(ItemVariant.FieldNo(Description), 'description');
        Fields.Add(ItemVariant.FieldNo("Description 2"), 'description2');
        Fields.Add(ItemVariant.FieldNo(Blocked), 'blocked');
        Fields.Add(ItemVariant.FieldNo("NPR Variety 1"), 'variety1');
        Fields.Add(ItemVariant.FieldNo("NPR Variety 1 Table"), 'variety1Table');
        Fields.Add(ItemVariant.FieldNo("NPR Variety 1 Value"), 'variety1Value');
        Fields.Add(ItemVariant.FieldNo("NPR Variety 2"), 'variety2');
        Fields.Add(ItemVariant.FieldNo("NPR Variety 2 Table"), 'variety2Table');
        Fields.Add(ItemVariant.FieldNo("NPR Variety 2 Value"), 'variety2Value');
        Fields.Add(ItemVariant.FieldNo("NPR Variety 3"), 'variety3');
        Fields.Add(ItemVariant.FieldNo("NPR Variety 3 Table"), 'variety3Table');
        Fields.Add(ItemVariant.FieldNo("NPR Variety 3 Value"), 'variety3Value');
        Fields.Add(ItemVariant.FieldNo("NPR Variety 4"), 'variety4');
        Fields.Add(ItemVariant.FieldNo("NPR Variety 4 Table"), 'variety4Table');
        Fields.Add(ItemVariant.FieldNo("NPR Variety 4 Value"), 'variety4Value');

        exit(Response.RespondOK(Request.GetData(ItemVariant, Fields)));
    end;

    local procedure GetItemCategory(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        ItemCategory: Record "Item Category";
        Fields: Dictionary of [Integer, Text];
    begin
        Fields.Add(ItemCategory.FieldNo("Code"), 'code');
        Fields.Add(ItemCategory.FieldNo(Description), 'description');
        Fields.Add(ItemCategory.FieldNo("Parent Category"), 'parentCode');
        Fields.Add(ItemCategory.FieldNo("Presentation Order"), 'presentationOrder');
        Fields.Add(ItemCategory.FieldNo("Has Children"), 'hasChildren');
        Fields.Add(ItemCategory.FieldNo("Indentation"), 'indentation');

        exit(Response.RespondOK(Request.GetData(ItemCategory, Fields)));
    end;

    local procedure GetBarcode(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        ItemReference: Record "Item Reference";
        Fields: Dictionary of [Integer, Text];
    begin
        if Request.QueryParams().ContainsKey('value') then begin
            ItemReference.SetFilter("Reference No.", '=%1', Request.QueryParams().Get('value'));
        end;
        if Request.QueryParams().ContainsKey('itemCode') then begin
            ItemReference.SetFilter("Item No.", '=%1', Request.QueryParams().Get('itemCode'));
        end;
        if Request.QueryParams().ContainsKey('variantCode') then begin
            ItemReference.SetFilter("Variant Code", '=%1', Request.QueryParams().Get('variantCode'));
        end;
        if Request.QueryParams().ContainsKey('unitOfMeasure') then begin
            ItemReference.SetFilter("Unit of Measure", '=%1', Request.QueryParams().Get('unitOfMeasure'));
        end;

        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");

        Fields.Add(ItemReference.FieldNo("Item No."), 'itemCode');
        Fields.Add(ItemReference.FieldNo("Variant Code"), 'variantCode');
        Fields.Add(ItemReference.FieldNo("Unit of Measure"), 'unitOfMeasure');
        Fields.Add(ItemReference.FieldNo("Reference No."), 'barcode');
        Fields.Add(ItemReference.FieldNo(Description), 'description');
        Fields.Add(ItemReference.FieldNo("Description 2"), 'description2');

        exit(Response.RespondOK(Request.GetData(ItemReference, Fields)));
    end;

    local procedure GetTranslation(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        ItemTranslation: Record "Item Translation";
        Fields: Dictionary of [Integer, Text];
    begin
        if Request.QueryParams().ContainsKey('itemCode') then begin
            ItemTranslation.SetFilter("Item No.", '=%1', Request.QueryParams().Get('itemCode'));
        end;
        if Request.QueryParams().ContainsKey('languageCode') then begin
            ItemTranslation.SetFilter("Language Code", '=%1', Request.QueryParams().Get('languageCode'));
        end;
        if Request.QueryParams().ContainsKey('variantCode') then begin
            ItemTranslation.SetFilter("Variant Code", '=%1', Request.QueryParams().Get('variantCode'));
        end;

        Fields.Add(ItemTranslation.FieldNo("Item No."), 'itemCode');
        Fields.Add(ItemTranslation.FieldNo("Language Code"), 'languageCode');
        Fields.Add(ItemTranslation.FieldNo("Variant Code"), 'variantCode');
        Fields.Add(ItemTranslation.FieldNo(Description), 'description');
        Fields.Add(ItemTranslation.FieldNo("Description 2"), 'description2');

        exit(Response.RespondOK(Request.GetData(ItemTranslation, Fields)));
    end;

    local procedure GetVariety(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Variety: Record "NPR Variety";
        Fields: Dictionary of [Integer, Text];
    begin
        if Request.QueryParams().ContainsKey('code') then begin
            Variety.SetFilter(Code, '=%1', Request.QueryParams().Get('code'));
        end;

        Fields.Add(Variety.FieldNo(Code), 'code');
        Fields.Add(Variety.FieldNo(Description), 'description');
        Fields.Add(Variety.FieldNo("Use in Variant Description"), 'useInVariantDescription');
        Fields.Add(Variety.FieldNo("Pre tag In Variant Description"), 'preTagInVariantDescription');
        Fields.Add(Variety.FieldNo("Use Description field"), 'useDescriptionField');

        exit(Response.RespondOK(Request.GetData(Variety, Fields)));
    end;

    local procedure GetVarietyTable(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        VarietyTable: Record "NPR Variety Table";
        Fields: Dictionary of [Integer, Text];
    begin
        if Request.QueryParams().ContainsKey('type') then begin
            VarietyTable.SetFilter(Type, '=%1', Request.QueryParams().Get('type'));
        end;
        if Request.QueryParams().ContainsKey('code') then begin
            VarietyTable.SetFilter(Code, '=%1', Request.QueryParams().Get('code'));
        end;

        Fields.Add(VarietyTable.FieldNo(Type), 'type');
        Fields.Add(VarietyTable.FieldNo(Code), 'code');
        Fields.Add(VarietyTable.FieldNo(Description), 'description');
        Fields.Add(VarietyTable.FieldNo("Use in Variant Description"), 'useInVariantDescription');
        Fields.Add(VarietyTable.FieldNo("Pre tag In Variant Description"), 'preTagInVariantDescription');
        Fields.Add(VarietyTable.FieldNo("Use Description field"), 'useDescriptionField');
        Fields.Add(VarietyTable.FieldNo("Is Copy"), 'isCopy');
        Fields.Add(VarietyTable.FieldNo("Copy from"), 'copyFrom');
        Fields.Add(VarietyTable.FieldNo("Lock Table"), 'lockTable');

        exit(Response.RespondOK(Request.GetData(VarietyTable, Fields)));
    end;

    local procedure GetVarietyValue(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        VarietyValue: Record "NPR Variety Value";
        Fields: Dictionary of [Integer, Text];
    begin
        if Request.QueryParams().ContainsKey('type') then begin
            VarietyValue.SetFilter(Type, '=%1', Request.QueryParams().Get('type'));
        end;
        if Request.QueryParams().ContainsKey('table') then begin
            VarietyValue.SetFilter("Table", '=%1', Request.QueryParams().Get('table'));
        end;
        if Request.QueryParams().ContainsKey('value') then begin
            VarietyValue.SetFilter(Value, '=%1', Request.QueryParams().Get('value'));
        end;

        Fields.Add(VarietyValue.FieldNo(Type), 'type');
        Fields.Add(VarietyValue.FieldNo("Table"), 'table');
        Fields.Add(VarietyValue.FieldNo(Value), 'value');
        Fields.Add(VarietyValue.FieldNo("Sort Order"), 'sortOrder');
        Fields.Add(VarietyValue.FieldNo(Description), 'description');

        exit(Response.RespondOK(Request.GetData(VarietyValue, Fields)));
    end;
}
#endif