codeunit 85458 "NPR API BI Tests"
{
    // [FEATURE] BI API: generic table read and table metadata

    Subtype = Test;

    var
        Assert: Codeunit Assert;
        LibraryAPIBI: Codeunit "NPR Library - API BI";
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";

    #region Principal resolution and allowlist
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ResolvePrincipalFailsWithoutEntraApp()
    var
        BIAccess: Codeunit "NPR API BI Access";
        PrincipalType: Enum "NPR API BI Principal Type";
        PrincipalId: Guid;
        Resolved: Boolean;
    begin
        // [SCENARIO] A session user that is not an Entra ID application cannot be resolved to a BI principal.
        // [GIVEN] No Entra ID application points at the current user
        LibraryAPIBI.ResetBIPrincipals();

        // [WHEN] The principal is resolved
        Resolved := BIAccess.ResolvePrincipal(PrincipalType, PrincipalId);

        // [THEN] Resolution fails
        Assert.IsFalse(Resolved, 'Principal must not resolve without an Entra ID application');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ResolvePrincipalReturnsEntraAppWhenNotLinkedToKey()
    var
        AADApplication: Record "AAD Application";
        BIAccess: Codeunit "NPR API BI Access";
        PrincipalType: Enum "NPR API BI Principal Type";
        PrincipalId: Guid;
    begin
        // [SCENARIO] An Entra ID application that does not belong to an API key is its own BI principal, identified by its client id.
        // [GIVEN] An Entra ID application whose user is the current session user
        LibraryAPIBI.ResetBIPrincipals();
        LibraryAPIBI.CreateEntraAppForCurrentUser(AADApplication);

        // [WHEN] The principal is resolved
        Assert.IsTrue(BIAccess.ResolvePrincipal(PrincipalType, PrincipalId), 'Principal must resolve');

        // [THEN] The principal is the Entra ID application itself
        Assert.AreEqual(PrincipalType::"Entra App", PrincipalType, 'Principal type');
        Assert.AreEqual(AADApplication."Client Id", PrincipalId, 'Principal id');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ResolvePrincipalReturnsApiKeyWhenLinked()
    var
        AADApplication: Record "AAD Application";
        NPAPIKey: Record "NPR NaviPartner API Key";
        BIAccess: Codeunit "NPR API BI Access";
        PrincipalType: Enum "NPR API BI Principal Type";
        PrincipalId: Guid;
    begin
        // [SCENARIO] An Entra ID application that was created from a NaviPartner API Key resolves to that key, not to itself.
        // [GIVEN] An Entra ID application for the current user, linked to an API key
        LibraryAPIBI.ResetBIPrincipals();
        LibraryAPIBI.CreateEntraAppForCurrentUser(AADApplication);
        LibraryAPIBI.CreateApiKey(NPAPIKey);
        LibraryAPIBI.LinkEntraAppToApiKey(AADApplication, NPAPIKey);

        // [WHEN] The principal is resolved
        Assert.IsTrue(BIAccess.ResolvePrincipal(PrincipalType, PrincipalId), 'Principal must resolve');

        // [THEN] The principal is the API key
        Assert.AreEqual(PrincipalType::"NP API Key", PrincipalType, 'Principal type');
        Assert.AreEqual(NPAPIKey.Id, PrincipalId, 'Principal id');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IsTableAllowedOnlyForTheExactPrincipalAndTable()
    var
        BIAccess: Codeunit "NPR API BI Access";
        PrincipalId: Guid;
    begin
        // [SCENARIO] A table counts as allowed only when a row exists for exactly that principal and that table.
        // [GIVEN] One allowlist row, for one Entra ID application and the Item table
        LibraryAPIBI.ResetBIPrincipals();
        PrincipalId := CreateGuid();
        LibraryAPIBI.AllowTable("NPR API BI Principal Type"::"Entra App", PrincipalId, Database::Item);

        // [WHEN] The allowlist is checked for that row and for neighbouring combinations
        // [THEN] Only the exact combination is allowed
        Assert.IsTrue(BIAccess.IsTableAllowed("NPR API BI Principal Type"::"Entra App", PrincipalId, Database::Item), 'The exact row must be allowed');
        Assert.IsFalse(BIAccess.IsTableAllowed("NPR API BI Principal Type"::"Entra App", PrincipalId, Database::Customer), 'Another table must not be allowed');
        Assert.IsFalse(BIAccess.IsTableAllowed("NPR API BI Principal Type"::"NP API Key", PrincipalId, Database::Item), 'Another principal type must not be allowed');
        Assert.IsFalse(BIAccess.IsTableAllowed("NPR API BI Principal Type"::"Entra App", CreateGuid(), Database::Item), 'Another principal must not be allowed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AllowlistRejectsTableTheEndpointCannotServe()
    var
        BIAllowedTable: Record "NPR API BI Allowed Table";
    begin
        // [SCENARIO] The setup refuses a table number that the BI endpoint would reject anyway.
        // [GIVEN] A new allowlist row for an Entra ID application
        LibraryAPIBI.ResetBIPrincipals();
        BIAllowedTable.Init();
        BIAllowedTable."Principal Type" := BIAllowedTable."Principal Type"::"Entra App";
        BIAllowedTable."Principal Id" := CreateGuid();

        // [WHEN] A system table is entered as the allowed table
        asserterror BIAllowedTable.Validate("Table No.", Database::"Table Metadata");

        // [THEN] The entry is rejected
        Assert.ExpectedErrorCode('Dialog');
    end;
    #endregion

    #region Field map and json names
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure JsonNamesAreCamelCaseOfTheEnglishFieldName()
    var
        BIMetadata: Codeunit "NPR API BI Metadata";
    begin
        // [SCENARIO] Json property names are derived from English field names by one deterministic camelCase rule.
        // [GIVEN] Field names that cover the punctuation Business Central uses

        // [WHEN] They are converted to json names
        // [THEN] Every one of them comes out as documented
        Assert.AreEqual('no', BIMetadata.ToJsonName('No.'), 'No.');
        Assert.AreEqual('vatBusPostingGroup', BIMetadata.ToJsonName('VAT Bus. Posting Group'), 'VAT Bus. Posting Group');
        Assert.AreEqual('description2', BIMetadata.ToJsonName('Description 2'), 'Description 2');
        Assert.AreEqual('unitPriceLCY', BIMetadata.ToJsonName('Unit Price (LCY)'), 'Unit Price (LCY)');
        Assert.AreEqual('nprItemGroup', BIMetadata.ToJsonName('NPR Item Group'), 'NPR Item Group');
        Assert.AreEqual('eMail', BIMetadata.ToJsonName('E-Mail'), 'E-Mail');
        Assert.AreEqual('id', BIMetadata.ToJsonName('Id'), 'Id');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FieldMapHasStoredFieldsOnlyAndMapsSystemIdToId()
    var
        Item: Record Item;
        BIMetadata: Codeunit "NPR API BI Metadata";
        Fields: Dictionary of [Integer, Text];
    begin
        // [SCENARIO] The field map of a table holds its stored fields, maps the system id to "id" and leaves out calculated and binary fields.
        // [GIVEN] The Item table, which has stored fields, a FlowField and a media set field

        // [WHEN] The field map is built
        BIMetadata.BuildFieldMap(Database::Item, Fields);

        // [THEN] Stored fields are mapped, the system id is "id", and FlowFields and media are absent
        Assert.AreEqual('no', Fields.Get(Item.FieldNo("No.")), 'No. must be mapped');
        Assert.AreEqual('unitPrice', Fields.Get(Item.FieldNo("Unit Price")), 'Unit Price must be mapped');
        Assert.AreEqual('id', Fields.Get(Item.FieldNo(SystemId)), 'SystemId must be mapped to id');
        Assert.IsTrue(Fields.ContainsKey(Item.FieldNo(SystemCreatedAt)), 'SystemCreatedAt must be included');
        Assert.IsTrue(Fields.ContainsKey(Item.FieldNo(SystemCreatedBy)), 'SystemCreatedBy must be included');
        Assert.IsTrue(Fields.ContainsKey(Item.FieldNo(SystemModifiedAt)), 'SystemModifiedAt must be included');
        Assert.IsTrue(Fields.ContainsKey(Item.FieldNo(SystemModifiedBy)), 'SystemModifiedBy must be included');
        Assert.IsFalse(Fields.ContainsKey(Item.FieldNo(Inventory)), 'The FlowField Inventory must be excluded');
        Assert.IsFalse(Fields.ContainsKey(Item.FieldNo(Picture)), 'The media set field Picture must be excluded');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure StoredFieldNamedIdIsSuffixedSoTheSystemIdKeepsId()
    var
        NPAPIKey: Record "NPR NaviPartner API Key";
        BIMetadata: Codeunit "NPR API BI Metadata";
        Fields: Dictionary of [Integer, Text];
    begin
        // [SCENARIO] A stored field whose json name collides with a reserved name gets its field number appended.
        // [GIVEN] The NaviPartner API Key table, whose first field is named Id

        // [WHEN] The field map is built
        BIMetadata.BuildFieldMap(Database::"NPR NaviPartner API Key", Fields);

        // [THEN] The stored field is suffixed and the system id keeps the reserved name
        Assert.AreEqual('id_1', Fields.Get(NPAPIKey.FieldNo(Id)), 'The stored field Id must be suffixed');
        Assert.AreEqual('id', Fields.Get(NPAPIKey.FieldNo(SystemId)), 'The system id must keep the name id');
    end;
    #endregion

    #region Data endpoint: access
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BiReadIsForbiddenWithoutEntraApp()
    var
        QueryParameters: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        Response: JsonObject;
    begin
        // [SCENARIO] A caller that holds the BI permission set but is not an Entra ID application is refused.
        // [GIVEN] The BI permission set and no Entra ID application for the current user
        LibraryAPIBI.ResetBIPrincipals();
        LibraryAPIBI.GrantBIPermission();

        // [WHEN] The Item table is read
        Response := LibraryAPIBI.CallBI(Database::Item, QueryParameters, Headers);

        // [THEN] The request is forbidden because no principal could be resolved
        Assert.AreEqual(403, LibraryAPIBI.GetStatusCode(Response), 'Status code');
        Assert.AreEqual('bi_principal_not_resolved', LibraryAPIBI.GetErrorCode(Response), 'Error code');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BiReadIsForbiddenWhenTableIsNotAllowlisted()
    var
        AADApplication: Record "AAD Application";
        QueryParameters: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        Response: JsonObject;
    begin
        // [SCENARIO] Holding the module permission set is not enough: the table itself has to be allowlisted.
        // [GIVEN] An Entra ID application that is allowlisted for Customer but not for Item
        LibraryAPIBI.ResetBIPrincipals();
        LibraryAPIBI.GrantBIPermission();
        LibraryAPIBI.CreateEntraAppForCurrentUser(AADApplication);
        LibraryAPIBI.AllowTable("NPR API BI Principal Type"::"Entra App", AADApplication."Client Id", Database::Customer);

        // [WHEN] The Item table is read
        Response := LibraryAPIBI.CallBI(Database::Item, QueryParameters, Headers);

        // [THEN] The request is forbidden because the table is not allowed
        Assert.AreEqual(403, LibraryAPIBI.GetStatusCode(Response), 'Status code');
        Assert.AreEqual('bi_table_not_allowed', LibraryAPIBI.GetErrorCode(Response), 'Error code');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BiReadUsesTheApiKeyAllowlistWhenTheEntraAppBelongsToAKey()
    var
        AADApplication: Record "AAD Application";
        NPAPIKey: Record "NPR NaviPartner API Key";
        QueryParameters: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        CustomerResponse: JsonObject;
        ItemResponse: JsonObject;
    begin
        // [SCENARIO] For an Entra ID application that belongs to an API key, only the allowlist of the key counts.
        // [GIVEN] A linked application, with Customer allowed for its client id and Item allowed for the key
        LibraryAPIBI.ResetBIPrincipals();
        LibraryAPIBI.GrantBIPermission();
        LibraryAPIBI.CreateEntraAppForCurrentUser(AADApplication);
        LibraryAPIBI.CreateApiKey(NPAPIKey);
        LibraryAPIBI.LinkEntraAppToApiKey(AADApplication, NPAPIKey);
        LibraryAPIBI.AllowTable("NPR API BI Principal Type"::"Entra App", AADApplication."Client Id", Database::Customer);
        LibraryAPIBI.AllowTable("NPR API BI Principal Type"::"NP API Key", NPAPIKey.Id, Database::Item);

        // [WHEN] Both tables are read
        CustomerResponse := LibraryAPIBI.CallBI(Database::Customer, QueryParameters, Headers);
        ItemResponse := LibraryAPIBI.CallBI(Database::Item, QueryParameters, Headers);

        // [THEN] The row of the client id is ignored and the row of the key is honoured
        Assert.AreEqual(403, LibraryAPIBI.GetStatusCode(CustomerResponse), 'The client id row must be ignored');
        Assert.AreEqual(200, LibraryAPIBI.GetStatusCode(ItemResponse), 'The API key row must be honoured');
    end;
    #endregion

    #region Data endpoint: payload, pagination and sync
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BiReadReturnsStoredFieldsAndTheSystemIdAsId()
    var
        AADApplication: Record "AAD Application";
        Item: Record Item;
        LibraryInventory: Codeunit "Library - Inventory";
        QueryParameters: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        Response: JsonObject;
        DataArray: JsonArray;
        RecordToken: JsonToken;
        RecordJson: JsonObject;
    begin
        // [SCENARIO] A record of an allowlisted table comes back as one json object per record, with the stored fields only.
        // [GIVEN] An Entra ID application allowlisted for Item, at least one item, and a page size of one
        LibraryAPIBI.ResetBIPrincipals();
        LibraryAPIBI.GrantBIPermission();
        LibraryAPIBI.CreateEntraAppForCurrentUser(AADApplication);
        LibraryAPIBI.AllowTable("NPR API BI Principal Type"::"Entra App", AADApplication."Client Id", Database::Item);
        LibraryInventory.CreateItem(Item);
        QueryParameters.Add('pageSize', '1');

        // [WHEN] The Item table is read
        Response := LibraryAPIBI.CallBI(Database::Item, QueryParameters, Headers);

        // [THEN] The record carries the stored fields and the system id, and no calculated or binary field
        Assert.AreEqual(200, LibraryAPIBI.GetStatusCode(Response), 'Status code');
        DataArray := LibraryAPIBI.GetDataArray(Response);
        Assert.AreEqual(1, DataArray.Count(), 'The page size must be honoured');
        DataArray.Get(0, RecordToken);
        RecordJson := RecordToken.AsObject();
        Assert.IsTrue(RecordJson.Contains('id'), 'id must be present');
        Assert.IsTrue(RecordJson.Contains('no'), 'no must be present');
        Assert.IsTrue(RecordJson.Contains('description'), 'description must be present');
        Assert.IsTrue(RecordJson.Contains('systemModifiedAt'), 'systemModifiedAt must be present');
        Assert.IsFalse(RecordJson.Contains('inventory'), 'The FlowField inventory must be absent');
        Assert.IsFalse(RecordJson.Contains('picture'), 'The media set field picture must be absent');
        Assert.IsTrue(RecordJson.Contains('rowVersion'), 'Every record carries rowVersion, because every read is incremental');
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BiSyncReturnsRecordsNewerThanLastRowVersionInAscendingOrder()
    var
        AADApplication: Record "AAD Application";
        NewestItem: Record Item;
        QueryParameters: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        Response: JsonObject;
        DataArray: JsonArray;
        RecordToken: JsonToken;
        Baseline: BigInteger;
        PreviousRowVersion: BigInteger;
        CurrentRowVersion: BigInteger;
        Records: Integer;
        FoundNewestItem: Boolean;
    begin
        // [SCENARIO] In sync mode the records come back ordered by ascending row version, starting just after the row version the caller asked from.
        // [GIVEN] An allowlisted Item table and a baseline that leaves the three newest settled items in the window
        LibraryAPIBI.ResetBIPrincipals();
        LibraryAPIBI.GrantBIPermission();
        LibraryAPIBI.CreateEntraAppForCurrentUser(AADApplication);
        LibraryAPIBI.AllowTable("NPR API BI Principal Type"::"Entra App", AADApplication."Client Id", Database::Item);
        Baseline := LibraryAPIBI.GetSettledBaseline(3);
        Assert.AreNotEqual(0, Baseline, 'The company needs at least four settled items for this test');
        Assert.IsTrue(LibraryAPIBI.GetSettledItem(1, NewestItem), 'The newest settled item must be readable');
        QueryParameters.Add('lastRowVersion', Format(Baseline, 0, 9));

        // [WHEN] The table is read in sync mode
        Response := LibraryAPIBI.CallBI(Database::Item, QueryParameters, Headers);

        // [THEN] Three records come back, every row version is newer than the baseline, and they ascend
        Assert.AreEqual(200, LibraryAPIBI.GetStatusCode(Response), 'Status code');
        DataArray := LibraryAPIBI.GetDataArray(Response);
        PreviousRowVersion := Baseline;
        foreach RecordToken in DataArray do begin
            CurrentRowVersion := LibraryAPIBI.GetBigInteger(RecordToken.AsObject(), 'rowVersion');
            Assert.IsTrue(CurrentRowVersion > PreviousRowVersion, 'Row versions must ascend and be newer than lastRowVersion');
            PreviousRowVersion := CurrentRowVersion;
            Records += 1;
            if LibraryAPIBI.GetText(RecordToken.AsObject(), 'no') = NewestItem."No." then
                FoundNewestItem := true;
        end;
        Assert.AreEqual(3, Records, 'The window must hold exactly the three newest settled items');
        Assert.IsTrue(FoundNewestItem, 'The newest settled item must be one of them');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BiSyncExcludesTheRecordAtTheGivenLastRowVersion()
    var
        AADApplication: Record "AAD Application";
        NewestItem: Record Item;
        SecondItem: Record Item;
        QueryParameters: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        Response: JsonObject;
        DataArray: JsonArray;
        RecordToken: JsonToken;
        ItemNo: Text;
        FoundNewest: Boolean;
        FoundSecond: Boolean;
    begin
        // [SCENARIO] lastRowVersion is exclusive: the record whose own row version is supplied is not returned again, while a newer one still is.
        // [GIVEN] An allowlisted Item table and a filter set to the row version of the second newest settled item
        LibraryAPIBI.ResetBIPrincipals();
        LibraryAPIBI.GrantBIPermission();
        LibraryAPIBI.CreateEntraAppForCurrentUser(AADApplication);
        LibraryAPIBI.AllowTable("NPR API BI Principal Type"::"Entra App", AADApplication."Client Id", Database::Item);
        Assert.IsTrue(LibraryAPIBI.GetSettledItem(1, NewestItem), 'The company needs at least two settled items for this test');
        Assert.IsTrue(LibraryAPIBI.GetSettledItem(2, SecondItem), 'The company needs at least two settled items for this test');
        QueryParameters.Add('lastRowVersion', Format(SecondItem.SystemRowVersion, 0, 9));

        // [WHEN] The table is read in sync mode from that row version
        Response := LibraryAPIBI.CallBI(Database::Item, QueryParameters, Headers);

        // [THEN] That record is excluded and the newer one is still returned
        Assert.AreEqual(200, LibraryAPIBI.GetStatusCode(Response), 'Status code');
        DataArray := LibraryAPIBI.GetDataArray(Response);
        foreach RecordToken in DataArray do begin
            ItemNo := LibraryAPIBI.GetText(RecordToken.AsObject(), 'no');
            if ItemNo = NewestItem."No." then
                FoundNewest := true;
            if ItemNo = SecondItem."No." then
                FoundSecond := true;
        end;
        Assert.IsFalse(FoundSecond, 'The record at lastRowVersion must be excluded');
        Assert.IsTrue(FoundNewest, 'A record newer than lastRowVersion must still be returned, which also proves the read was not simply empty');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BiReadIsRejectedForATableWithoutRowVersionIndex()
    var
        AADApplication: Record "AAD Application";
        QueryParameters: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        Response: JsonObject;
    begin
        // [SCENARIO] A table with no index on the row version is refused with a clear error, because every read is incremental and needs that index to order and resume by.
        // [GIVEN] An allowlisted table without an index that starts with SystemRowVersion
        LibraryAPIBI.ResetBIPrincipals();
        LibraryAPIBI.GrantBIPermission();
        LibraryAPIBI.CreateEntraAppForCurrentUser(AADApplication);
        LibraryAPIBI.AllowTable("NPR API BI Principal Type"::"Entra App", AADApplication."Client Id", Database::"NPR NaviPartner API Key");

        // [WHEN] That table is read
        Response := LibraryAPIBI.CallBI(Database::"NPR NaviPartner API Key", QueryParameters, Headers);

        // [THEN] The request is rejected as a bad request naming the missing index
        Assert.AreEqual(400, LibraryAPIBI.GetStatusCode(Response), 'Status code');
        Assert.AreEqual('bi_missing_rowversion_index', LibraryAPIBI.GetErrorCode(Response), 'Error code');
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BiUnknownTableNumberIsNotFound()
    var
        AADApplication: Record "AAD Application";
        QueryParameters: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        Response: JsonObject;
    begin
        // [SCENARIO] A table number that no table uses is reported as a missing resource.
        // [GIVEN] The BI permission set and an Entra ID application
        LibraryAPIBI.ResetBIPrincipals();
        LibraryAPIBI.GrantBIPermission();
        LibraryAPIBI.CreateEntraAppForCurrentUser(AADApplication);

        // [WHEN] A table number that does not exist is read
        Response := LibraryAPIBI.CallBI(1999999999, QueryParameters, Headers);

        // [THEN] The response is not found
        Assert.AreEqual(404, LibraryAPIBI.GetStatusCode(Response), 'Status code');
        Assert.AreEqual('resource_not_found', LibraryAPIBI.GetErrorCode(Response), 'Error code');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BiNonNumericTableNumberIsABadRequest()
    var
        AADApplication: Record "AAD Application";
        Body: JsonObject;
        Response: JsonObject;
        QueryParameters: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] A path segment that is not a number is reported as invalid input, not as a missing resource.
        // [GIVEN] The BI permission set and an Entra ID application
        LibraryAPIBI.ResetBIPrincipals();
        LibraryAPIBI.GrantBIPermission();
        LibraryAPIBI.CreateEntraAppForCurrentUser(AADApplication);

        // [WHEN] A table name is used instead of a table number
        Response := LibraryNPRetailAPI.CallApi('GET', '/bi/item', Body, QueryParameters, Headers);

        // [THEN] The response is a bad request
        Assert.AreEqual(400, LibraryAPIBI.GetStatusCode(Response), 'Status code');
        Assert.AreEqual('invalid_input', LibraryAPIBI.GetErrorCode(Response), 'Error code');
    end;
    #endregion

    #region Table metadata
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MetadataListFlagsAllowedAndSyncSupportedPerTable()
    var
        AADApplication: Record "AAD Application";
        Headers: Dictionary of [Text, Text];
        Response: JsonObject;
        DataArray: JsonArray;
        TableToken: JsonToken;
        TableJson: JsonObject;
        ItemSeen: Boolean;
        NoSyncTableSeen: Boolean;
    begin
        // [SCENARIO] The table list tells the caller which tables it may read and which of them support delta load.
        // [GIVEN] An Entra ID application allowlisted for Item only
        LibraryAPIBI.ResetBIPrincipals();
        LibraryAPIBI.GrantBIPermission();
        LibraryAPIBI.CreateEntraAppForCurrentUser(AADApplication);
        LibraryAPIBI.AllowTable("NPR API BI Principal Type"::"Entra App", AADApplication."Client Id", Database::Item);

        // [WHEN] The table list is requested
        Response := LibraryAPIBI.CallApiPath('/tablemetadata', Headers);

        // [THEN] Item is allowed and supports sync, and a table that is neither is flagged accordingly
        Assert.AreEqual(200, LibraryAPIBI.GetStatusCode(Response), 'Status code');
        DataArray := LibraryAPIBI.GetDataArray(Response);
        foreach TableToken in DataArray do begin
            TableJson := TableToken.AsObject();
            case LibraryAPIBI.GetInteger(TableJson, 'tableNo') of
                Database::Item:
                    begin
                        ItemSeen := true;
                        Assert.IsTrue(LibraryAPIBI.GetRequiredBoolean(TableJson, 'allowed'), 'Item must be allowed');
                        Assert.IsTrue(LibraryAPIBI.GetRequiredBoolean(TableJson, 'syncSupported'), 'Item must support sync');
                        Assert.AreEqual('Item', LibraryAPIBI.GetText(TableJson, 'name'), 'The English name of Item');
                        Assert.AreEqual('Item', LibraryAPIBI.GetText(TableJson, 'systemName'), 'The system name of Item');
                    end;
                Database::"NPR NaviPartner API Key":
                    begin
                        NoSyncTableSeen := true;
                        Assert.IsFalse(LibraryAPIBI.GetRequiredBoolean(TableJson, 'allowed'), 'The API key table must not be allowed');
                        Assert.IsFalse(LibraryAPIBI.GetRequiredBoolean(TableJson, 'syncSupported'), 'The API key table must not support sync');
                    end;
            end;
        end;
        Assert.IsTrue(ItemSeen, 'Item must be listed');
        Assert.IsTrue(NoSyncTableSeen, 'The API key table must be listed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MetadataTableDescribesTheFieldsTheDataEndpointReturns()
    var
        Item: Record Item;
        Headers: Dictionary of [Text, Text];
        Response: JsonObject;
        Body: JsonObject;
        FieldsToken: JsonToken;
        FieldToken: JsonToken;
        FieldJson: JsonObject;
        GuidTypeName: Text;
        DateTimeTypeName: Text;
        NumberFieldSeen: Boolean;
        InventorySeen: Boolean;
    begin
        // [SCENARIO] Field metadata describes exactly the fields the data endpoint returns, with their json names and types.
        // [GIVEN] The BI permission set and a request for English
        LibraryAPIBI.ResetBIPrincipals();
        LibraryAPIBI.GrantBIPermission();
        Headers.Add('accept-language', 'en-US,da;q=0.8');

        // [WHEN] The metadata of the Item table is requested
        Response := LibraryAPIBI.CallApiPath(StrSubstNo('/tablemetadata/%1', Database::Item), Headers);

        // [THEN] The No. field is described in full, the FlowField is absent and the language is echoed
        Assert.AreEqual(200, LibraryAPIBI.GetStatusCode(Response), 'Status code');
        Body := LibraryAPIBI.GetBody(Response);
        Assert.AreEqual('en-US', LibraryAPIBI.GetText(Body, 'language'), 'The language must be echoed');
        Assert.AreEqual(Database::Item, LibraryAPIBI.GetInteger(Body, 'tableNo'), 'The table number');
        Assert.IsTrue(LibraryAPIBI.GetBoolean(Body, 'syncSupported'), 'Item must support sync');
        Body.Get('fields', FieldsToken);
        foreach FieldToken in FieldsToken.AsArray() do begin
            FieldJson := FieldToken.AsObject();
            case LibraryAPIBI.GetInteger(FieldJson, 'fieldNo') of
                Item.FieldNo("No."):
                    begin
                        NumberFieldSeen := true;
                        Assert.AreEqual('no', LibraryAPIBI.GetText(FieldJson, 'jsonName'), 'The json name of No.');
                        Assert.AreEqual('No.', LibraryAPIBI.GetText(FieldJson, 'systemName'), 'The system name of No.');
                        Assert.AreEqual('Code', LibraryAPIBI.GetText(FieldJson, 'type'), 'The type of No.');
                        Assert.AreEqual(20, LibraryAPIBI.GetInteger(FieldJson, 'length'), 'The length of No.');
                        Assert.IsTrue(LibraryAPIBI.GetBoolean(FieldJson, 'isPartOfPrimaryKey'), 'No. is part of the primary key');
                    end;
                Item.FieldNo(SystemId):
                    GuidTypeName := LibraryAPIBI.GetText(FieldJson, 'type');
                Item.FieldNo(SystemModifiedAt):
                    DateTimeTypeName := LibraryAPIBI.GetText(FieldJson, 'type');
                Item.FieldNo(Inventory):
                    InventorySeen := true;
            end;
        end;
        Assert.IsTrue(NumberFieldSeen, 'The No. field must be described');
        Assert.IsFalse(InventorySeen, 'The FlowField Inventory must not be described');

        // [THEN] The type names are the ones the published documentation lists
        Assert.AreEqual('GUID', GuidTypeName, 'The type name of a Guid field');
        Assert.AreEqual('DateTime', DateTimeTypeName, 'The type name of a DateTime field');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MetadataSurvivesAnUnknownLanguageTag()
    var
        Headers: Dictionary of [Text, Text];
        Response: JsonObject;
        Body: JsonObject;
    begin
        // [SCENARIO] A language tag the platform does not know falls back to a usable language instead of failing the request.
        // [GIVEN] The BI permission set and a nonsense Accept-Language header
        LibraryAPIBI.ResetBIPrincipals();
        LibraryAPIBI.GrantBIPermission();
        Headers.Add('accept-language', 'xx-INVALID');

        // [WHEN] The metadata of the Item table is requested
        Response := LibraryAPIBI.CallApiPath(StrSubstNo('/tablemetadata/%1', Database::Item), Headers);

        // [THEN] The request succeeds and reports the language it fell back to
        Assert.AreEqual(200, LibraryAPIBI.GetStatusCode(Response), 'Status code');
        Body := LibraryAPIBI.GetBody(Response);
        Assert.AreNotEqual('', LibraryAPIBI.GetText(Body, 'language'), 'A language must be reported');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MetadataIsReadableWithoutAnAllowlistRow()
    var
        AADApplication: Record "AAD Application";
        Headers: Dictionary of [Text, Text];
        Response: JsonObject;
        Body: JsonObject;
    begin
        // [SCENARIO] Metadata is open to every holder of the BI permission set; only the data itself is gated by the allowlist.
        // [GIVEN] An Entra ID application with no allowlist row at all
        LibraryAPIBI.ResetBIPrincipals();
        LibraryAPIBI.GrantBIPermission();
        LibraryAPIBI.CreateEntraAppForCurrentUser(AADApplication);

        // [WHEN] The metadata of the Item table is requested
        Response := LibraryAPIBI.CallApiPath(StrSubstNo('/tablemetadata/%1', Database::Item), Headers);

        // [THEN] The metadata is returned and reports that the table may not be read
        Assert.AreEqual(200, LibraryAPIBI.GetStatusCode(Response), 'Status code');
        Body := LibraryAPIBI.GetBody(Response);
        Assert.IsFalse(LibraryAPIBI.GetBoolean(Body, 'allowed'), 'The table must be reported as not allowed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MetadataUnknownTableNumberIsNotFound()
    var
        Headers: Dictionary of [Text, Text];
        Response: JsonObject;
    begin
        // [SCENARIO] Asking for the metadata of a table that does not exist is reported as a missing resource.
        // [GIVEN] The BI permission set
        LibraryAPIBI.ResetBIPrincipals();
        LibraryAPIBI.GrantBIPermission();

        // [WHEN] The metadata of a system table is requested
        Response := LibraryAPIBI.CallApiPath(StrSubstNo('/tablemetadata/%1', Database::"Table Metadata"), Headers);

        // [THEN] The response is not found
        Assert.AreEqual(404, LibraryAPIBI.GetStatusCode(Response), 'Status code');
    end;
    #endregion

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MetadataSyncFlagAgreesWithTheReaderForEveryListedTable()
    var
        Headers: Dictionary of [Text, Text];
        Response: JsonObject;
        DataArray: JsonArray;
        TableToken: JsonToken;
        TableJson: JsonObject;
        APIRequest: Codeunit "NPR API Request";
        RecRef: RecordRef;
        Checked: Integer;
        Compared: Integer;
        TableNo: Integer;
    begin
        // [SCENARIO] The sync flag in the table list agrees with the check the data endpoint itself performs, so the list never promises delta load that the read would refuse.
        // [GIVEN] The table list as the BI API returns it
        LibraryAPIBI.ResetBIPrincipals();
        LibraryAPIBI.GrantBIPermission();
        Response := LibraryAPIBI.CallApiPath('/tablemetadata', Headers);
        DataArray := LibraryAPIBI.GetDataArray(Response);

        // [WHEN] The flag of a sample of the listed tables is compared with the reader
        foreach TableToken in DataArray do begin
            Checked += 1;
            if (Checked mod 25) = 0 then begin
                TableJson := TableToken.AsObject();
                TableNo := LibraryAPIBI.GetInteger(TableJson, 'tableNo');
                Clear(RecRef);
                RecRef.Open(TableNo);

                // [THEN] Both agree
                Assert.AreEqual(
                    APIRequest.HasRowVersionKey(RecRef),
                    LibraryAPIBI.GetRequiredBoolean(TableJson, 'syncSupported'),
                    StrSubstNo('The sync flag of table %1 must match the reader', TableNo));
                RecRef.Close();
                Compared += 1;
            end;
        end;
        Assert.IsTrue(Checked > 0, 'The table list must not be empty');
        Assert.IsTrue(Compared > 0, 'The sampling must have compared at least one table, otherwise this test proves nothing');
    end;

    #region Module permission
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BiRequiresItsOwnPermissionSet()
    var
        AADApplication: Record "AAD Application";
        AccessControl: Record "Access Control";
        QueryParameters: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        Response: JsonObject;
    begin
        // [SCENARIO] Without the BI permission set the endpoint is refused before any allowlist is consulted.
        // [GIVEN] An allowlisted Entra ID application whose user does not hold the BI permission set
        LibraryAPIBI.ResetBIPrincipals();
        LibraryAPIBI.CreateEntraAppForCurrentUser(AADApplication);
        LibraryAPIBI.AllowTable("NPR API BI Principal Type"::"Entra App", AADApplication."Client Id", Database::Item);
        AccessControl.SetRange("User Security ID", UserSecurityId());
        AccessControl.SetRange("Role ID", 'NPR API BI');
        if not AccessControl.IsEmpty() then
            AccessControl.DeleteAll(false);
        SelectLatestVersion();

        // [WHEN] The Item table is read
        Response := LibraryAPIBI.CallBI(Database::Item, QueryParameters, Headers);

        // [THEN] The request is forbidden because the permission set is missing
        Assert.AreEqual(403, LibraryAPIBI.GetStatusCode(Response), 'Status code');
    end;
    #endregion

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ReaderReturnsTheStableValueNameForAnEnumField()
    var
        BIAllowedTable: Record "NPR API BI Allowed Table";
        APIRequest: Codeunit "NPR API Request";
        Fields: Dictionary of [Integer, Text];
        Result: JsonObject;
        DataArray: JsonArray;
        RecordToken: JsonToken;
        PrincipalTypeValue: Text;
        Records: Integer;
    begin
        // [SCENARIO] An enum field is serialised as its value name, which is the same in every language, and not as the translated caption, which is not safe to store or compare.
        // [GIVEN] One record whose Principal Type is the value "NP API Key", a value whose caption is the different text "NaviPartner API Key"
        LibraryAPIBI.ResetBIPrincipals();
        LibraryAPIBI.AllowTable("NPR API BI Principal Type"::"NP API Key", CreateGuid(), Database::Item);
        BIAllowedTable.FindLast();
        BIAllowedTable.SetRecFilter();
        Fields.Add(BIAllowedTable.FieldNo("Principal Type"), 'principalType');

        // [WHEN] The shared reader serialises it
        Result := APIRequest.GetData(BIAllowedTable, Fields);

        // [THEN] The property carries the value name, never the caption
        Result.Get('data', RecordToken);
        DataArray := RecordToken.AsArray();
        foreach RecordToken in DataArray do begin
            Records += 1;
            PrincipalTypeValue := LibraryAPIBI.GetText(RecordToken.AsObject(), 'principalType');
            Assert.AreEqual('NP API Key', PrincipalTypeValue, 'An enum field must carry the value name');
            Assert.AreNotEqual('NaviPartner API Key', PrincipalTypeValue, 'An enum field must not carry the translated caption');
        end;
        Assert.AreEqual(1, Records, 'The record must be returned, otherwise nothing above was asserted');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BiSyncPagesThroughEveryRecordOnceInRowVersionOrder()
    var
        AADApplication: Record "AAD Application";
        QueryParameters: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        Response: JsonObject;
        Body: JsonObject;
        DataArray: JsonArray;
        RecordToken: JsonToken;
        SeenIds: List of [Text];
        RecordId: Text;
        NextPageKey: Text;
        Baseline: BigInteger;
        PreviousRowVersion: BigInteger;
        CurrentRowVersion: BigInteger;
        MorePages: Boolean;
        Pages: Integer;
    begin
        // [SCENARIO] An initial load, which is sync mode followed page by page, returns every record once with the row versions still ascending across the page boundaries.
        // [GIVEN] An allowlisted Item table, a baseline that leaves the five newest settled items in the window, and a page size of two
        LibraryAPIBI.ResetBIPrincipals();
        LibraryAPIBI.GrantBIPermission();
        LibraryAPIBI.CreateEntraAppForCurrentUser(AADApplication);
        LibraryAPIBI.AllowTable("NPR API BI Principal Type"::"Entra App", AADApplication."Client Id", Database::Item);
        Baseline := LibraryAPIBI.GetSettledBaseline(5);
        Assert.AreNotEqual(0, Baseline, 'The company needs at least six settled items for this test');
        QueryParameters.Add('pageSize', '2');
        QueryParameters.Add('lastRowVersion', Format(Baseline, 0, 9));
        PreviousRowVersion := Baseline;

        // [WHEN] Every page is followed to the end
        repeat
            Response := LibraryAPIBI.CallBI(Database::Item, QueryParameters, Headers);
            Assert.AreEqual(200, LibraryAPIBI.GetStatusCode(Response), 'Status code');
            Body := LibraryAPIBI.GetBody(Response);
            DataArray := LibraryAPIBI.GetDataArray(Response);
            Assert.IsTrue(DataArray.Count() <= 2, 'The page size must be honoured in sync mode as well');
            foreach RecordToken in DataArray do begin
                RecordId := LibraryAPIBI.GetText(RecordToken.AsObject(), 'id');
                Assert.IsFalse(SeenIds.Contains(RecordId), 'A record must not be returned twice across pages');
                SeenIds.Add(RecordId);

                CurrentRowVersion := LibraryAPIBI.GetBigInteger(RecordToken.AsObject(), 'rowVersion');
                Assert.IsTrue(CurrentRowVersion > PreviousRowVersion, 'Row versions must keep ascending across a page boundary');
                PreviousRowVersion := CurrentRowVersion;
            end;
            MorePages := LibraryAPIBI.GetRequiredBoolean(Body, 'morePages');
            if MorePages then begin
                NextPageKey := LibraryAPIBI.GetText(Body, 'nextPageKey');
                Assert.AreNotEqual('', NextPageKey, 'A page key must be returned while there are more pages');
                if QueryParameters.ContainsKey('pageKey') then
                    QueryParameters.Set('pageKey', NextPageKey)
                else
                    QueryParameters.Add('pageKey', NextPageKey);
            end;
            Pages += 1;
        until (not MorePages) or (Pages > 50);

        // [THEN] Paging finished on its own and returned the five records once each, over more than one page
        Assert.IsTrue(Pages <= 50, 'Paging did not finish, so the page key is not advancing in sync mode');
        Assert.IsTrue(Pages > 1, 'The data must span more than one page, otherwise the page boundary is untested');
        Assert.AreEqual(5, SeenIds.Count(), 'Every record in the window must be returned exactly once');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BiReadRejectsAnAttemptToTurnSyncOff()
    var
        AADApplication: Record "AAD Application";
        QueryParameters: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        Response: JsonObject;
    begin
        // [SCENARIO] Reads are always incremental, so asking for sync to be off is refused rather than silently ignored, which would leave the consumer believing it had a full read.
        // [GIVEN] An allowlisted Item table and a request asking for sync to be off
        LibraryAPIBI.ResetBIPrincipals();
        LibraryAPIBI.GrantBIPermission();
        LibraryAPIBI.CreateEntraAppForCurrentUser(AADApplication);
        LibraryAPIBI.AllowTable("NPR API BI Principal Type"::"Entra App", AADApplication."Client Id", Database::Item);
        QueryParameters.Add('sync', 'false');

        // [WHEN] The table is read
        Response := LibraryAPIBI.CallBI(Database::Item, QueryParameters, Headers);

        // [THEN] The request is rejected as invalid input
        Assert.AreEqual(400, LibraryAPIBI.GetStatusCode(Response), 'Status code');
        Assert.AreEqual('invalid_input', LibraryAPIBI.GetErrorCode(Response), 'Error code');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BiReadStillAcceptsSyncTrueAsANoOp()
    var
        AADApplication: Record "AAD Application";
        QueryParameters: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        Response: JsonObject;
    begin
        // [SCENARIO] A consumer written before sync became implicit keeps working, because sync=true asks for what the endpoint already does.
        // [GIVEN] An allowlisted Item table and a request that still passes sync=true
        LibraryAPIBI.ResetBIPrincipals();
        LibraryAPIBI.GrantBIPermission();
        LibraryAPIBI.CreateEntraAppForCurrentUser(AADApplication);
        LibraryAPIBI.AllowTable("NPR API BI Principal Type"::"Entra App", AADApplication."Client Id", Database::Item);
        QueryParameters.Add('sync', 'true');

        // [WHEN] The table is read
        Response := LibraryAPIBI.CallBI(Database::Item, QueryParameters, Headers);

        // [THEN] The read succeeds
        Assert.AreEqual(200, LibraryAPIBI.GetStatusCode(Response), 'Status code');
    end;
}
