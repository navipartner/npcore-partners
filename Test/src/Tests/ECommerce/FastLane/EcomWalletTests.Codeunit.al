#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 85238 "NPR Ecom Wallet Tests"
{
    Subtype = Test;

    var
        _Assert: Codeunit "Assert";

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
        DisableWallets();
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
        DisableWallets();

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
        EnableWallets();
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
        EnableWallets();
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
        EnableWallets();
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
        EnableWallets();
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

    #region Helpers
    local procedure EnableWallets()
    var
        WalletSetup: Record "NPR WalletAssetSetup";
    begin
        if not WalletSetup.Get() then
            WalletSetup.Insert();
        WalletSetup.Enabled := true;
        WalletSetup.Modify();
    end;

    local procedure DisableWallets()
    var
        WalletSetup: Record "NPR WalletAssetSetup";
    begin
        if not WalletSetup.Get() then
            WalletSetup.Insert();
        WalletSetup.Enabled := false;
        WalletSetup.Modify();
    end;

    local procedure SetupHeaderForWalletProcessing(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        LibEcom: Codeunit "NPR Library Ecommerce";
    begin
        LibEcom.CreateEcomSalesHeader(EcomSalesHeader);
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
    #endregion
}
#endif