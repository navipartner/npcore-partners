codeunit 85109 "NPR POS Action: POS Info Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('POSInfoMessage')]
    procedure ApplyPOSInfoActionOnSaleLines()
    var
        Item: Record Item;
        POSInfo: Record "NPR POS Info";
        POSInfoTransaction: Record "NPR POS Info Transaction";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSActionBusinessLogic: Codeunit "NPR POS Action: POS Info-B";
        ApplicationScope: Option " ","Current Line","All Lines","New Lines","Ask";
        i: Integer;
        ClearPOSInfo: Boolean;
        UserInputString: Text;
    begin
        //[Scenario] Apply POS info action on a sigle line in multiple lines POS Sale and check the result.

        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        NPRLibraryPOSMasterData.CreatePOSInfo('INVTEXT', POSInfo."Input Type"::Text, POSInfo.Type::"Show Message", 'This Action works OK!');

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        // [Given] Create three POS Sale lines
        for i := 1 to 3 do begin
            NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
            LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);
        end;

        // [When] Apply POS info action on single line
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        POSInfo.Get('INVTEXT');
        ApplicationScope := ApplicationScope::"All Lines";
        ClearPOSInfo := false;
        POSActionBusinessLogic.OpenPOSInfoPage(SalePOS, SaleLinePOS, POSInfo, UserInputString, ApplicationScope, ClearPOSInfo);

        // [Then] Check if the all lines have applied POS Info transactions
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.Findset() then
            repeat
                POSInfoTransaction.SetRange("POS Info Code", POSInfo.Code);
                POSInfoTransaction.SetRange("Register No.", SaleLinePOS."Register No.");
                POSInfoTransaction.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
                POSInfoTransaction.SetRange("Sales Line No.", SaleLinePOS."Line No.");
                POSInfoTransaction.FindFirst();
                Assert.AreEqual(POSInfoTransaction."POS Info Code", 'INVTEXT', 'ApplyPOSInfoActionOnSaleLines');
            until SaleLinePOS.Next() = 0;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OncePerTransactionGrossAmountIsSaleTotal()
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        POSEntry: Record "NPR POS Entry";
        POSInfo: Record "NPR POS Info";
        POSInfoPOSEntry: Record "NPR POS Info POS Entry";
        POSPaymentMethod: Record "NPR POS Payment Method";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSActionBusinessLogic: Codeunit "NPR POS Action: POS Info-B";
        ApplicationScope: Option " ","Current Line","All Lines","New Lines","Ask";
        SaleTotal: Decimal;
    begin
        //[Scenario] A once per transaction POS Info must record the sale total once, not the sale total plus its own payment lines.

        // [Given] POS & payment setup and a once per transaction POS Info
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        NPRLibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);
        NPRLibraryPOSMasterData.DontPrintReceiptOnSaleEnd(POSUnit);
        NPRLibraryPOSMasterData.CreatePOSInfo('CORE1304TRX', POSInfo."Input Type"::Text, POSInfo.Type::"Write Default Message", 'Once per transaction');
        POSInfo.Get('CORE1304TRX');
        POSInfo.Validate("Once per Transaction", true);
        POSInfo.Modify(true);

        // [Given] A sale with two item lines
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, 1, 500, '', '', '');
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, 1, 300, '', '', '');

        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleTotal := GetSaleLinesAmountInclVAT(SalePOS);
        Assert.IsTrue(SaleTotal > 0, 'The test sale must have an amount.');

        // [When] The POS Info is applied and the sale is paid and ended
        ApplicationScope := ApplicationScope::" ";
        POSActionBusinessLogic.OpenPOSInfoPage(SalePOS, SaleLinePOS, POSInfo, '', ApplicationScope, false);
        Assert.IsTrue(LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, SaleTotal, '', false), 'The sale must end.');

        // [Then] The POS Info entry holds the sale total, and it matches the POS entry
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindLast();

        POSInfoPOSEntry.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSInfoPOSEntry.SetRange("POS Info Code", POSInfo.Code);
        Assert.AreEqual(1, POSInfoPOSEntry.Count(), 'A once per transaction POS Info must create one entry only.');
        POSInfoPOSEntry.FindFirst();
        Assert.AreEqual(0, POSInfoPOSEntry."Sales Line No.", 'The entry must be the transaction level one.');
        Assert.AreEqual(SaleTotal, POSInfoPOSEntry."Gross Amount", 'Gross Amount must be the sale total, not the doubled amount.');
        Assert.AreEqual(POSEntry."Amount Incl. Tax & Round", POSInfoPOSEntry."Gross Amount", 'Gross Amount must match the POS entry amount.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AllLinesGrossAmountPerLineAndForTransaction()
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        POSEntry: Record "NPR POS Entry";
        POSInfo: Record "NPR POS Info";
        POSInfoPOSEntry: Record "NPR POS Info POS Entry";
        POSPaymentMethod: Record "NPR POS Payment Method";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        TempSaleLinePOS: Record "NPR POS Sale Line" temporary;
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSActionBusinessLogic: Codeunit "NPR POS Action: POS Info-B";
        ApplicationScope: Option " ","Current Line","All Lines","New Lines","Ask";
        SaleTotal: Decimal;
    begin
        //[Scenario] With application scope All Lines, every sale line entry gets its own amount and the transaction level entry gets the sale total.

        // [Given] POS & payment setup and a POS Info that is applied per line
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        NPRLibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);
        NPRLibraryPOSMasterData.DontPrintReceiptOnSaleEnd(POSUnit);
        NPRLibraryPOSMasterData.CreatePOSInfo('CORE1304LNS', POSInfo."Input Type"::Text, POSInfo.Type::"Write Default Message", 'All lines');
        POSInfo.Get('CORE1304LNS');

        // [Given] A sale with three item lines of different amounts
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, 1, 500, '', '', '');
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, 1, 300, '', '', '');
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, 1, 200, '', '', '');

        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        CopySaleLinesToBuffer(SalePOS, TempSaleLinePOS);
        SaleTotal := GetSaleLinesAmountInclVAT(SalePOS);

        // [When] The POS Info is applied to all lines and the sale is paid and ended
        ApplicationScope := ApplicationScope::"All Lines";
        POSActionBusinessLogic.OpenPOSInfoPage(SalePOS, SaleLinePOS, POSInfo, '', ApplicationScope, false);
        Assert.IsTrue(LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, SaleTotal, '', false), 'The sale must end.');

        // [Then] Every POS Info entry holds the amount of what it was applied to
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindLast();

        POSInfoPOSEntry.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSInfoPOSEntry.SetRange("POS Info Code", POSInfo.Code);
        Assert.AreEqual(4, POSInfoPOSEntry.Count(), 'Three sale lines and the transaction must have a POS Info entry.');
        POSInfoPOSEntry.FindSet();
        repeat
            if POSInfoPOSEntry."Sales Line No." = 0 then begin
                Assert.AreEqual(SaleTotal, POSInfoPOSEntry."Gross Amount", 'The transaction level entry must hold the sale total.');
                Assert.AreEqual(POSEntry."Amount Incl. Tax & Round", POSInfoPOSEntry."Gross Amount", 'The transaction level entry must match the POS entry amount.');
            end else begin
                TempSaleLinePOS.SetRange("Line No.", POSInfoPOSEntry."Sales Line No.");
                TempSaleLinePOS.FindFirst();
                Assert.AreEqual(TempSaleLinePOS."Amount Including VAT", POSInfoPOSEntry."Gross Amount", 'The line entry must hold the amount of its own sale line.');
            end;
        until POSInfoPOSEntry.Next() = 0;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure QuantityIsNotAddedOnTopOfStoredQuantity()
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        POSEntry: Record "NPR POS Entry";
        POSInfo: Record "NPR POS Info";
        POSInfoPOSEntry: Record "NPR POS Info POS Entry";
        POSInfoTransaction: Record "NPR POS Info Transaction";
        POSPaymentMethod: Record "NPR POS Payment Method";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSInfoReadAndInsert: Codeunit "NPR POS Info Read and Insert";
        ExpectedDiscountAmount: Decimal;
        ExpectedNetAmount: Decimal;
        SaleTotal: Decimal;
    begin
        //[Scenario] A POS Info row written through the public API already carries a quantity. End of sale must take the quantity from the sale line, not add to what is already there.

        // [Given] POS & payment setup and a POS Info
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        NPRLibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);
        NPRLibraryPOSMasterData.DontPrintReceiptOnSaleEnd(POSUnit);
        NPRLibraryPOSMasterData.CreatePOSInfo('CORE1304QTY', POSInfo."Input Type"::Text, POSInfo.Type::"Write Default Message", 'Quantity');
        POSInfo.Get('CORE1304QTY');

        // [Given] A sale with one line of three pieces
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, 3, 500, '', '', '');

        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleTotal := GetSaleLinesAmountInclVAT(SalePOS);
        ExpectedNetAmount := SaleLinePOS.Amount;
        ExpectedDiscountAmount := SaleLinePOS."Discount Amount";

        // [When] The POS Info is written through the public API, which stores the sale line quantity on the row
        POSInfoReadAndInsert.UpdatePOSInfo(POSInfo.Code, SaleLinePOS, 'Written through the public API');

        // [Given] Every amount field on the row already holds a value before the sale ends
        POSInfoTransaction.SetRange("POS Info Code", POSInfo.Code);
        POSInfoTransaction.SetRange("Register No.", SalePOS."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        POSInfoTransaction.FindFirst();
        POSInfoTransaction."Net Amount" := 999;
        POSInfoTransaction."Gross Amount" := 999;
        POSInfoTransaction."Discount Amount" := 999;
        POSInfoTransaction.Modify();

        Assert.IsTrue(LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, SaleTotal, '', false), 'The sale must end.');

        // [Then] Every posted amount comes from the sale line, none of them added on top of what was stored
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindLast();

        POSInfoPOSEntry.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSInfoPOSEntry.SetRange("POS Info Code", POSInfo.Code);
        POSInfoPOSEntry.FindFirst();
        Assert.AreEqual(3, POSInfoPOSEntry.Quantity, 'Quantity must be taken from the sale line, not added on top of the stored value.');
        Assert.AreEqual(SaleLinePOS."Amount Including VAT", POSInfoPOSEntry."Gross Amount", 'Gross Amount must be taken from the sale line, not added on top of the stored value.');
        Assert.AreEqual(ExpectedNetAmount, POSInfoPOSEntry."Net Amount", 'Net Amount must be taken from the sale line, not added on top of the stored value.');
        Assert.AreEqual(ExpectedDiscountAmount, POSInfoPOSEntry."Discount Amount", 'Discount Amount must be taken from the sale line, not added on top of the stored value.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AmountsAreCalculatedWhenStoredSaleDateIsBlank()
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        POSEntry: Record "NPR POS Entry";
        POSInfo: Record "NPR POS Info";
        POSInfoPOSEntry: Record "NPR POS Info POS Entry";
        POSInfoTransaction: Record "NPR POS Info Transaction";
        POSPaymentMethod: Record "NPR POS Payment Method";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        SaleTotal: Decimal;
    begin
        //[Scenario] The waiter pad path stores transaction level POS Info with a blank sale date. The amounts must still be calculated instead of staying at zero.

        // [Given] POS & payment setup and a POS Info
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        NPRLibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);
        NPRLibraryPOSMasterData.DontPrintReceiptOnSaleEnd(POSUnit);
        NPRLibraryPOSMasterData.CreatePOSInfo('CORE1304NODATE', POSInfo."Input Type"::Text, POSInfo.Type::"Write Default Message", 'No date');
        POSInfo.Get('CORE1304NODATE');

        // [Given] A sale with two item lines
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, 1, 500, '', '', '');
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, 1, 300, '', '', '');

        POSSale.GetCurrentSale(SalePOS);
        SaleTotal := GetSaleLinesAmountInclVAT(SalePOS);

        // [Given] A transaction level POS Info row carrying a blank sale date, the way the waiter pad path creates it
        POSInfoTransaction.Init();
        POSInfoTransaction."Register No." := SalePOS."Register No.";
        POSInfoTransaction."Sales Ticket No." := SalePOS."Sales Ticket No.";
        POSInfoTransaction."Sales Line No." := 0;
        POSInfoTransaction."Sale Date" := 0D;
        POSInfoTransaction."POS Info Code" := POSInfo.Code;
        POSInfoTransaction."POS Info" := 'Stored with no sale date';
        POSInfoTransaction.Insert(true);

        // [When] The sale is paid and ended
        Assert.IsTrue(LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, SaleTotal, '', false), 'The sale must end.');

        // [Then] The amounts are calculated, not left at zero
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindLast();

        POSInfoPOSEntry.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSInfoPOSEntry.SetRange("POS Info Code", POSInfo.Code);
        POSInfoPOSEntry.FindFirst();
        Assert.AreEqual(SaleTotal, POSInfoPOSEntry."Gross Amount", 'Gross Amount must be calculated even when the stored sale date is blank.');
        Assert.AreEqual(POSEntry."Amount Incl. Tax & Round", POSInfoPOSEntry."Gross Amount", 'Gross Amount must match the POS entry amount.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GrossAmountCarriesRoundingWithThePOSEntrySign()
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSInfo: Record "NPR POS Info";
        POSInfoPOSEntry: Record "NPR POS Info POS Entry";
        POSPaymentMethod: Record "NPR POS Payment Method";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSActionBusinessLogic: Codeunit "NPR POS Action: POS Info-B";
        POSRounding: Codeunit "NPR POS Rounding";
        ApplicationScope: Option " ","Current Line","All Lines","New Lines","Ask";
        InsertedRounding: Decimal;
    begin
        //[Scenario] A rounding line is stored negated on the sale line and reversed again when it becomes a POS entry line. The transaction level Gross Amount must still equal the POS entry amount including rounding.

        // [Given] POS & payment setup and a once per transaction POS Info
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);
        NPRLibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);
        NPRLibraryPOSMasterData.DontPrintReceiptOnSaleEnd(POSUnit);
        NPRLibraryPOSMasterData.CreatePOSInfo('CORE1304RND', POSInfo."Input Type"::Text, POSInfo.Type::"Write Default Message", 'Rounding');
        POSInfo.Get('CORE1304RND');
        POSInfo.Validate("Once per Transaction", true);
        POSInfo.Modify(true);

        // [Given] A sale of 100.03 with the POS Info applied
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        LibraryPOSMock.CreateItemLine(POSSession, Item, ItemReference, 0, 1, 100.03, '', '', '');

        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        ApplicationScope := ApplicationScope::" ";
        POSActionBusinessLogic.OpenPOSInfoPage(SalePOS, SaleLinePOS, POSInfo, '', ApplicationScope, false);

        // [Given] The customer hands over 100.05, so the payment flow books 0.02 of rounding
        InsertedRounding := POSRounding.InsertRounding(SalePOS, 0.02);
        Assert.IsTrue(InsertedRounding <> 0, 'The test needs a rounding line on the sale, otherwise it proves nothing.');

        // [When] The sale is paid and ended
        Assert.IsTrue(LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, 100.05, '', false), 'The sale must end.');

        // [Then] Gross Amount matches the POS entry including rounding, and Net Amount matches the POS entry excluding it
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindLast();

        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Rounding);
        Assert.IsFalse(POSEntrySalesLine.IsEmpty(), 'The posted sale must carry a rounding line, otherwise the rounding branch was never exercised.');

        POSInfoPOSEntry.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSInfoPOSEntry.SetRange("POS Info Code", POSInfo.Code);
        POSInfoPOSEntry.FindFirst();
        Assert.AreEqual(POSEntry."Amount Incl. Tax & Round", POSInfoPOSEntry."Gross Amount", 'Gross Amount must equal the POS entry amount including rounding.');
        Assert.AreEqual(POSEntry."Amount Excl. Tax", POSInfoPOSEntry."Net Amount", 'Net Amount must equal the POS entry amount excluding tax, which leaves rounding out.');
    end;

    local procedure GetSaleLinesAmountInclVAT(SalePOS: Record "NPR POS Sale"): Decimal
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetFilter("Line Type", '<>%1', SaleLinePOS."Line Type"::"POS Payment");
        SaleLinePOS.CalcSums("Amount Including VAT");
        exit(SaleLinePOS."Amount Including VAT");
    end;

    local procedure CopySaleLinesToBuffer(SalePOS: Record "NPR POS Sale"; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        TempSaleLinePOS.Reset();
        TempSaleLinePOS.DeleteAll();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindSet() then
            repeat
                TempSaleLinePOS := SaleLinePOS;
                TempSaleLinePOS.Insert();
            until SaleLinePOS.Next() = 0;
    end;

    [MessageHandler]
    procedure POSInfoMessage(Message: Text[1024])
    var
        POSInfoMessage: Label 'This Action works OK!';
    begin
        Assert.AreEqual(Message, POSInfoMessage, 'MessageHandler');
    end;
}