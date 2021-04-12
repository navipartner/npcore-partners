codeunit 85004 "NPR EFT Tests"
{
    // // [Feature] EFT Framework

    Subtype = Test;

    var
        _Initialized: Boolean;
        _POSUnit: Record "NPR POS Unit";
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _EFTSetup: Record "NPR EFT Setup";
        _LastTrxEntryNo: Integer;
        _POSSession: Codeunit "NPR POS Session";
        _POSStore: Record "NPR POS Store";
        _POSSetup: Record "NPR POS Setup";

    [Test]
    procedure PurchaseSuccess()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that a successful EFT payment is handled correctly

        // [Given] POS, EFT & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Item line worth >5 LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := 10;
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] Requesting to pay 5 LCY
        SetSessionActionStateBeforePayment();
        _LastTrxEntryNo := EFTTransactionMgt.StartPayment(_EFTSetup, 5, '', SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] 5 LCY is the trx result and a payment line for the result was created.
        EFTTransactionRequest.TestField("Result Amount", 5);
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);
        AssertPaymentLine(EFTTransactionRequest."Sales Line ID", EFTTransactionRequest."Result Amount", true);
    end;

    procedure GenericEFTPaymentSuccess(POSSession: Codeunit "NPR POS Session"; SalePOS: Record "NPR POS Sale"; PaymentAmount: Decimal)
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Add payment to an existing sales, can be used from by external test functions to add a successful EFT payment to sales
        // [Given] POS, EFT & Payment setup
        InitializeData();
        _POSSession := POSSession;

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] Requesting to pay 
        SetSessionActionStateBeforePayment();
        _LastTrxEntryNo := EFTTransactionMgt.StartPayment(_EFTSetup, PaymentAmount, '', SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] PaymentAmount LCY is the trx result and a payment line for the result was created.
        EFTTransactionRequest.TestField("Result Amount", PaymentAmount);
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);
        AssertPaymentLine(EFTTransactionRequest."Sales Line ID", EFTTransactionRequest."Result Amount", true);
    end;

    [Test]
    procedure PurchaseFailure()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that a failed EFT payment is handled correctly

        // [Given] POS, EFT & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Item line worth >5 LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := 10;
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(1);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] Requesting to pay 5 LCY
        SetSessionActionStateBeforePayment();
        _LastTrxEntryNo := EFTTransactionMgt.StartPayment(_EFTSetup, 5, '', SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] 0 LCY is the trx result and a payment line for the result was created.
        EFTTransactionRequest.TestField("Result Amount", 0);
        EFTTransactionRequest.TestField(Successful, false);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);

        AssertPaymentLine(EFTTransactionRequest."Sales Line ID", 0, true);
    end;

    [Test]
    procedure PurchaseError()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that an error'ed EFT payment is handled correctly (Note: uncaught errors at the integration level is NOT tested, since it is not supported i.e. considered a bug.)

        // [Given] POS, EFT & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Item line worth >5 LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := 10;
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(2);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] Requesting to pay 5 LCY
        SetSessionActionStateBeforePayment();
        _LastTrxEntryNo := EFTTransactionMgt.StartPayment(_EFTSetup, 5, '', SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] 5 LCY is the trx result and a payment line for the result was created.
        EFTTransactionRequest.TestField("Result Amount", 0);
        EFTTransactionRequest.TestField(Successful, false);
        EFTTransactionRequest.TestField("External Result Known", false);
        EFTTransactionRequest.TestField("Result Processed", true);

        AssertPaymentLine(EFTTransactionRequest."Sales Line ID", 0, true);
    end;

    [Test]
    procedure PurchaseSuccessThenAutoVoid()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        VoidEFTTransactionRequest: Record "NPR EFT Transaction Request";
        POSSale: Codeunit "NPR POS Sale";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that an approved and then automatically voided transaction is handled correctly.
        //            (Usecase: Signature decline, which the test mock mirrors when payment confirmation is declined.)

        // [Given] POS, EFT & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Item line worth >5 LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := 10;
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(1);

        // [When] Requesting to pay 5 LCY
        SetSessionActionStateBeforePayment();
        _LastTrxEntryNo := EFTTransactionMgt.StartPayment(_EFTSetup, 5, '', SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] 5 LCY is the trx result and a payment line for the result was created. It should be voided and linked to a newer void trx.
        EFTTransactionRequest.TestField("Result Amount", 5);
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);
        EFTTransactionRequest.TestField(Reversed, true);
        EFTTransactionRequest.TestField("Reversed by Entry No.");
        AssertPaymentLine(EFTTransactionRequest."Sales Line ID", 5, true);

        VoidEFTTransactionRequest.Get(EFTTransactionRequest."Reversed by Entry No.");
        VoidEFTTransactionRequest.TestField("Processing Type", VoidEFTTransactionRequest."Processing Type"::VOID);
        VoidEFTTransactionRequest.TestField(Successful, true);
        VoidEFTTransactionRequest.TestField("External Result Known", true);
        VoidEFTTransactionRequest.TestField("Result Amount", -5);
        VoidEFTTransactionRequest.TestField("Result Processed", true);
        AssertPaymentLine(VoidEFTTransactionRequest."Sales Line ID", -5, true);
    end;

    [Test]
    procedure PurchaseWithTip()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that a successful EFT payment is handled correctly when it includes a tip in response

        // [Given] POS, EFT & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Item line worth >5 LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := 10;
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [Given] EFT mock integration set to simulate external approval with tip of 3 LCY
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);
        EFTTestMockIntegration.SetExternalTipAmount(2);

        // [When] Requesting to pay 5 LCY
        SetSessionActionStateBeforePayment();
        _LastTrxEntryNo := EFTTransactionMgt.StartPayment(_EFTSetup, 5, '', SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] (5+2) LCY is the trx result and a payment line for the result was created along with a g/l deposit line for the tip.
        EFTTransactionRequest.TestField("Result Amount", 7);
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);
        EFTTransactionRequest.TestField("Tip Amount", 2);

        AssertPaymentLine(EFTTransactionRequest."Sales Line ID", 7, true);
        AssertServiceItemLine(EFTTransactionRequest."Tip Line ID", 2, true);
    end;

    [Test]
    procedure PurchaseWithSurcharge()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that a successful EFT payment is handled correctly when it includes surcharge in response

        // [Given] POS, EFT & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Item line worth >5 LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := 10;
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [Given] EFT mock integration set to simulate external approval with surcharge of 4 LCY
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);
        EFTTestMockIntegration.SetExternalSurchargeAmount(2);

        // [When] Requesting to pay 5 LCY
        SetSessionActionStateBeforePayment();
        _LastTrxEntryNo := EFTTransactionMgt.StartPayment(_EFTSetup, 5, '', SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] (5+2) LCY is the trx result and a payment line for the result was created along with a g/l deposit line for the surcharge.
        EFTTransactionRequest.TestField("Result Amount", 7);
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);
        EFTTransactionRequest.TestField("Fee Amount", 2);

        AssertPaymentLine(EFTTransactionRequest."Sales Line ID", 7, true);
        AssertServiceItemLine(EFTTransactionRequest."Fee Line ID", 2, true);
    end;

    [Test]
    procedure PurchaseWithCashback()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that a successful EFT payment is handled correctly when it includes cashback.

        // [Given] POS, EFT & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Item line worth 5 LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := 5;
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [Given] EFT mock integration set to simulate external approval with surcharge of 4 LCY
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] Requesting to pay 7 LCY (-> 2 LCY as cashback)
        SetSessionActionStateBeforePayment();
        _LastTrxEntryNo := EFTTransactionMgt.StartPayment(_EFTSetup, 7, '', SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] 7 LCY is the trx result and a payment line for the result was created. 2 was calculated as the cashback.
        EFTTransactionRequest.TestField("Result Amount", 7);
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);
        EFTTransactionRequest.TestField("Cashback Amount", 2);

        AssertPaymentLine(EFTTransactionRequest."Sales Line ID", 7, true);
    end;

    [Test]
    procedure CreatePurchaseRequestError()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that an error thrown when creating request record is caught and logged correctly.
        //            Example use-case: If integration does not support cashback and throws error for it when creating request.

        // [Given] POS, EFT & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Item line worth 5 LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := 5;
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(1);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] Requesting to pay 5 LCY
        // [Then] Get error back immediately
        SetSessionActionStateBeforePayment();
        asserterror EFTTransactionMgt.StartPayment(_EFTSetup, 5, '', SalePOS);
    end;

    [Test]
    procedure RefundSuccess()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that a successful unreferenced (no link to original trx) EFT refund is handled correctly

        // [Given] POS, EFT & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Item line worth -5 LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := 5;
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", -1);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] Requesting to refund 5 LCY
        SetSessionActionStateBeforePayment();
        _LastTrxEntryNo := EFTTransactionMgt.StartPayment(_EFTSetup, -5, '', SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] 5 LCY is the trx result and a payment line for the result was created.
        EFTTransactionRequest.TestField("Result Amount", -5);
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);

        AssertPaymentLine(EFTTransactionRequest."Sales Line ID", EFTTransactionRequest."Result Amount", true);
    end;

    [Test]
    procedure RefundFailure()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that a failed unreferenced (no link to original trx) EFT refund is handled correctly

        // [Given] POS, EFT & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Item line worth -5 LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := 5;
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", -1);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(1);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] Requesting to refund 5 LCY
        SetSessionActionStateBeforePayment();
        _LastTrxEntryNo := EFTTransactionMgt.StartPayment(_EFTSetup, -5, '', SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] 5 LCY is the trx result and a payment line for the result was created.
        EFTTransactionRequest.TestField("Result Amount", 0);
        EFTTransactionRequest.TestField(Successful, false);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);

        AssertPaymentLine(EFTTransactionRequest."Sales Line ID", EFTTransactionRequest."Result Amount", true);
    end;

    [Test]
    procedure ReferencedRefund()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that a successful referenced (with link to original trx) EFT refund is handled correctly.

        // [Given] An active sale, with item line and approved purchase.
        PurchaseSuccess();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] Refunding the approved EFT payment.
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _LastTrxEntryNo := EFTTransactionMgt.StartReferencedRefund(_EFTSetup, SalePOS, '', 0, OriginalEFTTransactionRequest."Entry No.");
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] The correct amount is refunded and the original payment is marked as reversed.
        EFTTransactionRequest.TestField("Result Amount", -5);
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);
        AssertPaymentLine(EFTTransactionRequest."Sales Line ID", EFTTransactionRequest."Result Amount", true);
        EFTTransactionRequest.TestField("Processed Entry No.", OriginalEFTTransactionRequest."Entry No.");
        OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Entry No.");
        OriginalEFTTransactionRequest.TestField(Reversed, true);
        OriginalEFTTransactionRequest.TestField("Reversed by Entry No.", EFTTransactionRequest."Entry No.");
    end;

    [Test]
    procedure ReferencedRefundOfNonExistingTrx()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that a failed referenced (with link to original trx) EFT refund is handled correctly, when the original is missing.

        // [Given] POS, EFT & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Item line worth 10 LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := 10;
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] Refunding the approved EFT payment, with an entry no. that doesn't exist.
        if OriginalEFTTransactionRequest.FindLast then;
        OriginalEFTTransactionRequest."Entry No." += 10000;

        // [Then] Error since the original transaction could not be found.
        asserterror EFTTransactionMgt.StartReferencedRefund(_EFTSetup, SalePOS, '', 0, OriginalEFTTransactionRequest."Entry No.");
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ReferencedRefundRecoveredPurchase()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that a referenced (with link to original trx) EFT refund is handled correctly, when the original trx is a recovered purchase record.

        // [Given] An active sale, with item line and approved purchase that was recovered.
        LookupSuccessOfLostPurchaseApproval();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);
        OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Processed Entry No.");

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] Refunding the recovered EFT payment.
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _LastTrxEntryNo := EFTTransactionMgt.StartReferencedRefund(_EFTSetup, SalePOS, '', 0, OriginalEFTTransactionRequest."Entry No.");
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] The correct amount is refunded and the original payment is marked as reversed.
        EFTTransactionRequest.TestField("Result Amount", -5);
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);
        AssertPaymentLine(EFTTransactionRequest."Sales Line ID", EFTTransactionRequest."Result Amount", true);
        EFTTransactionRequest.TestField("Processed Entry No.", OriginalEFTTransactionRequest."Entry No.");
        OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Entry No.");
        OriginalEFTTransactionRequest.TestField(Reversed, true);
        OriginalEFTTransactionRequest.TestField("Reversed by Entry No.", EFTTransactionRequest."Entry No.");
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ReferencedRefundRecoveredLookup()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that a referenced (with link to original trx) EFT refund is handled correctly, when the original trx is a successful lookup record linked to a purchase.

        // [Given] An active sale, with item line and approved purchase that was recovered.
        LookupSuccessOfLostPurchaseApproval();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] Refunding the lookup record.
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _LastTrxEntryNo := EFTTransactionMgt.StartReferencedRefund(_EFTSetup, SalePOS, '', 0, OriginalEFTTransactionRequest."Entry No.");
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] The correct amount is refunded and the original payment is marked as reversed.
        EFTTransactionRequest.TestField("Result Amount", -5);
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);
        AssertPaymentLine(EFTTransactionRequest."Sales Line ID", EFTTransactionRequest."Result Amount", true);
        OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Processed Entry No.");
        EFTTransactionRequest.TestField("Processed Entry No.", OriginalEFTTransactionRequest."Entry No.");
        OriginalEFTTransactionRequest.TestField(Reversed, true);
        OriginalEFTTransactionRequest.TestField("Reversed by Entry No.", EFTTransactionRequest."Entry No.");
    end;

    [Test]
    [HandlerFunctions('ConfirmNoHandler')]
    procedure ReferencedRefundUnrecoveredPurchase()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that a referenced (with link to original trx) EFT refund is handled correctly, when the original trx is an unrecovered purchase.

        // [Given] An active sale, with item line and approved purchase that was recovered.
        PurchaseError();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] Refunding the recovered EFT payment.
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        // [Then] An error occurs since inconclusive payments cannot be refunded directly.
        asserterror EFTTransactionMgt.StartReferencedRefund(_EFTSetup, SalePOS, '', 0, OriginalEFTTransactionRequest."Entry No.");
    end;

    [Test]
    [HandlerFunctions('ConfirmNoHandler,MessageHandler')]
    procedure ReferencedRefundUnsuccessfulLookup()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that a referenced (with link to original trx) EFT refund is handled correctly, when the original trx is an unsuccessful lookup record.

        // [Given] An active sale, with item line and approved purchase that was recovered unsuccessfully.
        LookupFailureOfLostPurchase();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] Refunding the recovered EFT payment.
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        // [Then] An error occurs since inconclusive payments cannot be refunded directly.
        asserterror EFTTransactionMgt.StartReferencedRefund(_EFTSetup, SalePOS, '', 0, OriginalEFTTransactionRequest."Entry No.");
    end;

    [Test]
    procedure VoidSuccess()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that a successful EFT void is handled correctly.

        // [Given] An active sale, with item line and approved purchase
        PurchaseSuccess();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] Voiding the approved EFT payment.
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _LastTrxEntryNo := EFTTransactionMgt.StartVoid(_EFTSetup, SalePOS, OriginalEFTTransactionRequest."Entry No.", true);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] The correct amount is refunded and the original payment is marked as reversed.
        EFTTransactionRequest.TestField("Result Amount", -5);
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);
        AssertPaymentLine(EFTTransactionRequest."Sales Line ID", EFTTransactionRequest."Result Amount", true);
        EFTTransactionRequest.TestField("Processed Entry No.", OriginalEFTTransactionRequest."Entry No.");
        OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Entry No.");
        OriginalEFTTransactionRequest.TestField(Reversed, true);
        OriginalEFTTransactionRequest.TestField("Reversed by Entry No.", EFTTransactionRequest."Entry No.");
    end;

    [Test]
    procedure VoidFailure()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that a failed EFT void is handled correctly.

        // [Given] An active sale, with item line and approved purchase.
        PurchaseSuccess();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Given] EFT mock integration set to simulate external failure
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(1);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] Voiding the approved EFT payment.
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _LastTrxEntryNo := EFTTransactionMgt.StartVoid(_EFTSetup, SalePOS, OriginalEFTTransactionRequest."Entry No.", true);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] Nothing is voided and original trx is not reversed.
        EFTTransactionRequest.TestField("Result Amount", 0);
        EFTTransactionRequest.TestField(Successful, false);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);
        EFTTransactionRequest.TestField("Processed Entry No.", OriginalEFTTransactionRequest."Entry No.");
        if not IsNullGuid(EFTTransactionRequest."Sales Line ID") then
            EFTTransactionRequest.FieldError("Sales Line ID");
        OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Entry No.");
        OriginalEFTTransactionRequest.TestField(Reversed, false);
        OriginalEFTTransactionRequest.TestField("Reversed by Entry No.", 0);
    end;

    [Test]
    procedure VoidError()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that an error'ed EFT void is handled correctly.

        // [Given] An active sale, with item line and approved purchase.
        PurchaseSuccess();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Given] EFT mock integration set to simulate external error
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(2);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] Voiding the approved EFT payment.
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _LastTrxEntryNo := EFTTransactionMgt.StartVoid(_EFTSetup, SalePOS, OriginalEFTTransactionRequest."Entry No.", true);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] Nothing is voided and original trx is not reversed.
        EFTTransactionRequest.TestField("Result Amount", 0);
        EFTTransactionRequest.TestField(Successful, false);
        EFTTransactionRequest.TestField("External Result Known", false);
        EFTTransactionRequest.TestField("Result Processed", true);
        EFTTransactionRequest.TestField("Processed Entry No.", OriginalEFTTransactionRequest."Entry No.");
        if not IsNullGuid(EFTTransactionRequest."Sales Line ID") then
            EFTTransactionRequest.FieldError("Sales Line ID");
        OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Entry No.");
        OriginalEFTTransactionRequest.TestField(Reversed, false);
        OriginalEFTTransactionRequest.TestField("Reversed by Entry No.", 0);
    end;

    [Test]
    procedure VoidOfPurchaseWithTip()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        Assert: Codeunit Assert;
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that a successful EFT void of trx with tip is handled correctly.

        // [Given] An active sale, with item line and approved purchase with tip.
        PurchaseWithTip();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] Voiding the approved EFT payment.
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _LastTrxEntryNo := EFTTransactionMgt.StartVoid(_EFTSetup, SalePOS, OriginalEFTTransactionRequest."Entry No.", true);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] The correct amount is refunded and the original payment is marked as reversed. Tip refund line is created to balance out original tip line.
        EFTTransactionRequest.TestField("Result Amount", -7);
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);
        AssertPaymentLine(EFTTransactionRequest."Sales Line ID", EFTTransactionRequest."Result Amount", true);
        AssertServiceItemLine(EFTTransactionRequest."Tip Line ID", EFTTransactionRequest."Tip Amount" * -1, true);
        EFTTransactionRequest.TestField("Processed Entry No.", OriginalEFTTransactionRequest."Entry No.");
        OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Entry No.");
        OriginalEFTTransactionRequest.TestField(Reversed, true);
        OriginalEFTTransactionRequest.TestField("Reversed by Entry No.", EFTTransactionRequest."Entry No.");
        AssertServiceItemLine(OriginalEFTTransactionRequest."Tip Line ID", OriginalEFTTransactionRequest."Tip Amount", true);
    end;

    [Test]
    procedure VoidOfPurchaseWithSurcharge()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        Assert: Codeunit Assert;
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that a successful EFT void of trx with surcharge is handled correctly.

        // [Given] An active sale, with item line and approved purchase with surcharge.
        PurchaseWithSurcharge();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] Voiding the approved EFT payment.
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _LastTrxEntryNo := EFTTransactionMgt.StartVoid(_EFTSetup, SalePOS, OriginalEFTTransactionRequest."Entry No.", true);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] The correct amount is refunded and the original payment is marked as reversed. Surcharge refund line is created to balance out original tip line.
        EFTTransactionRequest.TestField("Result Amount", -7);
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);
        AssertPaymentLine(EFTTransactionRequest."Sales Line ID", EFTTransactionRequest."Result Amount", true);
        AssertServiceItemLine(EFTTransactionRequest."Fee Line ID", EFTTransactionRequest."Fee Amount" * -1, true);
        EFTTransactionRequest.TestField("Processed Entry No.", OriginalEFTTransactionRequest."Entry No.");
        OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Entry No.");
        OriginalEFTTransactionRequest.TestField(Reversed, true);
        OriginalEFTTransactionRequest.TestField("Reversed by Entry No.", EFTTransactionRequest."Entry No.");
        AssertServiceItemLine(OriginalEFTTransactionRequest."Fee Line ID", OriginalEFTTransactionRequest."Fee Amount", true);
    end;

    [Test]
    procedure DoubleVoid()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that an EFT trx cannot be double voided.

        // [Given] An active sale, with item line and approved purchase that has been voided.
        VoidSuccess();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);
        OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Processed Entry No.");

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] Attempting to void trx again.
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        EFTTransactionRequest.Reset;
        // [Then] an error occurs since a trx can only be voided once.
        asserterror EFTTransactionMgt.StartVoid(_EFTSetup, SalePOS, OriginalEFTTransactionRequest."Entry No.", true);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure VoidRecoveredPurchase()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that voiding an EFT trx of a recovered payment is possible

        // [Given] An active sale, with item line and approved purchase that was recovered.
        LookupSuccessOfLostPurchaseApproval();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);
        OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Processed Entry No.");

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] Voiding the recovered EFT payment.
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _LastTrxEntryNo := EFTTransactionMgt.StartVoid(_EFTSetup, SalePOS, OriginalEFTTransactionRequest."Entry No.", true);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] The correct amount is refunded and the original payment is marked as reversed.
        EFTTransactionRequest.TestField("Result Amount", -5);
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);
        AssertPaymentLine(EFTTransactionRequest."Sales Line ID", EFTTransactionRequest."Result Amount", true);
        EFTTransactionRequest.TestField("Processed Entry No.", OriginalEFTTransactionRequest."Entry No.");
        OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Entry No.");
        OriginalEFTTransactionRequest.TestField(Reversed, true);
        OriginalEFTTransactionRequest.TestField("Reversed by Entry No.", EFTTransactionRequest."Entry No.");
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure VoidRecoveredLookup()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that void can also be performed on the lookup trx record of a recovered purchase trx. Same flow as VoidRecoveredPurchase()

        // [Given] An active sale, with item line and approved purchase that was recovered.
        LookupSuccessOfLostPurchaseApproval();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] Voiding the recovered EFT payment.
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _LastTrxEntryNo := EFTTransactionMgt.StartVoid(_EFTSetup, SalePOS, OriginalEFTTransactionRequest."Entry No.", true);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] The correct amount is refunded and the original payment is marked as reversed.
        EFTTransactionRequest.TestField("Result Amount", -5);
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);
        AssertPaymentLine(EFTTransactionRequest."Sales Line ID", EFTTransactionRequest."Result Amount", true);
        OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Entry No.");
        OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Processed Entry No.");
        EFTTransactionRequest.TestField("Processed Entry No.", OriginalEFTTransactionRequest."Entry No.");
        OriginalEFTTransactionRequest.TestField(Reversed, true);
        OriginalEFTTransactionRequest.TestField("Reversed by Entry No.", EFTTransactionRequest."Entry No.");
    end;

    [Test]
    procedure VoidUnrecoveredPurchase()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that voiding a payment with unknown result is impossible. (Must be recovered first, to keep NAV entries consistent. First in, before out).

        // [Given] An active sale, with item line and a failed purchase trx that has not been recovered yet.
        PurchaseError();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] Attempting to void trx
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        // [Then] an error occurs since trx result is unknown.
        asserterror EFTTransactionMgt.StartVoid(_EFTSetup, SalePOS, OriginalEFTTransactionRequest."Entry No.", true);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure VoidUnsuccessfulLookup()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that voiding a payment lookup with unknown result is impossible. (Must be successfully recovered first, to keep NAV entries consistent. First in, before out).

        // [Given] An active sale, with item line and a failed purchase trx that has not been recovered successfully.
        LookupFailureOfLostPurchase();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] Attempting to void trx
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        // [Then] an error occurs since trx result is unknown.
        asserterror EFTTransactionMgt.StartVoid(_EFTSetup, SalePOS, OriginalEFTTransactionRequest."Entry No.", true);
    end;

    [Test]
    procedure VoidSuccessFromFinishedSale()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that voiding an approved payment from a finished previous sale works.

        // [Given] A completed sale that had an approved EFT payment inside
        PostedPurchaseSuccessWithTipAndSurchargeAfterSaleEnd();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Given] New sale is started
        _POSSession.StartTransaction();
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] sending void request
        _LastTrxEntryNo := EFTTransactionMgt.StartVoid(_EFTSetup, SalePOS, OriginalEFTTransactionRequest."Entry No.", true);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] The correct amount is refunded and the original payment is marked as reversed.
        EFTTransactionRequest.TestField("Result Amount", OriginalEFTTransactionRequest."Result Amount" * -1);
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);
        EFTTransactionRequest.TestField("Processed Entry No.", OriginalEFTTransactionRequest."Entry No.");
        AssertPaymentLine(EFTTransactionRequest."Sales Line ID", EFTTransactionRequest."Result Amount", true);
        OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Entry No.");
        OriginalEFTTransactionRequest.TestField(Reversed, true);
        OriginalEFTTransactionRequest.TestField("Reversed by Entry No.", EFTTransactionRequest."Entry No.");
    end;

    [Test]
    procedure VoidTransactionInParkedSale()
    var
        POSActionSavePOSQuote: Codeunit "NPR POS Action: SavePOSSvSl";
        POSQuoteEntry: Record "NPR POS Saved Sale Entry";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that voiding an approved payment from a parked sale is not possible.

        // [Given] A parked sale with an approved EFT payment inside.
        PurchaseSuccess();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSActionSavePOSQuote.CreatePOSQuote(SalePOS, POSQuoteEntry);
        SalePOS.Delete(true);  //NPR5.55 [391678]

        // [Given] New sale is started
        _POSSession.StartTransaction();
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] sending void request
        // [Then] An error occurs
        asserterror EFTTransactionMgt.StartVoid(_EFTSetup, SalePOS, OriginalEFTTransactionRequest."Entry No.", true);
    end;

    [Test]
    procedure VoidRefund()
    var
        POSActionSavePOSQuote: Codeunit "NPR POS Action: SavePOSSvSl";
        POSQuoteEntry: Record "NPR POS Saved Sale Entry";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that successful void of a refund is handled correctly

        // [Given] An active sale with a successful refund trx in it
        RefundSuccess();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] sending void request
        _LastTrxEntryNo := EFTTransactionMgt.StartVoid(_EFTSetup, SalePOS, OriginalEFTTransactionRequest."Entry No.", true);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] The correct amount is refunded and the original payment is marked as reversed.
        EFTTransactionRequest.TestField("Result Amount", OriginalEFTTransactionRequest."Result Amount" * -1);
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);
        EFTTransactionRequest.TestField("Processed Entry No.", OriginalEFTTransactionRequest."Entry No.");
        AssertPaymentLine(EFTTransactionRequest."Sales Line ID", EFTTransactionRequest."Result Amount", true);
        OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Entry No.");
        OriginalEFTTransactionRequest.TestField(Reversed, true);
        OriginalEFTTransactionRequest.TestField("Reversed by Entry No.", EFTTransactionRequest."Entry No.");
    end;

    [Test]
    procedure OpenSuccess()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that successful EFT open is handled correctly.

        // [Given] POS, EFT & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSession(_POSSession, _POSUnit);
        _POSSession.StartTransaction();

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] sending open EFT request
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _LastTrxEntryNo := EFTTransactionMgt.StartBeginWorkshift(_EFTSetup, SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] Result is properly handled
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("Result Processed", true);
    end;

    [Test]
    procedure OpenFailure()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that failed EFT open is handled correctly.

        // [Given] POS, EFT & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSession(_POSSession, _POSUnit);
        _POSSession.StartTransaction();

        // [Given] EFT mock integration set to simulate external failure
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(1);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] sending open EFT request
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _LastTrxEntryNo := EFTTransactionMgt.StartBeginWorkshift(_EFTSetup, SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] Result is properly handled
        EFTTransactionRequest.TestField(Successful, false);
        EFTTransactionRequest.TestField("Result Processed", true);
    end;

    [Test]
    procedure CloseSuccess()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that successful EFT close is handled correctly.

        // [Given] POS, EFT & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSession(_POSSession, _POSUnit);
        _POSSession.StartTransaction();

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] sending close EFT request
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _LastTrxEntryNo := EFTTransactionMgt.StartEndWorkshift(_EFTSetup, SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] Result is properly handled
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("Result Processed", true);
    end;

    [Test]
    procedure CloseFailure()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that failed EFT close is handled correctly.

        // [Given] POS, EFT & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSession(_POSSession, _POSUnit);
        _POSSession.StartTransaction();

        // [Given] EFT mock integration set to simulate external failure
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(1);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] sending close EFT request
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _LastTrxEntryNo := EFTTransactionMgt.StartEndWorkshift(_EFTSetup, SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] Result is properly handled
        EFTTransactionRequest.TestField(Successful, false);
        EFTTransactionRequest.TestField("Result Processed", true);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure LookupSuccessOfLostPurchaseApproval()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that successful EFT lookup of lost trx approval is handled correctly.

        // [Given] An active sale, with item line and an error'ed purchase trx that has not been recovered yet.
        PurchaseError();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Given] EFT mock integration set to simulate external success
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);
        EFTTestMockIntegration.SetLookupAmount(OriginalEFTTransactionRequest."Amount Input");

        // [When] Performing lookup on a trx with financial impact.
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _LastTrxEntryNo := EFTTransactionMgt.StartLookup(_EFTSetup, SalePOS, OriginalEFTTransactionRequest."Entry No.");
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] Result is handled correctly and inserted on payment line.
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);
        EFTTransactionRequest.TestField("Result Amount", OriginalEFTTransactionRequest."Amount Input");
        EFTTransactionRequest.TestField("Processed Entry No.", OriginalEFTTransactionRequest."Entry No.");
        AssertPaymentLine(EFTTransactionRequest."Sales Line ID", EFTTransactionRequest."Result Amount", true);
        OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Entry No.");
        OriginalEFTTransactionRequest.TestField(Recovered, true);
        OriginalEFTTransactionRequest.TestField("Recovered by Entry No.", EFTTransactionRequest."Entry No.");
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure LookupSuccessOfLostPurchaseDecline()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that successful EFT lookup of lost trx approval is handled correctly.

        // [Given] An active sale, with item line and an error'ed purchase trx that has not been recovered yet.
        PurchaseError();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Given] EFT mock integration set to simulate external success
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);
        EFTTestMockIntegration.SetLookupAmount(0); //As if declined

        // [When] Performing lookup on the lost trx result.
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _LastTrxEntryNo := EFTTransactionMgt.StartLookup(_EFTSetup, SalePOS, OriginalEFTTransactionRequest."Entry No.");
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] Result is handled correctly and no payment line is inserted.
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);
        EFTTransactionRequest.TestField("Result Amount", 0);
        EFTTransactionRequest.TestField("Processed Entry No.", OriginalEFTTransactionRequest."Entry No.");
        OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Entry No.");
        OriginalEFTTransactionRequest.TestField(Recovered, true);
        OriginalEFTTransactionRequest.TestField("Recovered by Entry No.", EFTTransactionRequest."Entry No.");
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure LookupFailureOfLostPurchase()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that failed EFT lookup of lost trx is handled correctly.

        // [Given] An active sale, with item line and an error'ed purchase trx that has not been recovered yet.
        PurchaseError();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Given] EFT mock integration set to simulate external error
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(1);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);
        EFTTestMockIntegration.SetLookupAmount(OriginalEFTTransactionRequest."Amount Input");

        // [When] Performing lookup on a trx with financial impact.
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _LastTrxEntryNo := EFTTransactionMgt.StartLookup(_EFTSetup, SalePOS, OriginalEFTTransactionRequest."Entry No.");
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] Result is handled correctly. Original trx is still not marked as recovered and no payment line.
        EFTTransactionRequest.TestField(Successful, false);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);
        EFTTransactionRequest.TestField("Result Amount", 0);
        EFTTransactionRequest.TestField("Processed Entry No.", OriginalEFTTransactionRequest."Entry No.");
        if not IsNullGuid(EFTTransactionRequest."Sales Line ID") then
            EFTTransactionRequest.FieldError("Sales Line ID");
        OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Entry No.");
        OriginalEFTTransactionRequest.TestField(Recovered, false);
        OriginalEFTTransactionRequest.TestField("Recovered by Entry No.", 0);
    end;

    [Test]
    procedure LookupOfNonExistingTrx()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] Check that EFT lookup of non existing trx is handled correctly.

        // [Given] POS, EFT & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Item line worth >5 LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := 10;
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] Performing lookup on a non existing trx
        if OriginalEFTTransactionRequest.FindLast then;
        OriginalEFTTransactionRequest."Entry No." += 1000;

        // [Then] Error
        asserterror EFTTransactionMgt.StartLookup(_EFTSetup, SalePOS, OriginalEFTTransactionRequest."Entry No.");
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler,MessageHandler')]
    procedure LookupPromptConfirmIfLastTrxHasUnknownResult()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] The EFT lookup prompt confirmation when attempting to pay after unknown result is handled correctly, and can start looking up instead of new payment, if confirmed.

        // [Given] Confirm handler set to confirm lookup prompt.

        // [Given] An active sale, with item line and an error'ed purchase trx that has not been recovered yet.
        PurchaseError();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Given] EFT mock integration set to simulate external result
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);
        EFTTestMockIntegration.SetLookupAmount(OriginalEFTTransactionRequest."Amount Input");

        // [When] Attempting to perform another purchase trx.
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SetSessionActionStateBeforePayment();
        _LastTrxEntryNo := EFTTransactionMgt.StartPayment(_EFTSetup, 5, '', SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] The transaction ends up being a lookup of the last purchase trx instead of a new payment. Lookup is successful
        EFTTransactionRequest.TestField("Processing Type", EFTTransactionRequest."Processing Type"::LOOK_UP);
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);
        EFTTransactionRequest.TestField("Result Amount", OriginalEFTTransactionRequest."Amount Input");
        EFTTransactionRequest.TestField("Processed Entry No.", OriginalEFTTransactionRequest."Entry No.");
        AssertPaymentLine(EFTTransactionRequest."Sales Line ID", EFTTransactionRequest."Result Amount", true);
        OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Entry No.");
        OriginalEFTTransactionRequest.TestField(Recovered, true);
        OriginalEFTTransactionRequest.TestField("Recovered by Entry No.", EFTTransactionRequest."Entry No.");
    end;

    [Test]
    [HandlerFunctions('ConfirmNoHandler')]
    procedure LookupPromptDeclineIfLastTrxHasUnknownResult()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
    begin
        // [Scenario] The EFT lookup prompt confirmation when attempting to pay after unknown result is handled correctly, and can start new payment instead of looking up, if declined.

        // [Given] Confirm handler set to decline lookup prompt.

        // [Given] An active sale, with item line and an error'ed purchase trx that has not been recovered yet.
        PurchaseError();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Given] EFT mock integration set to simulate external result
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);
        EFTTestMockIntegration.SetLookupAmount(OriginalEFTTransactionRequest."Amount Input");

        // [When] Attempting to perform another purchase trx.
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SetSessionActionStateBeforePayment();
        _LastTrxEntryNo := EFTTransactionMgt.StartPayment(_EFTSetup, 5, '', SalePOS);

        // [Then] The new purchase trx was started and ended correctly. Initial transaction still needs lookup.
        EFTTransactionRequest.Get(_LastTrxEntryNo);
        EFTTransactionRequest.TestField("Processing Type", EFTTransactionRequest."Processing Type"::PAYMENT);
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);
        EFTTransactionRequest.TestField("Result Amount", 5);
        AssertPaymentLine(EFTTransactionRequest."Sales Line ID", EFTTransactionRequest."Result Amount", true);
        OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Entry No.");
        OriginalEFTTransactionRequest.TestField(Recovered, false);
        OriginalEFTTransactionRequest.TestField("Recovered by Entry No.", 0);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure DoubleLookupOfLostResult()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        EntryNo: Integer;
        Assert: Codeunit Assert;
    begin
        // [Scenario] Check that lookup cannot happen more than once.

        // [Given] An active sale, with item line and an error'ed purchase trx that has not been recovered yet.
        PurchaseError();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Given] EFT mock integration set to simulate external result
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);
        EFTTestMockIntegration.SetLookupAmount(OriginalEFTTransactionRequest."Amount Input");

        // [Given] Trx has already been recovered by a first lookup request.
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        EFTTransactionMgt.StartLookup(_EFTSetup, SalePOS, OriginalEFTTransactionRequest."Entry No.");
        OriginalEFTTransactionRequest.Find;
        OriginalEFTTransactionRequest.TestField(Recovered, true);

        // [When] Attempting to lookup the 2nd time
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        // [Then] Error
        asserterror EFTTransactionMgt.StartLookup(_EFTSetup, SalePOS, OriginalEFTTransactionRequest."Entry No.");
    end;

    [Test]
    procedure LookupOfKnownResult()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        EntryNo: Integer;
        Assert: Codeunit Assert;
    begin
        // [Scenario] Check that successful EFT lookup of known result is handled correctly.

        // [Given] An active sale, with item line and a successful purchase trx.
        PurchaseSuccess();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Given] EFT mock integration set to simulate external result
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);
        EFTTestMockIntegration.SetLookupAmount(OriginalEFTTransactionRequest."Amount Input");

        // [When] Attempting to lookup the trx
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        // [Then] Error
        asserterror EFTTransactionMgt.StartLookup(_EFTSetup, SalePOS, OriginalEFTTransactionRequest."Entry No.");
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure LookupSuccessOfLostPurchaseWithTip()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        EntryNo: Integer;
        Assert: Codeunit Assert;
    begin
        // [Scenario] Check that successful EFT lookup of lost trx is handled correctly, when lost trx had a tip amount.

        // [Given] An active sale, with item line and an error'ed purchase trx that has not been recovered yet.
        PurchaseError();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Given] EFT mock integration set to simulate external success with tip
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);
        EFTTestMockIntegration.SetLookupAmount(OriginalEFTTransactionRequest."Amount Input" + 3);
        EFTTestMockIntegration.SetExternalTipAmount(3);

        // [When] Performing lookup on a trx with financial impact.
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _LastTrxEntryNo := EFTTransactionMgt.StartLookup(_EFTSetup, SalePOS, OriginalEFTTransactionRequest."Entry No.");
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] Result is handled correctly and inserted on payment line.
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);
        EFTTransactionRequest.TestField("Result Amount", OriginalEFTTransactionRequest."Amount Input" + 3);
        EFTTransactionRequest.TestField("Processed Entry No.", OriginalEFTTransactionRequest."Entry No.");
        EFTTransactionRequest.TestField("Tip Amount", 3);
        AssertPaymentLine(EFTTransactionRequest."Sales Line ID", EFTTransactionRequest."Result Amount", true);
        AssertServiceItemLine(EFTTransactionRequest."Tip Line ID", EFTTransactionRequest."Tip Amount", true);
        OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Entry No.");
        OriginalEFTTransactionRequest.TestField(Recovered, true);
        OriginalEFTTransactionRequest.TestField("Recovered by Entry No.", EFTTransactionRequest."Entry No.");
    end;

    [Test]
    procedure LookupReversedTransaction()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        EntryNo: Integer;
        Assert: Codeunit Assert;
    begin
        // [Scenario] Check that a EFT lookup of a reversed transaction is not possible. (Result is final)

        // [Given] An active sale, with items, and approved purchase + reversed trx
        VoidSuccess();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);
        OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Processed Entry No.");

        // [When] Performing lookup on the void trx
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        // [Then] Error
        asserterror EFTTransactionMgt.StartLookup(_EFTSetup, SalePOS, OriginalEFTTransactionRequest."Entry No.");
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure LookupVoidTransaction()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        EntryNo: Integer;
        Assert: Codeunit Assert;
    begin
        // [Scenario] Check that a lookup can be performed of an error'ed void trx.

        // [Given] An active sale, with items, an approved purchase and error'ed void.
        VoidError();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Given] EFT mock integration set to simulate external result
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);
        EFTTestMockIntegration.SetLookupAmount(OriginalEFTTransactionRequest."Amount Input");

        // [When] Recovering a lost void trx result
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _LastTrxEntryNo := EFTTransactionMgt.StartLookup(_EFTSetup, SalePOS, OriginalEFTTransactionRequest."Entry No.");
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] Result is handled correctly
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);
        EFTTransactionRequest.TestField("Result Amount", OriginalEFTTransactionRequest."Amount Input");
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure LookupSuccessOfLostPurchaseFromFinishedSale()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        EntryNo: Integer;
        Assert: Codeunit Assert;
        SalesAmount: Decimal;
        PaymentAmount: Decimal;
        ChangeAmount: Decimal;
        RoundingAmount: Decimal;
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        // [Scenario] Check that a lost purchase in a sale that has finished, is handled correctly when looked up.

        // [Given] A sale with lost EFT trx inside, that has finished via other payment.
        PurchaseError();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);
        _POSSession.GetSale(POSSale);
        POSSale.GetTotals(SalesAmount, PaymentAmount, ChangeAmount, RoundingAmount);
        NPRLibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);
        NPRLibraryPOSMasterData.OpenPOSUnit(_POSUnit);
        NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, POSPaymentMethod.Code, SalesAmount, '');

        // [Given] EFT mock integration set to simulate external result
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);
        EFTTestMockIntegration.SetLookupAmount(OriginalEFTTransactionRequest."Amount Input");

        // [When] Looking up original trx
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _LastTrxEntryNo := EFTTransactionMgt.StartLookup(_EFTSetup, SalePOS, OriginalEFTTransactionRequest."Entry No.");

        // [Then] Lookup is successful but no payment line is created since the result is from another sale. Message is shown to user, explaining this.
        EFTTransactionRequest.Get(_LastTrxEntryNo);
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);
        EFTTransactionRequest.TestField("Result Amount", OriginalEFTTransactionRequest."Amount Input");

        EFTTransactionRequest.TestField("Financial Impact", false);
        if not IsNullGuid(EFTTransactionRequest."Sales Line ID") then
            EFTTransactionRequest.FieldError("Sales Line ID");
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure LookupSuccessOfLostPurchaseFromParkedSale()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        EntryNo: Integer;
        Assert: Codeunit Assert;
        POSActionSavePOSQuote: Codeunit "NPR POS Action: SavePOSSvSl";
        POSQuoteEntry: Record "NPR POS Saved Sale Entry";
    begin
        // [Scenario] Check that a lost purchase in a sale that has been parked, is handled correctly when looked up.

        // [Given] Parked sale with error'ed EFT trx inside
        PurchaseError();
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);
        POSActionSavePOSQuote.CreatePOSQuote(SalePOS, POSQuoteEntry);
        SalePOS.Delete(true);  //NPR5.55 [391678]

        // [Given] Fresh sale
        _POSSession.StartTransaction();
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] EFT mock integration set to simulate external result
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);
        EFTTestMockIntegration.SetLookupAmount(OriginalEFTTransactionRequest."Amount Input");

        // [When] Trying to do lookup of the trx
        _LastTrxEntryNo := EFTTransactionMgt.StartLookup(_EFTSetup, SalePOS, OriginalEFTTransactionRequest."Entry No.");
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] Lookup is successful but no payment line is created since the result is from another sale. Message is shown to user, explaining this.
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);
        EFTTransactionRequest.TestField("Result Amount", OriginalEFTTransactionRequest."Amount Input");

        EFTTransactionRequest.TestField("Financial Impact", false);
        if not IsNullGuid(EFTTransactionRequest."Sales Line ID") then
            EFTTransactionRequest.FieldError("Sales Line ID");
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure LookupSuccessOfLostPurchaseFromCancelledSale()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        EntryNo: Integer;
        Assert: Codeunit Assert;
        POSActionCancelSale: Codeunit "NPR POSAction: Cancel Sale";
    begin
        // [Scenario] Check that a lost purchase in a sale that has been cancelled, is handled correctly when looked up.

        // [Given] Cancelled sale with error'ed EFT trx inside
        PurchaseError();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        NPRLibraryPOSMasterData.OpenPOSUnit(_POSUnit);
        POSActionCancelSale.CancelSale(_POSSession);

        // [Given] Fresh sale
        _POSSession.StartTransaction();
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] EFT mock integration set to simulate external result
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);
        EFTTestMockIntegration.SetLookupAmount(OriginalEFTTransactionRequest."Amount Input");

        // [When] Trying to do lookup of the trx
        _LastTrxEntryNo := EFTTransactionMgt.StartLookup(_EFTSetup, SalePOS, OriginalEFTTransactionRequest."Entry No.");
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] Lookup is successful but no payment line is created since the result is from another sale. Message is shown to user, explaining this.
        EFTTransactionRequest.Get(_LastTrxEntryNo);
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);
        EFTTransactionRequest.TestField("Result Amount", OriginalEFTTransactionRequest."Amount Input");

        EFTTransactionRequest.TestField("Financial Impact", false);
        if not IsNullGuid(EFTTransactionRequest."Sales Line ID") then
            EFTTransactionRequest.FieldError("Sales Line ID");
    end;

    [Test]
    procedure AuxiliarySuccess()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        EntryNo: Integer;
        Assert: Codeunit Assert;
    begin
        // [Scenario] Check that a successful auxiliary EFT request is handled correctly

        // [Given] POS, EFT & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSession(_POSSession, _POSUnit);
        _POSSession.StartTransaction();

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] Performing auxiliary operation
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _LastTrxEntryNo := EFTTransactionMgt.StartAuxOperation(_EFTSetup, SalePOS, 1);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] operation is handled correctly
        EFTTransactionRequest.TestField("Result Processed", true);
        EFTTransactionRequest.TestField(Successful, true);
    end;

    [Test]
    procedure AuxiliaryFailure()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        EntryNo: Integer;
        Assert: Codeunit Assert;
    begin
        // [Scenario] Check that a failed auxiliary EFT request is handled correctly

        // [Given] POS, EFT & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSession(_POSSession, _POSUnit);
        _POSSession.StartTransaction();

        // [Given] EFT mock integration set to simulate external failure
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(1);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] Performing auxiliary operation
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _LastTrxEntryNo := EFTTransactionMgt.StartAuxOperation(_EFTSetup, SalePOS, 1);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] operation is handled correctly
        EFTTransactionRequest.TestField("Result Processed", true);
        EFTTransactionRequest.TestField(Successful, false);
    end;

    [Test]
    procedure PostedPurchaseSuccessWithTipAndSurchargeAfterSaleEnd()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        EntryNo: Integer;
        Assert: Codeunit Assert;
        POSEntry: Record "NPR POS Entry";
        POSPaymentLine: Record "NPR POS Entry Payment Line";
        POSSalesLine: Record "NPR POS Entry Sales Line";
        SaleEnded: Boolean;
    begin
        // [Scenario] Check that a successful payment including tip & surcharge, is all posted correctly when sale ends.

        // [Given] POS, EFT & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Item line worth 5 LCY
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := 5;
        Item.Modify;
        NPRLibraryPOSMock.CreateItemLine(_POSSession, Item."No.", 1);

        // [Given] EFT mock integration set to simulate external approval with tip & surcharge
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);
        EFTTestMockIntegration.SetExternalTipAmount(3);
        EFTTestMockIntegration.SetExternalSurchargeAmount(4);

        // [Given] EFT payment on full amount (5 LCY)
        SetSessionActionStateBeforePayment();
        _LastTrxEntryNo := EFTTransactionMgt.StartPayment(_EFTSetup, 5, '', SalePOS);
        EFTTransactionRequest.Get(_LastTrxEntryNo);
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("Result Processed", true);
        EFTTransactionRequest.TestField("Result Amount", 12);
        EFTTransactionRequest.TestField("Tip Amount", 3);
        EFTTransactionRequest.TestField("Fee Amount", 4);
        AssertPaymentLine(EFTTransactionRequest."Sales Line ID", EFTTransactionRequest."Result Amount", true);
        AssertServiceItemLine(EFTTransactionRequest."Fee Line ID", EFTTransactionRequest."Fee Amount", true);
        AssertServiceItemLine(EFTTransactionRequest."Tip Line ID", EFTTransactionRequest."Tip Amount", true);

        // [When] Sale ends
        _POSSession.GetSale(POSSale);
        NPRLibraryPOSMasterData.OpenPOSUnit(_POSUnit);
        SaleEnded := NPRLibraryPOSMock.EndSale(_POSSession);
        Assert.AreEqual(true, SaleEnded, 'Sale should be able to end when amount is fully paid via EFT');

        // [Then] All 3 lines are posted correctly
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst;
        POSPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSPaymentLine.SetRange("Retail ID", EFTTransactionRequest."Sales Line ID");
        POSPaymentLine.FindFirst;
        POSPaymentLine.TestField("Amount (LCY)", EFTTransactionRequest."Result Amount");
        POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSSalesLine.SetRange("Retail ID", EFTTransactionRequest."Fee Line ID");
        POSSalesLine.FindFirst;
        POSSalesLine.TestField("Amount Incl. VAT (LCY)", EFTTransactionRequest."Fee Amount");
        POSSalesLine.SetRange("Retail ID", EFTTransactionRequest."Tip Line ID");
        POSSalesLine.FindFirst;
        POSSalesLine.TestField("Amount Incl. VAT (LCY)", EFTTransactionRequest."Tip Amount");
    end;

    [Test]
    procedure LoadGiftCardSuccess()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        EntryNo: Integer;
        Assert: Codeunit Assert;
        POSEntry: Record "NPR POS Entry";
        POSPaymentLine: Record "NPR POS Entry Payment Line";
        POSSalesLine: Record "NPR POS Entry Sales Line";
        SaleEnded: Boolean;
        POSActionEFTGiftCard: Codeunit "NPR POS Action: EFT Gift Card";
        GiftCardPOSPaymentMethod: Record "NPR POS Payment Method";
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
        DiscountLineID: Guid;
        GiftCardEFTSetup: Record "NPR EFT Setup";
    begin
        // [Scenario] Check that gift card load success is handled correctly

        // [Given] POS, EFT & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] EFT mock integration set to simulate external approval
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [Given] A gift card payment type
        NPRLibraryPOSMasterData.CreatePOSPaymentMethod(GiftCardPOSPaymentMethod, GiftCardPOSPaymentMethod."Processing Type"::VOUCHER, '', false);
        GiftCardPOSPaymentMethod.Get(GiftCardPOSPaymentMethod.Code);
        GiftCardPOSPaymentMethod."Processing Type" := GiftCardPOSPaymentMethod."Processing Type"::Voucher;
        GiftCardPOSPaymentMethod.Modify;
        NPRLibraryEFT.CreateMockEFTSetup(GiftCardEFTSetup, _POSUnit."No.", GiftCardPOSPaymentMethod.Code);

        // [When] Loading a gift card with 10% discount
        _POSSession.GetFrontEnd(POSFrontEndManagement, true);
        POSActionEFTGiftCard.PrepareGiftCardLoopBusinessLogic(_POSSession, GiftCardPOSPaymentMethod.Code, 5, 10, 1);
        _LastTrxEntryNo := POSActionEFTGiftCard.LoadGiftCard(_POSSession, POSFrontEndManagement);
        DiscountLineID := POSActionEFTGiftCard.InsertVoucherDiscountLine(_POSSession);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] Voucher and discount line has been inserted correctly
        EFTTransactionRequest.TestField("Processing Type", EFTTransactionRequest."Processing Type"::GIFTCARD_LOAD);
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);
        EFTTransactionRequest.TestField("Result Amount", -5);
        AssertGLDepositLine(EFTTransactionRequest."Sales Line ID", EFTTransactionRequest."Result Amount" * -1, true);
        AssertGLDepositLine(DiscountLineID, (5 * 0.1 * -1), true);
    end;

    [Test]
    procedure LoadGiftCardFailure()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        EntryNo: Integer;
        Assert: Codeunit Assert;
        POSEntry: Record "NPR POS Entry";
        POSPaymentLine: Record "NPR POS Entry Payment Line";
        POSSalesLine: Record "NPR POS Entry Sales Line";
        SaleEnded: Boolean;
        POSActionEFTGiftCard: Codeunit "NPR POS Action: EFT Gift Card";
        GiftCardPOSPaymentMethod: Record "NPR POS Payment Method";
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
        DiscountLineID: Guid;
        GiftCardEFTSetup: Record "NPR EFT Setup";
    begin
        // [Scenario] Check that gift card load failure is handled correctly

        // [Given] POS, EFT & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] EFT mock integration set to simulate external failure
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(1);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [Given] A gift card payment type
        NPRLibraryPOSMasterData.CreatePOSPaymentMethod(GiftCardPOSPaymentMethod, GiftCardPOSPaymentMethod."Processing Type"::VOUCHER, '', false);
        GiftCardPOSPaymentMethod.Get(GiftCardPOSPaymentMethod.Code);
        GiftCardPOSPaymentMethod."Processing Type" := GiftCardPOSPaymentMethod."Processing Type"::Voucher;
        GiftCardPOSPaymentMethod.Modify;
        NPRLibraryEFT.CreateMockEFTSetup(GiftCardEFTSetup, _POSUnit."No.", GiftCardPOSPaymentMethod.Code);

        // [When] Loading a gift card with 10% discount
        _POSSession.GetFrontEnd(POSFrontEndManagement, true);
        POSActionEFTGiftCard.PrepareGiftCardLoopBusinessLogic(_POSSession, GiftCardPOSPaymentMethod.Code, 5, 10, 1);
        _LastTrxEntryNo := POSActionEFTGiftCard.LoadGiftCard(_POSSession, POSFrontEndManagement);
        Commit;
        asserterror POSActionEFTGiftCard.InsertVoucherDiscountLine(_POSSession);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] Voucher and discount line has been inserted correctly
        EFTTransactionRequest.TestField("Processing Type", EFTTransactionRequest."Processing Type"::GIFTCARD_LOAD);
        EFTTransactionRequest.TestField(Successful, false);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);
        EFTTransactionRequest.TestField("Result Amount", 0);
        if not IsNullGuid(EFTTransactionRequest."Sales Line ID") then
            EFTTransactionRequest.FieldError("Sales Line ID");
    end;

    [Test]
    procedure LoadGiftCardError()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        EntryNo: Integer;
        Assert: Codeunit Assert;
        POSEntry: Record "NPR POS Entry";
        POSPaymentLine: Record "NPR POS Entry Payment Line";
        POSSalesLine: Record "NPR POS Entry Sales Line";
        SaleEnded: Boolean;
        POSActionEFTGiftCard: Codeunit "NPR POS Action: EFT Gift Card";
        GiftCardPOSPaymentMethod: Record "NPR POS Payment Method";
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
        DiscountLineID: Guid;
        GiftCardEFTSetup: Record "NPR EFT Setup";
    begin
        // [Scenario] Check that gift card load error is handled correctly

        // [Given] POS, EFT & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] EFT mock integration set to simulate external error
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(2);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [Given] A gift card payment type
        NPRLibraryPOSMasterData.CreatePOSPaymentMethod(GiftCardPOSPaymentMethod, GiftCardPOSPaymentMethod."Processing Type"::VOUCHER, '', false);
        GiftCardPOSPaymentMethod.Get(GiftCardPOSPaymentMethod.Code);
        GiftCardPOSPaymentMethod."Processing Type" := GiftCardPOSPaymentMethod."Processing Type"::Voucher;
        GiftCardPOSPaymentMethod.Modify;
        NPRLibraryEFT.CreateMockEFTSetup(GiftCardEFTSetup, _POSUnit."No.", GiftCardPOSPaymentMethod.Code);

        // [When] Loading a gift card with 10% discount
        _POSSession.GetFrontEnd(POSFrontEndManagement, true);
        POSActionEFTGiftCard.PrepareGiftCardLoopBusinessLogic(_POSSession, GiftCardPOSPaymentMethod.Code, 5, 10, 1);
        _LastTrxEntryNo := POSActionEFTGiftCard.LoadGiftCard(_POSSession, POSFrontEndManagement);
        Commit;
        asserterror POSActionEFTGiftCard.InsertVoucherDiscountLine(_POSSession);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] Voucher and discount line has been inserted correctly
        EFTTransactionRequest.TestField("Processing Type", EFTTransactionRequest."Processing Type"::GIFTCARD_LOAD);
        EFTTransactionRequest.TestField(Successful, false);
        EFTTransactionRequest.TestField("External Result Known", false);
        EFTTransactionRequest.TestField("Result Processed", true);
        EFTTransactionRequest.TestField("Result Amount", 0);
        if not IsNullGuid(EFTTransactionRequest."Sales Line ID") then
            EFTTransactionRequest.FieldError("Sales Line ID");
    end;

    [Test]
    procedure VoidLoadGiftCard()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        EntryNo: Integer;
        Assert: Codeunit Assert;
        POSEntry: Record "NPR POS Entry";
        POSPaymentLine: Record "NPR POS Entry Payment Line";
        POSSalesLine: Record "NPR POS Entry Sales Line";
        SaleEnded: Boolean;
        POSActionEFTGiftCard: Codeunit "NPR POS Action: EFT Gift Card";
        GiftCardPOSPaymentMethod: Record "NPR POS Payment Method";
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
        DiscountLineID: Guid;
        GiftCardEFTSetup: Record "NPR EFT Setup";
    begin
        // [Scenario] Check that a gift card load can be voided.

        // [Given] A successful gift card load in an active sale
        LoadGiftCardSuccess();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Given] EFT mock integration set to simulate external success
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);

        // [When] Voiding the trx
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _LastTrxEntryNo := EFTTransactionMgt.StartVoid(_EFTSetup, SalePOS, OriginalEFTTransactionRequest."Entry No.", true);
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] The correct amount is refunded and the original giftcard load is marked as reversed.
        EFTTransactionRequest.TestField("Result Amount", 5);
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);
        AssertGLDepositLine(EFTTransactionRequest."Sales Line ID", EFTTransactionRequest."Result Amount" * -1, true);
        EFTTransactionRequest.TestField("Processed Entry No.", OriginalEFTTransactionRequest."Entry No.");
        OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Entry No.");
        OriginalEFTTransactionRequest.TestField(Reversed, true);
        OriginalEFTTransactionRequest.TestField("Reversed by Entry No.", EFTTransactionRequest."Entry No.");
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure LookupLostLoadGiftCardResult()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        EFTTestMockIntegration: Codeunit "NPR EFT Test Mock Integrat.";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Item: Record Item;
        POSSale: Codeunit "NPR POS Sale";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        EntryNo: Integer;
        Assert: Codeunit Assert;
        POSEntry: Record "NPR POS Entry";
        POSPaymentLine: Record "NPR POS Entry Payment Line";
        POSSalesLine: Record "NPR POS Entry Sales Line";
        SaleEnded: Boolean;
        POSActionEFTGiftCard: Codeunit "NPR POS Action: EFT Gift Card";
        GiftCardPOSPaymentMethod: Record "NPR POS Payment Method";
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
        DiscountLineID: Guid;
        GiftCardEFTSetup: Record "NPR EFT Setup";
    begin
        // [Scenario] Check that a lost gift card approval can be looked up

        // [Given] Error'ed gift card load in an active sale
        LoadGiftCardError();
        OriginalEFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Given] EFT mock integration set to simulate external success
        BindSubscription(EFTTestMockIntegration);
        EFTTestMockIntegration.SetCreateRequestHandler(0);
        EFTTestMockIntegration.SetDeviceResponseHandler(0);
        EFTTestMockIntegration.SetPaymentConfirmationHandler(0);
        EFTTestMockIntegration.SetLookupAmount(OriginalEFTTransactionRequest."Amount Input" * -1);

        // [When] Performing lookup on a trx with financial impact.
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _LastTrxEntryNo := EFTTransactionMgt.StartLookup(_EFTSetup, SalePOS, OriginalEFTTransactionRequest."Entry No.");
        EFTTransactionRequest.Get(_LastTrxEntryNo);

        // [Then] Result is handled correctly and inserted on payment line.
        EFTTransactionRequest.TestField(Successful, true);
        EFTTransactionRequest.TestField("External Result Known", true);
        EFTTransactionRequest.TestField("Result Processed", true);
        EFTTransactionRequest.TestField("Result Amount", OriginalEFTTransactionRequest."Amount Input" * -1);
        EFTTransactionRequest.TestField("Processed Entry No.", OriginalEFTTransactionRequest."Entry No.");
        AssertGLDepositLine(EFTTransactionRequest."Sales Line ID", EFTTransactionRequest."Result Amount" * -1, true);
        OriginalEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Entry No.");
        OriginalEFTTransactionRequest.TestField(Recovered, true);
        OriginalEFTTransactionRequest.TestField("Recovered by Entry No.", EFTTransactionRequest."Entry No.");
    end;

    procedure "// Aux"()
    begin
    end;

    procedure AssertPaymentLine(LineRetailID: Guid; Amount: Decimal; ShouldExist: Boolean)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
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

    procedure AssertServiceItemLine(LineRetailID: Guid; Amount: Decimal; ShouldExist: Boolean)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.SetRange("Retail ID", LineRetailID);
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
        SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Sale);
        if ShouldExist then begin
            SaleLinePOS.FindFirst;
            SaleLinePOS.TestField("Amount Including VAT", Amount);
        end else begin
            asserterror SaleLinePOS.FindFirst;
        end;
    end;

    procedure AssertGLDepositLine(LineRetailID: Guid; Amount: Decimal; ShouldExist: Boolean)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.SetRange("Retail ID", LineRetailID);
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::"G/L Entry");
        SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Deposit);
        if ShouldExist then begin
            SaleLinePOS.FindFirst;
            SaleLinePOS.TestField("Amount Including VAT", Amount);
        end else begin
            asserterror SaleLinePOS.FindFirst;
        end;
    end;

    procedure InitializeData()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        ItemRef: Record "Item Reference";
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
            NPRLibraryPOSMasterData.CreatePOSStore(_POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(_POSUnit, _POSStore.Code, POSPostingProfile.Code);
            NPRLibraryEFT.CreateEFTPaymentTypePOS(_POSPaymentMethod, _POSUnit, _POSStore);
            NPRLibraryEFT.CreateMockEFTSetup(_EFTSetup, _POSUnit."No.", _POSPaymentMethod.Code);
            _Initialized := true;
        end;

        NPRLibraryEFT.EFTTransactionCleanup(_POSUnit."No.");
        NPRLibraryPOSMasterData.ItemReferenceCleanup();

        Commit();
    end;

    procedure SetSessionActionStateBeforePayment()
    var
        POSActionPayment: Codeunit "NPR POS Action: Payment";
    begin
        _POSSession.ClearActionState();
        _POSSession.BeginAction(POSActionPayment.ActionCode()); //Required for EFT payments as they depend on outer PAYMENT workflow session state.
    end;



    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [ConfirmHandler]
    procedure ConfirmNoHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := false;
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;
}

