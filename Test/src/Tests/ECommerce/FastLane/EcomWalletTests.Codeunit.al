#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 85238 "NPR Ecom Wallet Tests"
{
    Subtype = Test;

    var
        _Assert: Codeunit "Assert";
        _LibEcom: Codeunit "NPR Library Ecommerce";

    #region CreateWallets — guard conditions (header exits early without processing)
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWallets_AlreadyProcessed_NoProcessing()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        WalletMgt: Codeunit "NPR EcomCreateWalletMgt";
    begin
        // [Scenario] CreateWallets exits without processing when wallet status is already Processed
        SetupHeaderForWalletProcessing(EcomSalesHeader);
        CreateWalletParentLine(EcomSalesLine, EcomSalesHeader, 'LINE-001');
        EcomSalesHeader."Attr. Wallet Processing Status" := EcomSalesHeader."Attr. Wallet Processing Status"::Processed;
        EcomSalesHeader.Modify();

        WalletMgt.CreateWallets(EcomSalesHeader, false, false);

        EcomSalesLine.Get(EcomSalesLine.RecordId());
        _Assert.AreEqual(
            EcomSalesLine."Attr. Wallet Processing Status"::" ",
            EcomSalesLine."Attr. Wallet Processing Status",
            'Wallet line status should remain blank when header is already Processed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWallets_WalletsExistFalse_NoProcessing()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        WalletMgt: Codeunit "NPR EcomCreateWalletMgt";
    begin
        // [Scenario] CreateWallets exits without processing when there are no wallets to create ("Wallets Exist" = false on the header)
        SetupHeaderForWalletProcessing(EcomSalesHeader);
        CreateWalletParentLine(EcomSalesLine, EcomSalesHeader, 'LINE-001');
        EcomSalesHeader."Attraction Wallets Exist" := false;
        EcomSalesHeader.Modify();

        WalletMgt.CreateWallets(EcomSalesHeader, false, false);

        EcomSalesLine.Get(EcomSalesLine.RecordId());
        _Assert.AreEqual(
            EcomSalesLine."Attr. Wallet Processing Status"::" ",
            EcomSalesLine."Attr. Wallet Processing Status",
            'Wallet line status should remain blank when "Wallets Exist" = false on the header');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWallets_HeaderCreated_NoProcessing()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        WalletMgt: Codeunit "NPR EcomCreateWalletMgt";
    begin
        // [Scenario] CreateWallets exits without processing when header Creation Status is Created
        SetupHeaderForWalletProcessing(EcomSalesHeader);
        CreateWalletParentLine(EcomSalesLine, EcomSalesHeader, 'LINE-001');
        EcomSalesHeader."Creation Status" := EcomSalesHeader."Creation Status"::Created;
        EcomSalesHeader.Modify();

        WalletMgt.CreateWallets(EcomSalesHeader, false, false);

        EcomSalesLine.Get(EcomSalesLine.RecordId());
        _Assert.AreEqual(
            EcomSalesLine."Attr. Wallet Processing Status"::" ",
            EcomSalesLine."Attr. Wallet Processing Status",
            'Wallet line status should remain blank when header Creation Status is Created');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWallets_CaptureNotProcessed_NoProcessing()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        WalletMgt: Codeunit "NPR EcomCreateWalletMgt";
    begin
        // [Scenario] CreateWallets exits without processing when capture is not yet done
        SetupHeaderForWalletProcessing(EcomSalesHeader);
        CreateWalletParentLine(EcomSalesLine, EcomSalesHeader, 'LINE-001');
        EcomSalesHeader."Capture Processing Status" := EcomSalesHeader."Capture Processing Status"::Pending;
        EcomSalesHeader.Modify();

        WalletMgt.CreateWallets(EcomSalesHeader, false, false);

        EcomSalesLine.Get(EcomSalesLine.RecordId());
        _Assert.AreEqual(
            EcomSalesLine."Attr. Wallet Processing Status"::" ",
            EcomSalesLine."Attr. Wallet Processing Status",
            'Wallet line status should remain blank when capture is not yet processed');
    end;
    #endregion

    #region CreateWallets — component validation
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWallets_ComponentVirtualItemPending_WalletSkipped()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        ComponentLine: Record "NPR Ecom Sales Line";
        ParentLine: Record "NPR Ecom Sales Line";
        WalletMgt: Codeunit "NPR EcomCreateWalletMgt";
    begin
        // [Scenario] CreateWallets skips wallet creation when a virtual component is still pending
        SetupHeaderForWalletProcessing(EcomSalesHeader);
        CreateWalletParentLine(ParentLine, EcomSalesHeader, 'PARENT-1');
        CreateWalletComponentLine(ComponentLine, EcomSalesHeader, ParentLine."External Line ID", 'COMP-1', ParentLine."Line No." + 10000);
        // ComponentLine."Virtual Item Process Status" = blank (pending)

        WalletMgt.CreateWallets(EcomSalesHeader, false, false);

        ParentLine.Get(ParentLine.RecordId());
        _Assert.AreEqual(
            ParentLine."Attr. Wallet Processing Status"::" ",
            ParentLine."Attr. Wallet Processing Status",
            'Wallet line status should remain blank when a virtual component is still pending');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWallets_ComponentVirtualItemError_WalletLineSetToError()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        ComponentLine: Record "NPR Ecom Sales Line";
        ParentLine: Record "NPR Ecom Sales Line";
        WalletMgt: Codeunit "NPR EcomCreateWalletMgt";
    begin
        // [Scenario] CreateWallets sets wallet line and header status to Error when a virtual component has failed
        SetupHeaderForWalletProcessing(EcomSalesHeader);
        CreateWalletParentLine(ParentLine, EcomSalesHeader, 'PARENT-1');
        CreateWalletComponentLine(ComponentLine, EcomSalesHeader, ParentLine."External Line ID", 'COMP-1', ParentLine."Line No." + 10000);
        ComponentLine."Virtual Item Process Status" := ComponentLine."Virtual Item Process Status"::Error;
        ComponentLine.Modify();

        WalletMgt.CreateWallets(EcomSalesHeader, false, false);

        ParentLine.Get(ParentLine.RecordId());
        _Assert.AreEqual(
            ParentLine."Attr. Wallet Processing Status"::Error,
            ParentLine."Attr. Wallet Processing Status",
            'Wallet line status should be Error when a virtual component has failed');

        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        _Assert.AreEqual(
            EcomSalesHeader."Attr. Wallet Processing Status"::Error,
            EcomSalesHeader."Attr. Wallet Processing Status",
            'Header Wallet Processing Status should be Error when wallet component processing failed');
    end;
    #endregion

    #region CreateWallets — retry / failure handling (wallets disabled to simulate failure)
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWallets_Failure_BelowMaxRetry_WalletLineNotError()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        ParentLine: Record "NPR Ecom Sales Line";
        WalletMgt: Codeunit "NPR EcomCreateWalletMgt";
    begin
        // [Scenario] Wallet creation failure below max retry does not set Error status on wallet line
        _LibEcom.EnableAttractionWallets(false);
        SetupHeaderForWalletProcessing(EcomSalesHeader);
        CreateWalletParentLine(ParentLine, EcomSalesHeader, 'LINE-001');
        // Default Max Wallet Retry Count = 3; wallet retry count starts at 0

        WalletMgt.CreateWallets(EcomSalesHeader, false, true); // UpdateRetryCount=true; count becomes 1, 1 < 3

        ParentLine.Get(ParentLine.RecordId());
        _Assert.AreNotEqual(
            ParentLine."Attr. Wallet Processing Status"::Error,
            ParentLine."Attr. Wallet Processing Status",
            'Wallet line status should not be Error when retry count is below max');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWallets_Failure_MaxRetryReached_WalletLineError()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        IncEcomSetup: Record "NPR Inc Ecom Sales Doc Setup";
        ParentLine: Record "NPR Ecom Sales Line";
        WalletMgt: Codeunit "NPR EcomCreateWalletMgt";
    begin
        // [Scenario] Wallet creation failure at max retry sets Error status on wallet line and header
        _LibEcom.EnableAttractionWallets(false);

        // Set max wallet retry count to 1 so a single failure with UpdateRetryCount=true triggers Error
        if not IncEcomSetup.Get() then
            IncEcomSetup.Insert();
        IncEcomSetup."Max Attr. Wallet Retry Count" := 1;
        IncEcomSetup.Modify();

        SetupHeaderForWalletProcessing(EcomSalesHeader);
        CreateWalletParentLine(ParentLine, EcomSalesHeader, 'LINE-001');

        WalletMgt.CreateWallets(EcomSalesHeader, false, true); // count becomes 1, 1 >= 1 → Error

        ParentLine.Get(ParentLine.RecordId());
        _Assert.AreEqual(
            ParentLine."Attr. Wallet Processing Status"::Error,
            ParentLine."Attr. Wallet Processing Status",
            'Wallet line status should be Error when retry count reaches max');

        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        _Assert.AreEqual(
            EcomSalesHeader."Attr. Wallet Processing Status"::Error,
            EcomSalesHeader."Attr. Wallet Processing Status",
            'Header Wallet Processing Status should be Error when wallet line reaches max retries');
        _Assert.AreEqual(
            EcomSalesHeader."Virtual Items Process Status"::Error,
            EcomSalesHeader."Virtual Items Process Status",
            'Header Virtual Items Process Status should be Error when wallet line reaches max retries');
    end;
    #endregion

    #region CreateWallets — successful creation
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWallets_Success_WalletLineProcessed()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        ParentLine: Record "NPR Ecom Sales Line";
        WalletAssetHeaderRef: Record "NPR WalletAssetHeaderReference";
        WalletMgt: Codeunit "NPR EcomCreateWalletMgt";
    begin
        // [Scenario] Wallet creation succeeds: wallet line and header status become Processed and a wallet record is linked
        _LibEcom.EnableAttractionWallets(true);
        SetupHeaderForWalletProcessing(EcomSalesHeader);
        CreateWalletParentLine(ParentLine, EcomSalesHeader, 'LINE-001');
        // No virtual item components → all component checks pass

        WalletMgt.CreateWallets(EcomSalesHeader, false, false);

        ParentLine.Get(ParentLine.RecordId());
        _Assert.AreEqual(
            ParentLine."Attr. Wallet Processing Status"::Processed,
            ParentLine."Attr. Wallet Processing Status",
            'Wallet line status should be Processed after successful wallet creation');

        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        _Assert.AreEqual(
            EcomSalesHeader."Attr. Wallet Processing Status"::Processed,
            EcomSalesHeader."Attr. Wallet Processing Status",
            'Header Wallet Processing Status should be Processed after successful wallet creation');

        WalletAssetHeaderRef.SetRange(LinkToTableId, Database::"NPR Ecom Sales Header");
        WalletAssetHeaderRef.SetRange(LinkToSystemId, EcomSalesHeader.SystemId);
        _Assert.IsFalse(WalletAssetHeaderRef.IsEmpty(), 'A wallet reference record should be created linking the wallet to the ecom sales header');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWallets_MultipleWalletLines_AllProcessed_HeaderProcessed()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        ParentLine: Record "NPR Ecom Sales Line";
        ParentLine2: Record "NPR Ecom Sales Line";
        WalletMgt: Codeunit "NPR EcomCreateWalletMgt";
    begin
        // [Scenario] All wallet lines are processed → header status becomes Processed
        _LibEcom.EnableAttractionWallets(true);
        SetupHeaderForWalletProcessing(EcomSalesHeader);
        CreateWalletParentLine(ParentLine, EcomSalesHeader, 'LINE-001');
        CreateWalletParentLine(ParentLine2, EcomSalesHeader, 'LINE-002');

        WalletMgt.CreateWallets(EcomSalesHeader, false, false);

        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        _Assert.AreEqual(
            EcomSalesHeader."Attr. Wallet Processing Status"::Processed,
            EcomSalesHeader."Attr. Wallet Processing Status",
            'Header Wallet Processing Status should be Processed when all wallet lines are successfully processed');
        _Assert.AreEqual(
            EcomSalesHeader."Virtual Items Process Status"::Processed,
            EcomSalesHeader."Virtual Items Process Status",
            'Header Virtual Items Process Status should be Processed when all wallet lines are successfully processed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWallets_MultipleWalletLines_OneProcessed_HeaderPartiallyProcessed()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        ParentLine: Record "NPR Ecom Sales Line";
        ParentLine2: Record "NPR Ecom Sales Line";
        WalletMgt: Codeunit "NPR EcomCreateWalletMgt";
    begin
        // [Scenario] One wallet line is processed → header status becomes Partially Processed
        _LibEcom.EnableAttractionWallets(true);
        SetupHeaderForWalletProcessing(EcomSalesHeader);
        CreateWalletParentLine(ParentLine, EcomSalesHeader, 'LINE-001');
        CreateWalletParentLine(ParentLine2, EcomSalesHeader, 'LINE-002');
        ParentLine2.Subtype := ParentLine2.Subtype::Ticket;
        ParentLine2."Virtual Item Process Status" := ParentLine2."Virtual Item Process Status"::" ";
        ParentLine2.Modify();  // Make this line fail wallet creation so only one line is processed

        WalletMgt.CreateWallets(EcomSalesHeader, false, false);

        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        _Assert.AreEqual(
            EcomSalesHeader."Attr. Wallet Processing Status"::"Partially Processed",
            EcomSalesHeader."Attr. Wallet Processing Status",
            'Header Wallet Processing Status should be Partially Processed when only some wallet lines are successfully processed');
        _Assert.AreEqual(
            EcomSalesHeader."Virtual Items Process Status"::"Partially Processed",
            EcomSalesHeader."Virtual Items Process Status",
            'Header Virtual Items Process Status should be Partially Processed when only some wallet lines are successfully processed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWallets_MultipleWalletLines_OneComponentError_HeaderError()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        ComponentLine: Record "NPR Ecom Sales Line";
        ParentLine: Record "NPR Ecom Sales Line";
        ParentLine2: Record "NPR Ecom Sales Line";
        WalletMgt: Codeunit "NPR EcomCreateWalletMgt";
    begin
        // [Scenario] One wallet line has a failed component → that wallet line becomes Error → header becomes Error
        _LibEcom.EnableAttractionWallets(true);
        SetupHeaderForWalletProcessing(EcomSalesHeader);
        CreateWalletParentLine(ParentLine, EcomSalesHeader, 'LINE-001');
        CreateWalletParentLine(ParentLine2, EcomSalesHeader, 'LINE-002');
        CreateWalletComponentLine(ComponentLine, EcomSalesHeader, ParentLine2."External Line ID", 'COMP-1', ParentLine2."Line No." + 10000);
        ComponentLine."Virtual Item Process Status" := ComponentLine."Virtual Item Process Status"::Error;
        ComponentLine.Modify();

        WalletMgt.CreateWallets(EcomSalesHeader, false, false);

        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        _Assert.AreEqual(
            EcomSalesHeader."Attr. Wallet Processing Status"::Error,
            EcomSalesHeader."Attr. Wallet Processing Status",
            'Header status should be Error when at least one wallet line has a failed component');
    end;
    #endregion

    #region CreateWallets - sell-to email reference
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWallets_SellToEmail_StoredAsLooseReference()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        ParentLine: Record "NPR Ecom Sales Line";
        WalletMgt: Codeunit "NPR EcomCreateWalletMgt";
        WalletHeaderEntryNos: List of [Integer];
        Email: Text[80];
    begin
        // [Scenario] The buyer email is written to the wallet as a loose, searchable reference - table id 0 with a null
        // system id - and not as a record link. That is the only shape UpdateEmailAddressOnAllWallets() looks for, and it
        // keeps the email row from colliding with the header record link written for the same wallet.
        _LibEcom.EnableAttractionWallets(true);
        Email := UniqueEmail();
        SetupHeaderForWalletProcessing(EcomSalesHeader);
        EcomSalesHeader."Sell-to Email" := Email;
        EcomSalesHeader.Modify();
        CreateWalletParentLine(ParentLine, EcomSalesHeader, 'LINE-001');

        WalletMgt.CreateWallets(EcomSalesHeader, false, false);

        FindWalletHeaderEntryNos(EcomSalesHeader, WalletHeaderEntryNos);
        _Assert.AreEqual(1, WalletHeaderEntryNos.Count(), 'One wallet should have been created for the single wallet line');
        _Assert.AreEqual(
            1,
            CountEmailReferences(WalletHeaderEntryNos.Get(1), Email),
            'The wallet should carry exactly one email reference, stored with table id 0 and a null system id');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWallets_NoSellToEmail_NoLooseReference()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        ParentLine: Record "NPR Ecom Sales Line";
        WalletMgt: Codeunit "NPR EcomCreateWalletMgt";
        WalletHeaderEntryNos: List of [Integer];
    begin
        // [Scenario] A blank sell-to email writes no reference at all. An empty reference row would be matched wholesale by
        // UpdateEmailAddressOnAllWallets('', ...) across unrelated wallets, so the blank must not reach the wallet.
        _LibEcom.EnableAttractionWallets(true);
        SetupHeaderForWalletProcessing(EcomSalesHeader);  // the library helper leaves "Sell-to Email" blank
        CreateWalletParentLine(ParentLine, EcomSalesHeader, 'LINE-001');

        WalletMgt.CreateWallets(EcomSalesHeader, false, false);

        FindWalletHeaderEntryNos(EcomSalesHeader, WalletHeaderEntryNos);
        _Assert.AreEqual(1, WalletHeaderEntryNos.Count(), 'One wallet should have been created for the single wallet line');
        _Assert.AreEqual(
            0,
            CountLooseReferences(WalletHeaderEntryNos.Get(1)),
            'No loose reference row should be written for a wallet whose document has no sell-to email');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWallets_QuantityTwo_EmailReferenceOnEveryWallet()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        ParentLine: Record "NPR Ecom Sales Line";
        WalletMgt: Codeunit "NPR EcomCreateWalletMgt";
        WalletHeaderEntryNos: List of [Integer];
        Email: Text[80];
        WalletHeaderEntryNo: Integer;
    begin
        // [Scenario] A wallet line of quantity 2 creates one wallet per unit, and each of them gets its own email reference -
        // the reference is written inside the per-wallet loop, not once per line.
        _LibEcom.EnableAttractionWallets(true);
        Email := UniqueEmail();
        SetupHeaderForWalletProcessing(EcomSalesHeader);
        EcomSalesHeader."Sell-to Email" := Email;
        EcomSalesHeader.Modify();
        CreateWalletParentLine(ParentLine, EcomSalesHeader, 'LINE-001');
        ParentLine.Quantity := 2;
        ParentLine.Modify();

        WalletMgt.CreateWallets(EcomSalesHeader, false, false);

        FindWalletHeaderEntryNos(EcomSalesHeader, WalletHeaderEntryNos);
        _Assert.AreEqual(2, WalletHeaderEntryNos.Count(), 'Two wallets should have been created for a wallet line of quantity 2');
        foreach WalletHeaderEntryNo in WalletHeaderEntryNos do
            _Assert.AreEqual(
                1,
                CountEmailReferences(WalletHeaderEntryNo, Email),
                'Every wallet created for the line should carry exactly one email reference');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateWallets_SellToEmail_EmailChangeRewritesReference()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        ParentLine: Record "NPR Ecom Sales Line";
        AttractionWalletFacade: Codeunit "NPR AttractionWalletFacade";
        WalletMgt: Codeunit "NPR EcomCreateWalletMgt";
        WalletHeaderEntryNos: List of [Integer];
        Email: Text[80];
        NewEmail: Text[80];
    begin
        // [Scenario] End to end through the production consumer: the reference the ecom track writes must be reachable by
        // UpdateEmailAddressOnAllWallets(). That procedure matches on an exact reference filter within table id 0 and a null
        // system id, so a row written in any other shape leaves the wallet holding the old address forever.
        _LibEcom.EnableAttractionWallets(true);
        Email := UniqueEmail();
        NewEmail := UniqueEmail();
        SetupHeaderForWalletProcessing(EcomSalesHeader);
        EcomSalesHeader."Sell-to Email" := Email;
        EcomSalesHeader.Modify();
        CreateWalletParentLine(ParentLine, EcomSalesHeader, 'LINE-001');
        WalletMgt.CreateWallets(EcomSalesHeader, false, false);
        FindWalletHeaderEntryNos(EcomSalesHeader, WalletHeaderEntryNos);
        _Assert.AreEqual(1, WalletHeaderEntryNos.Count(), 'One wallet should have been created for the single wallet line');

        AttractionWalletFacade.UpdateEmailAddressOnAllWallets(Email, NewEmail);

        _Assert.AreEqual(
            0,
            CountEmailReferences(WalletHeaderEntryNos.Get(1), Email),
            'The old address should be gone from the wallet after the email change');
        _Assert.AreEqual(
            1,
            CountEmailReferences(WalletHeaderEntryNos.Get(1), NewEmail),
            'The wallet email reference should have been rewritten to the new address');
    end;
    #endregion

    #region Helpers
    local procedure SetupHeaderForWalletProcessing(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
        _LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
        EcomSalesHeader."Capture Processing Status" := EcomSalesHeader."Capture Processing Status"::Processed;
        EcomSalesHeader."Attr. Wallet Processing Status" := EcomSalesHeader."Attr. Wallet Processing Status"::Pending;
        EcomSalesHeader."Attraction Wallets Exist" := true;
        EcomSalesHeader.Modify();
    end;

    local procedure CreateWalletParentLine(var EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; ExternalLineId: Text[100])
    begin
        EcomSalesLine.Init();
        EcomSalesLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesLine."Document Type" := EcomSalesHeader."Document Type";
        EcomSalesLine."Line No." := GetNextLineNo(EcomSalesHeader);
        EcomSalesLine.Type := EcomSalesLine.Type::Item;
        EcomSalesLine.Quantity := 1;
        EcomSalesLine."Unit Price" := 100;
        EcomSalesLine."Line Amount" := 100;
        EcomSalesLine."Is Attraction Wallet" := true;
        EcomSalesLine."External Line ID" := ExternalLineId;
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

    local procedure CreateWalletComponentLine(var EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; ParentExternalLineId: Text[100]; ExternalLineId: Text[100]; LineNo: Integer)
    begin
        EcomSalesLine.Init();
        EcomSalesLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesLine."Document Type" := EcomSalesHeader."Document Type";
        EcomSalesLine."Line No." := LineNo;
        EcomSalesLine.Type := EcomSalesLine.Type::Item;
        EcomSalesLine.Subtype := EcomSalesLine.Subtype::Coupon;
        EcomSalesLine.Quantity := 1;
        EcomSalesLine."Unit Price" := 10;
        EcomSalesLine."Line Amount" := 10;
        EcomSalesLine."Is Attraction Wallet" := false;
        EcomSalesLine."External Line ID" := ExternalLineId;
        EcomSalesLine."Parent Ext. Line ID" := ParentExternalLineId;
        EcomSalesLine.Insert(true);
    end;

    local procedure UniqueEmail(): Text[80]
    begin
        // The wallet track commits, so rows survive between tests in a run - a per-test address keeps
        // UpdateEmailAddressOnAllWallets() in one test off the wallets created by another.
        exit(CopyStr('wallet.buyer.' + DelChr(Format(CreateGuid()), '=', '{}-') + '@test.navipartner.com', 1, 80));
    end;

    local procedure FindWalletHeaderEntryNos(EcomSalesHeader: Record "NPR Ecom Sales Header"; var WalletHeaderEntryNos: List of [Integer])
    var
        WalletAssetHeaderRef: Record "NPR WalletAssetHeaderReference";
    begin
        Clear(WalletHeaderEntryNos);
        WalletAssetHeaderRef.SetCurrentKey(LinkToTableId, LinkToSystemId);
        WalletAssetHeaderRef.SetRange(LinkToTableId, Database::"NPR Ecom Sales Header");
        WalletAssetHeaderRef.SetRange(LinkToSystemId, EcomSalesHeader.SystemId);
        if WalletAssetHeaderRef.FindSet() then
            repeat
                if not WalletHeaderEntryNos.Contains(WalletAssetHeaderRef.WalletHeaderEntryNo) then
                    WalletHeaderEntryNos.Add(WalletAssetHeaderRef.WalletHeaderEntryNo);
            until WalletAssetHeaderRef.Next() = 0;
    end;

    local procedure CountEmailReferences(WalletHeaderEntryNoParam: Integer; Email: Text[100]): Integer
    var
        WalletAssetHeaderRef: Record "NPR WalletAssetHeaderReference";
    begin
        FilterLooseReferences(WalletAssetHeaderRef, WalletHeaderEntryNoParam);
        WalletAssetHeaderRef.SetRange(LinkToReference, Email);
        exit(WalletAssetHeaderRef.Count());
    end;

    local procedure CountLooseReferences(WalletHeaderEntryNoParam: Integer): Integer
    var
        WalletAssetHeaderRef: Record "NPR WalletAssetHeaderReference";
    begin
        FilterLooseReferences(WalletAssetHeaderRef, WalletHeaderEntryNoParam);
        exit(WalletAssetHeaderRef.Count());
    end;

    local procedure FilterLooseReferences(var WalletAssetHeaderRef: Record "NPR WalletAssetHeaderReference"; WalletHeaderEntryNoParam: Integer)
    var
        NullGuid: Guid;
    begin
        WalletAssetHeaderRef.Reset();
        WalletAssetHeaderRef.SetRange(WalletHeaderEntryNo, WalletHeaderEntryNoParam);
        WalletAssetHeaderRef.SetRange(LinkToTableId, 0);
        WalletAssetHeaderRef.SetRange(LinkToSystemId, NullGuid);
    end;
    #endregion
}
#endif