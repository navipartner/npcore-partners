#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85204 "NPR APIPOSSale Park"
{
    // [FEATURE] POST /pos/sale/:saleId/park — saves the active sale as a Saved Sale Entry

    Subtype = Test;

    var
        _Initialized: Boolean;
        _POSUnit: Record "NPR POS Unit";
        _POSStore: Record "NPR POS Store";
        _Item: Record Item;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ParkSale_ReturnsSavedEntryWithReceiptAndPosUnit()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        POSSavedSaleEntry: Record "NPR POS Saved Sale Entry";
        POSSaleRec: Record "NPR POS Sale";
        JToken: JsonToken;
        SaleId: Guid;
        SavedSaleSystemIdText: Text;
        SavedSaleSystemId: Guid;
    begin
        // [SCENARIO] POST /pos/sale/{id}/park parks the active sale and returns the saved entry info.
        Initialize();
        SaleId := CreateActiveSale();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/park', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Park should succeed');

        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('saleId', JToken), 'Response should contain saleId');
        SavedSaleSystemIdText := JToken.AsValue().AsText();
        Assert.AreNotEqual('', SavedSaleSystemIdText, 'saleId should not be empty');

        Evaluate(SavedSaleSystemId, SavedSaleSystemIdText);
        Assert.IsTrue(POSSavedSaleEntry.GetBySystemId(SavedSaleSystemId), 'Saved Sale Entry should exist');
        Assert.AreEqual(_POSUnit."No.", POSSavedSaleEntry."Register No.", 'Saved Sale Entry should be on the test POS Unit');

        ResponseBody.Get('posUnit', JToken);
        Assert.AreEqual(_POSUnit."No.", JToken.AsValue().AsText(), 'Response posUnit should match');
        ResponseBody.Get('receiptNo', JToken);
        Assert.AreNotEqual('', JToken.AsValue().AsText(), 'Response receiptNo should not be empty');

        Assert.IsFalse(POSSaleRec.GetBySystemId(SaleId), 'Active POS Sale should be gone after park');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ParkSale_Returns404WhenSaleGone()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        UnknownId: Guid;
        JToken: JsonToken;
        StatusCode: Integer;
    begin
        // [SCENARIO] POST /pos/sale/{unknownId}/park returns 404.
        Initialize();
        UnknownId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(UnknownId) + '/park', Body, QueryParams, Headers);
        Response.Get('statusCode', JToken);
        StatusCode := JToken.AsValue().AsInteger();
        Assert.AreEqual(404, StatusCode, 'Unknown sale should return 404');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ParkSale_Returns400WhenUnitClosed()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
        SaleId: Guid;
        StatusCode: Integer;
    begin
        // [SCENARIO] Parking while POS Unit is closed returns 400.
        Initialize();
        SaleId := CreateActiveSale();

        _POSUnit.Find();
        _POSUnit.Status := _POSUnit.Status::INACTIVE;
        _POSUnit.Modify();
        Commit();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/park', Body, QueryParams, Headers);
        Response.Get('statusCode', JToken);
        StatusCode := JToken.AsValue().AsInteger();
        Assert.AreEqual(400, StatusCode, 'Closed POS Unit should return 400');

        _POSUnit.Find();
        _POSUnit.Status := _POSUnit.Status::OPEN;
        _POSUnit.Modify();
        Commit();
    end;

    local procedure Initialize()
    var
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSSetup: Record "NPR POS Setup";
        UserSetup: Record "User Setup";
    begin
        if _Initialized then
            exit;

        LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API POS');

        LibraryPOSMasterData.CreatePOSSetup(POSSetup);
        LibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
        LibraryPOSMasterData.CreatePOSStore(_POSStore, POSPostingProfile.Code);
        LibraryPOSMasterData.CreatePOSUnit(_POSUnit, _POSStore.Code, POSPostingProfile.Code);
        LibraryPOSMasterData.DontPrintReceiptOnSaleEnd(_POSUnit);
        _POSUnit."POS Type" := _POSUnit."POS Type"::UNATTENDED;
        _POSUnit.Modify();

        if not UserSetup.Get(UserId) then begin
            UserSetup.Init();
            UserSetup."User ID" := CopyStr(UserId, 1, MaxStrLen(UserSetup."User ID"));
            UserSetup.Insert();
        end;
        UserSetup."NPR POS Unit No." := _POSUnit."No.";
        UserSetup.Modify();

        LibraryPOSMasterData.CreateItemForPOSSaleUsage(_Item, _POSUnit, _POSStore);

        CreateCleanupJobQueueEntry();

        _Initialized := true;
        Commit();
    end;

    local procedure CreateActiveSale() SaleId: Guid
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        SaleId := CreateGuid();
        Body.Add('posUnit', _POSUnit."No.");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(CreateGuid()), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Add sale line should succeed');
    end;

    local procedure CreateCleanupJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR JQ Cleanup Dead POS Sales");
        if not JobQueueEntry.IsEmpty() then
            exit;

        JobQueueEntry.Init();
        JobQueueEntry.ID := CreateGuid();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"NPR JQ Cleanup Dead POS Sales";
        JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
        JobQueueEntry.Insert(true);
    end;

    local procedure FormatGuid(Id: Guid): Text
    begin
        exit(Format(Id, 0, 4).ToLower());
    end;
}
#endif
