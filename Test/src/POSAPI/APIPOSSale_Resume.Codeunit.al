#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85205 "NPR APIPOSSale Resume"
{
    // [FEATURE] POST /pos/sale/:saleId/resume — restores a parked sale to an active POS Sale on the API user's User Setup POS unit

    Subtype = Test;

    var
        _Initialized: Boolean;
        _POSUnit: Record "NPR POS Unit";
        _POSStore: Record "NPR POS Store";
        _Item: Record Item;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ResumeSale_RestoresToActivePOSSale()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        ParkedSaleId: Guid;
        ResumedSaleIdText: Text;
        ResumedSaleSystemId: Guid;
        POSSaleRec: Record "NPR POS Sale";
        POSSavedSaleEntry: Record "NPR POS Saved Sale Entry";
    begin
        // [SCENARIO] POST /pos/sale/{parkedId}/resume recreates an active POS Sale and deletes the Saved Sale Entry.
        Initialize();
        ParkedSaleId := CreateParkedSale();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(ParkedSaleId) + '/resume', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Resume should succeed');

        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('saleId', JToken), 'Response should contain saleId');
        ResumedSaleIdText := JToken.AsValue().AsText();
        Evaluate(ResumedSaleSystemId, ResumedSaleIdText);
        Assert.IsTrue(POSSaleRec.GetBySystemId(ResumedSaleSystemId), 'Active POS Sale should exist after resume');
        Assert.AreEqual(_POSUnit."No.", POSSaleRec."Register No.", 'Resumed sale should be on requested POS Unit');

        Assert.IsFalse(POSSavedSaleEntry.GetBySystemId(ParkedSaleId), 'Saved Sale Entry should be gone after resume');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ResumeSale_Returns404WhenNotParked()
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
        Initialize();
        UnknownId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(UnknownId) + '/resume', Body, QueryParams, Headers);
        Response.Get('statusCode', JToken);
        StatusCode := JToken.AsValue().AsInteger();
        Assert.AreEqual(404, StatusCode, 'Unknown saved sale should return 404');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ResumeSale_NoPOSUnitInUserSetup_ReturnsBadRequest()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        UserSetup: Record "User Setup";
        ParkedSaleId: Guid;
        JToken: JsonToken;
        StatusCode: Integer;
    begin
        // [SCENARIO] Resume returns 400 when the API user's User Setup has no POS Unit assigned
        Initialize();
        ParkedSaleId := CreateParkedSale();

        // [GIVEN] API user's User Setup has no POS Unit
        UserSetup.Get(UserId);
        UserSetup."NPR POS Unit No." := '';
        UserSetup.Modify();
        Commit();

        // [WHEN] Resume
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(ParkedSaleId) + '/resume', Body, QueryParams, Headers);

        // [CLEANUP] Restore User Setup before asserting so later test methods are unaffected
        UserSetup.Get(UserId);
        UserSetup."NPR POS Unit No." := _POSUnit."No.";
        UserSetup.Modify();
        Commit();

        // [THEN] 400
        Response.Get('statusCode', JToken);
        StatusCode := JToken.AsValue().AsInteger();
        Assert.AreEqual(400, StatusCode, 'No POS Unit in User Setup should return 400');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ResumeSale_Returns400WhenUnitClosed()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ParkedSaleId: Guid;
        JToken: JsonToken;
        StatusCode: Integer;
    begin
        Initialize();
        ParkedSaleId := CreateParkedSale();

        _POSUnit.Find();
        _POSUnit.Status := _POSUnit.Status::INACTIVE;
        _POSUnit.Modify();
        Commit();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(ParkedSaleId) + '/resume', Body, QueryParams, Headers);
        Response.Get('statusCode', JToken);
        StatusCode := JToken.AsValue().AsInteger();
        Assert.AreEqual(400, StatusCode, 'Closed POS Unit should return 400');

        _POSUnit.Find();
        _POSUnit.Status := _POSUnit.Status::OPEN;
        _POSUnit.Modify();
        Commit();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ResumeSale_CanResumeOnDifferentPOSUnit()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        POSPostingProfile: Record "NPR POS Posting Profile";
        OtherPOSUnit: Record "NPR POS Unit";
        UserSetup: Record "User Setup";
        Response: JsonObject;
        ResponseBody: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
        ParkedSaleId: Guid;
        ResumedSaleIdText: Text;
        ResumedSaleSystemId: Guid;
        POSSaleRec: Record "NPR POS Sale";
    begin
        // [SCENARIO] A parked sale can be resumed onto a different POS Unit by reassigning the API user's User Setup POS Unit
        Initialize();
        ParkedSaleId := CreateParkedSale(); // parked on _POSUnit (the User Setup unit)

        POSPostingProfile.FindFirst();
        LibraryPOSMasterData.CreatePOSUnit(OtherPOSUnit, _POSStore.Code, POSPostingProfile.Code);
        LibraryPOSMasterData.DontPrintReceiptOnSaleEnd(OtherPOSUnit);
        OtherPOSUnit."POS Type" := OtherPOSUnit."POS Type"::UNATTENDED;
        OtherPOSUnit.Status := OtherPOSUnit.Status::OPEN;
        OtherPOSUnit.Modify();
        Assert.AreNotEqual(_POSUnit."No.", OtherPOSUnit."No.", 'Test setup must use two distinct POS Units');

        // [GIVEN] API user's User Setup now points at the OTHER unit
        UserSetup.Get(UserId);
        UserSetup."NPR POS Unit No." := OtherPOSUnit."No.";
        UserSetup.Modify();
        Commit();

        // [WHEN] Resume (unit resolved from User Setup)
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(ParkedSaleId) + '/resume', Body, QueryParams, Headers);

        // [CLEANUP] Restore User Setup before asserting so later test methods are unaffected
        UserSetup.Get(UserId);
        UserSetup."NPR POS Unit No." := _POSUnit."No.";
        UserSetup.Modify();
        Commit();

        // [THEN] The sale resumed onto the User-Setup unit (OtherPOSUnit)
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Resume on different POS Unit should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('saleId', JToken);
        ResumedSaleIdText := JToken.AsValue().AsText();
        Evaluate(ResumedSaleSystemId, ResumedSaleIdText);
        Assert.IsTrue(POSSaleRec.GetBySystemId(ResumedSaleSystemId), 'Active POS Sale should exist after cross-unit resume');
        Assert.AreEqual(OtherPOSUnit."No.", POSSaleRec."Register No.", 'Resumed sale should be on the User-Setup POS Unit');
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

    local procedure CreateParkedSale() SavedSaleSystemId: Guid
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        ActiveSaleId: Guid;
    begin
        ActiveSaleId := CreateGuid();
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(ActiveSaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(ActiveSaleId) + '/saleline/' + FormatGuid(CreateGuid()), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Add sale line should succeed');

        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(ActiveSaleId) + '/park', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Park should succeed');

        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('saleId', JToken);
        Evaluate(SavedSaleSystemId, JToken.AsValue().AsText());
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
