codeunit 85457 "NPR Library - API BI"
{
    Access = Internal;

    var
        _CreatedPrincipals: List of [Guid];
        TestEntraAppDescriptionLbl: Label 'BI API test app', Locked = true;
        TestApiKeyDescriptionLbl: Label 'BI API test key', Locked = true;

    /// <summary>
    /// Removes the BI principals and allowlist rows that earlier tests in this codeunit created.
    /// The test runner isolates per codeunit rather than per test, so without this the outcome of a
    /// test would depend on its neighbours.
    /// Only rows this library created are removed. The allowlist table is shared across companies
    /// and holds real setup, so wiping it wholesale would destroy configuration on any environment
    /// the suite happens to run against.
    /// </summary>
    procedure ResetBIPrincipals()
    var
        AADApplication: Record "AAD Application";
        BIAllowedTable: Record "NPR API BI Allowed Table";
        PrincipalId: Guid;
    begin
        AADApplication.SetRange("User ID", UserSecurityId());
        if not AADApplication.IsEmpty() then
            AADApplication.DeleteAll(false);

        foreach PrincipalId in _CreatedPrincipals do begin
            BIAllowedTable.Reset();
            BIAllowedTable.SetRange("Principal Id", PrincipalId);
            if not BIAllowedTable.IsEmpty() then
                BIAllowedTable.DeleteAll(false);
        end;
        Clear(_CreatedPrincipals);
    end;

    procedure CreateEntraAppForCurrentUser(var AADApplication: Record "AAD Application")
    begin
        AADApplication.Init();
        AADApplication."Client Id" := CreateGuid();
        AADApplication.Description := CopyStr(TestEntraAppDescriptionLbl, 1, MaxStrLen(AADApplication.Description));
        AADApplication.State := AADApplication.State::Enabled;
        AADApplication."User ID" := UserSecurityId();
        AADApplication.Insert(false);
    end;

    procedure CreateApiKey(var NPAPIKey: Record "NPR NaviPartner API Key")
    begin
        NPAPIKey.Init();
        NPAPIKey.Id := CreateGuid();
        NPAPIKey.Description := CopyStr(TestApiKeyDescriptionLbl, 1, MaxStrLen(NPAPIKey.Description));
        NPAPIKey.Status := NPAPIKey.Status::Active;
        NPAPIKey."Key Secret Hint" := 'test******test';
        NPAPIKey.Insert(false);
    end;

    procedure LinkEntraAppToApiKey(var AADApplication: Record "AAD Application"; NPAPIKey: Record "NPR NaviPartner API Key")
    begin
        AADApplication."NPR NaviPartner API Key Id" := NPAPIKey.Id;
        AADApplication.Modify(false);
    end;

    procedure AllowTable(PrincipalType: Enum "NPR API BI Principal Type"; PrincipalId: Guid; TableNo: Integer)
    var
        BIAllowedTable: Record "NPR API BI Allowed Table";
    begin
        BIAllowedTable.Init();
        BIAllowedTable."Principal Type" := PrincipalType;
        BIAllowedTable."Principal Id" := PrincipalId;
        BIAllowedTable.Validate("Table No.", TableNo);
        BIAllowedTable.Insert(true);

        if not _CreatedPrincipals.Contains(PrincipalId) then
            _CreatedPrincipals.Add(PrincipalId);
    end;

    procedure GrantBIPermission()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
    begin
        LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API BI');
        SelectLatestVersion();
    end;

    procedure CallBI(TableNo: Integer; QueryParameters: Dictionary of [Text, Text]; Headers: Dictionary of [Text, Text]) Response: JsonObject
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Body: JsonObject;
    begin
        exit(LibraryNPRetailAPI.CallApi('GET', StrSubstNo('/bi/%1', TableNo), Body, QueryParameters, Headers));
    end;

    procedure CallApiPath(Path: Text; Headers: Dictionary of [Text, Text]) Response: JsonObject
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Body: JsonObject;
        QueryParameters: Dictionary of [Text, Text];
    begin
        exit(LibraryNPRetailAPI.CallApi('GET', Path, Body, QueryParameters, Headers));
    end;

    procedure GetStatusCode(Response: JsonObject): Integer
    var
        JToken: JsonToken;
    begin
        if not Response.Get('statusCode', JToken) then
            exit(0);
        exit(JToken.AsValue().AsInteger());
    end;

    procedure GetErrorCode(Response: JsonObject): Text
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Body: JsonObject;
        JToken: JsonToken;
    begin
        Body := LibraryNPRetailAPI.GetResponseBody(Response);
        if not Body.Get('code', JToken) then
            exit('');
        exit(JToken.AsValue().AsText());
    end;

    procedure GetBody(Response: JsonObject) Body: JsonObject
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
    begin
        exit(LibraryNPRetailAPI.GetResponseBody(Response));
    end;

    procedure GetDataArray(Response: JsonObject) DataArray: JsonArray
    var
        Body: JsonObject;
        JToken: JsonToken;
    begin
        Body := GetBody(Response);
        if Body.Get('data', JToken) then
            DataArray := JToken.AsArray();
    end;

    procedure GetText(JsonObj: JsonObject; PropertyName: Text): Text
    var
        JToken: JsonToken;
    begin
        if not JsonObj.Get(PropertyName, JToken) then
            exit('');
        if JToken.AsValue().IsNull() then
            exit('');
        exit(JToken.AsValue().AsText());
    end;

    procedure GetInteger(JsonObj: JsonObject; PropertyName: Text): Integer
    var
        JToken: JsonToken;
    begin
        if not JsonObj.Get(PropertyName, JToken) then
            exit(0);
        exit(JToken.AsValue().AsInteger());
    end;

    procedure GetBigInteger(JsonObj: JsonObject; PropertyName: Text): BigInteger
    var
        JToken: JsonToken;
        Value: BigInteger;
    begin
        if not JsonObj.Get(PropertyName, JToken) then
            exit(0);
        if not Evaluate(Value, JToken.AsValue().AsText()) then
            exit(0);
        exit(Value);
    end;

    procedure GetBoolean(JsonObj: JsonObject; PropertyName: Text): Boolean
    var
        JToken: JsonToken;
    begin
        if not JsonObj.Get(PropertyName, JToken) then
            exit(false);
        exit(JToken.AsValue().AsBoolean());
    end;

    /// <summary>
    /// Reads a boolean that the payload is required to carry. GetBoolean cannot tell a missing
    /// property from a false one, so a test asserting "false" would still pass if the property were
    /// renamed out of the response.
    /// </summary>
    procedure GetRequiredBoolean(JsonObj: JsonObject; PropertyName: Text): Boolean
    var
        Assert: Codeunit Assert;
        JToken: JsonToken;
    begin
        Assert.IsTrue(JsonObj.Get(PropertyName, JToken), StrSubstNo('The response must carry the property %1', PropertyName));
        exit(JToken.AsValue().AsBoolean());
    end;

    /// <summary>
    /// The item that sits FromTop places from the newest SETTLED row version, where settled means
    /// below the minimum active row version. Sync mode deliberately stops below that boundary, so a
    /// record written by the running test transaction can never appear in a sync read and is useless
    /// as test data. The test runner keeps one transaction open for the whole codeunit, so anything
    /// an earlier test created is still active too.
    /// </summary>
    procedure GetSettledItem(FromTop: Integer; var Item: Record Item): Boolean
    var
        i: Integer;
    begin
        Item.Reset();
        Item.SetCurrentKey(SystemRowVersion);
        Item.SetFilter(SystemRowVersion, '<%1', Database.MinimumActiveRowVersion());
        Item.Ascending(false);
        if not Item.FindSet() then
            exit(false);
        for i := 2 to FromTop do
            if Item.Next() = 0 then
                exit(false);
        exit(true);
    end;

    /// <summary>
    /// A lastRowVersion that leaves exactly RecordsInWindow settled items in the sync window.
    /// </summary>
    procedure GetSettledBaseline(RecordsInWindow: Integer) Baseline: BigInteger
    var
        Item: Record Item;
    begin
        if not GetSettledItem(RecordsInWindow + 1, Item) then
            exit(0);
        exit(Item.SystemRowVersion);
    end;
}
