codeunit 85563 "NPR API Inventory Varieties"
{
    // [FEATURE] Inventory API: variety fields on items and variants, variants on items, variety master data endpoints

    Subtype = Test;

    var
        _Assert: Codeunit Assert;
        _LibraryInventory: Codeunit "Library - Inventory";
        _LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        _LibraryVariety: Codeunit "NPR Library - Variety";
        _Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetItemVariant_ReturnsVarietyFields()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        QueryParams: Dictionary of [Text, Text];
        Data: JsonArray;
        Token: JsonToken;
    begin
        // [SCENARIO] GET /inventory/itemvariant returns the variety, variety table and variety value of each position.
        // [GIVEN] An item with two variety positions and one variant with a value in each
        Initialize();
        CreateItemWithVariants(2, 1, Item);
        ItemVariant.SetRange("Item No.", Item."No.");
        ItemVariant.FindFirst();
        _Assert.AreNotEqual('', ItemVariant."NPR Variety 2 Value", 'Test setup must fill variety position 2');
        Commit();

        // [WHEN] The variants of the item are read
        QueryParams.Add('itemCode', Item."No.");
        Data := GetDataArray(CallInventoryApi('/inventory/itemvariant', QueryParams));

        // [THEN] The variant carries all twelve variety properties, blank for the unused positions
        _Assert.AreEqual(1, Data.Count(), 'One variant expected');
        Data.Get(0, Token);
        AssertVariantVarietyFields(ItemVariant, Token.AsObject());
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetItem_ReturnsVarietySetup()
    var
        Item: Record Item;
        VarietyGroup: Record "NPR Variety Group";
        LibraryUtility: Codeunit "Library - Utility";
        QueryParams: Dictionary of [Text, Text];
        Body: JsonObject;
    begin
        // [SCENARIO] GET /inventory/item/:id returns the variety setup of the item, with crossVarietyNo as the language independent option name.
        // [GIVEN] An item with two variety positions, a variety group and cross variety set to Variety 2
        Initialize();
        CreateItemWithVariants(2, 0, Item);
        VarietyGroup.Init();
        VarietyGroup.Code := LibraryUtility.GenerateRandomCode(VarietyGroup.FieldNo(Code), Database::"NPR Variety Group");
        VarietyGroup.Description := VarietyGroup.Code;
        VarietyGroup.Insert();
        Item.Get(Item."No.");
        Item."NPR Variety Group" := VarietyGroup.Code;
        Item."NPR Cross Variety No." := Item."NPR Cross Variety No."::Variety2;
        Item.Modify();
        Commit();

        // [WHEN] The item is read by its id
        Body := GetBody(CallInventoryApi('/inventory/item/' + FormatGuid(Item.SystemId), QueryParams));

        // [THEN] The item carries the variety setup
        AssertItemVarietyFields(Item, Body);
        _Assert.AreEqual('Variety2', GetText(Body, 'crossVarietyNo'), 'crossVarietyNo must be the option name');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ListItems_WithVariants_ReturnsVariantsArray()
    var
        Item: Record Item;
        QueryParams: Dictionary of [Text, Text];
        Data: JsonArray;
        Token: JsonToken;
    begin
        // [SCENARIO] GET /inventory/item?withVariants=true returns each item with its variants and their variety values.
        // [GIVEN] An item with two variety positions and two variants
        Initialize();
        CreateItemWithVariants(2, 2, Item);
        Commit();

        // [WHEN] The item list is read with withVariants=true
        QueryParams.Add('itemCode', Item."No.");
        QueryParams.Add('withVariants', 'true');
        Data := GetDataArray(CallInventoryApi('/inventory/item', QueryParams));

        // [THEN] The item carries both variants
        _Assert.AreEqual(1, Data.Count(), 'One item expected');
        Data.Get(0, Token);
        AssertItemVarietyFields(Item, Token.AsObject());
        AssertVariantsArray(Item, Token.AsObject());
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetItem_WithVariants_ReturnsVariantsArray()
    var
        Item: Record Item;
        QueryParams: Dictionary of [Text, Text];
        Body: JsonObject;
    begin
        // [SCENARIO] GET /inventory/item/:id?withVariants=true returns the item with its variants and their variety values.
        // [GIVEN] An item with three variety positions and two variants
        Initialize();
        CreateItemWithVariants(3, 2, Item);
        Commit();

        // [WHEN] The item is read by its id with withVariants=true
        QueryParams.Add('withVariants', 'true');
        Body := GetBody(CallInventoryApi('/inventory/item/' + FormatGuid(Item.SystemId), QueryParams));

        // [THEN] The item carries both variants
        AssertVariantsArray(Item, Body);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ListItems_WithoutVariants_HasNoVariantsArray()
    var
        Item: Record Item;
        QueryParams: Dictionary of [Text, Text];
        Data: JsonArray;
        Token: JsonToken;
        Body: JsonObject;
    begin
        // [SCENARIO] Without withVariants the item endpoints return the same shape as before, with no variants array.
        // [GIVEN] An item with variants
        Initialize();
        CreateItemWithVariants(1, 2, Item);
        Commit();

        // [WHEN] The item list is read without withVariants
        QueryParams.Add('itemCode', Item."No.");
        Data := GetDataArray(CallInventoryApi('/inventory/item', QueryParams));

        // [THEN] The item has its usual properties and no variants
        _Assert.AreEqual(1, Data.Count(), 'One item expected');
        Data.Get(0, Token);
        _Assert.AreEqual(Item."No.", GetText(Token.AsObject(), 'code'), 'code');
        _Assert.IsTrue(Token.AsObject().Contains('unitPrice'), 'unitPrice must still be returned');
        _Assert.IsFalse(Token.AsObject().Contains('variants'), 'variants must not be returned by default');

        // [WHEN] The item is read by its id without withVariants
        Clear(QueryParams);
        Body := GetBody(CallInventoryApi('/inventory/item/' + FormatGuid(Item.SystemId), QueryParams));

        // [THEN] The item has no variants either
        _Assert.IsTrue(Body.Contains('hasVariants'), 'hasVariants must still be returned');
        _Assert.IsFalse(Body.Contains('variants'), 'variants must not be returned by default');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ListItems_WithVariantsAndSync_Returns400()
    var
        Item: Record Item;
        QueryParams: Dictionary of [Text, Text];
        Response: JsonObject;
    begin
        // [SCENARIO] withVariants cannot be combined with sync=true, because a variant change does not move the item row version.
        // [GIVEN] An item with variants
        Initialize();
        CreateItemWithVariants(1, 1, Item);
        Commit();

        // [WHEN] The item list is read with sync=true only
        QueryParams.Add('itemCode', Item."No.");
        QueryParams.Add('sync', 'true');
        Response := CallInventoryApi('/inventory/item', QueryParams);

        // [THEN] The call succeeds as before
        _Assert.IsTrue(_LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'sync=true alone must keep working');

        // [WHEN] withVariants=true is added
        QueryParams.Add('withVariants', 'true');
        Response := CallInventoryApi('/inventory/item', QueryParams);

        // [THEN] The call is rejected with 400
        _Assert.AreEqual(400, GetStatusCode(Response), 'withVariants together with sync=true must return 400');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Variants_ReturnBlockedFlag()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        QueryParams: Dictionary of [Text, Text];
        Data: JsonArray;
        Token: JsonToken;
        Body: JsonObject;
        BlockedVariantCode: Code[10];
    begin
        // [SCENARIO] Blocked variants are still returned, flagged as blocked, so a webshop can hide them and a sync client sees the change.
        // [GIVEN] An item with two variants, one of them blocked
        Initialize();
        CreateItemWithVariants(1, 2, Item);
        ItemVariant.SetRange("Item No.", Item."No.");
        ItemVariant.FindFirst();
        ItemVariant.Blocked := true;
        ItemVariant.Modify();
        BlockedVariantCode := ItemVariant.Code;
        Commit();

        // [WHEN] The variants are read from the variant endpoint
        QueryParams.Add('itemCode', Item."No.");
        Data := GetDataArray(CallInventoryApi('/inventory/itemvariant', QueryParams));

        // [THEN] Both variants are returned and only the blocked one is flagged
        _Assert.AreEqual(2, Data.Count(), 'Blocked variants must still be returned');
        foreach Token in Data do
            _Assert.AreEqual(GetText(Token.AsObject(), 'variantCode') = BlockedVariantCode, GetBoolean(Token.AsObject(), 'blocked'), 'blocked on /inventory/itemvariant');

        // [WHEN] The item is read with its variants
        Clear(QueryParams);
        QueryParams.Add('withVariants', 'true');
        Body := GetBody(CallInventoryApi('/inventory/item/' + FormatGuid(Item.SystemId), QueryParams));

        // [THEN] The variants array flags the same variant
        _Assert.IsTrue(Body.Get('variants', Token), 'variants must be returned');
        Data := Token.AsArray();
        _Assert.AreEqual(2, Data.Count(), 'Blocked variants must still be returned');
        foreach Token in Data do
            _Assert.AreEqual(GetText(Token.AsObject(), 'variantCode') = BlockedVariantCode, GetBoolean(Token.AsObject(), 'blocked'), 'blocked on item variants');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetVarietyValue_FiltersByTypeAndTable()
    var
        ValueA1: Record "NPR Variety Value";
        ValueA2: Record "NPR Variety Value";
        ValueB1: Record "NPR Variety Value";
        OtherTypeValue: Record "NPR Variety Value";
        VarietyValue: Record "NPR Variety Value";
        QueryParams: Dictionary of [Text, Text];
        Data: JsonArray;
        Token: JsonToken;
        Json: JsonObject;
    begin
        // [SCENARIO] GET /inventory/varietyvalue?type=&table= returns only the values of that variety table, with sort order and description.
        // [GIVEN] Two values in table A and one value in table B of the same variety, and a value in a table with the same code under another variety
        Initialize();
        _LibraryVariety.CreateVarietyValue('', '', '', ValueA1);
        _LibraryVariety.CreateVarietyValue(ValueA1.Type, ValueA1.Table, '', ValueA2);
        ValueA2.Description := 'Medium';
        ValueA2."Sort Order" := 35;
        ValueA2.Modify();
        _LibraryVariety.CreateVarietyValue(ValueA1.Type, '', '', ValueB1);
        _LibraryVariety.CreateVarietyValue('', ValueA1.Table, '', OtherTypeValue);
        Commit();

        // [WHEN] The values are read filtered on the variety and table A
        QueryParams.Add('type', ValueA1.Type);
        QueryParams.Add('table', ValueA1.Table);
        Data := GetDataArray(CallInventoryApi('/inventory/varietyvalue', QueryParams));

        // [THEN] Only the two values of table A are returned with every documented property
        _Assert.AreEqual(2, Data.Count(), 'Two variety values expected');
        foreach Token in Data do begin
            Json := Token.AsObject();
            _Assert.AreEqual(ValueA1.Type, GetText(Json, 'type'), 'type');
            _Assert.AreEqual(ValueA1.Table, GetText(Json, 'table'), 'table');
            VarietyValue.Get(GetText(Json, 'type'), GetText(Json, 'table'), GetText(Json, 'value'));
            _Assert.AreEqual(FormatGuid(VarietyValue.SystemId), GetText(Json, 'id'), 'id');
            _Assert.AreEqual(VarietyValue."Sort Order", GetInteger(Json, 'sortOrder'), 'sortOrder');
            _Assert.AreEqual(VarietyValue.Description, GetText(Json, 'description'), 'description');
            _Assert.IsFalse(Json.Contains('replicationCounter'), 'The obsolete replication counter must not be returned');
        end;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetVarietyTable_FiltersByType()
    var
        VarietyTable: Record "NPR Variety Table";
        SecondTable: Record "NPR Variety Table";
        ThirdTable: Record "NPR Variety Table";
        OtherVarietyTable: Record "NPR Variety Table";
        QueryParams: Dictionary of [Text, Text];
        Data: JsonArray;
        Token: JsonToken;
        Json: JsonObject;
    begin
        // [SCENARIO] GET /inventory/varietytable?type= returns only the tables of that variety, with every documented property.
        // [GIVEN] Three tables of one variety whose flags differ so that no two flags hold the same values, and a table of another variety
        Initialize();
        _LibraryVariety.CreateVarietyTable('', '', VarietyTable);
        SetVarietyTableFields(VarietyTable, 'Kids sizes', true, 'Yr:', false, false, '', true);
        _LibraryVariety.CreateVarietyTable(VarietyTable.Type, '', SecondTable);
        SetVarietyTableFields(SecondTable, 'Adult sizes', false, 'Sz:', true, false, '', true);
        _LibraryVariety.CreateVarietyTable(VarietyTable.Type, '', ThirdTable);
        SetVarietyTableFields(ThirdTable, 'Shoe sizes', false, '', false, true, 'ORIGINAL', false);
        _LibraryVariety.CreateVarietyTable('', '', OtherVarietyTable);
        Commit();

        // [WHEN] The tables are read filtered on the variety
        QueryParams.Add('type', VarietyTable.Type);
        Data := GetDataArray(CallInventoryApi('/inventory/varietytable', QueryParams));

        // [THEN] Only the three tables of that variety are returned with every documented property
        _Assert.AreEqual(3, Data.Count(), 'Three variety tables expected');
        foreach Token in Data do begin
            Json := Token.AsObject();
            VarietyTable.Get(GetText(Json, 'type'), GetText(Json, 'code'));
            _Assert.AreEqual(FormatGuid(VarietyTable.SystemId), GetText(Json, 'id'), 'id');
            _Assert.AreEqual(VarietyTable.Description, GetText(Json, 'description'), 'description');
            _Assert.AreEqual(VarietyTable."Use in Variant Description", GetBoolean(Json, 'useInVariantDescription'), 'useInVariantDescription');
            _Assert.AreEqual(VarietyTable."Pre tag In Variant Description", GetText(Json, 'preTagInVariantDescription'), 'preTagInVariantDescription');
            _Assert.AreEqual(VarietyTable."Use Description field", GetBoolean(Json, 'useDescriptionField'), 'useDescriptionField');
            _Assert.AreEqual(VarietyTable."Is Copy", GetBoolean(Json, 'isCopy'), 'isCopy');
            _Assert.AreEqual(VarietyTable."Copy from", GetText(Json, 'copyFrom'), 'copyFrom');
            _Assert.AreEqual(VarietyTable."Lock Table", GetBoolean(Json, 'lockTable'), 'lockTable');
            _Assert.IsFalse(Json.Contains('replicationCounter'), 'The obsolete replication counter must not be returned');
        end;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetVariety_FiltersByCode()
    var
        Variety: Record "NPR Variety";
        OtherVariety: Record "NPR Variety";
        QueryParams: Dictionary of [Text, Text];
        Data: JsonArray;
        Token: JsonToken;
        Json: JsonObject;
    begin
        // [SCENARIO] GET /inventory/variety?code= returns that variety with every documented property.
        // [GIVEN] A variety whose description differs from its code and whose two flags differ, and another variety
        Initialize();
        _LibraryVariety.CreateVariety('', Variety);
        Variety.Description := 'Colour';
        Variety."Use in Variant Description" := true;
        Variety."Pre tag In Variant Description" := 'Col.';
        Variety."Use Description field" := false;
        Variety.Modify();
        _LibraryVariety.CreateVariety('', OtherVariety);
        Commit();

        // [WHEN] The varieties are read filtered on the code
        QueryParams.Add('code', Variety.Code);
        Data := GetDataArray(CallInventoryApi('/inventory/variety', QueryParams));

        // [THEN] Only that variety is returned with every documented property
        _Assert.AreEqual(1, Data.Count(), 'One variety expected');
        Data.Get(0, Token);
        Json := Token.AsObject();
        _Assert.AreEqual(FormatGuid(Variety.SystemId), GetText(Json, 'id'), 'id');
        _Assert.AreEqual(Variety.Code, GetText(Json, 'code'), 'code');
        _Assert.AreEqual(Variety.Description, GetText(Json, 'description'), 'description');
        _Assert.AreEqual(Variety."Use in Variant Description", GetBoolean(Json, 'useInVariantDescription'), 'useInVariantDescription');
        _Assert.AreEqual(Variety."Pre tag In Variant Description", GetText(Json, 'preTagInVariantDescription'), 'preTagInVariantDescription');
        _Assert.AreEqual(Variety."Use Description field", GetBoolean(Json, 'useDescriptionField'), 'useDescriptionField');
        _Assert.IsFalse(Json.Contains('replicationCounter'), 'The obsolete replication counter must not be returned');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetVarietyValue_SyncIsSupported()
    var
        QueryParams: Dictionary of [Text, Text];
        Response: JsonObject;
    begin
        // [SCENARIO] GET /inventory/varietyvalue?sync=true does not fail; without a key that starts with SystemRowVersion the API raises an error.
        Initialize();

        // [WHEN] The variety values are read in sync mode
        QueryParams.Add('sync', 'true');
        Response := CallInventoryApi('/inventory/varietyvalue', QueryParams);

        // [THEN] The call succeeds
        _Assert.IsTrue(_LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'sync=true must work on variety values');
    end;

    local procedure Initialize()
    begin
        if _Initialized then
            exit;

        _LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API Inventory');
        _Initialized := true;
        Commit();
    end;

    local procedure CreateItemWithVariants(VarietySets: Integer; VariantCount: Integer; var Item: Record Item)
    var
        ItemVariant: Record "Item Variant";
        i: Integer;
    begin
        _LibraryInventory.CreateItem(Item);
        _LibraryVariety.CreateVarietySetsAndAddToItem(VarietySets, Item);
        for i := 1 to VariantCount do begin
            _LibraryInventory.CreateItemVariant(ItemVariant, Item."No.");
            _LibraryVariety.CreateVarietyValuesAndAddToItemVariant(ItemVariant);
        end;
        Item.Get(Item."No.");
    end;

    local procedure SetVarietyTableFields(var VarietyTable: Record "NPR Variety Table"; Description: Text[50]; UseInVariantDescription: Boolean; PreTag: Text[10]; UseDescriptionField: Boolean; IsCopy: Boolean; CopyFrom: Code[40]; LockTable: Boolean)
    begin
        VarietyTable.Description := Description;
        VarietyTable."Use in Variant Description" := UseInVariantDescription;
        VarietyTable."Pre tag In Variant Description" := PreTag;
        VarietyTable."Use Description field" := UseDescriptionField;
        VarietyTable."Is Copy" := IsCopy;
        VarietyTable."Copy from" := CopyFrom;
        VarietyTable."Lock Table" := LockTable;
        VarietyTable.Modify();
    end;

    local procedure AssertItemVarietyFields(Item: Record Item; Json: JsonObject)
    begin
        _Assert.AreEqual(Item."NPR Variety 1", GetText(Json, 'variety1'), 'variety1');
        _Assert.AreEqual(Item."NPR Variety 1 Table", GetText(Json, 'variety1Table'), 'variety1Table');
        _Assert.AreEqual(Item."NPR Variety 2", GetText(Json, 'variety2'), 'variety2');
        _Assert.AreEqual(Item."NPR Variety 2 Table", GetText(Json, 'variety2Table'), 'variety2Table');
        _Assert.AreEqual(Item."NPR Variety 3", GetText(Json, 'variety3'), 'variety3');
        _Assert.AreEqual(Item."NPR Variety 3 Table", GetText(Json, 'variety3Table'), 'variety3Table');
        _Assert.AreEqual(Item."NPR Variety 4", GetText(Json, 'variety4'), 'variety4');
        _Assert.AreEqual(Item."NPR Variety 4 Table", GetText(Json, 'variety4Table'), 'variety4Table');
        _Assert.AreEqual(Item."NPR Variety Group", GetText(Json, 'varietyGroup'), 'varietyGroup');
        _Assert.IsTrue(Json.Contains('crossVarietyNo'), 'crossVarietyNo must be returned');
    end;

    local procedure AssertVariantsArray(Item: Record Item; ItemJson: JsonObject)
    var
        ItemVariant: Record "Item Variant";
        Token: JsonToken;
        Variants: JsonArray;
        VariantJson: JsonObject;
    begin
        _Assert.IsTrue(ItemJson.Get('variants', Token), 'variants must be returned');
        Variants := Token.AsArray();
        ItemVariant.SetRange("Item No.", Item."No.");
        _Assert.AreEqual(ItemVariant.Count(), Variants.Count(), 'Every variant of the item must be returned');

        foreach Token in Variants do begin
            VariantJson := Token.AsObject();
            ItemVariant.Get(Item."No.", GetText(VariantJson, 'variantCode'));
            _Assert.AreEqual(FormatGuid(ItemVariant.SystemId), GetText(VariantJson, 'id'), 'id');
            _Assert.AreEqual(ItemVariant.Description, GetText(VariantJson, 'description'), 'description');
            _Assert.AreEqual(ItemVariant."Description 2", GetText(VariantJson, 'description2'), 'description2');
            _Assert.AreEqual(ItemVariant.Blocked, GetBoolean(VariantJson, 'blocked'), 'blocked');
            AssertVariantVarietyFields(ItemVariant, VariantJson);
        end;
    end;

    local procedure AssertVariantVarietyFields(ItemVariant: Record "Item Variant"; Json: JsonObject)
    begin
        _Assert.AreEqual(ItemVariant."NPR Variety 1", GetText(Json, 'variety1'), 'variety1');
        _Assert.AreEqual(ItemVariant."NPR Variety 1 Table", GetText(Json, 'variety1Table'), 'variety1Table');
        _Assert.AreEqual(ItemVariant."NPR Variety 1 Value", GetText(Json, 'variety1Value'), 'variety1Value');
        _Assert.AreEqual(ItemVariant."NPR Variety 2", GetText(Json, 'variety2'), 'variety2');
        _Assert.AreEqual(ItemVariant."NPR Variety 2 Table", GetText(Json, 'variety2Table'), 'variety2Table');
        _Assert.AreEqual(ItemVariant."NPR Variety 2 Value", GetText(Json, 'variety2Value'), 'variety2Value');
        _Assert.AreEqual(ItemVariant."NPR Variety 3", GetText(Json, 'variety3'), 'variety3');
        _Assert.AreEqual(ItemVariant."NPR Variety 3 Table", GetText(Json, 'variety3Table'), 'variety3Table');
        _Assert.AreEqual(ItemVariant."NPR Variety 3 Value", GetText(Json, 'variety3Value'), 'variety3Value');
        _Assert.AreEqual(ItemVariant."NPR Variety 4", GetText(Json, 'variety4'), 'variety4');
        _Assert.AreEqual(ItemVariant."NPR Variety 4 Table", GetText(Json, 'variety4Table'), 'variety4Table');
        _Assert.AreEqual(ItemVariant."NPR Variety 4 Value", GetText(Json, 'variety4Value'), 'variety4Value');
    end;

    local procedure CallInventoryApi(Path: Text; QueryParams: Dictionary of [Text, Text]): JsonObject
    var
        Body: JsonObject;
        Headers: Dictionary of [Text, Text];
    begin
        exit(_LibraryNPRetailAPI.CallApi('GET', Path, Body, QueryParams, Headers));
    end;

    local procedure GetBody(Response: JsonObject): JsonObject
    begin
        _Assert.IsTrue(_LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'The API call should succeed');
        exit(_LibraryNPRetailAPI.GetResponseBody(Response));
    end;

    local procedure GetDataArray(Response: JsonObject): JsonArray
    var
        Token: JsonToken;
    begin
        _Assert.IsTrue(GetBody(Response).Get('data', Token), 'The response should contain data');
        exit(Token.AsArray());
    end;

    local procedure GetStatusCode(Response: JsonObject): Integer
    var
        Token: JsonToken;
    begin
        _Assert.IsTrue(Response.Get('statusCode', Token), 'The response should contain a status code');
        exit(Token.AsValue().AsInteger());
    end;

    local procedure GetText(Json: JsonObject; PropertyName: Text): Text
    var
        Token: JsonToken;
    begin
        _Assert.IsTrue(Json.Get(PropertyName, Token), PropertyName + ' must be returned');
        exit(Token.AsValue().AsText());
    end;

    local procedure GetInteger(Json: JsonObject; PropertyName: Text): Integer
    var
        Token: JsonToken;
    begin
        _Assert.IsTrue(Json.Get(PropertyName, Token), PropertyName + ' must be returned');
        exit(Token.AsValue().AsInteger());
    end;

    local procedure GetBoolean(Json: JsonObject; PropertyName: Text): Boolean
    var
        Token: JsonToken;
    begin
        _Assert.IsTrue(Json.Get(PropertyName, Token), PropertyName + ' must be returned');
        exit(Token.AsValue().AsBoolean());
    end;

    local procedure FormatGuid(Id: Guid): Text
    begin
        exit(Format(Id, 0, 4).ToLower());
    end;
}
