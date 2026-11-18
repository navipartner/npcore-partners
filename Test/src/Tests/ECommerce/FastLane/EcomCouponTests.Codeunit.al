#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 85243 "NPR Ecom Coupon Tests"
{
    Subtype = Test;

    var
        _Assert: Codeunit "Assert";
        _LibCoupon: Codeunit "NPR Library Coupon";
        _LibEcom: Codeunit "NPR Library Ecommerce";
        _LibDocApi: Codeunit "NPR Library Ecom Doc Api";
        _LibInventory: Codeunit "NPR Library - Inventory";

    #region CheckIfLineCanBeProcessed — tested via EcomCreateCouponImpl.Process()
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CouponProcess_NotCaptured_Error()
    var
        CouponType: Record "NPR NpDc Coupon Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        CouponImpl: Codeunit "NPR EcomCreateCouponImpl";
    begin
        // [Scenario] Process raises error when coupon line is not captured
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedCouponLine(EcomSalesLine, EcomSalesHeader, _LibEcom.CreateEcomCouponItem(CouponType), 1, 100);
        EcomSalesLine.Captured := false;
        EcomSalesLine.Modify();

        asserterror CouponImpl.Process(EcomSalesLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CouponProcess_WrongSubtype_Error()
    var
        CouponType: Record "NPR NpDc Coupon Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        CouponImpl: Codeunit "NPR EcomCreateCouponImpl";
    begin
        // [Scenario] Process raises error when line subtype is not Coupon
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedCouponLine(EcomSalesLine, EcomSalesHeader, _LibEcom.CreateEcomCouponItem(CouponType), 1, 100);
        EcomSalesLine.Subtype := EcomSalesLine.Subtype::" ";
        EcomSalesLine.Modify();

        asserterror CouponImpl.Process(EcomSalesLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CouponProcess_ReturnOrder_Error()
    var
        CouponType: Record "NPR NpDc Coupon Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        CouponImpl: Codeunit "NPR EcomCreateCouponImpl";
    begin
        // [Scenario] Process raises error when document type is Return Order
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedCouponLine(EcomSalesLine, EcomSalesHeader, _LibEcom.CreateEcomCouponItem(CouponType), 1, 100);
        EcomSalesLine."Document Type" := EcomSalesLine."Document Type"::"Return Order";
        EcomSalesLine.Modify();

        asserterror CouponImpl.Process(EcomSalesLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CouponProcess_AlreadyProcessed_Error()
    var
        CouponType: Record "NPR NpDc Coupon Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        CouponImpl: Codeunit "NPR EcomCreateCouponImpl";
    begin
        // [Scenario] Process raises error when line is already processed
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedCouponLine(EcomSalesLine, EcomSalesHeader, _LibEcom.CreateEcomCouponItem(CouponType), 1, 100);
        EcomSalesLine."Virtual Item Process Status" := EcomSalesLine."Virtual Item Process Status"::Processed;
        EcomSalesLine.Modify();

        asserterror CouponImpl.Process(EcomSalesLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CouponProcess_HeaderCreated_Error()
    var
        CouponType: Record "NPR NpDc Coupon Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        CouponImpl: Codeunit "NPR EcomCreateCouponImpl";
    begin
        // [Scenario] Process raises error when sales document creation status is Created
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."Creation Status" := EcomSalesHeader."Creation Status"::Created;
        EcomSalesHeader.Modify();
        CreateCapturedCouponLine(EcomSalesLine, EcomSalesHeader, _LibEcom.CreateEcomCouponItem(CouponType), 1, 100);

        asserterror CouponImpl.Process(EcomSalesLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CouponProcess_NoCouponType_Error()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        CouponImpl: Codeunit "NPR EcomCreateCouponImpl";
    begin
        // [Scenario] Process raises error when the item has no coupon type mapping in any setup table
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        // Create a line whose item has no NPR NpDc Iss.OnSale Setup Line or WalletCouponSetup record
        CreateCapturedCouponLine(EcomSalesLine, EcomSalesHeader, _LibInventory.CreateItemNo(), 1, 100);

        asserterror CouponImpl.Process(EcomSalesLine);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CouponProcess_UnsupportedModule_Error()
    var
        CouponType: Record "NPR NpDc Coupon Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        CouponImpl: Codeunit "NPR EcomCreateCouponImpl";
    begin
        // [Scenario] Process raises error when the coupon type mapped to the item has an unsupported Issue Coupon Module
        _LibCoupon.CreateCouponSetup();
        _LibCoupon.CreateDiscountAmountCouponType('UNSUPPORTED', CouponType, 10);
        // CreateDiscountAmountCouponType sets Issue Coupon Module to 'DEFAULT' which is not in the supported list

        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedCouponLine(EcomSalesLine, EcomSalesHeader, _LibEcom.CreateEcomCouponItemForType(CouponType.Code), 1, 100);

        asserterror CouponImpl.Process(EcomSalesLine);
    end;
    #endregion

    #region HandleResponse — status updates after coupon creation attempt
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure HandleResponse_Success_LineStatusProcessed()
    var
        CouponType: Record "NPR NpDc Coupon Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        CouponProcess: Codeunit "NPR EcomCreateCouponProcess";
    begin
        // [Scenario] HandleResponse with Success=true sets:
        //    - line Virtual Item Process Status to Processed
        //    - header Coupon Processing Status to Processed when all coupon lines are done
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedCouponLine(EcomSalesLine, EcomSalesHeader, _LibEcom.CreateEcomCouponItem(CouponType), 1, 100);

        CouponProcess.HandleResponse(true, EcomSalesLine, false);

        EcomSalesLine.Find();
        _Assert.AreEqual(
            EcomSalesLine."Virtual Item Process Status"::Processed,
            EcomSalesLine."Virtual Item Process Status",
            'Line Virtual Item Process Status should be Processed after successful HandleResponse');

        EcomSalesHeader.Find();
        _Assert.AreEqual(
            EcomSalesHeader."Coupon Processing Status"::Processed,
            EcomSalesHeader."Coupon Processing Status",
            'Header Coupon Processing Status should be Processed when the only coupon line is processed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure HandleResponse_Success_MultiLine_AllProcessed_HeaderProcessed()
    var
        CouponType: Record "NPR NpDc Coupon Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesLine2: Record "NPR Ecom Sales Line";
        CouponProcess: Codeunit "NPR EcomCreateCouponProcess";
        ItemNo: Code[20];
    begin
        // [Scenario] Header Coupon Processing Status becomes Processed when all coupon lines are processed
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        ItemNo := _LibEcom.CreateEcomCouponItem(CouponType);
        CreateCapturedCouponLine(EcomSalesLine, EcomSalesHeader, ItemNo, 1, 100);
        CreateCapturedCouponLine(EcomSalesLine2, EcomSalesHeader, ItemNo, 1, 50);

        CouponProcess.HandleResponse(true, EcomSalesLine, false);
        CouponProcess.HandleResponse(true, EcomSalesLine2, false);

        EcomSalesHeader.Find();
        _Assert.AreEqual(
            EcomSalesHeader."Coupon Processing Status"::Processed,
            EcomSalesHeader."Coupon Processing Status",
            'Header Coupon Processing Status should be Processed when all coupon lines are processed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure HandleResponse_Success_MultiLine_OnePending_HeaderPartiallyProcessed()
    var
        CouponType: Record "NPR NpDc Coupon Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesLine2: Record "NPR Ecom Sales Line";
        CouponProcess: Codeunit "NPR EcomCreateCouponProcess";
        ItemNo: Code[20];
    begin
        // [Scenario] Header Coupon Processing Status becomes Partially Processed when only some coupon lines are processed
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        ItemNo := _LibEcom.CreateEcomCouponItem(CouponType);
        CreateCapturedCouponLine(EcomSalesLine, EcomSalesHeader, ItemNo, 1, 100);
        CreateCapturedCouponLine(EcomSalesLine2, EcomSalesHeader, ItemNo, 1, 50);

        CouponProcess.HandleResponse(true, EcomSalesLine, false);
        // EcomSalesLine2 remains pending (Virtual Item Process Status = blank)

        EcomSalesHeader.Find();
        _Assert.AreEqual(
            EcomSalesHeader."Coupon Processing Status"::"Partially Processed",
            EcomSalesHeader."Coupon Processing Status",
            'Header Coupon Processing Status should be Partially Processed when one coupon line is still pending');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure HandleResponse_Failure_BelowMaxRetry_LineStatusNotError()
    var
        CouponType: Record "NPR NpDc Coupon Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        CouponProcess: Codeunit "NPR EcomCreateCouponProcess";
    begin
        // [Scenario] HandleResponse with failure below max retry count does not set line status to Error
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedCouponLine(EcomSalesLine, EcomSalesHeader, _LibEcom.CreateEcomCouponItem(CouponType), 1, 100);
        // Default Max Virtual Item Retry Count = 3, retry count starts at 0

        CouponProcess.HandleResponse(false, EcomSalesLine, true); // UpdateRetryCount=true; count becomes 1, below max 3

        EcomSalesLine.Find();
        _Assert.AreNotEqual(
            EcomSalesLine."Virtual Item Process Status"::Error,
            EcomSalesLine."Virtual Item Process Status",
            'Line status should not be Error when retry count is below max');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure HandleResponse_Failure_MaxRetryReached_LineStatusError()
    var
        CouponType: Record "NPR NpDc Coupon Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        IncEcomSetup: Record "NPR Inc Ecom Sales Doc Setup";
        CouponProcess: Codeunit "NPR EcomCreateCouponProcess";
    begin
        // [Scenario] HandleResponse with failure at max retry count sets line and header status to Error
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedCouponLine(EcomSalesLine, EcomSalesHeader, _LibEcom.CreateEcomCouponItem(CouponType), 1, 100);

        // Set max retry count to 1 so a single failure with UpdateRetryCount=true triggers Error
        if not IncEcomSetup.Get() then
            IncEcomSetup.Insert();
        IncEcomSetup."Max Virtual Item Retry Count" := 1;
        IncEcomSetup.Modify();

        CouponProcess.HandleResponse(false, EcomSalesLine, true); // count becomes 1, 1 >= 1 → Error

        EcomSalesLine.Find();
        _Assert.AreEqual(
            EcomSalesLine."Virtual Item Process Status"::Error,
            EcomSalesLine."Virtual Item Process Status",
            'Line status should be Error when retry count reaches max');

        EcomSalesHeader.Find();
        _Assert.AreEqual(
            EcomSalesHeader."Coupon Processing Status"::Error,
            EcomSalesHeader."Coupon Processing Status",
            'Header Coupon Processing Status should be Error when line reaches max retries');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure HandleResponse_Failure_StoresErrorMessage()
    var
        CouponType: Record "NPR NpDc Coupon Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        CouponProcess: Codeunit "NPR EcomCreateCouponProcess";
        TestErrorMsg: Label 'Test coupon creation failure message', Locked = true;
    begin
        // [Scenario] HandleResponse with failure stores the last error text on the line
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedCouponLine(EcomSalesLine, EcomSalesHeader, _LibEcom.CreateEcomCouponItem(CouponType), 1, 100);

        if SetLastErrorText(TestErrorMsg) then; // Sets last error text
        CouponProcess.HandleResponse(false, EcomSalesLine, false);

        EcomSalesLine.Find();
        _Assert.AreNotEqual('', EcomSalesLine."Virtual Item Process ErrMsg", 'Error message should be stored on the line after failure');
    end;
    #endregion

    #region Coupon issuance — EcomCreateCouponImpl.Process() creates EcomSalesCouponLink records
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CouponProcess_ValidSetup_CouponLinkCreated()
    var
        CouponType: Record "NPR NpDc Coupon Type";
        EcomSalesCouponLink: Record "NPR Ecom Sales Coupon Link";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        CouponImpl: Codeunit "NPR EcomCreateCouponImpl";
    begin
        // [Scenario] Process creates an EcomSalesCouponLink record linking the ecom document to the issued coupon
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedCouponLine(EcomSalesLine, EcomSalesHeader, _LibEcom.CreateEcomCouponItem(CouponType), 1, 100);

        CouponImpl.Process(EcomSalesLine);

        EcomSalesCouponLink.SetRange("Source", EcomSalesCouponLink."Source"::"Ecom Sales Document");
        EcomSalesCouponLink.SetRange("Source System Id", EcomSalesHeader.SystemId);
        EcomSalesCouponLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        _Assert.AreEqual(1, EcomSalesCouponLink.Count(), 'One EcomSalesCouponLink record should be created for a qty-1 coupon line');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CouponProcess_Qty3_ThreeCouponLinksCreated()
    var
        CouponType: Record "NPR NpDc Coupon Type";
        EcomSalesCouponLink: Record "NPR Ecom Sales Coupon Link";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        CouponImpl: Codeunit "NPR EcomCreateCouponImpl";
    begin
        // [Scenario] Process creates one EcomSalesCouponLink record per coupon quantity unit
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedCouponLine(EcomSalesLine, EcomSalesHeader, _LibEcom.CreateEcomCouponItem(CouponType), 3, 50);

        CouponImpl.Process(EcomSalesLine);

        EcomSalesCouponLink.SetRange("Source", EcomSalesCouponLink."Source"::"Ecom Sales Document");
        EcomSalesCouponLink.SetRange("Source System Id", EcomSalesHeader.SystemId);
        EcomSalesCouponLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        _Assert.AreEqual(3, EcomSalesCouponLink.Count(), 'Three EcomSalesCouponLink records should be created for a qty-3 coupon line');
    end;
    #endregion

    #region GET issuedAssets — end-to-end resolvability
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetSalesDocument_IssuedAssets_CouponIdResolvesToRealCoupon()
    var
        CouponType: Record "NPR NpDc Coupon Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        CouponImpl: Codeunit "NPR EcomCreateCouponImpl";
    begin
        // [Scenario] A processed qty=1 coupon line issues a coupon + link row. The GET response must emit
        // that coupon under salesDocumentLines[].issuedAssets[], and the emitted id must round-trip:
        // GetBySystemId resolves it to a real coupon whose referenceNo matches. Guards the hoisted per-doc
        // coupon link buffer path (LoadDocCouponLinks + the in-memory per-line filter) end-to-end.
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        CreateCapturedCouponLine(EcomSalesLine, EcomSalesHeader, _LibEcom.CreateEcomCouponItem(CouponType), 1, 100);
        CouponImpl.Process(EcomSalesLine);

        // [When] the document is read back as Get V2 and as Get V3 build it
        // [Then] each version has exactly one line with exactly one issued asset, the coupon
        AssertOneIssuedCoupon(_LibDocApi.GetSalesDocumentTextV2(EcomSalesHeader), '(Get V2)');
        AssertOneIssuedCoupon(_LibDocApi.GetSalesDocumentTextV3(EcomSalesHeader), '(Get V3)');
    end;
    #endregion

    #region Archived coupons stay on the ecommerce document
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ArchivedCoupon_StillListedOnDocumentWithSameId()
    var
        CouponType: Record "NPR NpDc Coupon Type";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        NpDcArchCoupon: Record "NPR NpDc Arch. Coupon";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        CouponImpl: Codeunit "NPR EcomCreateCouponImpl";
        EcomCreateVchrImpl: Codeunit "NPR EcomCreateVchrImpl";
        CouponSystemIds: List of [Guid];
        ReferenceNos: List of [Text];
    begin
        // [GIVEN] a processed coupon line whose coupon is then archived from the coupon card
        CreateProcessedCouponDocument(EcomSalesHeader, EcomSalesLine, CouponType, 1);
        ArchiveDocumentCoupons(EcomSalesHeader, CouponSystemIds, ReferenceNos);

        // [WHEN] the document's coupons are looked up
        CouponImpl.BuildCouponTempBufferForDoc(EcomSalesHeader, TempCoupon);

        // [THEN] the archived coupon is still listed, with the id it had before it was archived, marked as archived
        _Assert.AreEqual(1, TempCoupon.Count(), 'An archived coupon must still be listed on the ecommerce document that issued it.');
        TempCoupon.FindFirst();
        _Assert.AreEqual(CouponSystemIds.Get(1), TempCoupon.SystemId, 'The listed archived coupon must keep the id the coupon had before it was archived.');
        _Assert.AreEqual(ReferenceNos.Get(1), TempCoupon."Reference No.", 'The listed archived coupon must show its reference number.');
        _Assert.IsTrue(EcomCreateVchrImpl.IsArchivedTempDescription(TempCoupon.Description), 'The listed archived coupon must be marked as archived.');
        _Assert.IsTrue(NpDcArchCoupon.GetBySystemId(CouponSystemIds.Get(1)), 'Archiving must keep the coupon''s SystemId on the archived coupon.');

        // [THEN] GET V2 and V3 still return it as an issued asset
        AssertOneIssuedCoupon(_LibDocApi.GetSalesDocumentTextV2(EcomSalesHeader), '(Get V2, archived coupon)');
        AssertOneIssuedCoupon(_LibDocApi.GetSalesDocumentTextV3(EcomSalesHeader), '(Get V3, archived coupon)');
    end;
    #endregion

    #region Helpers

    local procedure AssertOneIssuedCoupon(DocumentText: Text; Context: Text)
    var
        NpDcCoupon: Record "NPR NpDc Coupon";
        NpDcArchCoupon: Record "NPR NpDc Arch. Coupon";
        RootObject: JsonObject;
        LineObject: JsonObject;
        AssetObject: JsonObject;
        LinesArray: JsonArray;
        AssetsArray: JsonArray;
        JToken: JsonToken;
        LineToken: JsonToken;
        AssetToken: JsonToken;
        AssetId: Guid;
        AssetCount: Integer;
        ReferenceNo: Text;
    begin
        RootObject.ReadFrom(DocumentText);
        RootObject.Get('salesDocumentLines', JToken);
        LinesArray := JToken.AsArray();
        _Assert.AreEqual(1, LinesArray.Count(), 'Expected exactly one sales document line. ' + Context);

        LinesArray.Get(0, LineToken);
        LineObject := LineToken.AsObject();
        LineObject.Get('issuedAssets', JToken);
        AssetsArray := JToken.AsArray();
        _Assert.AreEqual(1, AssetsArray.Count(), 'Expected exactly one issued asset for the qty=1 coupon line. ' + Context);

        foreach AssetToken in AssetsArray do begin
            AssetObject := AssetToken.AsObject();

            AssetObject.Get('type', JToken);
            _Assert.AreEqual('coupon', JToken.AsValue().AsText(), 'Issued asset type should be coupon. ' + Context);

            AssetObject.Get('id', JToken);
            _Assert.IsTrue(Evaluate(AssetId, JToken.AsValue().AsText()), 'issuedAssets id must be a valid Guid. ' + Context);

            if NpDcCoupon.GetBySystemId(AssetId) then
                ReferenceNo := NpDcCoupon."Reference No."
            else begin
                _Assert.IsTrue(NpDcArchCoupon.GetBySystemId(AssetId), 'GetBySystemId must resolve the emitted issuedAssets id to a coupon or an archived coupon. ' + Context);
                ReferenceNo := NpDcArchCoupon."Reference No.";
            end;
            AssetObject.Get('referenceNo', JToken);
            _Assert.AreEqual(ReferenceNo, JToken.AsValue().AsText(), 'issuedAssets referenceNo must match the resolved coupon. ' + Context);

            AssetCount += 1;
        end;
        _Assert.AreEqual(1, AssetCount, 'Exactly one issued asset should have been asserted. ' + Context);
    end;

    local procedure CreateCapturedCouponLine(var EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; ItemNo: Code[20]; Qty: Decimal; UnitPrice: Decimal)
    begin
        EcomSalesLine.Init();
        EcomSalesLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesLine."Document Type" := EcomSalesHeader."Document Type";
        EcomSalesLine."External Document No." := EcomSalesHeader."External No.";
        EcomSalesLine."Line No." := GetNextLineNo(EcomSalesHeader);
        EcomSalesLine.Type := EcomSalesLine.Type::Item;
        EcomSalesLine.Subtype := EcomSalesLine.Subtype::Coupon;
        EcomSalesLine."No." := ItemNo;
        EcomSalesLine.Quantity := Qty;
        EcomSalesLine."Unit Price" := UnitPrice;
        EcomSalesLine."Line Amount" := Qty * UnitPrice;
        EcomSalesLine.Captured := true;
        EcomSalesLine.Insert(true);
    end;

    local procedure CreateProcessedCouponDocument(var EcomSalesHeader: Record "NPR Ecom Sales Header"; var EcomSalesLine: Record "NPR Ecom Sales Line"; var CouponType: Record "NPR NpDc Coupon Type"; Qty: Decimal)
    var
        CouponImpl: Codeunit "NPR EcomCreateCouponImpl";
    begin
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."External No." := _LibEcom.NextExternalNo('CPNARCH');
        EcomSalesHeader.Modify();
        CreateCapturedCouponLine(EcomSalesLine, EcomSalesHeader, _LibEcom.CreateEcomCouponItem(CouponType), Qty, 100);
        CouponImpl.Process(EcomSalesLine);
    end;

    local procedure ArchiveDocumentCoupons(EcomSalesHeader: Record "NPR Ecom Sales Header"; var CouponSystemIds: List of [Guid]; var ReferenceNos: List of [Text])
    var
        EcomSalesCouponLink: Record "NPR Ecom Sales Coupon Link";
        NpDcCoupon: Record "NPR NpDc Coupon";
        NpDcCouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
    begin
        EcomSalesCouponLink.SetRange(Source, EcomSalesCouponLink.Source::"Ecom Sales Document");
        EcomSalesCouponLink.SetRange("Source System Id", EcomSalesHeader.SystemId);
        EcomSalesCouponLink.FindSet();
        repeat
            NpDcCoupon.GetBySystemId(EcomSalesCouponLink."Coupon System Id");
            CouponSystemIds.Add(NpDcCoupon.SystemId);
            ReferenceNos.Add(NpDcCoupon."Reference No.");
            NpDcCouponMgt.ArchiveCoupon(NpDcCoupon);
        until EcomSalesCouponLink.Next() = 0;
    end;

    local procedure GetNextLineNo(EcomSalesHeader: Record "NPR Ecom Sales Header"): Integer
    var
        ExistingLine: Record "NPR Ecom Sales Line";
    begin
        ExistingLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        if ExistingLine.FindLast() then
            exit(ExistingLine."Line No." + 10000);

        exit(10000);
    end;

    [TryFunction]
    local procedure SetLastErrorText(ErrorMsg: Text)
    begin
        Error(ErrorMsg);
    end;
    #endregion
}
#endif