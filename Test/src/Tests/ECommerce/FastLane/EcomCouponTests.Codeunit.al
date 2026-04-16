#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 85243 "NPR Ecom Coupon Tests"
{
    Subtype = Test;

    var
        _Assert: Codeunit "Assert";
        _LibCoupon: Codeunit "NPR Library Coupon";
        _LibEcom: Codeunit "NPR Library Ecommerce";
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
        CreateCapturedCouponLine(EcomSalesLine, EcomSalesHeader, CreateEcomCouponType(CouponType), 1, 100);
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
        CreateCapturedCouponLine(EcomSalesLine, EcomSalesHeader, CreateEcomCouponType(CouponType), 1, 100);
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
        CreateCapturedCouponLine(EcomSalesLine, EcomSalesHeader, CreateEcomCouponType(CouponType), 1, 100);
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
        CreateCapturedCouponLine(EcomSalesLine, EcomSalesHeader, CreateEcomCouponType(CouponType), 1, 100);
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
        CreateCapturedCouponLine(EcomSalesLine, EcomSalesHeader, CreateEcomCouponType(CouponType), 1, 100);

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
        CreateCapturedCouponLine(EcomSalesLine, EcomSalesHeader, CreateCouponItemSetup(CouponType.Code), 1, 100);

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
        CreateCapturedCouponLine(EcomSalesLine, EcomSalesHeader, CreateEcomCouponType(CouponType), 1, 100);

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
        ItemNo := CreateEcomCouponType(CouponType);
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
        ItemNo := CreateEcomCouponType(CouponType);
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
        CreateCapturedCouponLine(EcomSalesLine, EcomSalesHeader, CreateEcomCouponType(CouponType), 1, 100);
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
        CreateCapturedCouponLine(EcomSalesLine, EcomSalesHeader, CreateEcomCouponType(CouponType), 1, 100);

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
        CreateCapturedCouponLine(EcomSalesLine, EcomSalesHeader, CreateEcomCouponType(CouponType), 1, 100);

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
        CreateCapturedCouponLine(EcomSalesLine, EcomSalesHeader, CreateEcomCouponType(CouponType), 1, 100);

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
        CreateCapturedCouponLine(EcomSalesLine, EcomSalesHeader, CreateEcomCouponType(CouponType), 3, 50);

        CouponImpl.Process(EcomSalesLine);

        EcomSalesCouponLink.SetRange("Source", EcomSalesCouponLink."Source"::"Ecom Sales Document");
        EcomSalesCouponLink.SetRange("Source System Id", EcomSalesHeader.SystemId);
        EcomSalesCouponLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        _Assert.AreEqual(3, EcomSalesCouponLink.Count(), 'Three EcomSalesCouponLink records should be created for a qty-3 coupon line');
    end;
    #endregion

    #region Helpers
    /// <summary>
    /// Creates a coupon type with the ON-ECOM-SALE issue module, creates an item, and links the item
    /// to the coupon type via NPR NpDc Iss.OnEcomSale S.Line.
    /// Returns the item no. to use as EcomSalesLine."No." when creating test coupon lines.
    /// </summary>
    local procedure CreateEcomCouponType(var CouponType: Record "NPR NpDc Coupon Type"): Code[20]
    var
        CouponModule: Record "NPR NpDc Coupon Module";
        OnEcomSaleCouponModule: Codeunit "NPR OnEcomSaleCouponModule";
    begin
        _LibCoupon.CreateCouponSetup();

        // Ensure the 'ON-ECOM-SALE' module record exists in the module table so the coupon type field relation is satisfied
        if not CouponModule.Get(CouponModule.Type::"Issue Coupon", OnEcomSaleCouponModule.ModuleCode()) then begin
            CouponModule.Init();
            CouponModule.Type := CouponModule.Type::"Issue Coupon";
            CouponModule.Code := OnEcomSaleCouponModule.ModuleCode();
            CouponModule.Description := 'Issue Coupon - Ecommerce Sale';
            CouponModule.Insert();
        end;

        _LibCoupon.CreateDiscountAmountCouponType('ECOM-COUPON', CouponType, 10);
        CouponType."Issue Coupon Module" := OnEcomSaleCouponModule.ModuleCode();
        CouponType.Modify();

        exit(CreateCouponItemSetup(CouponType.Code));
    end;

    /// <summary>
    /// Creates an item and an NPR NpDc Iss.OnEcomSale S.Line linking it to the given coupon type.
    /// Returns the item no.
    /// </summary>
    local procedure CreateCouponItemSetup(CouponTypeCode: Code[20]) ItemNo: Code[20]
    var
        EcomSalesCouponSetupLine: Record "NPR NpDc Iss.OnEcomSale S.Line";
    begin
        ItemNo := _LibInventory.CreateItemNo();

        EcomSalesCouponSetupLine.SetRange(Type, EcomSalesCouponSetupLine.Type::Item);
        EcomSalesCouponSetupLine.SetRange("No.", ItemNo);
        EcomSalesCouponSetupLine.SetRange("Variant Code", '');
        EcomSalesCouponSetupLine.SetRange("Coupon Type", CouponTypeCode);
        if EcomSalesCouponSetupLine.IsEmpty() then begin
            EcomSalesCouponSetupLine.Reset();
            EcomSalesCouponSetupLine.SetRange("Coupon Type", CouponTypeCode);
            if not EcomSalesCouponSetupLine.FindLast() then
                EcomSalesCouponSetupLine."Line No." := 0;

            EcomSalesCouponSetupLine.Init();
            EcomSalesCouponSetupLine."Coupon Type" := CouponTypeCode;
            EcomSalesCouponSetupLine."Line No." += 10000;
            EcomSalesCouponSetupLine.Type := EcomSalesCouponSetupLine.Type::Item;
            EcomSalesCouponSetupLine."No." := ItemNo;
            EcomSalesCouponSetupLine.Insert();
        end;
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