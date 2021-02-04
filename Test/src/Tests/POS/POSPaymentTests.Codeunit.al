codeunit 85006 "NPR POS Payment Tests"
{
    // // [Feature] POS Payment + end of sale test

    Subtype = Test;

    var
        _Initialized: Boolean;
        _POSUnit: Record "NPR POS Unit";
        _PaymentTypePOS: Record "NPR Payment Type POS";
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _POSSession: Codeunit "NPR POS Session";
        _POSStore: Record "NPR POS Store";
        _POSSetup: Record "NPR POS Setup";

    [Test]
    procedure PurchaseBelowTotal()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR Sale POS";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR Sale Line POS";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        Assert: Codeunit "Assert";
        SaleEnded: Boolean;
        POSEntry: Record "NPR POS Entry";
    begin
        // [Scenario] Check that a successful cash payment is handled correctly via a created payment line without sale ending.

        // [Given] POS & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Item line worth 10 LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := 10;
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [When] Paying 4 LCY
        SaleEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, 4, '');

        // [Then] Sale did not end
        Assert.IsFalse(SaleEnded, 'Sale should not end when paying less than the total');
        Assert.IsTrue(SalePOS.Find(), 'Active sale still exists');
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        Assert.IsFalse(POSEntry.FindFirst(), 'Sale was not moved to POS entry as it is still active');
    end;

    [Test]
    procedure PurchaseEqualTotal()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR Sale POS";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR Sale Line POS";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        SaleEnded: Boolean;
        Assert: Codeunit "Assert";
        POSEntry: Record "NPR POS Entry";
        POSSalesLine: Record "NPR POS Sales Line";
        POSPaymentLine: Record "NPR POS Payment Line";
    begin
        // [Scenario] Check that a successful cash payment is handled correctly via a created payment line, with sale ending as payment equalled the total.

        // [Given] POS & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Item line worth 10 LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := 10;
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [When] Paying 4 LCY
        SaleEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, 10, '');

        // [Then] Sale ended with information on new POS entry.
        Assert.IsTrue(SaleEnded, 'Sale ended');
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        Assert.IsTrue(POSEntry.FindFirst(), 'Sale was moved to POS Entry');

        POSPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        Assert.IsTrue(POSPaymentLine.FindFirst, 'Payment line exist with matching info');
        POSPaymentLine.TestField("Amount (LCY)", 10);
        POSPaymentLine.TestField("POS Payment Method Code", _POSPaymentMethod.Code);

        POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        Assert.IsTrue(POSSalesLine.FindFirst, 'Sales line exist with matching info');
        POSSalesLine.TestField("Amount Incl. VAT (LCY)", 10);
        POSSalesLine.TestField(Type, POSSalesLine.Type::Item);
        POSSalesLine.TestField("No.", Item."No.");
    end;

    [Test]
    procedure PurchaseAboveTotal()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalePOS: Record "NPR Sale POS";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR Sale Line POS";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        SaleEnded: Boolean;
        Assert: Codeunit "Assert";
        POSEntry: Record "NPR POS Entry";
        POSSalesLine: Record "NPR POS Sales Line";
        POSPaymentLine: Record "NPR POS Payment Line";
        Register: Record "NPR Register";
        POSSetup: Codeunit "NPR POS Setup";
        ReturnPaymentTypePOS: Record "NPR Payment Type POS";
    begin
        // [Scenario] Check that a successful cash payment is handled correctly via a created payment line, with sale ending as payment was above the total.

        // [Given] POS & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Item line worth >5 LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := 10;
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [When] Paying 4 LCY
        SaleEnded := NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, 15, '');

        // [Then] Sale ended with information on new POS entry.
        Assert.IsTrue(SaleEnded, 'Sale ended');
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        Assert.IsTrue(POSEntry.FindFirst(), 'Sale was moved to POS Entry');

        POSPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSPaymentLine.SetRange("POS Payment Method Code", _POSPaymentMethod.Code);
        Assert.IsTrue(POSPaymentLine.FindFirst, 'Payment line exist with matching info for payment');
        POSPaymentLine.TestField("Amount (LCY)", 15);

        POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        Assert.IsTrue(POSSalesLine.FindFirst, 'Sales line exist with matching info');
        POSSalesLine.TestField("Amount Incl. VAT (LCY)", 10);
        POSSalesLine.TestField(Type, POSSalesLine.Type::Item);
        POSSalesLine.TestField("No.", Item."No.");

        // [Then] POS Entry includes the change due to overtender.
        _POSSession.GetSetup(POSSetup);
        POSSetup.GetRegisterRecord(Register);
        ReturnPaymentTypePOS.GetByRegister(Register."Return Payment Type", Register."Register No.");

        POSPaymentLine.SetRange("POS Payment Method Code", ReturnPaymentTypePOS."No.");
        Assert.Istrue(POSPaymentLine.FindFirst, 'Payment line exists with matching info for return payment (change)');
        POSPaymentLine.TestField("Amount (LCY)", -5);
    end;

    procedure InitializeData()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
    begin
        if _Initialized then begin
            //Clean any previous mock session
            _POSSession.Destructor();
            Clear(_POSSession);
        end;

        if not _Initialized then begin
            NPRLibraryPOSMasterData.CreatePOSSetup(_POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            NPRLibraryPOSMasterData.CreatePOSStore(_POSStore);
            NPRLibraryPOSMasterData.CreatePOSUnit(_POSUnit, _POSStore.Code, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_POSPaymentMethod, _POSPaymentMethod."Processing Type"::CASH, '', false);
            _Initialized := true;
        end;

        Commit;
    end;
}