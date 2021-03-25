codeunit 85019 "NPR Tax Free Tests"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;
    [Test]
    [HandlerFunctions('AnswerYesConfirmHandlerNo')]
    procedure TryIssueVoucherGlobalBlue()
    var
        Item: Record Item;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        SalePOS: Record "NPR Sale POS";
        TaxFreeVoucher: Record "NPR Tax Free Voucher";
        TaxFreeVoucherSaleLink: Record "NPR Tax Free Voucher Sale Link";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryTaxFree: Codeunit "NPR Library - Tax Free";
        MockTaxFreeHadnlerIface: Codeunit "NPR Mock Tax Free Handler";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        TaxFreeHandler: Codeunit "NPR Tax Free Handler Mgt.";
        SaleEnded: Boolean;
        TaxFreetest: Codeunit "NPR Tax Free Tests";
        tmpHandlerParameter: Record "NPR Tax Free Handler Param." temporary;
    begin
        // [Scenario] Check if after sale system issues voucher if manualy called and store is eligible GlobalBlue

        // [Given] POS, EFT & Payment setup, Tax Free Pos Unit Setup
        InitializeData();

        // [Given] Set GloblBlue Tax Free Unit
        NPRLibraryTaxFree.AddHandlerTaxFreePosUnit(_TaxFreePOSUnit, _TaxFreeService, tmpHandlerParameter, _TaxFreePOSUnit."Handler ID Enum"::GLOBALBLUE_I2);

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Set issue Tax Free voucher manual
        SalePOS."Issue Tax Free Voucher" := true;
        SalePOS.Modify();

        // [Given] Item line unit price between service min & max for eligible store
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := NPRLibraryTaxFree.GenerateRandomDecBetween(_TaxFreeservice."Maximum Purchase Amount", _TaxFreeservice."Minimum Purchase Amount", 2);
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [Given]  Bind Mock Events to skip external communication
        BindSubscription(TaxFreetest);
        BindSubscription(MockTaxFreeHadnlerIface);

        // [When] Requesting to pay Item."Unit Price"
        SetSessionActionStateBeforePayment();
        _LastTrxEntryNo := EFTTransactionMgt.StartPayment(_EFTSetup, Item."Unit Price", '', SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [When] Sale ends
        _POSSession.GetSale(POSSale);
        SaleEnded := NPRLibraryPOSMock.EndSale(_POSSession);
        Assert.AreEqual(true, SaleEnded, 'Sale should be able to end when amount is fully paid via EFT');

        // [Then] Confirm Generated Voucher
        TaxFreeVoucherSaleLink.SetCurrentKey("Sales Ticket No.");
        TaxFreeVoucherSaleLink.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        Assert.IsTrue(TaxFreeVoucherSaleLink.FindFirst(), 'Voucher link should be created');
        Assert.IsTrue(TaxFreeVoucher.Get(TaxFreeVoucherSaleLink."Voucher Entry No."), 'Voucher should be created');

    end;

    [Test]
    [HandlerFunctions('ExpectedMessage')]
    procedure TryIssueVoucherNotEligableGlobalBlue()
    var
        Item: Record Item;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        SalePOS: Record "NPR Sale POS";
        TaxFreeVoucher: Record "NPR Tax Free Voucher";
        TaxFreeVoucherSaleLink: Record "NPR Tax Free Voucher Sale Link";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryTaxFree: Codeunit "NPR Library - Tax Free";
        MockTaxFreeHadnlerIface: Codeunit "NPR Mock Tax Free Handler";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        TaxFreeHandler: Codeunit "NPR Tax Free Handler Mgt.";
        SaleEnded: Boolean;
        TaxFreetest: Codeunit "NPR Tax Free Tests";
        tmpHandlerParameter: Record "NPR Tax Free Handler Param." temporary;
    begin
        // [Scenario] Check if after sale system does not issues voucher if manualy called and store is not eligible GlobalBlue

        // [Given] POS, EFT & Payment setup, Tax Free Pos Unit Setup
        InitializeData();

        // [Given] Set GloblBlue Tax Free Unit
        NPRLibraryTaxFree.AddHandlerTaxFreePosUnit(_TaxFreePOSUnit, _TaxFreeService, tmpHandlerParameter, _TaxFreePOSUnit."Handler ID Enum"::GLOBALBLUE_I2);

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Set issue Tax Free voucher manual
        SalePOS."Issue Tax Free Voucher" := true;
        SalePOS.Modify();

        // [Given] Item line unit price below min for not eligible store
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := _TaxFreeservice."Minimum Purchase Amount" - 1;
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [Given]  Bind Mock Events to skip external communication
        BindSubscription(TaxFreetest);
        BindSubscription(MockTaxFreeHadnlerIface);

        // [When] Requesting to pay Item."Unit Price" LCY
        SetSessionActionStateBeforePayment();
        _LastTrxEntryNo := EFTTransactionMgt.StartPayment(_EFTSetup, Item."Unit Price", '', SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [When] Sale ends
        _POSSession.GetSale(POSSale);
        SaleEnded := NPRLibraryPOSMock.EndSale(_POSSession);

        // [Then] Confirm voucher not generated
        TaxFreeVoucherSaleLink.SetCurrentKey("Sales Ticket No.");
        TaxFreeVoucherSaleLink.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        Assert.AreEqual(_ExpectedMessagesList.Contains(NotEligibleMsg), true, 'Not eligible info should appear.');
        Assert.AreEqual(true, SaleEnded, 'Sale should be able to end when amount is fully paid via EFT');
        Assert.IsFalse(TaxFreeVoucherSaleLink.FindFirst(), 'Voucher link should not be created');
        Assert.IsFalse(TaxFreeVoucher.Get(TaxFreeVoucherSaleLink."Voucher Entry No."), 'Voucher should not be created');

    end;

    [Test]
    [HandlerFunctions('AnswerYesConfirmHandlerNo')]
    procedure AskToIssueVoucherOnForeignYesGlobalBlue()
    var
        Item: Record Item;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        SalePOS: Record "NPR Sale POS";
        TaxFreeVoucher: Record "NPR Tax Free Voucher";
        TaxFreeVoucherSaleLink: Record "NPR Tax Free Voucher Sale Link";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryTaxFree: Codeunit "NPR Library - Tax Free";
        MockTaxFreeHadnlerIface: Codeunit "NPR Mock Tax Free Handler";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        TaxFreeHandler: Codeunit "NPR Tax Free Handler Mgt.";
        SaleEnded: Boolean;
        TaxFreetest: Codeunit "NPR Tax Free Tests";
        tmpHandlerParameter: Record "NPR Tax Free Handler Param." temporary;

    begin
        // [Scenario] Check if after sale system asks to issue voucher if store is eligible and card is foreign GlobalBlue

        // [Given] POS, EFT & Payment setup, Tax Free Pos Unit Setup
        InitializeData();

        // [Given] Set GloblBlue Tax Free Unit
        NPRLibraryTaxFree.AddHandlerTaxFreePosUnit(_TaxFreePOSUnit, _TaxFreeService, tmpHandlerParameter, _TaxFreePOSUnit."Handler ID Enum"::GLOBALBLUE_I2);

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Item line unit price between service min & max for eligible store
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := NPRLibraryTaxFree.GenerateRandomDecBetween(_TaxFreeservice."Maximum Purchase Amount", _TaxFreeservice."Minimum Purchase Amount", 2);
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [Given]  Bind Mock Events to skip external communication
        BindSubscription(TaxFreetest);
        BindSubscription(MockTaxFreeHadnlerIface);

        // [Given] Answer yes to this questions else no
        ConfirmAddYesAnswers(IssueTaxFreeVoucherCnfrm);

        // [When] Requesting to pay Item."Unit Price" LCY
        SetSessionActionStateBeforePayment();
        _LastTrxEntryNo := EFTTransactionMgt.StartPayment(_EFTSetup, Item."Unit Price", '', SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [When] Sale ends
        _POSSession.GetSale(POSSale);
        SaleEnded := NPRLibraryPOSMock.EndSale(_POSSession);

        // [Then] Confirm it is generated and question is asked
        TaxFreeVoucherSaleLink.SetCurrentKey("Sales Ticket No.");
        TaxFreeVoucherSaleLink.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        Assert.AreEqual(true, SaleEnded, 'Sale should be able to end when amount is fully paid via EFT');
        Assert.AreEqual(_ExpectedCnfrmList.Contains(IssueTaxFreeVoucherCnfrm), true, 'Should ask cofirmation to issue.');
        Assert.IsTrue(TaxFreeVoucherSaleLink.FindFirst(), 'Voucher link should be created');
        Assert.IsTrue(TaxFreeVoucher.Get(TaxFreeVoucherSaleLink."Voucher Entry No."), 'Voucher should be created');
    end;

    [Test]
    procedure SkipIssueVoucherQstIfNotEligibleGlobalBlue()
    var
        Item: Record Item;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        SalePOS: Record "NPR Sale POS";
        TaxFreeVoucher: Record "NPR Tax Free Voucher";
        TaxFreeVoucherSaleLink: Record "NPR Tax Free Voucher Sale Link";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryTaxFree: Codeunit "NPR Library - Tax Free";
        MockTaxFreeHadnlerIface: Codeunit "NPR Mock Tax Free Handler";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        TaxFreeHandler: Codeunit "NPR Tax Free Handler Mgt.";
        SaleEnded: Boolean;
        TaxFreetest: Codeunit "NPR Tax Free Tests";
        tmpHandlerParameter: Record "NPR Tax Free Handler Param." temporary;

    begin
        // [Scenario] Check if after sale system skip asks to issue voucher if store is not eligible and card is foreign GlobalBlue

        // [Given] POS, EFT & Payment setup, Tax Free Pos Unit Setup
        InitializeData();

        // [Given] Set GloblBlue Tax Free Unit
        NPRLibraryTaxFree.AddHandlerTaxFreePosUnit(_TaxFreePOSUnit, _TaxFreeService, tmpHandlerParameter, _TaxFreePOSUnit."Handler ID Enum"::GLOBALBLUE_I2);

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Item line unit price between service below min for not eligible store LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := _TaxFreeservice."Minimum Purchase Amount" - 1;
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [Given] Bind Mock Events to skip external communication
        BindSubscription(TaxFreetest);
        BindSubscription(MockTaxFreeHadnlerIface);

        // [When] Requesting to pay Item."Unit Price" LCY
        SetSessionActionStateBeforePayment();
        _LastTrxEntryNo := EFTTransactionMgt.StartPayment(_EFTSetup, Item."Unit Price", '', SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [When] Sale ends
        _POSSession.GetSale(POSSale);
        SaleEnded := NPRLibraryPOSMock.EndSale(_POSSession);

        // [Then] confirm it is not generated and question is not asked
        TaxFreeVoucherSaleLink.SetCurrentKey("Sales Ticket No.");
        TaxFreeVoucherSaleLink.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        Assert.IsFalse(TaxFreeVoucher.Get(TaxFreeVoucherSaleLink."Voucher Entry No."), 'Voucher should not be created');
        Assert.IsFalse(TaxFreeVoucherSaleLink.FindFirst(), 'Voucher link should not be created');
        Assert.AreEqual(true, SaleEnded, 'Sale should be able to end when amount is fully paid via EFT');
        Assert.AreEqual(_ExpectedCnfrmList.Contains(IssueTaxFreeVoucherCnfrm), false, 'Should not ask cofirmation to issue.');
    end;

    [Test]
    [HandlerFunctions('ExpectedConfirmHandlerNo')]
    procedure NoVoucherIssuedIfAnswerNoEligibleGlobalBlue()
    var
        Item: Record Item;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        SalePOS: Record "NPR Sale POS";
        TaxFreeVoucher: Record "NPR Tax Free Voucher";
        TaxFreeVoucherSaleLink: Record "NPR Tax Free Voucher Sale Link";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryTaxFree: Codeunit "NPR Library - Tax Free";
        MockTaxFreeHadnlerIface: Codeunit "NPR Mock Tax Free Handler";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        TaxFreeHandler: Codeunit "NPR Tax Free Handler Mgt.";
        SaleEnded: Boolean;
        TaxFreetest: Codeunit "NPR Tax Free Tests";
        tmpHandlerParameter: Record "NPR Tax Free Handler Param." temporary;

    begin
        // [Scenario] Check if after sale system does not issue voucher if store is eligible and card is foreign on question false GlobalBlue

        // [Given] POS, EFT & Payment setup, Tax Free Pos Unit Setup
        InitializeData();

        // [Given] Set Globl Blue
        NPRLibraryTaxFree.AddHandlerTaxFreePosUnit(_TaxFreePOSUnit, _TaxFreeService, tmpHandlerParameter, _TaxFreePOSUnit."Handler ID Enum"::GLOBALBLUE_I2);

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Item line unit price between service below min for not eligible store LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := NPRLibraryTaxFree.GenerateRandomDecBetween(_TaxFreeservice."Maximum Purchase Amount", _TaxFreeservice."Minimum Purchase Amount", 2);
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [Given] Bind Mock Events to skip external communication
        BindSubscription(TaxFreetest);
        BindSubscription(MockTaxFreeHadnlerIface);

        // [When] Requesting to pay Item."Unit Price" LCY
        SetSessionActionStateBeforePayment();
        _LastTrxEntryNo := EFTTransactionMgt.StartPayment(_EFTSetup, Item."Unit Price", '', SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [When] Sale ends
        _POSSession.GetSale(POSSale);
        SaleEnded := NPRLibraryPOSMock.EndSale(_POSSession);

        // [Then] confirm it is not generated and question is not asked
        TaxFreeVoucherSaleLink.SetCurrentKey("Sales Ticket No.");
        TaxFreeVoucherSaleLink.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        Assert.IsFalse(TaxFreeVoucherSaleLink.FindFirst(), 'Voucher link should not be created');
        Assert.AreEqual(true, SaleEnded, 'Sale should be able to end when amount is fully paid via EFT');
        Assert.AreEqual(_ExpectedCnfrmList.Contains(IssueTaxFreeVoucherCnfrm), true, 'Should ask cofirmation to issue.');
        Assert.IsFalse(TaxFreeVoucher.Get(TaxFreeVoucherSaleLink."Voucher Entry No."), 'Voucher should not be created');
    end;

    [Test]
    [HandlerFunctions('AnswerYesConfirmHandlerNo,ExpectedMessage')]
    procedure VoidIssuedVoucherGlobalBlue()
    var
        Item: Record Item;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        SalePOS: Record "NPR Sale POS";
        TaxFreeVoucher: Record "NPR Tax Free Voucher";
        TaxFreeVoucherSaleLink: Record "NPR Tax Free Voucher Sale Link";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryTaxFree: Codeunit "NPR Library - Tax Free";
        MockTaxFreeHadnlerIface: Codeunit "NPR Mock Tax Free Handler";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        TaxFreeHandler: Codeunit "NPR Tax Free Handler Mgt.";
        SaleEnded: Boolean;
        TaxFreetest: Codeunit "NPR Tax Free Tests";
        tmpHandlerParameter: Record "NPR Tax Free Handler Param." temporary;

    begin
        // [Scenario] Check can void voucher when issued GlobalBlue

        // [Given] POS, EFT & Payment setup, Tax Free Pos Unit Setup
        InitializeData();

        // [Given] Set Globl Blue Tax Free Unit
        NPRLibraryTaxFree.AddHandlerTaxFreePosUnit(_TaxFreePOSUnit, _TaxFreeService, tmpHandlerParameter, _TaxFreePOSUnit."Handler ID Enum"::GLOBALBLUE_I2);

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Set issue Tax Free voucher manual
        SalePOS."Issue Tax Free Voucher" := true;
        SalePOS.Modify();

        // [Given] Item line unit price between service min & max for eligible store LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := NPRLibraryTaxFree.GenerateRandomDecBetween(_TaxFreeservice."Maximum Purchase Amount", _TaxFreeservice."Minimum Purchase Amount", 2);
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [Given]  Bind Mock Events to skip external communication
        BindSubscription(TaxFreetest);
        BindSubscription(MockTaxFreeHadnlerIface);

        // [When] Requesting to pay Item."Unit Price" LCY
        SetSessionActionStateBeforePayment();
        _LastTrxEntryNo := EFTTransactionMgt.StartPayment(_EFTSetup, Item."Unit Price", '', SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [When] Sale ends and voucher is issued
        _POSSession.GetSale(POSSale);
        SaleEnded := NPRLibraryPOSMock.EndSale(_POSSession);
        Assert.AreEqual(true, SaleEnded, 'Sale should be able to end when amount is fully paid via EFT');

        // [Then] Try find voucher and Void voucher
        TaxFreeVoucherSaleLink.SetCurrentKey("Sales Ticket No.");
        TaxFreeVoucherSaleLink.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        Assert.IsTrue(TaxFreeVoucherSaleLink.FindFirst(), 'Voucher link should be created');
        Assert.IsTrue(TaxFreeVoucher.Get(TaxFreeVoucherSaleLink."Voucher Entry No."), 'Voucher should be created');
        TaxFreeHandler.VoucherVoid(TaxFreeVoucher);
        TaxFreeVoucher.TestField(Void, true);
    end;

    [Test]
    [HandlerFunctions('AnswerYesConfirmHandlerNo')]
    procedure ReissueIssuedVoucherGlobalBlue()
    var
        Item: Record Item;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        SalePOS: Record "NPR Sale POS";
        TaxFreeVoucher: Record "NPR Tax Free Voucher";
        TaxFreeVoucherSaleLink: Record "NPR Tax Free Voucher Sale Link";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryTaxFree: Codeunit "NPR Library - Tax Free";
        MockTaxFreeHadnlerIface: Codeunit "NPR Mock Tax Free Handler";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        TaxFreeHandler: Codeunit "NPR Tax Free Handler Mgt.";
        SaleEnded: Boolean;
        TaxFreetest: Codeunit "NPR Tax Free Tests";
        tmpHandlerParameter: Record "NPR Tax Free Handler Param." temporary;
        OldVoucher: Record "NPR Tax Free Voucher";
    begin
        // [Scenario] Check can Reissue voucher when issued GlobalBlue

        // [Given] POS, EFT & Payment setup, Tax Free Pos Unit Setup
        InitializeData();

        // [Given] Set Globl Blue Tax Free Unit
        NPRLibraryTaxFree.AddHandlerTaxFreePosUnit(_TaxFreePOSUnit, _TaxFreeService, tmpHandlerParameter, _TaxFreePOSUnit."Handler ID Enum"::GLOBALBLUE_I2);

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Set issue Tax Free voucher manual
        SalePOS."Issue Tax Free Voucher" := true;
        SalePOS.Modify();

        // [Given] Item line unit price between service min & max for eligible store LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := NPRLibraryTaxFree.GenerateRandomDecBetween(_TaxFreeservice."Maximum Purchase Amount", _TaxFreeservice."Minimum Purchase Amount", 2);
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        //[Given] Question to answer Yes
        ConfirmAddYesAnswers(ReissueQst);

        // [Given]  Bind Mock Events to skip external communication
        BindSubscription(TaxFreetest);
        BindSubscription(MockTaxFreeHadnlerIface);

        // [When] Requesting to pay Item."Unit Price" LCY
        SetSessionActionStateBeforePayment();
        _LastTrxEntryNo := EFTTransactionMgt.StartPayment(_EFTSetup, Item."Unit Price", '', SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [When] Sale ends and voucher is issued
        _POSSession.GetSale(POSSale);
        SaleEnded := NPRLibraryPOSMock.EndSale(_POSSession);
        Assert.AreEqual(true, SaleEnded, 'Sale should be able to end when amount is fully paid via EFT');

        // [Then] Try find voucher and Reissue voucher, confirm old is voided new is generated and not voided
        TaxFreeVoucherSaleLink.SetCurrentKey("Sales Ticket No.");
        TaxFreeVoucherSaleLink.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        Assert.IsTrue(TaxFreeVoucherSaleLink.FindFirst(), 'Voucher link should be created');
        Assert.IsTrue(TaxFreeVoucher.Get(TaxFreeVoucherSaleLink."Voucher Entry No."), 'Voucher should be created');
        OldVoucher.Get(TaxFreeVoucher."Entry No.");
        TaxFreeHandler.VoucherReissue(TaxFreeVoucher);
        OldVoucher.Get(OldVoucher."Entry No.");
        OldVoucher.TestField(Void, true);
        TaxFreeVoucher.Get(OldVoucher."Entry No." + 1);
        TaxFreeVoucher.TestField(Void, false);
    end;

    [Test]
    [HandlerFunctions('AnswerYesConfirmHandlerNo,ExpectedMessage')]
    procedure CantReissueVoidedVoucherGlobalBlue()
    var
        Item: Record Item;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        SalePOS: Record "NPR Sale POS";
        TaxFreeVoucher: Record "NPR Tax Free Voucher";
        TaxFreeVoucherSaleLink: Record "NPR Tax Free Voucher Sale Link";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryTaxFree: Codeunit "NPR Library - Tax Free";
        MockTaxFreeHadnlerIface: Codeunit "NPR Mock Tax Free Handler";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        TaxFreeHandler: Codeunit "NPR Tax Free Handler Mgt.";
        SaleEnded: Boolean;
        TaxFreetest: Codeunit "NPR Tax Free Tests";
        OldVoucher: Record "NPR Tax Free Voucher";
        tmpHandlerParameter: Record "NPR Tax Free Handler Param." temporary;
    begin
        // [Scenario] Check can't Reissue voucher when voided GlobalBlue


        // [Given] POS, EFT & Payment setup, Tax Free Pos Unit Setup
        InitializeData();

        // [Given] Set Globl Blue Tax Free Unit
        NPRLibraryTaxFree.AddHandlerTaxFreePosUnit(_TaxFreePOSUnit, _TaxFreeService, tmpHandlerParameter, _TaxFreePOSUnit."Handler ID Enum"::GLOBALBLUE_I2);

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Set issue Tax Free voucher manual
        SalePOS."Issue Tax Free Voucher" := true;
        SalePOS.Modify();

        // [Given] Item line unit price between service min & max for eligible store LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := NPRLibraryTaxFree.GenerateRandomDecBetween(_TaxFreeservice."Maximum Purchase Amount", _TaxFreeservice."Minimum Purchase Amount", 2);
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        //[Given] Question to answer Yes
        ConfirmAddYesAnswers(ReissueQst);

        // [Given]  Bind Mock Events to skip external communication
        BindSubscription(TaxFreetest);
        BindSubscription(MockTaxFreeHadnlerIface);

        // [When] Requesting to pay Item."Unit Price" LCY
        SetSessionActionStateBeforePayment();
        _LastTrxEntryNo := EFTTransactionMgt.StartPayment(_EFTSetup, Item."Unit Price", '', SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [When] Sale ends and voucher is issued
        _POSSession.GetSale(POSSale);
        SaleEnded := NPRLibraryPOSMock.EndSale(_POSSession);
        Assert.AreEqual(true, SaleEnded, 'Sale should be able to end when amount is fully paid via EFT');

        //[When] Void issued voucher
        TaxFreeVoucherSaleLink.SetCurrentKey("Sales Ticket No.");
        TaxFreeVoucherSaleLink.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        Assert.IsTrue(TaxFreeVoucherSaleLink.FindFirst(), 'Voucher link should be created');
        Assert.IsTrue(TaxFreeVoucher.Get(TaxFreeVoucherSaleLink."Voucher Entry No."), 'Voucher should be created');
        TaxFreeHandler.VoucherVoid(TaxFreeVoucher);

        // [Then] Try find voucher and Reissue voucher, confirm that voided voucher cannot be reissued
        TaxFreeVoucherSaleLink.SetCurrentKey("Sales Ticket No.");
        TaxFreeVoucherSaleLink.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        Assert.IsTrue(TaxFreeVoucherSaleLink.FindFirst(), 'Voucher link should be created');
        Assert.IsTrue(TaxFreeVoucher.Get(TaxFreeVoucherSaleLink."Voucher Entry No."), 'Voucher should be created');
        OldVoucher.Get(TaxFreeVoucher."Entry No.");
        TaxFreeHandler.VoucherReissue(TaxFreeVoucher);
        OldVoucher.Get(OldVoucher."Entry No.");
        OldVoucher.TestField(Void, true);
        Assert.AreEqual(_ExpectedMessagesList.Contains(AlreadyVoidedMessage), true, 'Voided info info should appear.');
        Assert.IsFalse(TaxFreeVoucher.Get(OldVoucher."Entry No." + 1), 'No new voucher shuld be issued');
    end;

    [Test]
    procedure TestErrorOnMissingDataGlobalBlue()
    var
        TaxFreeHandler: Codeunit "NPR Tax Free Handler Mgt.";
        NPRLibraryTaxFree: Codeunit "NPR Library - Tax Free";
        xValue: Text;
        tmpHandlerParameter: Record "NPR Tax Free Handler Param." temporary;

    begin
        // [Scenario] Check if missing "NPR Tax Free GB I2 Param." "Shop ID" and "Desk ID" and Username and Password throws error

        // [Given] POS, EFT, Payment setup, TaxFreePosUnit, TaxFreePosUnitParam
        InitializeData();
        // [Given] Set Globl Blue
        NPRLibraryTaxFree.AddHandlerTaxFreePosUnit(_TaxFreePOSUnit, _TaxFreeService, tmpHandlerParameter, _TaxFreePOSUnit."Handler ID Enum"::GLOBALBLUE_I2);
        _TaxFreePosUnitPrm.SetRange("Tax Free Unit", _TaxFreePOSUnit."POS Unit No.");
        _TaxFreePosUnitPrm.FindFirst();

        xValue := _TaxFreePosUnitPrm."Shop ID";

        // [When] No Shop ID
        _TaxFreePosUnitPrm."Shop ID" := '';
        _TaxFreePosUnitPrm.Modify();

        // [Then] Error mandatory fields are not set up
        asserterror TaxFreeHandler.UnitAutoConfigure(_TaxFreePOSUnit, false);

        _TaxFreePosUnitPrm."Shop ID" := xValue;

        xValue := _TaxFreePosUnitPrm."Desk ID";

        // [When] Or No Desk ID 
        _TaxFreePosUnitPrm."Desk ID" := '';
        _TaxFreePosUnitPrm.Modify();

        // [Then] Error mandatory fields are not set up
        asserterror TaxFreeHandler.UnitAutoConfigure(_TaxFreePOSUnit, false);

        _TaxFreePosUnitPrm."Desk ID" := xValue;

        xValue := _TaxFreePosUnitPrm.Username;
        // [When] Or No Username 
        _TaxFreePosUnitPrm.Username := '';
        _TaxFreePosUnitPrm.Modify();

        // [Then] Error mandatory fields are not set up
        asserterror TaxFreeHandler.UnitAutoConfigure(_TaxFreePOSUnit, false);

        _TaxFreePosUnitPrm.Username := xValue;

        xValue := _TaxFreePosUnitPrm.Password;
        // [When] Or No Password 
        _TaxFreePosUnitPrm.Password := '';
        _TaxFreePosUnitPrm.Modify();

        // [Then] Error mandatory fields are not set up
        asserterror TaxFreeHandler.UnitAutoConfigure(_TaxFreePOSUnit, false);

    end;

    [Test]
    procedure TryIssueVoucherPremier()
    var
        Item: Record Item;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        SalePOS: Record "NPR Sale POS";
        TaxFreeVoucher: Record "NPR Tax Free Voucher";
        TaxFreeVoucherSaleLink: Record "NPR Tax Free Voucher Sale Link";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryTaxFree: Codeunit "NPR Library - Tax Free";
        MockTaxFreeHadnlerIface: Codeunit "NPR Mock Tax Free Handler";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        TaxFreeHandler: Codeunit "NPR Tax Free Handler Mgt.";
        SaleEnded: Boolean;
        TaxFreetest: Codeunit "NPR Tax Free Tests";
        tmpHandlerParameter: Record "NPR Tax Free Handler Param." temporary;
        ItemValue: Decimal;
    begin
        // [Scenario]Check if after sale system does issues voucher if manualy called and store is eligible Premier

        // [Given] POS, EFT & Payment setup, Tax Free Pos Unit Setup
        InitializeData();

        // [Given] Set Premier
        NPRLibraryTaxFree.AddHandlerTaxFreePosUnit(_TaxFreePOSUnit, _TaxFreeservice, tmpHandlerParameter, _TaxFreePOSUnit."Handler ID Enum"::PREMIER_PI);

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Set issue Tax Free voucher manual
        SalePOS."Issue Tax Free Voucher" := true;
        SalePOS.Modify();

        // [Given] Item line unit price abowe min for eligible store LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        tmpHandlerParameter.DeserializeParameterBLOB(_TaxFreePOSUnit);
        tmpHandlerParameter.SetRange(Parameter, 'Minimum Amount Limit');
        tmpHandlerParameter.FindFirst();
        Evaluate(ItemValue, tmpHandlerParameter.Value);
        Item."Unit Price" := ItemValue + 1;
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [Given]  Bind Mock Events to skip external communication
        BindSubscription(TaxFreetest);
        BindSubscription(MockTaxFreeHadnlerIface);

        // [When] Requesting to pay Item."Unit Price" LCY
        SetSessionActionStateBeforePayment();
        _LastTrxEntryNo := EFTTransactionMgt.StartPayment(_EFTSetup, Item."Unit Price", '', SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [When] Sale ends
        _POSSession.GetSale(POSSale);
        SaleEnded := NPRLibraryPOSMock.EndSale(_POSSession);
        Assert.AreEqual(true, SaleEnded, 'Sale should be able to end when amount is fully paid via EFT');

        // [Then] confirm it is not generated
        TaxFreeVoucherSaleLink.SetCurrentKey("Sales Ticket No.");
        TaxFreeVoucherSaleLink.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        Assert.IsTrue(TaxFreeVoucherSaleLink.FindFirst(), 'Voucher link should be created');
        Assert.IsTrue(TaxFreeVoucher.Get(TaxFreeVoucherSaleLink."Voucher Entry No."), 'Voucher should be created');
    end;

    [Test]
    [HandlerFunctions('ExpectedMessage')]
    procedure TryErroNotEligibleIssueVoucherPremier()
    var
        Item: Record Item;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        SalePOS: Record "NPR Sale POS";
        TaxFreeVoucher: Record "NPR Tax Free Voucher";
        TaxFreeVoucherSaleLink: Record "NPR Tax Free Voucher Sale Link";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryTaxFree: Codeunit "NPR Library - Tax Free";
        MockTaxFreeHadnlerIface: Codeunit "NPR Mock Tax Free Handler";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        TaxFreeHandler: Codeunit "NPR Tax Free Handler Mgt.";
        SaleEnded: Boolean;
        TaxFreetest: Codeunit "NPR Tax Free Tests";
        tmpHandlerParameter: Record "NPR Tax Free Handler Param." temporary;
        ItemValue: Decimal;
    begin
        // [Scenario] Check if after sale system does not issues voucher if manualy called and store is not eligible Premier

        // [Given] POS, EFT & Payment setup, Tax Free Pos Unit Setup
        InitializeData();

        // [Given] Set Globl Blue
        NPRLibraryTaxFree.AddHandlerTaxFreePosUnit(_TaxFreePOSUnit, _TaxFreeService, tmpHandlerParameter, _TaxFreePOSUnit."Handler ID Enum"::PREMIER_PI);

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Set issue Tax Free voucher manual
        SalePOS."Issue Tax Free Voucher" := true;
        SalePOS.Modify();

        // [Given] Item line unit price below min for eligible store LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        tmpHandlerParameter.DeserializeParameterBLOB(_TaxFreePOSUnit);
        tmpHandlerParameter.SetRange(Parameter, 'Minimum Amount Limit');
        tmpHandlerParameter.FindFirst();
        Evaluate(ItemValue, tmpHandlerParameter.Value);
        Item."Unit Price" := ItemValue - 1;
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [Given]  Bind Mock Events to skip external communication
        BindSubscription(TaxFreetest);
        BindSubscription(MockTaxFreeHadnlerIface);
        // [When] Requesting to pay Item."Unit Price" LCY
        SetSessionActionStateBeforePayment();
        _LastTrxEntryNo := EFTTransactionMgt.StartPayment(_EFTSetup, Item."Unit Price", '', SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [When] Sale ends
        _POSSession.GetSale(POSSale);
        SaleEnded := NPRLibraryPOSMock.EndSale(_POSSession);

        // [Then] confirm it is not generated
        TaxFreeVoucherSaleLink.SetCurrentKey("Sales Ticket No.");
        TaxFreeVoucherSaleLink.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        Assert.AreEqual(_ExpectedMessagesList.Contains(NotEligibleMsg), true, 'Not eligible info should appear.');
        Assert.AreEqual(true, SaleEnded, 'Sale should be able to end when amount is fully paid via EFT');
        Assert.IsFalse(TaxFreeVoucherSaleLink.FindFirst(), 'Voucher link should not be created');
        Assert.IsFalse(TaxFreeVoucher.Get(TaxFreeVoucherSaleLink."Voucher Entry No."), 'Voucher should not be created');

    end;

    [Test]
    [HandlerFunctions('AnswerYesConfirmHandlerNo')]
    procedure AskToIssueVoucherOnForeignYesPremier()
    var
        Item: Record Item;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        SalePOS: Record "NPR Sale POS";
        TaxFreeVoucher: Record "NPR Tax Free Voucher";
        TaxFreeVoucherSaleLink: Record "NPR Tax Free Voucher Sale Link";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryTaxFree: Codeunit "NPR Library - Tax Free";
        MockTaxFreeHadnlerIface: Codeunit "NPR Mock Tax Free Handler";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        TaxFreeHandler: Codeunit "NPR Tax Free Handler Mgt.";
        SaleEnded: Boolean;
        TaxFreetest: Codeunit "NPR Tax Free Tests";
        tmpHandlerParameter: Record "NPR Tax Free Handler Param." temporary;
        ItemValue: Decimal;
    begin
        // [Scenario] Check if after sale system ask to issue voucher if and store is eligible and card foreign Premier

        // [Given] POS, EFT & Payment setup, Tax Free Pos Unit Setup
        InitializeData();

        // [Given] Set Globl Blue
        NPRLibraryTaxFree.AddHandlerTaxFreePosUnit(_TaxFreePOSUnit, _TaxFreeService, tmpHandlerParameter, _TaxFreePOSUnit."Handler ID Enum"::PREMIER_PI);

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Item line unit price abowe service min for eligible store LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        tmpHandlerParameter.DeserializeParameterBLOB(_TaxFreePOSUnit);
        tmpHandlerParameter.SetRange(Parameter, 'Minimum Amount Limit');
        tmpHandlerParameter.FindFirst();
        Evaluate(ItemValue, tmpHandlerParameter.Value);
        Item."Unit Price" := ItemValue + 1;
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [Given]  Bind Mock Events to skip external communication
        BindSubscription(TaxFreetest);
        BindSubscription(MockTaxFreeHadnlerIface);

        // [Given] Answer yes to this questions else no
        ConfirmAddYesAnswers(IssueTaxFreeVoucherCnfrm);

        // [When] Requesting to pay Item."Unit Price" LCY
        SetSessionActionStateBeforePayment();
        _LastTrxEntryNo := EFTTransactionMgt.StartPayment(_EFTSetup, Item."Unit Price", '', SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [When] Sale ends
        _POSSession.GetSale(POSSale);
        SaleEnded := NPRLibraryPOSMock.EndSale(_POSSession);

        // [Then] confirm it is generated and question is asked
        TaxFreeVoucherSaleLink.SetCurrentKey("Sales Ticket No.");
        TaxFreeVoucherSaleLink.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        Assert.AreEqual(true, SaleEnded, 'Sale should be able to end when amount is fully paid via EFT');
        Assert.AreEqual(_ExpectedCnfrmList.Contains(IssueTaxFreeVoucherCnfrm), true, 'Should ask cofirmation to issue.');
        Assert.IsTrue(TaxFreeVoucherSaleLink.FindFirst(), 'Voucher link should be created');
        Assert.IsTrue(TaxFreeVoucher.Get(TaxFreeVoucherSaleLink."Voucher Entry No."), 'Voucher should be created');
    end;

    [Test]
    procedure SkipIssueVoucherQstIfNotEligiblePremier()
    var
        Item: Record Item;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        SalePOS: Record "NPR Sale POS";
        TaxFreeVoucher: Record "NPR Tax Free Voucher";
        TaxFreeVoucherSaleLink: Record "NPR Tax Free Voucher Sale Link";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryTaxFree: Codeunit "NPR Library - Tax Free";
        MockTaxFreeHadnlerIface: Codeunit "NPR Mock Tax Free Handler";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        TaxFreeHandler: Codeunit "NPR Tax Free Handler Mgt.";
        SaleEnded: Boolean;
        TaxFreetest: Codeunit "NPR Tax Free Tests";
        tmpHandlerParameter: Record "NPR Tax Free Handler Param." temporary;
        ItemValue: Decimal;
    begin
        // [Scenario] Check if after sale system skip ask to issue voucher if store is not eligible Premier

        // [Given] POS, EFT & Payment setup, Tax Free Pos Unit Setup
        InitializeData();

        // [Given] Set Globl Blue
        NPRLibraryTaxFree.AddHandlerTaxFreePosUnit(_TaxFreePOSUnit, _TaxFreeService, tmpHandlerParameter, _TaxFreePOSUnit."Handler ID Enum"::PREMIER_PI);

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Item line unit price below service min for eligible store LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        tmpHandlerParameter.DeserializeParameterBLOB(_TaxFreePOSUnit);
        tmpHandlerParameter.SetRange(Parameter, 'Minimum Amount Limit');
        tmpHandlerParameter.FindFirst();
        Evaluate(ItemValue, tmpHandlerParameter.Value);
        Item."Unit Price" := ItemValue - 1;
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [Given] Bind Mock Events to skip external communication
        BindSubscription(TaxFreetest);
        BindSubscription(MockTaxFreeHadnlerIface);

        // [When] Requesting to pay Item."Unit Price" LCY
        SetSessionActionStateBeforePayment();
        _LastTrxEntryNo := EFTTransactionMgt.StartPayment(_EFTSetup, Item."Unit Price", '', SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [When] Sale ends
        _POSSession.GetSale(POSSale);
        SaleEnded := NPRLibraryPOSMock.EndSale(_POSSession);

        // [Then] confirm it is not generated and question is not asked
        TaxFreeVoucherSaleLink.SetCurrentKey("Sales Ticket No.");
        TaxFreeVoucherSaleLink.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        Assert.IsFalse(TaxFreeVoucher.Get(TaxFreeVoucherSaleLink."Voucher Entry No."), 'Voucher should not be created');
        Assert.IsFalse(TaxFreeVoucherSaleLink.FindFirst(), 'Voucher link should not be created');
        Assert.AreEqual(true, SaleEnded, 'Sale should be able to end when amount is fully paid via EFT');
        Assert.AreEqual(_ExpectedCnfrmList.Contains(IssueTaxFreeVoucherCnfrm), false, 'Should not ask cofirmation to issue.');
    end;

    [Test]
    [HandlerFunctions('ExpectedConfirmHandlerNo')]
    procedure NoVoucherIssuedIfAnswerNoEligiblePremier()
    var
        Item: Record Item;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        SalePOS: Record "NPR Sale POS";
        TaxFreeVoucher: Record "NPR Tax Free Voucher";
        TaxFreeVoucherSaleLink: Record "NPR Tax Free Voucher Sale Link";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryTaxFree: Codeunit "NPR Library - Tax Free";
        MockTaxFreeHadnlerIface: Codeunit "NPR Mock Tax Free Handler";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        TaxFreeHandler: Codeunit "NPR Tax Free Handler Mgt.";
        SaleEnded: Boolean;
        TaxFreetest: Codeunit "NPR Tax Free Tests";
        tmpHandlerParameter: Record "NPR Tax Free Handler Param." temporary;
        ItemValue: Decimal;
    begin
        // [Scenario] Check if after sale system does not issue voucher if store is eligible and card is foreign on question false Premier

        // [Given] POS, EFT & Payment setup, Tax Free Pos Unit Setup
        InitializeData();

        // [Given] Set Globl Blue
        NPRLibraryTaxFree.AddHandlerTaxFreePosUnit(_TaxFreePOSUnit, _TaxFreeService, tmpHandlerParameter, _TaxFreePOSUnit."Handler ID Enum"::PREMIER_PI);

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Item line unit price between service abowe min for eligible store LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        tmpHandlerParameter.DeserializeParameterBLOB(_TaxFreePOSUnit);
        tmpHandlerParameter.SetRange(Parameter, 'Minimum Amount Limit');
        tmpHandlerParameter.FindFirst();
        Evaluate(ItemValue, tmpHandlerParameter.Value);
        Item."Unit Price" := ItemValue + 1;
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [Given] Bind Mock Events to skip external communication
        BindSubscription(TaxFreetest);
        BindSubscription(MockTaxFreeHadnlerIface);

        // [When] Requesting to pay Item."Unit Price" LCY
        SetSessionActionStateBeforePayment();
        _LastTrxEntryNo := EFTTransactionMgt.StartPayment(_EFTSetup, Item."Unit Price", '', SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [When] Sale ends
        _POSSession.GetSale(POSSale);
        SaleEnded := NPRLibraryPOSMock.EndSale(_POSSession);

        // [Then] confirm it is not generated and question is not asked
        TaxFreeVoucherSaleLink.SetCurrentKey("Sales Ticket No.");
        TaxFreeVoucherSaleLink.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        Assert.IsFalse(TaxFreeVoucherSaleLink.FindFirst(), 'Voucher link should not be created');
        Assert.AreEqual(true, SaleEnded, 'Sale should be able to end when amount is fully paid via EFT');
        Assert.AreEqual(_ExpectedCnfrmList.Contains(IssueTaxFreeVoucherCnfrm), true, 'Should ask cofirmation to issue.');
        Assert.IsFalse(TaxFreeVoucher.Get(TaxFreeVoucherSaleLink."Voucher Entry No."), 'Voucher should not be created');
    end;

    [Test]
    [HandlerFunctions('ExpectedMessage')]
    procedure VoidIssuedVoucherPremier()
    var
        Item: Record Item;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        SalePOS: Record "NPR Sale POS";
        TaxFreeVoucher: Record "NPR Tax Free Voucher";
        TaxFreeVoucherSaleLink: Record "NPR Tax Free Voucher Sale Link";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryTaxFree: Codeunit "NPR Library - Tax Free";
        MockTaxFreeHadnlerIface: Codeunit "NPR Mock Tax Free Handler";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        TaxFreeHandler: Codeunit "NPR Tax Free Handler Mgt.";
        SaleEnded: Boolean;
        TaxFreetest: Codeunit "NPR Tax Free Tests";
        tmpHandlerParameter: Record "NPR Tax Free Handler Param." temporary;
        ItemValue: Decimal;
    begin
        // [Scenario] Check can void voucher when issued Premier

        // [Given] POS, EFT & Payment setup, Tax Free Pos Unit Setup
        InitializeData();

        // [Given] Set Globl Blue
        NPRLibraryTaxFree.AddHandlerTaxFreePosUnit(_TaxFreePOSUnit, _TaxFreeService, tmpHandlerParameter, _TaxFreePOSUnit."Handler ID Enum"::PREMIER_PI);

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Set issue Tax Free voucher manual
        SalePOS."Issue Tax Free Voucher" := true;
        SalePOS.Modify();

        // [Given] Item line unit price between service abowe min for eligible store LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        tmpHandlerParameter.DeserializeParameterBLOB(_TaxFreePOSUnit);
        tmpHandlerParameter.SetRange(Parameter, 'Minimum Amount Limit');
        tmpHandlerParameter.FindFirst();
        Evaluate(ItemValue, tmpHandlerParameter.Value);
        Item."Unit Price" := ItemValue + 1;
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [Given]  Bind Mock Events to skip external communication
        BindSubscription(TaxFreetest);
        BindSubscription(MockTaxFreeHadnlerIface);

        // [When] Requesting to pay Item."Unit Price" LCY
        SetSessionActionStateBeforePayment();
        _LastTrxEntryNo := EFTTransactionMgt.StartPayment(_EFTSetup, Item."Unit Price", '', SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [When] Sale ends and voucher is issued
        _POSSession.GetSale(POSSale);
        SaleEnded := NPRLibraryPOSMock.EndSale(_POSSession);
        Assert.AreEqual(true, SaleEnded, 'Sale should be able to end when amount is fully paid via EFT');

        // [Then] Try find voucher and Void voucher
        TaxFreeVoucherSaleLink.SetCurrentKey("Sales Ticket No.");
        TaxFreeVoucherSaleLink.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        Assert.IsTrue(TaxFreeVoucherSaleLink.FindFirst(), 'Voucher link should be created');
        Assert.IsTrue(TaxFreeVoucher.Get(TaxFreeVoucherSaleLink."Voucher Entry No."), 'Voucher should be created');
        TaxFreeHandler.VoucherVoid(TaxFreeVoucher);
        TaxFreeVoucher.TestField(Void, true);
    end;

    [Test]
    procedure ReissueIssuedVoucherPremier()
    var
        Item: Record Item;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        SalePOS: Record "NPR Sale POS";
        TaxFreeVoucher: Record "NPR Tax Free Voucher";
        TaxFreeVoucherSaleLink: Record "NPR Tax Free Voucher Sale Link";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryTaxFree: Codeunit "NPR Library - Tax Free";
        MockTaxFreeHadnlerIface: Codeunit "NPR Mock Tax Free Handler";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        TaxFreeHandler: Codeunit "NPR Tax Free Handler Mgt.";
        SaleEnded: Boolean;
        TaxFreetest: Codeunit "NPR Tax Free Tests";
        OldVoucher: Record "NPR Tax Free Voucher";
        tmpHandlerParameter: Record "NPR Tax Free Handler Param." temporary;
        ItemValue: Decimal;
    begin
        // [Scenario] Check can Reissue voucher when issued and check old voucher is void Premier

        // [Given] POS, EFT & Payment setup, Tax Free Pos Unit Setup
        InitializeData();

        // [Given] Set Globl Blue
        NPRLibraryTaxFree.AddHandlerTaxFreePosUnit(_TaxFreePOSUnit, _TaxFreeService, tmpHandlerParameter, _TaxFreePOSUnit."Handler ID Enum"::PREMIER_PI);

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Set issue Tax Free voucher manual
        SalePOS."Issue Tax Free Voucher" := true;
        SalePOS.Modify();

        // [Given] Item line unit price service abowe min for eligible store LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        tmpHandlerParameter.DeserializeParameterBLOB(_TaxFreePOSUnit);
        tmpHandlerParameter.SetRange(Parameter, 'Minimum Amount Limit');
        tmpHandlerParameter.FindFirst();
        Evaluate(ItemValue, tmpHandlerParameter.Value);
        Item."Unit Price" := ItemValue + 1;
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [Given]  Bind Mock Events to skip external communication
        BindSubscription(TaxFreetest);
        BindSubscription(MockTaxFreeHadnlerIface);

        // [When] Requesting to pay Item."Unit Price" LCY
        SetSessionActionStateBeforePayment();
        _LastTrxEntryNo := EFTTransactionMgt.StartPayment(_EFTSetup, Item."Unit Price", '', SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [When] Sale ends and voucher is issued
        _POSSession.GetSale(POSSale);
        SaleEnded := NPRLibraryPOSMock.EndSale(_POSSession);
        Assert.AreEqual(true, SaleEnded, 'Sale should be able to end when amount is fully paid via EFT');

        // [Then] Try find voucher and Reissue voucher
        TaxFreeVoucherSaleLink.SetCurrentKey("Sales Ticket No.");
        TaxFreeVoucherSaleLink.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        Assert.IsTrue(TaxFreeVoucherSaleLink.FindFirst(), 'Voucher link should be created');
        Assert.IsTrue(TaxFreeVoucher.Get(TaxFreeVoucherSaleLink."Voucher Entry No."), 'Voucher should be created');
        OldVoucher.Get(TaxFreeVoucher."Entry No.");
        TaxFreeHandler.VoucherReissue(TaxFreeVoucher);
    end;

    [Test]
    [HandlerFunctions('ExpectedMessage')]
    procedure CantReissueVoidedVoucherPremier()
    var
        Item: Record Item;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        SalePOS: Record "NPR Sale POS";
        TaxFreeVoucher: Record "NPR Tax Free Voucher";
        TaxFreeVoucherSaleLink: Record "NPR Tax Free Voucher Sale Link";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryTaxFree: Codeunit "NPR Library - Tax Free";
        MockTaxFreeHadnlerIface: Codeunit "NPR Mock Tax Free Handler";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        TaxFreeHandler: Codeunit "NPR Tax Free Handler Mgt.";
        SaleEnded: Boolean;
        TaxFreetest: Codeunit "NPR Tax Free Tests";
        OldVoucher: Record "NPR Tax Free Voucher";
        tmpHandlerParameter: Record "NPR Tax Free Handler Param." temporary;
        ItemValue: Decimal;
    begin
        // [Scenario] Check can't Reissue voucher when voided Premier


        // [Given] POS, EFT & Payment setup, Tax Free Pos Unit Setup
        InitializeData();

        // [Given] Set Globl Blue Tax Free Unit
        NPRLibraryTaxFree.AddHandlerTaxFreePosUnit(_TaxFreePOSUnit, _TaxFreeService, tmpHandlerParameter, _TaxFreePOSUnit."Handler ID Enum"::PREMIER_PI);

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Set issue Tax Free voucher manual
        SalePOS."Issue Tax Free Voucher" := true;
        SalePOS.Modify();

        // [Given] Item line unit price service abowe min for eligible store LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        tmpHandlerParameter.DeserializeParameterBLOB(_TaxFreePOSUnit);
        tmpHandlerParameter.SetRange(Parameter, 'Minimum Amount Limit');
        tmpHandlerParameter.FindFirst();
        Evaluate(ItemValue, tmpHandlerParameter.Value);
        Item."Unit Price" := ItemValue + 1;
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        //[Given] Question to answer Yes
        ConfirmAddYesAnswers(ReissueQst);

        // [Given]  Bind Mock Events to skip external communication
        BindSubscription(TaxFreetest);
        BindSubscription(MockTaxFreeHadnlerIface);

        // [When] Requesting to pay Item."Unit Price" LCY
        SetSessionActionStateBeforePayment();
        _LastTrxEntryNo := EFTTransactionMgt.StartPayment(_EFTSetup, Item."Unit Price", '', SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [When] Sale ends and voucher is issued
        _POSSession.GetSale(POSSale);
        SaleEnded := NPRLibraryPOSMock.EndSale(_POSSession);
        Assert.AreEqual(true, SaleEnded, 'Sale should be able to end when amount is fully paid via EFT');

        //[When] Void issued voucher
        TaxFreeVoucherSaleLink.SetCurrentKey("Sales Ticket No.");
        TaxFreeVoucherSaleLink.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        Assert.IsTrue(TaxFreeVoucherSaleLink.FindFirst(), 'Voucher link should be created');
        Assert.IsTrue(TaxFreeVoucher.Get(TaxFreeVoucherSaleLink."Voucher Entry No."), 'Voucher should be created');
        TaxFreeHandler.VoucherVoid(TaxFreeVoucher);

        // [Then] Try find voucher and Reissue voucher, confirm that voided voucher cannot be reissued
        TaxFreeVoucherSaleLink.SetCurrentKey("Sales Ticket No.");
        TaxFreeVoucherSaleLink.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        Assert.IsTrue(TaxFreeVoucherSaleLink.FindFirst(), 'Voucher link should be created');
        Assert.IsTrue(TaxFreeVoucher.Get(TaxFreeVoucherSaleLink."Voucher Entry No."), 'Voucher should be created');
        OldVoucher.Get(TaxFreeVoucher."Entry No.");
        TaxFreeHandler.VoucherReissue(TaxFreeVoucher);
        OldVoucher.Get(OldVoucher."Entry No.");
        OldVoucher.TestField(Void, true);
        Assert.AreEqual(_ExpectedMessagesList.Contains(AlreadyVoidedMessage), true, 'Voided info info should appear.');
        Assert.IsFalse(TaxFreeVoucher.Get(OldVoucher."Entry No." + 1), 'No new voucher shuld be issued');
    end;

    [MessageHandler]
    procedure ExpectedMessage(Message: Text[1024])
    begin
        _ExpectedMessagesList.Add(Message);
    end;

    [ConfirmHandler]
    procedure ExpectedConfirmHandlerYes(Question: Text[1024]; var Reply: Boolean)
    begin
        _ExpectedCnfrmList.Add(Question);
        Reply := true;
    end;

    [ConfirmHandler]
    procedure ExpectedConfirmHandlerNo(Question: Text[1024]; var Reply: Boolean)
    begin
        _ExpectedCnfrmList.Add(Question);
        Reply := false;
    end;

    [ConfirmHandler]
    procedure AnswerYesConfirmHandlerNo(Question: Text[1024]; var Reply: Boolean)
    begin
        _ExpectedCnfrmList.Add(Question);
        Reply := _YesCnfrmList.Contains(Question);
    end;

    local procedure ConfirmAddYesAnswers(Question: Text[1024])
    begin
        _YesCnfrmList.Add(Question);
    end;

    procedure InitializeData()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        NPRLibraryTaxFree: Codeunit "NPR Library - Tax Free";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
    begin
        Clear(_ExpectedMessagesList);
        Clear(_ExpectedCnfrmList);
        Clear(_YesCnfrmList);
        if _Initialized then begin
            //Clean any previous mock session
            _POSSession.Destructor();
            Clear(_POSSession);
        end;

        if not _Initialized then begin
            NPRLibraryPOSMasterData.CreatePOSSetup(_POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            NPRLibraryPOSMasterData.CreatePOSStore(_POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(_POSUnit, _POSStore.Code, POSPostingProfile.Code);
            NPRLibraryEFT.CreateEFTPaymentTypePOS(_POSPaymentMethod, _POSUnit, _POSStore);
            NPRLibraryEFT.CreateMockEFTSetup(_EFTSetup, _POSUnit."No.", _POSPaymentMethod.Code);
            NPRLibraryTaxFree.CreateTaxFreePosUnit(_POSUnit."No.", _TaxFreePOSUnit);
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_POSPaymentMethod, _POSPaymentMethod."Processing Type"::CASH, '', false);
            _Initialized := true;
        end;
NPRLibraryEFT.EFTTransactionCleanup(_POSUnit."No.");
        Commit;
    end;

    var
        NotEligibleMsg: Label 'An error occurred during tax free processing:\Sale is not eligible for tax free voucher. VAT amount or sale date is outside the allowed limits.', Locked = true;
        IssueTaxFreeVoucherCnfrm: Label 'Foreign credit card detected. Should a tax free voucher be issued for this sale?', Locked = true;
        Caption_UseID: Label 'Does the customer have Global Blue Tax Free identification available?', Locked = True;
        ReissueQst: Label 'Are you sure you want to proceed with reissue of tax free voucher:\\%1: %2\%3: %4\%5: %6\\Reissuing a tax free voucher voids the current voucher and issues a new one in its place.\The current voucher will no longer be valid for tax free refunding.\\Please proceed only if the customer is present in the store!', Locked = true;
        AlreadyVoidedMessage: Label 'An error occurred during tax free processing:\This voucher has already been voided', Locked = true;
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _Initialized: Boolean;
        _POSUnit: Record "NPR POS Unit";
        _EFTSetup: Record "NPR EFT Setup";
        _POSSession: Codeunit "NPR POS Session";
        _POSStore: Record "NPR POS Store";
        _POSSetup: Record "NPR POS Setup";
        _TaxFreePOSUnit: Record "NPR Tax Free POS Unit";
        _TaxFreeVoucher: Record "NPR Tax Free Voucher";
        _TmpTaxFreeConsolidation: Record "NPR Tax Free Consolidation" temporary;
        _TaxFreeservice: Record "NPR Tax Free GB I2 Service";
        _TaxFreePosUnitPrm: Record "NPR Tax Free GB I2 Param.";
        _LastTrxEntryNo: Integer;
        _ExpectedMessagesList: List of [Text];
        _ExpectedCnfrmList: List of [Text];
        _YesCnfrmList: List of [Text];
        Assert: Codeunit Assert;

    procedure SetSessionActionStateBeforePayment()
    var
        POSActionPayment: Codeunit "NPR POS Action: Payment";
    begin
        _POSSession.ClearActionState();
        _POSSession.BeginAction(POSActionPayment.ActionCode()); //Required for EFT payments as they depend on outer PAYMENT workflow session state.
    end;

    procedure AssertPaymentLine(LineRetailID: Guid; Amount: Decimal; ShouldExist: Boolean)
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        SaleLinePOS.SetRange("Retail ID", LineRetailID);
        SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Payment);
        if ShouldExist then begin
            SaleLinePOS.FindFirst;
            SaleLinePOS.TestField("Amount Including VAT", Amount);
        end else begin
            asserterror SaleLinePOS.FindFirst;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Tax Free Handler Mgt.", 'OnBeforeSetConstructor', '', true, true)]
    procedure OnBeforeSetConstructor(var TaxFreeHandlerIfaceIn: Interface "NPR Tax Free Handler Interface"; var ConstrSet: Boolean)
    var
        MockTaxFreeHadnlerIface: Codeunit "NPR Mock Tax Free Handler";
    begin
        TaxFreeHandlerIfaceIn := MockTaxFreeHadnlerIface;
        ConstrSet := true;
    end;
}
