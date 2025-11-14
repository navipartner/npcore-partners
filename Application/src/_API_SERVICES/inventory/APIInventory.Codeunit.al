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
        end;
    end;

    procedure GetItem(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Item: Record Item;
        JsonBuilder: Codeunit "NPR Json Builder";
        ItemId: Text;
        WithAttributes: Boolean;
    begin
        ItemId := Request.Paths().Get(3);
        Item.ReadIsolation := IsolationLevel::ReadCommitted;
        if not Item.GetBySystemId(ItemId) then
            exit(Response.RespondResourceNotFound());

        Item.CalcFields(Inventory);
        if (Request.QueryParams().ContainsKey('withAttributes')) then
            WithAttributes := (Request.QueryParams().Get('withAttributes').ToLower() = 'true');

        exit(Response.RespondOK(ItemToJson(JsonBuilder, Item, WithAttributes, true).Build()));
    end;

    procedure ListItems(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Item: Record "Item";
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
        Sync: Boolean;
    begin
        Parameters := Request.QueryParams();

        if (Parameters.ContainsKey('withAttributes')) then
            WithAttributes := (Parameters.Get('withAttributes').ToLower() = 'true');

        if Parameters.ContainsKey('itemCode') then
            Item.SetRange("No.", Parameters.Get('itemCode'));

        RecRef.GetTable(Item);

        if (Parameters.ContainsKey('pageSize')) then
            Evaluate(Limit, Parameters.Get('pageSize'));
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

        RecRef.SetTable(Item);
        Item.ReadIsolation := IsolationLevel::ReadCommitted;

        JsonBuilder.StartArray();

        if PageContinuation then
            DataFound := Item.Find('>')
        else
            DataFound := Item.Find('-');

        if DataFound then
            repeat
                JsonBuilder.AddObject(ItemToJson(JsonBuilder, Item, WithAttributes, false, Sync));
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

    local procedure ItemToJson(var JsonBuilder: Codeunit "NPR Json Builder"; var Item: Record Item; WithAttributes: Boolean; SingleItem: Boolean): Codeunit "NPR Json Builder"
    begin
        exit(ItemToJson(JsonBuilder, Item, WithAttributes, SingleItem, true));
    end;

    local procedure ItemToJson(var JsonBuilder: Codeunit "NPR Json Builder"; var Item: Record Item; WithAttributes: Boolean; SingleItem: Boolean; Sync: Boolean): Codeunit "NPR Json Builder"
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
                                 .AddProperty('vendorItemNo', Item."Vendor Item No.");

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

        JsonBuilder.EndObject();
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
}
#endif