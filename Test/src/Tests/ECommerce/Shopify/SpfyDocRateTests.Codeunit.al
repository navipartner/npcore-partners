codeunit 85574 "NPR Spfy Doc Rate Tests"
{
    // [FEATURE] Shopify documents stay valued at the exchange rate Shopify used
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        // One instance for the whole run: it sets up the posted document number series once, and a second setup would reissue numbers the first test committed.
        _LibraryReturn: Codeunit "NPR Library Spfy Legacy Return";
        _VoucherType: Record "NPR NpRv Voucher Type";
        _Initialized: Boolean;

    #region Rate protection

    [Test]
    procedure PostingDateMovedWithoutDialog_KeepsShopifyRate()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
    begin
        // [SCENARIO] Moving the posting date of a Shopify order where no one can be asked keeps the rate Shopify used.
        Initialize();
        // [GIVEN] A foreign currency whose table rate differs from Shopify's
        CreateCurrency(Currency);
        // [GIVEN] A Shopify order valued at Shopify's rate
        CreateShopifyOrder(SalesHeader, Currency.Code, true);

        // [WHEN] The posting date is moved with dialogs hidden
        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.Validate("Posting Date", CalcDate('<+5D>', WorkDate()));

        // [THEN] The order keeps Shopify's rate
        _Assert.AreEqual(ShopifyFactor(), SalesHeader."Currency Factor", 'A silent posting date change must not revalue a Shopify order.');
    end;

    [Test]
    procedure PostingDateMovedWithoutDialog_InvoicePostsAtShopifyRate()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        LibrarySales: Codeunit "Library - Sales";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] A Shopify order whose posting date was moved where no one could be asked posts its receivable at the rate Shopify used.
        Initialize();
        // [GIVEN] A foreign currency whose table rate differs from Shopify's
        CreateCurrency(Currency);
        // [GIVEN] A Shopify order of 100.00 valued at Shopify's rate
        CreateShopifyOrder(SalesHeader, Currency.Code, true);
        AddGLLine(SalesHeader, 100);
        // [GIVEN] Its posting date moved with dialogs hidden
        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.Validate("Posting Date", CalcDate('<+5D>', WorkDate()));
        SalesHeader.Modify(true);

        // [WHEN] The order is posted
        InvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] The receivable is 100.00 at Shopify's rate, 769.23
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange("Document No.", InvoiceNo);
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields("Amount (LCY)");
        _Assert.AreEqual(Round(100 / ShopifyFactor(), 0.01), CustLedgerEntry."Amount (LCY)", 'The invoice must post at Shopify''s rate.');
    end;

    [Test]
    procedure WarehouseShipmentPostingDate_KeepsShopifyRate()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
    begin
        // [SCENARIO] A warehouse shipment that moves the posting date of a Shopify order, which BC does without asking about the rate, keeps the rate Shopify used.
        Initialize();
        // [GIVEN] A foreign currency whose table rate differs from Shopify's
        CreateCurrency(Currency);
        // [GIVEN] A Shopify order valued at Shopify's rate
        CreateShopifyOrder(SalesHeader, Currency.Code, true);

        // [WHEN] Warehouse shipment posting moves the order's posting date, as BC's SalesWhsePostShipment does
        SalesHeader.SetCalledFromWhseDoc(true);
        SalesHeader.Validate("Posting Date", CalcDate('<+5D>', WorkDate()));

        // [THEN] The order keeps Shopify's rate
        _Assert.AreEqual(ShopifyFactor(), SalesHeader."Currency Factor", 'A warehouse posting date change must not revalue a Shopify order.');
    end;

    [Test]
    procedure FailedCurrencyEditOnReleasedOrder_LaterBatchReplacePostingDateKeepsShopifyRate()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        SalesOrder: TestPage "Sales Order";
        EditError: Text;
    begin
        // [SCENARIO] A user's failed attempt to re-enter the currency code of a released Shopify order does not let a later silent revaluation of the order through.
        Initialize();
        // [GIVEN] A foreign currency whose table rate differs from Shopify's
        CreateCurrency(Currency);
        // [GIVEN] A released Shopify order valued at Shopify's rate
        CreateShopifyOrder(SalesHeader, Currency.Code, true);
        SalesHeader.Status := SalesHeader.Status::Released;
        SalesHeader.Modify();
        // The failed edit rolls the transaction back, and the order must outlive it.
        Commit();
        // [GIVEN] The user re-entered the same currency code on the order page, which failed on the order's status
        SalesOrder.OpenEdit();
        SalesOrder.GoToRecord(SalesHeader);
        asserterror SalesOrder."Currency Code".SetValue(Currency.Code);
        EditError := GetLastErrorText();
        SalesOrder.Close();
        SalesHeader.Find();

        // [WHEN] Batch posting replaces the posting date
        SalesHeader.BatchConfirmUpdatePostingDate(true, CalcDate('<+5D>', WorkDate()), false, 0D, false);

        // [THEN] The edit had reached BC's status check, the step before the rate is read
        _Assert.IsTrue(StrPos(EditError, SalesHeader.FieldCaption(Status)) > 0, 'The currency edit must fail on the status check: ' + EditError);
        // [THEN] The posting date was replaced, so the rate would have been read again
        _Assert.AreEqual(CalcDate('<+5D>', WorkDate()), SalesHeader."Posting Date", 'Replace Posting Date must have moved the date.');
        // [THEN] The order keeps Shopify's rate
        _Assert.AreEqual(ShopifyFactor(), SalesHeader."Currency Factor", 'A failed currency edit must not let Replace Posting Date revalue a Shopify order.');
    end;

    [Test]
    procedure BatchReplacePostingDate_KeepsShopifyRate()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
    begin
        // [SCENARIO] Batch posting with Replace Posting Date keeps the rate Shopify used on a Shopify order.
        Initialize();
        // [GIVEN] A foreign currency whose table rate differs from Shopify's
        CreateCurrency(Currency);
        // [GIVEN] A Shopify order valued at Shopify's rate
        CreateShopifyOrder(SalesHeader, Currency.Code, true);

        // [WHEN] Batch posting replaces the posting date
        SalesHeader.BatchConfirmUpdatePostingDate(true, CalcDate('<+5D>', WorkDate()), false, 0D, false);

        // [THEN] The posting date was replaced, so the rate would have been read again
        _Assert.AreEqual(CalcDate('<+5D>', WorkDate()), SalesHeader."Posting Date", 'Replace Posting Date must have moved the date.');
        // [THEN] The order keeps Shopify's rate
        _Assert.AreEqual(ShopifyFactor(), SalesHeader."Currency Factor", 'Replace Posting Date must not revalue a Shopify order.');
    end;

    [Test]
    procedure BatchReplacePostingDateOnOtherDocument_TakesTableRate()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
    begin
        // [SCENARIO] Batch posting with Replace Posting Date revalues a foreign currency document that does not carry Shopify's rate from the rate table, as before.
        Initialize();
        // [GIVEN] A foreign currency whose table rate differs from the document's
        CreateCurrency(Currency);
        // [GIVEN] An order at that rate that does not carry Shopify's rate
        CreateShopifyOrder(SalesHeader, Currency.Code, false);

        // [WHEN] Batch posting replaces the posting date
        SalesHeader.BatchConfirmUpdatePostingDate(true, CalcDate('<+5D>', WorkDate()), false, 0D, false);

        // [THEN] The document takes the table rate
        _Assert.AreEqual(TableFactor(), SalesHeader."Currency Factor", 'A document without Shopify''s rate must keep BC''s behaviour.');
    end;

    [Test]
    procedure CurrencyCodeRevalidatedFromCode_KeepsShopifyRate()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
    begin
        // [SCENARIO] Code that validates an unchanged currency code again, as Sales-Post does after replacing the posting date, keeps the rate Shopify used.
        Initialize();
        // [GIVEN] A foreign currency whose table rate differs from Shopify's
        CreateCurrency(Currency);
        // [GIVEN] A Shopify order valued at Shopify's rate
        CreateShopifyOrder(SalesHeader, Currency.Code, true);

        // [WHEN] The unchanged currency code is validated again from code
        SalesHeader.Validate("Currency Code");

        // [THEN] The order keeps Shopify's rate
        _Assert.AreEqual(ShopifyFactor(), SalesHeader."Currency Factor", 'Re-validating the same currency must not revalue a Shopify order.');
    end;

    [Test]
    procedure PostingDateMovedOnOtherDocument_TakesTableRate()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
    begin
        // [SCENARIO] A foreign currency document that does not carry Shopify's rate is revalued from the rate table as before.
        Initialize();
        // [GIVEN] A foreign currency whose table rate differs from the document's
        CreateCurrency(Currency);
        // [GIVEN] An order at that rate that does not carry Shopify's rate
        CreateShopifyOrder(SalesHeader, Currency.Code, false);

        // [WHEN] The posting date is moved with dialogs hidden
        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.Validate("Posting Date", CalcDate('<+5D>', WorkDate()));

        // [THEN] The document takes the table rate
        _Assert.AreEqual(TableFactor(), SalesHeader."Currency Factor", 'A document without Shopify''s rate must keep BC''s behaviour.');
    end;

    [Test]
    procedure CurrencyChanged_ForgetsShopifyRate()
    var
        Currency: Record Currency;
        OtherCurrency: Record Currency;
        SalesHeader: Record "Sales Header";
    begin
        // [SCENARIO] A Shopify order moved to another currency no longer keeps the rate Shopify used for the first one.
        Initialize();
        // [GIVEN] Two foreign currencies
        CreateCurrency(Currency);
        CreateCurrency(OtherCurrency);
        // [GIVEN] A Shopify order valued at Shopify's rate in the first one
        CreateShopifyOrder(SalesHeader, Currency.Code, true);

        // [WHEN] The order is moved to the other currency
        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.Validate("Currency Code", OtherCurrency.Code);

        // [THEN] The order takes the other currency's table rate
        _Assert.AreEqual(TableFactor(), SalesHeader."Currency Factor", 'A new currency must take its own rate.');
        // [THEN] The order keeps no Shopify rate
        _Assert.AreEqual(0, SalesHeader."NPR Spfy Currency Factor", 'The Shopify rate of another currency must be forgotten.');
    end;

    [Test]
    procedure BillToCustomerInAnotherCurrency_ForgetsShopifyRate()
    var
        Currency: Record Currency;
        OtherCurrency: Record Currency;
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        LibrarySales: Codeunit "Library - Sales";
        SpfyDocumentRate: Codeunit "NPR Spfy Document Rate";
    begin
        // [SCENARIO] A Shopify order whose Bill-to customer is billed in another currency takes that currency's rate and no longer keeps Shopify's, although BC validates the new currency code with xRec already holding it.
        Initialize();
        // [GIVEN] Two foreign currencies
        CreateCurrency(Currency);
        CreateCurrency(OtherCurrency);
        // [GIVEN] A Shopify order valued at Shopify's rate in the first one
        CreateShopifyOrder(SalesHeader, Currency.Code, true);
        // [GIVEN] A customer billed in the other currency
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Currency Code", OtherCurrency.Code);
        Customer.Modify(true);

        // [WHEN] The order is billed to that customer
        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.Validate("Bill-to Customer No.", Customer."No.");

        // [THEN] The order is in the other currency at its table rate
        _Assert.AreEqual(OtherCurrency.Code, SalesHeader."Currency Code", 'The order must take the Bill-to customer''s currency.');
        _Assert.AreEqual(TableFactor(), SalesHeader."Currency Factor", 'A new currency must take its own rate.');
        // [THEN] The order keeps no Shopify rate
        _Assert.AreEqual(0, SalesHeader."NPR Spfy Currency Factor", 'The Shopify rate of another currency must be forgotten.');
        _Assert.IsFalse(SpfyDocumentRate.IsLocked(SalesHeader), 'An order in another currency must not be held at Shopify''s rate.');
    end;

    [Test]
    procedure CurrencyCodeAssignedWithoutValidation_IsNotProtected()
    var
        Currency: Record Currency;
        OtherCurrency: Record Currency;
        SalesHeader: Record "Sales Header";
        SpfyDocumentRate: Codeunit "NPR Spfy Document Rate";
    begin
        // [SCENARIO] A Shopify order whose currency code is assigned from code without validation is no longer held at the rate Shopify used for its first currency.
        Initialize();
        // [GIVEN] Two foreign currencies
        CreateCurrency(Currency);
        CreateCurrency(OtherCurrency);
        // [GIVEN] A Shopify order valued at Shopify's rate in the first one
        CreateShopifyOrder(SalesHeader, Currency.Code, true);

        // [WHEN] The other currency code is assigned without validation
        SalesHeader."Currency Code" := OtherCurrency.Code;

        // [THEN] The order is not protected
        _Assert.IsFalse(SpfyDocumentRate.IsLocked(SalesHeader), 'A rate kept for one currency must not protect another.');
    end;

    [Test]
    [HandlerFunctions('ConfirmYes')]
    procedure UserAcceptsNewRate_DocumentTakesTableRate()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        SpfyDocumentRate: Codeunit "NPR Spfy Document Rate";
    begin
        // [SCENARIO] A user asked by BC whether to update the exchange rate who answers Yes gets the new rate, and the order is no longer kept at Shopify's.
        Initialize();
        // [GIVEN] A foreign currency whose table rate differs from Shopify's
        CreateCurrency(Currency);
        // [GIVEN] A Shopify order valued at Shopify's rate
        CreateShopifyOrder(SalesHeader, Currency.Code, true);

        // [WHEN] The user moves the posting date and confirms the rate update
        SalesHeader.SetHideValidationDialog(false);
        SalesHeader.Validate("Posting Date", CalcDate('<+5D>', WorkDate()));

        // [THEN] The order takes the table rate
        _Assert.AreEqual(TableFactor(), SalesHeader."Currency Factor", 'The user''s decision to update the rate must stand.');
        // [THEN] The order is no longer protected
        _Assert.IsFalse(SpfyDocumentRate.IsLocked(SalesHeader), 'An order the user revalued must not be held at Shopify''s rate.');
    end;

    [Test]
    [HandlerFunctions('ConfirmYes')]
    procedure UserReentersCurrencyCodeAndAccepts_DocumentTakesTableRate()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        SpfyDocumentRate: Codeunit "NPR Spfy Document Rate";
        SalesOrder: TestPage "Sales Order";
    begin
        // [SCENARIO] A user who re-enters the currency code of an open Shopify order is asked by BC whether to update the rate, and a Yes takes the table rate.
        Initialize();
        // [GIVEN] A foreign currency whose table rate differs from Shopify's
        CreateCurrency(Currency);
        // [GIVEN] An open Shopify order valued at Shopify's rate
        CreateShopifyOrder(SalesHeader, Currency.Code, true);

        // [WHEN] The user enters the same currency code on the order page and confirms the rate update
        SalesOrder.OpenEdit();
        SalesOrder.GoToRecord(SalesHeader);
        SalesOrder."Currency Code".SetValue(Currency.Code);
        SalesOrder.Close();

        // [THEN] The order takes the table rate
        SalesHeader.Find();
        _Assert.AreEqual(TableFactor(), SalesHeader."Currency Factor", 'The user''s decision to update the rate must stand.');
        // [THEN] The order is no longer protected
        _Assert.IsFalse(SpfyDocumentRate.IsLocked(SalesHeader), 'An order the user revalued must not be held at Shopify''s rate.');
    end;

    [Test]
    [HandlerFunctions('ConfirmNo')]
    procedure UserDeclinesNewRate_KeepsShopifyRate()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        SpfyDocumentRate: Codeunit "NPR Spfy Document Rate";
    begin
        // [SCENARIO] A user asked by BC whether to update the exchange rate who answers No keeps the rate Shopify used.
        Initialize();
        // [GIVEN] A foreign currency whose table rate differs from Shopify's
        CreateCurrency(Currency);
        // [GIVEN] A Shopify order valued at Shopify's rate
        CreateShopifyOrder(SalesHeader, Currency.Code, true);

        // [WHEN] The user moves the posting date and declines the rate update
        SalesHeader.SetHideValidationDialog(false);
        SalesHeader.Validate("Posting Date", CalcDate('<+5D>', WorkDate()));

        // [THEN] The order keeps Shopify's rate
        _Assert.AreEqual(ShopifyFactor(), SalesHeader."Currency Factor", 'Declining the update must keep Shopify''s rate.');
        // [THEN] The order stays protected
        _Assert.IsTrue(SpfyDocumentRate.IsLocked(SalesHeader), 'The order must stay protected.');
    end;

    [Test]
    [HandlerFunctions('ConfirmYes')]
    procedure CorrectiveCreditMemo_KeepsRevaluedInvoiceRateWhenItsPostingDateMoves()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        CreditMemo: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
    begin
        // [SCENARIO] A corrective credit memo for a Shopify invoice that a user revalued keeps that invoice's rate, not Shopify's, when its posting date is moved silently.
        Initialize();
        // [GIVEN] A foreign currency whose table rate is 0.08 for one day, 0.05 before and after it
        CreateCurrency(Currency);
        LibraryERM.CreateExchangeRate(Currency.Code, CalcDate('<+3D>', WorkDate()), RevaluedFactor(), RevaluedFactor());
        LibraryERM.CreateExchangeRate(Currency.Code, CalcDate('<+4D>', WorkDate()), TableFactor(), TableFactor());
        // [GIVEN] A Shopify order whose posting date a user moved onto that day, accepting the rate update to 0.08
        CreateShopifyOrder(SalesHeader, Currency.Code, true);
        AddGLLine(SalesHeader, 100);
        SalesHeader.SetHideValidationDialog(false);
        SalesHeader.Validate("Posting Date", CalcDate('<+3D>', WorkDate()));
        SalesHeader.Modify(true);
        // [GIVEN] The order posted, and a corrective credit memo copied from its invoice
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
        CreateCorrectiveCreditMemo(SalesInvoiceHeader, CreditMemo);

        // [WHEN] The credit memo's posting date is moved with dialogs hidden to a day the table rate is 0.05
        CreditMemo.SetHideValidationDialog(true);
        CreditMemo.Validate("Posting Date", CalcDate('<+5D>', WorkDate()));

        // [THEN] The credit memo keeps the invoice's rate of 0.08
        _Assert.AreEqual(RevaluedFactor(), CreditMemo."Currency Factor", 'A credit for a Shopify invoice must stay at the invoice''s rate.');
        // [THEN] The credit memo is protected at the invoice's rate, not at Shopify's
        _Assert.AreEqual(RevaluedFactor(), CreditMemo."NPR Spfy Currency Factor", 'The credit memo must be protected at the invoice''s rate.');
    end;

    [Test]
    procedure ShopifyInvoiceCopiedToNewOrder_IsNotProtected()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        NewOrder: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CopyDocMgt: Codeunit "Copy Document Mgt.";
        LibrarySales: Codeunit "Library - Sales";
    begin
        // [SCENARIO] A new order copied from a Shopify invoice is a new sale, so it does not keep the rate Shopify used for the original.
        Initialize();
        // [GIVEN] A posted Shopify invoice at Shopify's rate
        CreateCurrency(Currency);
        CreateShopifyOrder(SalesHeader, Currency.Code, true);
        AddGLLine(SalesHeader, 100);
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
        // [GIVEN] A new, empty order
        NewOrder."Document Type" := NewOrder."Document Type"::Order;
        NewOrder.Insert(true);

        // [WHEN] The invoice is copied into it with its header
        CopyDocMgt.SetProperties(true, false, false, false, true, false, false);
        CopyDocMgt.CopySalesDoc("Sales Document Type From"::"Posted Invoice", SalesInvoiceHeader."No.", NewOrder);

        // [THEN] The new order keeps no Shopify rate
        NewOrder.Find();
        _Assert.AreEqual(0, NewOrder."NPR Spfy Currency Factor", 'Only a credit for a Shopify invoice may keep its rate.');
    end;

    [Test]
    procedure PartialCreditOfCard_RoundsItsShareDown()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        CreditMemo: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        CreditNpRvSalesLine: Record "NPR NpRv Sales Line";
        LibrarySales: Codeunit "Library - Sales";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        VoucherQty: Decimal;
        VoucherUnitPrice: Decimal;
        VoucherUnitAmountLCY: Decimal;
    begin
        // [SCENARIO] A credit of part of a gift card writes off its share of the issued amount rounded down, so two half credits never add up to more than the card was issued at.
        Initialize();
        // [GIVEN] A posted Shopify invoice that issued a voucher at 765.01 for a gift card line of 100
        CreateCurrency(Currency);
        CreateShopifyOrder(SalesHeader, Currency.Code, true);
        AddVoucherLine(SalesHeader, 100, NpRvSalesLine);
        StampShopifyAmount(NpRvSalesLine, 765.01, LcyCode(), 100);
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
        // [GIVEN] A corrective credit memo copied from it whose gift card line credits half the price
        CreateCorrectiveCreditMemo(SalesInvoiceHeader, CreditMemo);
        SalesLine.SetRange("Document Type", CreditMemo."Document Type");
        SalesLine.SetRange("Document No.", CreditMemo."No.");
        SalesLine.SetRange("No.", _VoucherType."Account No.");
        SalesLine.FindFirst();
        SalesLine.Validate("Unit Price", 50);
        SalesLine.Modify(true);
        CreditNpRvSalesLine.SetRange("Document Type", CreditMemo."Document Type");
        CreditNpRvSalesLine.SetRange("Document No.", CreditMemo."No.");
        CreditNpRvSalesLine.FindFirst();

        // [WHEN] The write-off of its voucher is calculated
        NpRvVoucherMgt.GetVoucherQtyAndUnitAmounts(CreditNpRvSalesLine, CreditMemo."Currency Code", CreditMemo."Currency Factor", CreditMemo."Posting Date", VoucherQty, VoucherUnitPrice, VoucherUnitAmountLCY);

        // [THEN] It is 382.50, half of 765.01 rounded down
        _Assert.AreEqual(382.50, VoucherUnitAmountLCY, 'A partial write-off must round down so the card is never overdrawn.');
    end;

    [Test]
    procedure CreditForOrderInvoicedInOtherCurrency_KeepsTableRate()
    var
        Currency: Record Currency;
        OtherCurrency: Record Currency;
        ReturnOrder: Record "Sales Header";
        TempSalesInvoiceHeader: Record "Sales Invoice Header" temporary;
        LibrarySales: Codeunit "Library - Sales";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyDocumentRate: Codeunit "NPR Spfy Document Rate";
        SpfyRefundDocBuilder: Codeunit "NPR Spfy Refund Doc. Builder";
    begin
        // [SCENARIO] A credit in one currency for a Shopify order invoiced in another has no rate of its own currency to reverse at, so it keeps the table rate and is not protected.
        Initialize();
        // [GIVEN] Two foreign currencies whose table rate is 0.05
        CreateCurrency(Currency);
        CreateCurrency(OtherCurrency);
        LibrarySpfyImport.CreateStore('SPFYDR445C');
        // [GIVEN] A posted invoice of Shopify order 944500000031 in the other currency at 0.13
        PostInvoiceOfShopifyOrder('944500000031', 'SPFYDR445C', OtherCurrency.Code, ShopifyFactor());
        // [GIVEN] A return order for it in the first currency at the table rate
        LibrarySales.CreateSalesHeader(ReturnOrder, ReturnOrder."Document Type"::"Return Order", LibrarySales.CreateCustomerNo());
        ReturnOrder.Validate("Currency Code", Currency.Code);

        // [WHEN] The return takes the order's invoice rate
        SpfyDocumentRate.KeepOrderInvoiceCurrencyFactor('SPFYDR445C', '944500000031', ReturnOrder);

        // [THEN] The invoice is found as the order's, so the table rate below is the outcome of its other currency
        _Assert.IsTrue(SpfyRefundDocBuilder.CollectOrderInvoices('SPFYDR445C', '944500000031', TempSalesInvoiceHeader), 'The order''s invoice must be found.');
        // [THEN] The return keeps the table rate
        _Assert.AreEqual(TableFactor(), ReturnOrder."Currency Factor", 'An invoice in another currency gives no rate to reverse at.');
        // [THEN] The return is not protected
        _Assert.AreEqual(0, ReturnOrder."NPR Spfy Currency Factor", 'A return without an invoice rate in its currency must not be protected.');
    end;

    [Test]
    procedure CreditForOrderInvoicedAtTwoRates_KeepsTableRate()
    var
        Currency: Record Currency;
        ReturnOrder: Record "Sales Header";
        TempSalesInvoiceHeader: Record "Sales Invoice Header" temporary;
        LibrarySales: Codeunit "Library - Sales";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyDocumentRate: Codeunit "NPR Spfy Document Rate";
        SpfyRefundDocBuilder: Codeunit "NPR Spfy Refund Doc. Builder";
    begin
        // [SCENARIO] A credit for a Shopify order whose invoices posted at different rates has no single rate to reverse at, so it keeps the table rate and is not protected.
        Initialize();
        // [GIVEN] A foreign currency whose table rate differs from both invoice rates
        CreateCurrency(Currency);
        LibrarySpfyImport.CreateStore('SPFYDR445M');
        // [GIVEN] Two posted invoices of Shopify order 944500000030, at 0.13 and at 0.08
        PostInvoiceOfShopifyOrder('944500000030', 'SPFYDR445M', Currency.Code, ShopifyFactor());
        PostInvoiceOfShopifyOrder('944500000030', 'SPFYDR445M', Currency.Code, RevaluedFactor());
        // [GIVEN] A return order for it at the table rate
        LibrarySales.CreateSalesHeader(ReturnOrder, ReturnOrder."Document Type"::"Return Order", LibrarySales.CreateCustomerNo());
        ReturnOrder.Validate("Currency Code", Currency.Code);

        // [WHEN] The return takes the order's invoice rate
        SpfyDocumentRate.KeepOrderInvoiceCurrencyFactor('SPFYDR445M', '944500000030', ReturnOrder);

        // [THEN] Both invoices are found as the order's, so the table rate below is the outcome of their disagreement, not of a missing invoice
        _Assert.IsTrue(SpfyRefundDocBuilder.CollectOrderInvoices('SPFYDR445M', '944500000030', TempSalesInvoiceHeader), 'The order''s invoices must be found.');
        _Assert.AreEqual(2, TempSalesInvoiceHeader.Count(), 'Both of the order''s invoices must be found.');
        // [THEN] The return keeps the table rate
        _Assert.AreEqual(TableFactor(), ReturnOrder."Currency Factor", 'Invoices at different rates give no rate to reverse at.');
        // [THEN] The return is not protected
        _Assert.AreEqual(0, ReturnOrder."NPR Spfy Currency Factor", 'A return without a single invoice rate must not be protected.');
    end;

    #endregion

    #region Voucher issuance and write-off

    [Test]
    procedure VoucherWithShopifyAmount_IsIssuedAtThatAmount()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        LibrarySales: Codeunit "Library - Sales";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] A gift card sold on a foreign currency Shopify order is issued at the LCY amount Shopify booked for its line, not at the conversion of its price.
        Initialize();
        // [GIVEN] A Shopify order at Shopify's rate with a gift card line of 100, which Shopify booked at 765.00 LCY (the conversion gives 769.23)
        CreateCurrency(Currency);
        CreateShopifyOrder(SalesHeader, Currency.Code, true);
        AddVoucherLine(SalesHeader, 100, NpRvSalesLine);
        StampShopifyAmount(NpRvSalesLine, 765, LcyCode(), 100);

        // [WHEN] The order is posted
        InvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] The voucher is issued at 765.00
        _Assert.AreEqual(765, IssuedAmount(InvoiceNo), 'The voucher must be issued at the amount Shopify booked.');
    end;

    [Test]
    procedure VoucherLinesOnOneOrder_AreEachIssuedAtTheirShopifyAmount()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        FirstNpRvSalesLine: Record "NPR NpRv Sales Line";
        SecondNpRvSalesLine: Record "NPR NpRv Sales Line";
        LibrarySales: Codeunit "Library - Sales";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] Each gift card on a multi-line Shopify order is issued at the LCY Shopify booked for its own line, not at a conversion through the order's rate.
        Initialize();
        // [GIVEN] A Shopify order at Shopify's rate with gift card lines of 100 and 50, which Shopify booked at 765.00 and 382.51 LCY (769.23 and 384.62 by conversion)
        CreateCurrency(Currency);
        CreateShopifyOrder(SalesHeader, Currency.Code, true);
        AddVoucherLine(SalesHeader, 100, FirstNpRvSalesLine);
        StampShopifyAmount(FirstNpRvSalesLine, 765, LcyCode(), 100);
        AddVoucherLine(SalesHeader, 50, SecondNpRvSalesLine);
        StampShopifyAmount(SecondNpRvSalesLine, 382.51, LcyCode(), 50);

        // [WHEN] The order is posted
        InvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] The first gift card is issued at 765.00
        _Assert.AreEqual(765, IssuedAmountOnLine(InvoiceNo, FirstNpRvSalesLine."Document Line No."), 'The first card must be issued at Shopify''s amount for its line.');
        // [THEN] The second gift card is issued at 382.51
        _Assert.AreEqual(382.51, IssuedAmountOnLine(InvoiceNo, SecondNpRvSalesLine."Document Line No."), 'The second card must be issued at Shopify''s amount for its line.');
    end;

    [Test]
    [HandlerFunctions('ConfirmYes')]
    procedure VoucherOnOrderRevaluedByUser_IsIssuedAtConversion()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        LibrarySales: Codeunit "Library - Sales";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] A gift card on a Shopify order that a user moved to BC's rate is issued like the order's other lines, at the conversion of its price, not at Shopify's amount.
        Initialize();
        // [GIVEN] A Shopify order at Shopify's rate with a gift card line of 100 that Shopify booked at 765.00 LCY
        CreateCurrency(Currency);
        CreateShopifyOrder(SalesHeader, Currency.Code, true);
        AddVoucherLine(SalesHeader, 100, NpRvSalesLine);
        StampShopifyAmount(NpRvSalesLine, 765, LcyCode(), 100);
        // [GIVEN] A user moved its posting date and accepted the table rate of 0.05
        SalesHeader.SetHideValidationDialog(false);
        SalesHeader.Validate("Posting Date", CalcDate('<+5D>', WorkDate()));
        SalesHeader.Modify(true);

        // [WHEN] The order is posted
        InvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] The voucher is issued at 100 converted at 0.05, as the gift card line posted
        _Assert.AreEqual(Round(100 / TableFactor(), 0.01), IssuedAmount(InvoiceNo), 'A voucher on a revalued order must follow the order''s rate.');
    end;

    [Test]
    procedure VoucherLineEditedAfterImport_IsIssuedAtConversion()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        LibrarySales: Codeunit "Library - Sales";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] A gift card line whose price was changed after import no longer matches Shopify's amount, so the voucher is issued at the conversion of its price.
        Initialize();
        // [GIVEN] A Shopify order with a gift card line of 100 that Shopify booked at 765.00 LCY
        CreateCurrency(Currency);
        CreateShopifyOrder(SalesHeader, Currency.Code, true);
        AddVoucherLine(SalesHeader, 100, NpRvSalesLine);
        StampShopifyAmount(NpRvSalesLine, 765, LcyCode(), 100);
        // [GIVEN] The line's price changed to 90 afterwards
        SalesLine.Get(NpRvSalesLine."Document Type", NpRvSalesLine."Document No.", NpRvSalesLine."Document Line No.");
        SalesLine.Validate("Unit Price", 90);
        SalesLine.Modify(true);

        // [WHEN] The order is posted
        InvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] The voucher is issued at 90 converted at the order's rate
        _Assert.AreEqual(Round(90 / ShopifyFactor(), 0.01), IssuedAmount(InvoiceNo), 'An edited line must fall back to conversion.');
    end;

    [Test]
    procedure VoucherWithForeignStoreCurrency_IsIssuedAtConversion()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        LibrarySales: Codeunit "Library - Sales";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] When the Shopify store currency is not the LCY, the voucher is issued at the conversion of its price, as before.
        Initialize();
        // [GIVEN] A Shopify order with a gift card line of 100 whose store currency amount is in a foreign currency
        CreateCurrency(Currency);
        CreateShopifyOrder(SalesHeader, Currency.Code, true);
        AddVoucherLine(SalesHeader, 100, NpRvSalesLine);
        StampShopifyAmount(NpRvSalesLine, 765, Currency.Code, 100);

        // [WHEN] The order is posted
        InvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] The voucher is issued at 100 converted at the order's rate
        _Assert.AreEqual(Round(100 / ShopifyFactor(), 0.01), IssuedAmount(InvoiceNo), 'A store currency other than the LCY must fall back to conversion.');
    end;

    [Test]
    procedure VoucherOnPricesExclVATDocument_GrossesUpShopifyAmount()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        LibrarySales: Codeunit "Library - Sales";
        InvoiceNo: Code[20];
        Expected: Decimal;
    begin
        // [SCENARIO] On a document with prices excluding VAT, the voucher is issued at Shopify's amount with the line's VAT added, as its price is.
        Initialize();
        // [GIVEN] A Shopify order with prices excluding VAT and a gift card line of 80 that Shopify booked at 612.00 LCY before VAT
        CreateCurrency(Currency);
        CreateShopifyOrder(SalesHeader, Currency.Code, true);
        SalesHeader.Validate("Prices Including VAT", false);
        SalesHeader.Modify(true);
        AddVoucherLine(SalesHeader, 80, NpRvSalesLine);
        StampShopifyAmount(NpRvSalesLine, 612, LcyCode(), 80);
        SalesLine.Get(NpRvSalesLine."Document Type", NpRvSalesLine."Document No.", NpRvSalesLine."Document Line No.");
        Expected := Round(612 * (1 + SalesLine."VAT %" / 100), 0.01);

        // [WHEN] The order is posted
        InvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] The voucher is issued above Shopify's amount before VAT, so the line's VAT was added
        _Assert.IsTrue(IssuedAmount(InvoiceNo) > 612, 'The voucher line must carry VAT for this test to prove anything.');
        // [THEN] The voucher is issued at 612.00 plus the line's VAT
        _Assert.AreEqual(Expected, IssuedAmount(InvoiceNo), 'Shopify''s amount must carry the line''s VAT like the price does.');
    end;

    [Test]
    procedure CorrectiveCreditMemo_WritesOffIssuedAmount()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        CreditMemo: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Voucher: Record "NPR NpRv Voucher";
        LibrarySales: Codeunit "Library - Sales";
        CreditMemoNo: Code[20];
    begin
        // [SCENARIO] A corrective credit memo for a Shopify invoice writes the voucher off at the amount it was issued at, leaving nothing on the card.
        Initialize();
        // [GIVEN] A posted Shopify invoice that issued a voucher at 765.00 for a gift card line of 100 (769.23 at the invoice's rate)
        CreateCurrency(Currency);
        CreateShopifyOrder(SalesHeader, Currency.Code, true);
        AddVoucherLine(SalesHeader, 100, NpRvSalesLine);
        StampShopifyAmount(NpRvSalesLine, 765, LcyCode(), 100);
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
        Voucher.Get(IssuedVoucherNo(SalesInvoiceHeader."No."));
        // [GIVEN] A corrective credit memo copied from it
        CreateCorrectiveCreditMemo(SalesInvoiceHeader, CreditMemo);

        // [WHEN] The credit memo is posted
        CreditMemoNo := LibrarySales.PostSalesDocument(CreditMemo, true, true);

        // [THEN] The voucher is written off at 765.00
        _Assert.AreEqual(-765, VoucherEntryAmount(Voucher."No.", Voucher."Reference No.", CreditMemoNo), 'The write-off must equal the issued amount.');
        // [THEN] Nothing is left on the voucher
        _Assert.AreEqual(0, VoucherEntryAmount(Voucher."No.", Voucher."Reference No.", ''), 'A fully credited voucher must keep no balance.');
    end;

    [Test]
    procedure PartialCredit_WritesOffShareOfIssuedAmount()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        CreditMemo: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        LibrarySales: Codeunit "Library - Sales";
        VoucherNo: Code[20];
    begin
        // [SCENARIO] A credit memo that credits part of a gift card's price writes off the same share of the amount the voucher was issued at and leaves the rest on the card.
        Initialize();
        // [GIVEN] A posted Shopify invoice that issued a voucher at 765.00 for a gift card line of 100
        CreateCurrency(Currency);
        CreateShopifyOrder(SalesHeader, Currency.Code, true);
        AddVoucherLine(SalesHeader, 100, NpRvSalesLine);
        StampShopifyAmount(NpRvSalesLine, 765, LcyCode(), 100);
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
        VoucherNo := IssuedVoucherNo(SalesInvoiceHeader."No.");
        // [GIVEN] A credit memo copied from it whose gift card line credits 40 of the 100
        CreateCorrectiveCreditMemo(SalesInvoiceHeader, CreditMemo);
        SalesLine.SetRange("Document Type", CreditMemo."Document Type");
        SalesLine.SetRange("Document No.", CreditMemo."No.");
        SalesLine.SetRange("No.", _VoucherType."Account No.");
        SalesLine.FindFirst();
        SalesLine.Validate("Unit Price", 40);
        SalesLine.Modify(true);

        // [WHEN] The credit memo is posted
        LibrarySales.PostSalesDocument(CreditMemo, true, true);

        // [THEN] 306.00 is written off and 459.00 stays on the card
        VoucherEntry.SetRange("Voucher No.", VoucherNo);
        VoucherEntry.CalcSums(Amount);
        _Assert.AreEqual(459, VoucherEntry.Amount, 'Only the credited share of the issued amount may be written off.');
    end;

    [Test]
    procedure CreditMemoForOtherInvoice_IsNotTiedToIssuedAmount()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        CreditMemo: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        CreditNpRvSalesLine: Record "NPR NpRv Sales Line";
        LibrarySales: Codeunit "Library - Sales";
    begin
        // [SCENARIO] A credit memo for a foreign currency invoice that did not carry Shopify's rate keeps converting its voucher write-off, as before.
        Initialize();
        // [GIVEN] A posted foreign currency invoice with a voucher, not valued at a Shopify rate
        CreateCurrency(Currency);
        CreateShopifyOrder(SalesHeader, Currency.Code, false);
        AddVoucherLine(SalesHeader, 100, NpRvSalesLine);
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));

        // [WHEN] A corrective credit memo is copied from it
        CreateCorrectiveCreditMemo(SalesInvoiceHeader, CreditMemo);

        // [THEN] Its voucher line carries no issued amount to reverse
        CreditNpRvSalesLine.SetRange("Document Type", CreditMemo."Document Type");
        CreditNpRvSalesLine.SetRange("Document No.", CreditMemo."No.");
        CreditNpRvSalesLine.FindFirst();
        _Assert.AreEqual(0, CreditNpRvSalesLine."Issued Unit Amount (LCY)", 'Only credits for Shopify invoices reverse the issued amount.');
    end;

    [Test]
    procedure CreditMemoForInvoicePostedBeforeThisChange_WritesOffWhatWasIssued()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        CreditMemo: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Voucher: Record "NPR NpRv Voucher";
        LibrarySales: Codeunit "Library - Sales";
        CreditMemoNo: Code[20];
    begin
        // [SCENARIO] A corrective credit memo for a foreign currency invoice posted before Shopify's rate was kept still posts and writes the voucher off at what it was issued at.
        Initialize();
        // [GIVEN] A posted foreign currency invoice without a kept Shopify rate, whose voucher for a gift card line of 100 was issued by conversion at 769.23
        CreateCurrency(Currency);
        CreateShopifyOrder(SalesHeader, Currency.Code, false);
        AddVoucherLine(SalesHeader, 100, NpRvSalesLine);
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
        Voucher.Get(IssuedVoucherNo(SalesInvoiceHeader."No."));
        // [GIVEN] A corrective credit memo copied from it
        CreateCorrectiveCreditMemo(SalesInvoiceHeader, CreditMemo);

        // [WHEN] The credit memo is posted
        CreditMemoNo := LibrarySales.PostSalesDocument(CreditMemo, true, true);

        // [THEN] The voucher is written off at the 769.23 it was issued at
        _Assert.AreEqual(-Round(100 / ShopifyFactor(), 0.01), VoucherEntryAmount(Voucher."No.", Voucher."Reference No.", CreditMemoNo), 'The write-off must equal the issued amount.');
        // [THEN] Nothing is left on the voucher
        _Assert.AreEqual(0, VoucherEntryAmount(Voucher."No.", Voucher."Reference No.", ''), 'A fully credited voucher must keep no balance.');
    end;

    [Test]
    procedure RefundPaymentLineWithoutShopMoney_PaysAtRefundDateRate()
    var
        Currency: Record Currency;
        TempPaymentLine: Record "NPR Magento Payment Line" temporary;
        SpfyDocumentRate: Codeunit "NPR Spfy Document Rate";
        AmountLCYPerAmount: Decimal;
    begin
        // [SCENARIO] A refund of a credit held at the invoice's rate, one of whose payment lines carries no amount in the Shopify store currency, pays out at the table rate on the refund's date, because Shopify's figure for the whole refund is not known.
        Initialize();
        // [GIVEN] A foreign currency with realized FX accounts and a table rate of 0.05
        CreateCurrency(Currency);
        // [GIVEN] Refund payment lines of 8.00 that Shopify booked at 60.00 LCY, and 5.00 with no shop money
        InsertRefundPaymentLine(TempPaymentLine, 10000, 8, 60, LcyCode());
        InsertRefundPaymentLine(TempPaymentLine, 20000, 5, 0, '');

        // [WHEN] The refund's LCY per unit is read for a credit held at the invoice's rate
        AmountLCYPerAmount := SpfyDocumentRate.RefundAmountLCYPerAmount(Currency.Code, WorkDate(), true, TempPaymentLine);

        // [THEN] It is the table rate on the refund's date, 20.00 LCY per unit
        _Assert.AreEqual(1 / TableFactor(), AmountLCYPerAmount, 'A refund without Shopify''s amount for every line must pay out at the refund date''s rate.');
    end;

    [Test]
    procedure RefundInForeignStoreCurrency_PaysAtRefundDateRate()
    var
        Currency: Record Currency;
        StoreCurrency: Record Currency;
        TempPaymentLine: Record "NPR Magento Payment Line" temporary;
        SpfyDocumentRate: Codeunit "NPR Spfy Document Rate";
        AmountLCYPerAmount: Decimal;
    begin
        // [SCENARIO] When the Shopify store currency is not the LCY, a refund of a credit held at the invoice's rate pays out at the table rate on the refund's date, as Shopify refunds at that day's rate and its shop money is not an LCY amount.
        Initialize();
        // [GIVEN] A foreign document currency with realized FX accounts and a table rate of 0.05, and a Shopify store currency that is not the LCY either
        CreateCurrency(Currency);
        CreateCurrency(StoreCurrency);
        // [GIVEN] A refund payment line of 8.00 that Shopify booked at 60.00 in the store currency
        InsertRefundPaymentLine(TempPaymentLine, 10000, 8, 60, StoreCurrency.Code);

        // [WHEN] The refund's LCY per unit is read for a credit held at the invoice's rate
        AmountLCYPerAmount := SpfyDocumentRate.RefundAmountLCYPerAmount(Currency.Code, WorkDate(), true, TempPaymentLine);

        // [THEN] It is the table rate on the refund's date, 20.00 LCY per unit
        _Assert.AreEqual(1 / TableFactor(), AmountLCYPerAmount, 'A store currency other than the LCY must pay out at the refund date''s rate.');
    end;

    [Test]
    procedure RefundWithoutShopifyLCYOfCreditNotHeldAtInvoiceRate_KeepsCreditRate()
    var
        Currency: Record Currency;
        StoreCurrency: Record Currency;
        TempPaymentLine: Record "NPR Magento Payment Line" temporary;
        SpfyDocumentRate: Codeunit "NPR Spfy Document Rate";
        AmountLCYPerAmount: Decimal;
    begin
        // [SCENARIO] A refund without Shopify's LCY of a credit that is not held at an earlier rate pays out at the credit's own rate, as BC does.
        Initialize();
        // [GIVEN] A foreign document currency with realized FX accounts, and a Shopify store currency that is not the LCY
        CreateCurrency(Currency);
        CreateCurrency(StoreCurrency);
        // [GIVEN] A refund payment line of 8.00 that Shopify booked at 60.00 in the store currency
        InsertRefundPaymentLine(TempPaymentLine, 10000, 8, 60, StoreCurrency.Code);

        // [WHEN] The refund's LCY per unit is read for a credit not held at the invoice's rate
        AmountLCYPerAmount := SpfyDocumentRate.RefundAmountLCYPerAmount(Currency.Code, WorkDate(), false, TempPaymentLine);

        // [THEN] There is none, so the credit's own rate applies
        _Assert.AreEqual(0, AmountLCYPerAmount, 'A credit at its own rate must keep it for the refund.');
    end;

    [Test]
    procedure CorrectiveCreditMemoOnPricesExclVATInvoice_WritesOffIssuedAmount()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        CreditMemo: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Voucher: Record "NPR NpRv Voucher";
        LibrarySales: Codeunit "Library - Sales";
        CreditMemoNo: Code[20];
        IssuedAmountLCY: Decimal;
    begin
        // [SCENARIO] A corrective credit memo for a Shopify invoice with prices excluding VAT compares the two gross prices, so it writes the voucher off at exactly what it was issued at.
        Initialize();
        // [GIVEN] A posted Shopify invoice with prices excluding VAT whose gift card line of 80 was issued at Shopify's 612.00 plus VAT
        CreateCurrency(Currency);
        CreateShopifyOrder(SalesHeader, Currency.Code, true);
        SalesHeader.Validate("Prices Including VAT", false);
        SalesHeader.Modify(true);
        AddVoucherLine(SalesHeader, 80, NpRvSalesLine);
        StampShopifyAmount(NpRvSalesLine, 612, LcyCode(), 80);
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
        Voucher.Get(IssuedVoucherNo(SalesInvoiceHeader."No."));
        IssuedAmountLCY := IssuedAmount(SalesInvoiceHeader."No.");
        // [GIVEN] A corrective credit memo copied from it
        CreateCorrectiveCreditMemo(SalesInvoiceHeader, CreditMemo);

        // [WHEN] The credit memo is posted
        CreditMemoNo := LibrarySales.PostSalesDocument(CreditMemo, true, true);

        // [THEN] The voucher had been issued with VAT on top of 612.00, so both prices were grossed up
        _Assert.IsTrue(IssuedAmountLCY > 612, 'The voucher line must carry VAT for this test to prove anything.');
        // [THEN] The voucher is written off at exactly what it was issued at
        _Assert.AreEqual(-IssuedAmountLCY, VoucherEntryAmount(Voucher."No.", Voucher."Reference No.", CreditMemoNo), 'The write-off must equal the issued amount.');
        // [THEN] Nothing is left on the voucher
        _Assert.AreEqual(0, VoucherEntryAmount(Voucher."No.", Voucher."Reference No.", ''), 'A fully credited voucher must keep no balance.');
    end;

    [Test]
    procedure InvoiceLineIssuingDifferentAmounts_IsNotTiedToIssuedAmount()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        OtherVoucherEntry: Record "NPR NpRv Voucher Entry";
        TempCreditNpRvSalesLine: Record "NPR NpRv Sales Line" temporary;
        LibrarySales: Codeunit "Library - Sales";
        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
        InvoiceNo: Code[20];
        NextEntryNo: Integer;
    begin
        // [SCENARIO] When the vouchers of one invoice line were not all issued at the same amount, a credit for it has no single amount to write off at, so it converts as before.
        Initialize();
        // [GIVEN] A posted Shopify invoice that issued a voucher at 765.00 for a gift card line of 100
        CreateCurrency(Currency);
        CreateShopifyOrder(SalesHeader, Currency.Code, true);
        AddVoucherLine(SalesHeader, 100, NpRvSalesLine);
        StampShopifyAmount(NpRvSalesLine, 765, LcyCode(), 100);
        InvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesInvoiceLine.SetRange("Document No.", InvoiceNo);
        SalesInvoiceLine.SetRange("No.", _VoucherType."Account No.");
        SalesInvoiceLine.FindFirst();
        // [GIVEN] A second voucher issued on the same invoice line at 700.00
        VoucherEntry.SetRange("Entry Type", VoucherEntry."Entry Type"::"Issue Voucher");
        VoucherEntry.SetRange("Document Type", VoucherEntry."Document Type"::Invoice);
        VoucherEntry.SetRange("Document No.", InvoiceNo);
        VoucherEntry.FindFirst();
        OtherVoucherEntry.FindLast();
        NextEntryNo := OtherVoucherEntry."Entry No." + 1;
        OtherVoucherEntry := VoucherEntry;
        OtherVoucherEntry."Entry No." := NextEntryNo;
        OtherVoucherEntry.Amount := 700;
        OtherVoucherEntry."Remaining Amount" := 700;
        OtherVoucherEntry.Insert();

        // [WHEN] A credit voucher line takes its issued amount from the invoice line
        NpRvSalesDocMgt.SetIssuedAmountToReverse(SalesInvoiceLine, Currency.Code, ShopifyFactor(), TempCreditNpRvSalesLine);

        // [THEN] It carries no issued amount
        _Assert.AreEqual(0, TempCreditNpRvSalesLine."Issued Unit Amount (LCY)", 'Vouchers issued at different amounts give no single amount to reverse.');
    end;

    [Test]
    procedure ToppedUpCard_IsReversedAtIssuedAmount()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        TempCreditNpRvSalesLine: Record "NPR NpRv Sales Line" temporary;
        LibrarySales: Codeunit "Library - Sales";
        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] A Shopify gift card the invoice loaded as a top-up of an existing card, as the legacy import does, is reversed at the amount it was loaded with, like a new card.
        Initialize();
        // [GIVEN] A posted Shopify invoice whose gift card line of 100 loaded 765.00 onto a card as a top-up
        CreateCurrency(Currency);
        CreateShopifyOrder(SalesHeader, Currency.Code, true);
        AddVoucherLine(SalesHeader, 100, NpRvSalesLine);
        StampShopifyAmount(NpRvSalesLine, 765, LcyCode(), 100);
        InvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        VoucherEntry.SetRange("Entry Type", VoucherEntry."Entry Type"::"Issue Voucher");
        VoucherEntry.SetRange("Document Type", VoucherEntry."Document Type"::Invoice);
        VoucherEntry.SetRange("Document No.", InvoiceNo);
        VoucherEntry.FindFirst();
        VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Top-up";
        VoucherEntry.Modify();
        SalesInvoiceLine.SetRange("Document No.", InvoiceNo);
        SalesInvoiceLine.SetRange("No.", _VoucherType."Account No.");
        SalesInvoiceLine.FindFirst();

        // [WHEN] A credit voucher line at the invoice's rate takes its issued amount from the invoice line
        NpRvSalesDocMgt.SetIssuedAmountToReverse(SalesInvoiceLine, Currency.Code, ShopifyFactor(), TempCreditNpRvSalesLine);

        // [THEN] It reverses the 765.00 the top-up loaded
        _Assert.AreEqual(765, TempCreditNpRvSalesLine."Issued Unit Amount (LCY)", 'A top-up must be reversed at the amount it loaded.');
    end;

    [Test]
    procedure ArchivedCard_IsReversedAtIssuedAmount()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Voucher: Record "NPR NpRv Voucher";
        TempCreditNpRvSalesLine: Record "NPR NpRv Sales Line" temporary;
        LibrarySales: Codeunit "Library - Sales";
        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] A gift card that has been archived since the Shopify invoice issued it is still reversed at the amount it was issued at.
        Initialize();
        // [GIVEN] A posted Shopify invoice that issued a voucher at 765.00 for a gift card line of 100
        CreateCurrency(Currency);
        CreateShopifyOrder(SalesHeader, Currency.Code, true);
        AddVoucherLine(SalesHeader, 100, NpRvSalesLine);
        StampShopifyAmount(NpRvSalesLine, 765, LcyCode(), 100);
        InvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesInvoiceLine.SetRange("Document No.", InvoiceNo);
        SalesInvoiceLine.SetRange("No.", _VoucherType."Account No.");
        SalesInvoiceLine.FindFirst();
        // [GIVEN] The voucher archived since
        Voucher.SetRange("No.", IssuedVoucherNo(InvoiceNo));
        NpRvVoucherMgt.ArchiveVouchers(Voucher);

        // [WHEN] A credit voucher line at the invoice's rate takes its issued amount from the invoice line
        NpRvSalesDocMgt.SetIssuedAmountToReverse(SalesInvoiceLine, Currency.Code, ShopifyFactor(), TempCreditNpRvSalesLine);

        // [THEN] The voucher is no longer live, so the amount comes from its archive
        _Assert.IsFalse(Voucher.FindFirst(), 'The voucher must have been archived for this test to prove anything.');
        // [THEN] It reverses the 765.00 the voucher was issued at
        _Assert.AreEqual(765, TempCreditNpRvSalesLine."Issued Unit Amount (LCY)", 'An archived voucher must be reversed at the amount it was issued at.');
    end;

    [Test]
    procedure CreditInOtherCurrency_IsNotTiedToIssuedAmount()
    var
        Currency: Record Currency;
        OtherCurrency: Record Currency;
        SalesHeader: Record "Sales Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        TempCreditNpRvSalesLine: Record "NPR NpRv Sales Line" temporary;
        LibrarySales: Codeunit "Library - Sales";
        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
    begin
        // [SCENARIO] A credit in another currency than the Shopify invoice it reverses converts its voucher write-off, because its price cannot be compared with the invoice's.
        Initialize();
        // [GIVEN] A posted Shopify invoice that issued a voucher at 765.00 for a gift card line of 100
        CreateCurrency(Currency);
        CreateCurrency(OtherCurrency);
        CreateShopifyOrder(SalesHeader, Currency.Code, true);
        AddVoucherLine(SalesHeader, 100, NpRvSalesLine);
        StampShopifyAmount(NpRvSalesLine, 765, LcyCode(), 100);
        SalesInvoiceLine.SetRange("Document No.", LibrarySales.PostSalesDocument(SalesHeader, true, true));
        SalesInvoiceLine.SetRange("No.", _VoucherType."Account No.");
        SalesInvoiceLine.FindFirst();

        // [WHEN] A credit voucher line in the other currency takes its issued amount from the invoice line
        NpRvSalesDocMgt.SetIssuedAmountToReverse(SalesInvoiceLine, OtherCurrency.Code, ShopifyFactor(), TempCreditNpRvSalesLine);

        // [THEN] It carries no issued amount
        _Assert.AreEqual(0, TempCreditNpRvSalesLine."Issued Unit Amount (LCY)", 'A credit in another currency must not reverse the issued amount.');
        // [THEN] It carries no issued price
        _Assert.AreEqual(0, TempCreditNpRvSalesLine."Issued Unit Price", 'A credit in another currency must not compare its price with the invoice''s.');
    end;

    [Test]
    procedure CreditAtOtherRate_IsNotTiedToIssuedAmount()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        TempCreditNpRvSalesLine: Record "NPR NpRv Sales Line" temporary;
        LibrarySales: Codeunit "Library - Sales";
        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
    begin
        // [SCENARIO] A credit line reversing an invoice posted at another rate than the credit's, such as lines of a second invoice added to a credit memo, converts its voucher write-off like its own lines.
        Initialize();
        // [GIVEN] A posted Shopify invoice at 0.13 that issued a voucher at 765.00 for a gift card line of 100
        CreateCurrency(Currency);
        CreateShopifyOrder(SalesHeader, Currency.Code, true);
        AddVoucherLine(SalesHeader, 100, NpRvSalesLine);
        StampShopifyAmount(NpRvSalesLine, 765, LcyCode(), 100);
        SalesInvoiceLine.SetRange("Document No.", LibrarySales.PostSalesDocument(SalesHeader, true, true));
        SalesInvoiceLine.SetRange("No.", _VoucherType."Account No.");
        SalesInvoiceLine.FindFirst();

        // [WHEN] A credit voucher line on a credit at 0.08 takes its issued amount from the invoice line
        NpRvSalesDocMgt.SetIssuedAmountToReverse(SalesInvoiceLine, Currency.Code, RevaluedFactor(), TempCreditNpRvSalesLine);

        // [THEN] It carries no issued amount
        _Assert.AreEqual(0, TempCreditNpRvSalesLine."Issued Unit Amount (LCY)", 'A credit at another rate than the invoice must not reverse the issued amount.');
    end;

    [Test]
    [HandlerFunctions('ConfirmYes,MessageOk')]
    procedure CreditRevaluedByUser_ConvertsVoucherWriteOff()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        CreditMemo: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        CreditNpRvSalesLine: Record "NPR NpRv Sales Line";
        LibrarySales: Codeunit "Library - Sales";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        VoucherQty: Decimal;
        VoucherUnitPrice: Decimal;
        VoucherUnitAmountLCY: Decimal;
    begin
        // [SCENARIO] A corrective credit memo a user moves to another rate reverses its lines at that rate, so its voucher is written off at that rate too, not at the amount it was issued at.
        Initialize();
        // [GIVEN] A posted Shopify invoice that issued a voucher at 765.00 for a gift card line of 100
        CreateCurrency(Currency);
        CreateShopifyOrder(SalesHeader, Currency.Code, true);
        AddVoucherLine(SalesHeader, 100, NpRvSalesLine);
        StampShopifyAmount(NpRvSalesLine, 765, LcyCode(), 100);
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
        // [GIVEN] A corrective credit memo copied from it, which reverses the issued amount
        CreateCorrectiveCreditMemo(SalesInvoiceHeader, CreditMemo);

        // [WHEN] The user moves the credit memo's posting date, confirms the rate update and saves it
        CreditMemo.SetHideValidationDialog(false);
        CreditMemo.Validate("Posting Date", CalcDate('<+5D>', WorkDate()));
        CreditMemo.Modify(true);

        // [THEN] The credit memo takes the table rate
        _Assert.AreEqual(TableFactor(), CreditMemo."Currency Factor", 'The user''s decision to update the rate must stand.');
        // [THEN] Its voucher is written off at 100 converted at that rate, 2,000.00, as its line reverses
        CreditNpRvSalesLine.SetRange("Document Type", CreditMemo."Document Type");
        CreditNpRvSalesLine.SetRange("Document No.", CreditMemo."No.");
        CreditNpRvSalesLine.FindFirst();
        NpRvVoucherMgt.GetVoucherQtyAndUnitAmounts(CreditNpRvSalesLine, CreditMemo."Currency Code", CreditMemo."Currency Factor", CreditMemo."Posting Date", VoucherQty, VoucherUnitPrice, VoucherUnitAmountLCY);
        _Assert.AreEqual(Round(100 / TableFactor(), 0.01), VoucherUnitAmountLCY, 'A revalued credit must convert its voucher write-off like its lines.');
    end;

    #endregion

    #region Legacy import

    [Test]
    procedure LegacyImport_ForeignCurrencyOrder_TakesShopifyRate()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        SpfyOrderMgt: Codeunit "NPR Spfy Order Mgt.";
        Order: JsonToken;
        StoreCode: Code[20];
    begin
        // [SCENARIO] The legacy import values a foreign currency order at Shopify's rate and protects it at that rate.
        Initialize();
        // [GIVEN] A Shopify store and a foreign currency whose table rate differs from Shopify's
        CreateCurrency(Currency);
        // [GIVEN] An order of the store's fallback customer, as the import leaves it
        CreateLegacyImportOrder(StoreCode, SalesHeader);
        // [GIVEN] A Shopify order of 13.00 in that currency that Shopify booked at 100.00 LCY
        Order := LegacyOrderHeaderJson('445000001', Currency.Code, 13, 100);

        // [WHEN] The legacy import updates the order header
        SpfyOrderMgt.UpdateSalesHeader(StoreCode, Order, SalesHeader);

        // [THEN] The order is valued at Shopify's rate
        _Assert.AreEqual(ShopifyFactor(), SalesHeader."Currency Factor", 'The import must value the order at Shopify''s rate.');
        // [THEN] The order is protected at Shopify's rate
        _Assert.AreEqual(ShopifyFactor(), SalesHeader."NPR Spfy Currency Factor", 'The import must protect Shopify''s rate.');
    end;

    [Test]
    procedure LegacyImport_ForeignStoreCurrency_IsNotProtected()
    var
        Currency: Record Currency;
        StoreCurrency: Record Currency;
        SalesHeader: Record "Sales Header";
        SpfyOrderMgt: Codeunit "NPR Spfy Order Mgt.";
        Order: JsonToken;
        StoreCode: Code[20];
    begin
        // [SCENARIO] When the Shopify store currency is not the LCY, the order's totals give no LCY rate, so the legacy import leaves the order to BC's rate table as before.
        Initialize();
        // [GIVEN] A Shopify store and two foreign currencies, one for the order and one as the store currency
        CreateCurrency(Currency);
        CreateCurrency(StoreCurrency);
        // [GIVEN] An order of the store's fallback customer, as the import leaves it
        CreateLegacyImportOrder(StoreCode, SalesHeader);
        // [GIVEN] A Shopify order of 13.00 that Shopify booked at 100.00 in the store currency
        Order := LegacyOrderHeaderJsonInStoreCurrency('445000004', Currency.Code, StoreCurrency.Code, 13, 100);

        // [WHEN] The legacy import updates the order header
        SpfyOrderMgt.UpdateSalesHeader(StoreCode, Order, SalesHeader);

        // [THEN] The order takes the table rate
        _Assert.AreEqual(TableFactor(), SalesHeader."Currency Factor", 'A store currency other than the LCY must keep BC''s rate.');
        // [THEN] The order is not protected
        _Assert.AreEqual(0, SalesHeader."NPR Spfy Currency Factor", 'A rate not from Shopify''s LCY totals must not be protected.');
    end;

    [Test]
    procedure LegacyImport_ImportedRate_SurvivesSilentPostingDateChange()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        SpfyOrderMgt: Codeunit "NPR Spfy Order Mgt.";
        StoreCode: Code[20];
    begin
        // [SCENARIO] The rate the legacy import took from Shopify survives a later silent posting date change.
        Initialize();
        // [GIVEN] A Shopify store and a foreign currency whose table rate differs from Shopify's
        CreateCurrency(Currency);
        // [GIVEN] An order the legacy import valued at Shopify's rate from a Shopify order of 13.00 booked at 100.00 LCY
        CreateLegacyImportOrder(StoreCode, SalesHeader);
        SpfyOrderMgt.UpdateSalesHeader(StoreCode, LegacyOrderHeaderJson('445000002', Currency.Code, 13, 100), SalesHeader);

        // [WHEN] The posting date is moved with dialogs hidden
        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.Validate("Posting Date", CalcDate('<+5D>', WorkDate()));

        // [THEN] The order keeps Shopify's rate
        _Assert.AreEqual(ShopifyFactor(), SalesHeader."Currency Factor", 'The imported rate must survive a silent posting date change.');
    end;

    [Test]
    procedure LegacyReimport_WithoutShopifyRate_ReleasesOrderToTableRate()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
        SpfyOrderMgt: Codeunit "NPR Spfy Order Mgt.";
        StoreCode: Code[20];
    begin
        // [SCENARIO] A legacy re-import of an order whose Shopify totals no longer give a rate takes the order and its lines back to the table rate.
        Initialize();
        // [GIVEN] A Shopify store and a foreign currency whose table rate differs from Shopify's
        CreateCurrency(Currency);
        // [GIVEN] An order the legacy import valued at Shopify's rate from a Shopify order of 13.00 booked at 100.00 LCY
        CreateLegacyImportOrder(StoreCode, SalesHeader);
        SpfyOrderMgt.UpdateSalesHeader(StoreCode, LegacyOrderHeaderJson('445000003', Currency.Code, 13, 100), SalesHeader);
        SalesHeader.Modify(true);
        // [GIVEN] A G/L line whose unit cost of 100.00 LCY is 13.00 at Shopify's rate
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::"G/L Account", LibraryERM.CreateGLAccountWithSalesSetup(), 1);
        SalesLine.Validate("Unit Cost (LCY)", 100);
        SalesLine.Modify(true);

        // [GIVEN] No one to ask about the rate, as in the import job
        SalesHeader.SetHideValidationDialog(true);

        // [WHEN] The order is imported again without Shopify's amount in the shop currency
        SpfyOrderMgt.UpdateSalesHeader(StoreCode, LegacyOrderHeaderJson('445000003', Currency.Code, 13, 0), SalesHeader);

        // [THEN] The order takes the table rate
        _Assert.AreEqual(TableFactor(), SalesHeader."Currency Factor", 'An order without Shopify''s rate must take the table rate.');
        // [THEN] The order is no longer protected
        _Assert.AreEqual(0, SalesHeader."NPR Spfy Currency Factor", 'An order without Shopify''s rate must not stay protected.');
        // [THEN] The line follows the table rate, 100.00 LCY being 5.00
        SalesLine.Find();
        _Assert.AreEqual(100 * TableFactor(), SalesLine."Unit Cost", 'The lines must follow the released rate.');
    end;

    [Test]
    procedure LegacyImport_GiftCardLine_CarriesShopifyAmount()
    var
        SalesHeader: Record "Sales Header";
        ItemLine: Record "Sales Line";
        GiftCardLine: Record "Sales Line";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyOrderMgt: Codeunit "NPR Spfy Order Mgt.";
        Order: JsonToken;
        StoreCode: Code[20];
    begin
        // [SCENARIO] The legacy import stores the LCY amount Shopify booked for a gift card line on its voucher line, with the price it belongs to.
        Initialize();
        // [GIVEN] A store selling gift cards and an order with a gift card line of 50
        StoreCode := 'SPFYDR445';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.SetupSalesOrderWithShopifyLine('944500000001', 100, SalesHeader, ItemLine);
        AddShopifyGiftCardLine(StoreCode, SalesHeader, '944500000002', GiftCardLine);
        // [GIVEN] Shopify fulfilled the gift card and booked it at 384.62 LCY
        Order := LibrarySpfyImport.LegacyOrderJson('944500000000',
            GiftCardOrderLineText('944500000002', 50, 384.62, LcyCode()),
            '{"status":"success","line_items":[{"id":944500000002,"fulfillment_status":"fulfilled","quantity":1}],' +
            '"receipt":{"gift_cards":[{"line_item_id":944500000002,"id":"944500000099","masked_code":"**** **** **** 4450"}]}}');

        // [WHEN] The import updates the lines
        SpfyOrderMgt.UpsertSalesLines(StoreCode, Order, SalesHeader, true);

        // [THEN] The voucher line carries Shopify's amount
        NpRvSalesLine.SetRange("Document Type", GiftCardLine."Document Type");
        NpRvSalesLine.SetRange("Document No.", GiftCardLine."Document No.");
        NpRvSalesLine.SetRange("Document Line No.", GiftCardLine."Line No.");
        NpRvSalesLine.SetRange(Posted, false);
        NpRvSalesLine.FindFirst();
        _Assert.AreEqual(384.62, NpRvSalesLine."Spfy Amount (Store Currency)", 'The voucher line must carry Shopify''s amount.');
        // [THEN] The voucher line carries Shopify's store currency
        _Assert.AreEqual(LcyCode(), NpRvSalesLine."Spfy Store Currency Code", 'The voucher line must carry Shopify''s store currency.');
        // [THEN] The voucher line carries the price the amount belongs to
        GiftCardLine.Get(GiftCardLine."Document Type", GiftCardLine."Document No.", GiftCardLine."Line No.");
        _Assert.AreEqual(GiftCardLine."Unit Price", NpRvSalesLine."Spfy Captured Unit Price", 'The amount must be tied to the price it belongs to.');
    end;

    #endregion

    #region Ecommerce import

    [Test]
    procedure EcomVoucherLine_KeepsStoreCurrencyValue()
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        LogEntry: Record "NPR Spfy Event Log Entry";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        LineToken: JsonToken;
    begin
        // [SCENARIO] The ecommerce import keeps a gift card's value in the Shopify store currency next to its presentment price.
        Initialize();
        // [GIVEN] A Shopify order of 13.00 that Shopify booked at 100.00 LCY, so its rate is Shopify's
        LogEntry."Store Currency Code" := LcyCode();
        LogEntry."Amount (PCY)" := 13;
        LogEntry."Amount (SCY)" := 100;
        // [GIVEN] A gift card line worth 100.00 in the store currency, sold at 13.00 in the presentment currency
        LineToken.ReadFrom(EcomGiftCardLineText(100, 13, 100));

        // [WHEN] The line's voucher amounts are read
        SpfyEcomSalesDocImport.PopulateVoucherAmounts(LineToken, LogEntry, EcomSalesLine);

        // [THEN] The line keeps 100.00 in the store currency
        _Assert.AreEqual(100, EcomSalesLine."Unit Price (Store Currency)", 'The store currency value must be kept.');
        // [THEN] The line keeps the store currency
        _Assert.AreEqual(LcyCode(), EcomSalesLine."Store Currency Code", 'The store currency must be kept.');
        // [THEN] The presentment price is unchanged
        _Assert.AreEqual(13, EcomSalesLine."Unit Price", 'The presentment price must be unchanged.');
    end;

    [Test]
    procedure EcomVoucherLineSoldAtDiscount_KeepsItsDenominationInStoreCurrency()
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        LogEntry: Record "NPR Spfy Event Log Entry";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        LineToken: JsonToken;
    begin
        // [SCENARIO] A gift card sold below its denomination keeps the denomination as its value, in the store currency as well as in the presentment currency.
        Initialize();
        // [GIVEN] A Shopify order of 13.00 that Shopify booked at 100.00 LCY, so its rate is Shopify's
        LogEntry."Store Currency Code" := LcyCode();
        LogEntry."Amount (PCY)" := 13;
        LogEntry."Amount (SCY)" := 100;
        // [GIVEN] A gift card worth 120.00 in the store currency sold at 13.00 (100.00 in the store currency)
        LineToken.ReadFrom(EcomGiftCardLineText(120, 13, 100));

        // [WHEN] The line's voucher amounts are read
        SpfyEcomSalesDocImport.PopulateVoucherAmounts(LineToken, LogEntry, EcomSalesLine);

        // [THEN] The line keeps the denomination of 120.00 in the store currency, not the 100.00 charged
        _Assert.AreEqual(120, EcomSalesLine."Unit Price (Store Currency)", 'The store currency value must be the card''s denomination.');
        // [THEN] The line's price is the denomination in the presentment currency, 15.60
        _Assert.AreEqual(15.6, EcomSalesLine."Unit Price", 'The presentment price must be the card''s denomination.');
    end;

    [Test]
    procedure EcomVoucherLineChargedAboveItsVariantPrice_KeepsChargedStoreCurrencyValue()
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        LogEntry: Record "NPR Spfy Event Log Entry";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        LineToken: JsonToken;
    begin
        // [SCENARIO] When a gift card was sold above its variant's price, the card takes the charged price, so its store currency value is the charged one too, not the variant's.
        Initialize();
        // [GIVEN] A Shopify order of 13.00 that Shopify booked at 100.00 LCY, so its rate is Shopify's
        LogEntry."Store Currency Code" := LcyCode();
        LogEntry."Amount (PCY)" := 13;
        LogEntry."Amount (SCY)" := 100;
        // [GIVEN] A gift card line charged 13.00 (100.00 in the store currency) whose variant is priced at 50.00 in the store currency
        LineToken.ReadFrom(EcomGiftCardLineText(50, 13, 100));

        // [WHEN] The line's voucher amounts are read
        SpfyEcomSalesDocImport.PopulateVoucherAmounts(LineToken, LogEntry, EcomSalesLine);

        // [THEN] The line takes the charged price
        _Assert.AreEqual(13, EcomSalesLine."Unit Price", 'A card charged above its variant price must take the charged price.');
        // [THEN] The line keeps the charged 100.00 in the store currency
        _Assert.AreEqual(100, EcomSalesLine."Unit Price (Store Currency)", 'The store currency value must follow the charged price.');
    end;

    [Test]
    procedure EcomVoucherLineOnOrderWithoutShopifyRate_KeepsNoStoreCurrencyValue()
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        LogEntry: Record "NPR Spfy Event Log Entry";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        LineToken: JsonToken;
    begin
        // [SCENARIO] When a Shopify order gives no amount in the shop currency, its rate comes from BC's table, so a gift card's store currency value is not kept and its face value converts at that rate like the order's lines.
        Initialize();
        // [GIVEN] A Shopify order of 13.00 with no total in the shop currency
        LogEntry."Store Currency Code" := LcyCode();
        LogEntry."Amount (PCY)" := 13;
        LogEntry."Amount (SCY)" := 0;
        // [GIVEN] A gift card line worth 100.00 in the store currency, sold at 13.00 in the presentment currency
        LineToken.ReadFrom(EcomGiftCardLineText(100, 13, 100));

        // [WHEN] The line's voucher amounts are read
        SpfyEcomSalesDocImport.PopulateVoucherAmounts(LineToken, LogEntry, EcomSalesLine);

        // [THEN] The line keeps no store currency value
        _Assert.AreEqual(0, EcomSalesLine."Unit Price (Store Currency)", 'A store currency value without Shopify''s rate must not be kept.');
        // [THEN] The presentment price is unchanged
        _Assert.AreEqual(13, EcomSalesLine."Unit Price", 'The presentment price must be unchanged.');
    end;

    [Test]
    procedure EcomVoucherFaceValue_UsesStoreCurrencyValue()
    var
        Currency: Record Currency;
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomCreateVchrImpl: Codeunit "NPR EcomCreateVchrImpl";
        FaceValueLCY: Decimal;
    begin
        // [SCENARIO] An ecommerce gift card sold in a foreign currency is worth its store currency value when the store currency is the LCY, not the conversion of its price.
        Initialize();
        // [GIVEN] A foreign currency order at Shopify's rate with a gift card of 13.01 worth 100.00 LCY in the store (100.08 by conversion)
        CreateCurrency(Currency);
        EcomSalesHeader."Currency Code" := Currency.Code;
        EcomSalesHeader."Currency Exchange Rate" := ShopifyFactor();
        EcomSalesHeader."Received Date" := WorkDate();
        EcomSalesLine."Unit Price" := 13.01;
        EcomSalesLine."Unit Price (Store Currency)" := 100;
        EcomSalesLine."Store Currency Code" := LcyCode();

        // [WHEN] The voucher's face value is calculated
        FaceValueLCY := EcomCreateVchrImpl.CalculateVoucherFaceValueLCY(EcomSalesHeader, EcomSalesLine);

        // [THEN] It is 100.00
        _Assert.AreEqual(100, FaceValueLCY, 'The store currency value must be the voucher''s face value.');
    end;

    [Test]
    procedure EcomVoucherFaceValueInForeignStoreCurrency_IsConverted()
    var
        Currency: Record Currency;
        StoreCurrency: Record Currency;
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomCreateVchrImpl: Codeunit "NPR EcomCreateVchrImpl";
        FaceValueLCY: Decimal;
    begin
        // [SCENARIO] When the Shopify store currency is not the LCY, an ecommerce gift card's face value is the conversion of its price, as before.
        Initialize();
        // [GIVEN] A foreign currency order at 0.13 with a gift card of 13.01 that the store values at 100.00 in a store currency that is not the LCY
        CreateCurrency(Currency);
        CreateCurrency(StoreCurrency);
        EcomSalesHeader."Currency Code" := Currency.Code;
        EcomSalesHeader."Currency Exchange Rate" := ShopifyFactor();
        EcomSalesHeader."Received Date" := WorkDate();
        EcomSalesLine."Unit Price" := 13.01;
        EcomSalesLine."Unit Price (Store Currency)" := 100;
        EcomSalesLine."Store Currency Code" := StoreCurrency.Code;

        // [WHEN] The voucher's face value is calculated
        FaceValueLCY := EcomCreateVchrImpl.CalculateVoucherFaceValueLCY(EcomSalesHeader, EcomSalesLine);

        // [THEN] It is 13.01 converted at 0.13, 100.08
        _Assert.AreEqual(Round(13.01 / ShopifyFactor(), 0.01), FaceValueLCY, 'A store currency other than the LCY must fall back to conversion.');
    end;

    [Test]
    procedure EcomOrderHeader_KeepsShopifyRate()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        LogEntry: Record "NPR Spfy Event Log Entry";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
    begin
        // [SCENARIO] A BC order created by the ecommerce import from a Shopify order valued at Shopify's rate is protected at that rate.
        Initialize();
        // [GIVEN] A Shopify order of 13.00 that Shopify booked at 100.00 LCY, and its ecommerce document at that rate
        CreateCurrency(Currency);
        InsertShopifyLogEntry(LogEntry, '944500000010', LogEntry."Document Type"::Order, Currency.Code, 13, 100);
        EcomSalesHeader."Document Type" := EcomSalesHeader."Document Type"::Order;
        EcomSalesHeader."Document Source" := EcomSalesHeader."Document Source"::Shopify;
        EcomSalesHeader."External No." := '944500000010';
        EcomSalesHeader."Currency Exchange Rate" := ShopifyFactor();
        // [GIVEN] The BC order the import made from it
        CreateShopifyOrder(SalesHeader, Currency.Code, false);

        // [WHEN] The import finishes the BC order's currency
        SpfyEventLogDocProcessr.KeepShopifySalesHeaderCurrencyFactor(SalesHeader, EcomSalesHeader);

        // [THEN] The order is protected at Shopify's rate
        _Assert.AreEqual(ShopifyFactor(), SalesHeader."NPR Spfy Currency Factor", 'The ecommerce order must be protected at Shopify''s rate.');
    end;

    [Test]
    procedure EcomOrderHeaderAtOtherRate_IsNotProtected()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        LogEntry: Record "NPR Spfy Event Log Entry";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
    begin
        // [SCENARIO] A BC order created by the ecommerce import whose rate is no longer the one on its ecommerce document does not carry Shopify's rate, so it is not protected.
        Initialize();
        // [GIVEN] A Shopify order of 13.00 that Shopify booked at 100.00 LCY, and its ecommerce document at 0.13
        CreateCurrency(Currency);
        InsertShopifyLogEntry(LogEntry, '944500000012', LogEntry."Document Type"::Order, Currency.Code, 13, 100);
        EcomSalesHeader."Document Type" := EcomSalesHeader."Document Type"::Order;
        EcomSalesHeader."Document Source" := EcomSalesHeader."Document Source"::Shopify;
        EcomSalesHeader."External No." := '944500000012';
        EcomSalesHeader."Currency Exchange Rate" := ShopifyFactor();
        // [GIVEN] The BC order the import made from it, now at 0.08
        CreateShopifyOrder(SalesHeader, Currency.Code, false);
        SalesHeader.Validate("Currency Factor", RevaluedFactor());

        // [WHEN] The import finishes the BC order's currency
        SpfyEventLogDocProcessr.KeepShopifySalesHeaderCurrencyFactor(SalesHeader, EcomSalesHeader);

        // [THEN] The order is not protected
        _Assert.AreEqual(0, SalesHeader."NPR Spfy Currency Factor", 'An order no longer at Shopify''s rate must not be protected.');
    end;

    [Test]
    procedure EcomOrderHeaderWithoutShopifyRate_IsNotProtected()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        LogEntry: Record "NPR Spfy Event Log Entry";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
    begin
        // [SCENARIO] A BC order created by the ecommerce import from a Shopify order without a total in the shop currency carries no rate from Shopify, so it is not protected.
        Initialize();
        // [GIVEN] A Shopify order of 13.00 with no total in the shop currency, and its ecommerce document at 0.13
        CreateCurrency(Currency);
        InsertShopifyLogEntry(LogEntry, '944500000011', LogEntry."Document Type"::Order, Currency.Code, 13, 0);
        EcomSalesHeader."Document Type" := EcomSalesHeader."Document Type"::Order;
        EcomSalesHeader."Document Source" := EcomSalesHeader."Document Source"::Shopify;
        EcomSalesHeader."External No." := '944500000011';
        EcomSalesHeader."Currency Exchange Rate" := ShopifyFactor();
        // [GIVEN] The BC order the import made from it, at the same rate
        CreateShopifyOrder(SalesHeader, Currency.Code, false);

        // [WHEN] The import finishes the BC order's currency
        SpfyEventLogDocProcessr.KeepShopifySalesHeaderCurrencyFactor(SalesHeader, EcomSalesHeader);

        // [THEN] The order is not protected
        _Assert.AreEqual(0, SalesHeader."NPR Spfy Currency Factor", 'An order whose rate is not from Shopify must not be protected.');
    end;

    [Test]
    procedure EcomReturnHeader_TakesOrderInvoiceRate()
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        ReturnOrder: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySales: Codeunit "Library - Sales";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
    begin
        // [SCENARIO] A BC return order the ecommerce import makes for a Shopify return takes the rate the order's invoice posted at.
        Initialize();
        // [GIVEN] A posted invoice for Shopify order 944500000020, at Shopify's rate
        CreateCurrency(Currency);
        LibrarySpfyImport.CreateStore('SPFYDR445E');
        CreateShopifyOrder(SalesHeader, Currency.Code, true);
        AddGLLine(SalesHeader, 100);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID", '944500000020', false);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Store Code", 'SPFYDR445E', false);
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
        // [GIVEN] A Shopify return of that order and its ecommerce document, which names the order by its GID
        InsertShopifyLogEntry(LogEntry, '944500000021', LogEntry."Document Type"::"Return Order", Currency.Code, 0, 0);
        LogEntry."Store Code" := 'SPFYDR445E';
        LogEntry.Modify();
        EcomSalesHeader."Document Type" := EcomSalesHeader."Document Type"::"Return Order";
        EcomSalesHeader."Document Source" := EcomSalesHeader."Document Source"::Shopify;
        EcomSalesHeader."External No." := '944500000021';
        EcomSalesHeader."External Document Id" := 'gid://shopify/Order/944500000020';
        // [GIVEN] The BC return order the import made, at the table rate
        LibrarySales.CreateSalesHeader(ReturnOrder, ReturnOrder."Document Type"::"Return Order", SalesHeader."Sell-to Customer No.");
        ReturnOrder.Validate("Currency Code", Currency.Code);

        // [WHEN] The import finishes the return order's currency
        SpfyEventLogDocProcessr.KeepShopifySalesHeaderCurrencyFactor(ReturnOrder, EcomSalesHeader);

        // [THEN] The return order is valued at the invoice's rate
        _Assert.AreEqual(SalesInvoiceHeader."Currency Factor", ReturnOrder."Currency Factor", 'The return must reverse at the invoice''s rate.');
        // [THEN] The return order is protected at the invoice's rate
        _Assert.AreEqual(SalesInvoiceHeader."Currency Factor", ReturnOrder."NPR Spfy Currency Factor", 'The return must be protected at the invoice''s rate.');
    end;

    [Test]
    procedure EcomImportOfShopifyOrder_KeepsShopifyRate()
    var
        Currency: Record Currency;
        Customer: Record Customer;
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        SalesHeader: Record "Sales Header";
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySales: Codeunit "Library - Sales";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        StoreCode: Code[20];
        Sku: Code[20];
        ItemNo: Code[20];
    begin
        // [SCENARIO] The ecommerce import creates the BC order for a Shopify order at the rate Shopify used and protects it there.
        Initialize();
        // [GIVEN] A Shopify store with its ecommerce store, a customer, and a foreign currency whose table rate differs from Shopify's
        LibrarySpfyImport.SetupSimpleItemOrder(StoreCode, Sku, ItemNo);
        LibrarySales.CreateCustomer(Customer);
        CreateCurrency(Currency);
        // [GIVEN] Shopify order 944500000040 of 13.00 that Shopify booked at 100.00 LCY
        InsertShopifyLogEntry(LogEntry, '944500000040', LogEntry."Document Type"::Order, Currency.Code, 13, 100);
        LogEntry."Store Code" := StoreCode;
        LogEntry.Modify();
        // [GIVEN] Its ecommerce document at Shopify's rate
        InsertShopifyEcomHeader(EcomSalesHeader."Document Type"::Order, '944500000040', Customer."No.", Currency.Code, ShopifyFactor(), EcomSalesHeader);

        // [WHEN] The ecommerce document is processed into a sales order
        ProcessEcomDocument(EcomSalesHeader);

        // [THEN] The sales order is valued at Shopify's rate
        SalesHeader.Get(SalesHeader."Document Type"::Order, EcomSalesHeader."Created Doc No.");
        _Assert.AreEqual(ShopifyFactor(), SalesHeader."Currency Factor", 'The import must value the order at Shopify''s rate.');
        // [THEN] The sales order is protected at Shopify's rate
        _Assert.AreEqual(ShopifyFactor(), SalesHeader."NPR Spfy Currency Factor", 'The import must protect Shopify''s rate.');
    end;

    [Test]
    procedure EcomImportOfShopifyReturn_TakesOrderInvoiceRate()
    var
        ReturnOrder: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        LogEntry: Record "NPR Spfy Event Log Entry";
    begin
        // [SCENARIO] The ecommerce import creates the BC return order for a Shopify return at the rate the order's invoice posted at and protects it there.
        Initialize();
        // [GIVEN] A posted invoice for Shopify order 944500000041 at Shopify's rate, in a foreign currency whose table rate differs from it
        // [GIVEN] Shopify return 944500000042 of that order, its log entry with the stored order data and its ecommerce document naming the order
        CreateShopifyEcomReturnOfInvoicedOrder('944500000041', '944500000042', SalesInvoiceHeader, LogEntry, EcomSalesHeader);

        // [WHEN] The ecommerce document is processed into a sales return order
        ProcessEcomDocument(EcomSalesHeader);

        // [THEN] The return order is valued at the invoice's rate
        ReturnOrder.Get(ReturnOrder."Document Type"::"Return Order", EcomSalesHeader."Created Doc No.");
        _Assert.AreEqual(SalesInvoiceHeader."Currency Factor", ReturnOrder."Currency Factor", 'The import must value the return at the invoice''s rate.');
        // [THEN] The return order is protected at the invoice's rate
        _Assert.AreEqual(SalesInvoiceHeader."Currency Factor", ReturnOrder."NPR Spfy Currency Factor", 'The import must protect the invoice''s rate.');
    end;

    [Test]
    procedure EcomImportOfShopifyReturnAfterOrderDataDiscarded_TakesOrderInvoiceRate()
    var
        ReturnOrder: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        LogEntry: Record "NPR Spfy Event Log Entry";
        SpfyEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
    begin
        // [SCENARIO] A Shopify return whose log entry lost its stored order data before the return order was created still takes the rate the order's invoice posted at.
        Initialize();
        // [GIVEN] A posted invoice for Shopify order 944500000043 at Shopify's rate, in a foreign currency whose table rate differs from it
        // [GIVEN] Shopify return 944500000044 of that order, its log entry and its ecommerce document naming the order
        CreateShopifyEcomReturnOfInvoicedOrder('944500000043', '944500000044', SalesInvoiceHeader, LogEntry, EcomSalesHeader);
        // [GIVEN] The log entry's stored order data is discarded
        LogEntry.SetRecFilter();
        SpfyEventLogMgt.DiscardStoredOrderData(LogEntry);

        // [WHEN] The ecommerce document is processed into a sales return order
        ProcessEcomDocument(EcomSalesHeader);

        // [THEN] The return order is valued and protected at the invoice's rate
        ReturnOrder.Get(ReturnOrder."Document Type"::"Return Order", EcomSalesHeader."Created Doc No.");
        _Assert.AreEqual(SalesInvoiceHeader."Currency Factor", ReturnOrder."Currency Factor", 'The return must be valued at the invoice''s rate without the stored order data.');
        _Assert.AreEqual(SalesInvoiceHeader."Currency Factor", ReturnOrder."NPR Spfy Currency Factor", 'The return must be protected at the invoice''s rate without the stored order data.');
    end;

    /// <summary>
    /// A posted invoice for Shopify order OrderId at Shopify's rate in a new foreign currency, and Shopify return ReturnId of it: its log entry with the order data stored, and its ecommerce document with the order's GID, as the import writes them.
    /// </summary>
    local procedure CreateShopifyEcomReturnOfInvoicedOrder(OrderId: Text[30]; ReturnId: Text[30]; var SalesInvoiceHeader: Record "Sales Invoice Header"; var LogEntry: Record "NPR Spfy Event Log Entry"; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        LibrarySales: Codeunit "Library - Sales";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        OrderData: JsonToken;
        OrderGIDTok: Label 'gid://shopify/Order/%1', Locked = true;
        StoreCode: Code[20];
        Sku: Code[20];
        ItemNo: Code[20];
    begin
        LibrarySpfyImport.SetupSimpleItemOrder(StoreCode, Sku, ItemNo);
        CreateCurrency(Currency);
        CreateShopifyOrder(SalesHeader, Currency.Code, true);
        AddGLLine(SalesHeader, 100);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID", OrderId, false);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Store Code", StoreCode, false);
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
        InsertShopifyLogEntry(LogEntry, ReturnId, LogEntry."Document Type"::"Return Order", Currency.Code, 0, 0);
        LogEntry."Store Code" := StoreCode;
        LogEntry.Modify();
        OrderData.ReadFrom('{"data":{"order":{"id":"' + StrSubstNo(OrderGIDTok, OrderId) + '"}}}');
        LibrarySpfyImport.WriteOrderDataBlob(LogEntry, OrderData);
        InsertShopifyEcomHeader(EcomSalesHeader."Document Type"::"Return Order", CopyStr(ReturnId, 1, 20), SalesHeader."Sell-to Customer No.", Currency.Code, 0, EcomSalesHeader);
        EcomSalesHeader."External Document Id" := StrSubstNo(OrderGIDTok, OrderId);
        EcomSalesHeader.Modify();
    end;


    [Test]
    procedure EcomReturnRefund_PaysOutShopifyAmountLCY()
    var
        Currency: Record Currency;
        ReturnOrder: Record "Sales Header";
        PaymentMethod: Record "Payment Method";
        GLEntry: Record "G/L Entry";
        LibrarySales: Codeunit "Library - Sales";
        CreditMemoNo: Code[20];
    begin
        // [SCENARIO] The refund BC posts as a Shopify return's balancing entry pays out the LCY Shopify booked for it, not the credit at the order's rate.
        Initialize();
        // [GIVEN] A foreign currency whose table rate differs from Shopify's
        CreateCurrency(Currency);
        // [GIVEN] A Shopify return order of 13.00 at the order's rate (100.00 LCY), balanced through a payment method, which Shopify refunded at 98.00 LCY
        CreateEcomReturnWithShopifyRefund(Currency.Code, ReturnOrder, PaymentMethod);

        // [WHEN] The return order is posted
        CreditMemoNo := LibrarySales.PostSalesDocument(ReturnOrder, true, true);

        // [THEN] The balancing account pays out 98.00
        GLEntry.SetRange("G/L Account No.", PaymentMethod."Bal. Account No.");
        GLEntry.SetRange("Document Type", GLEntry."Document Type"::Refund);
        GLEntry.SetRange("Document No.", CreditMemoNo);
        GLEntry.CalcSums(Amount);
        _Assert.AreEqual(-98, GLEntry.Amount, 'The refund must pay out what Shopify booked in LCY.');
        // [THEN] The 2.00 between the order's rate and Shopify's refund is booked as realized FX
        GLEntry.SetRange("G/L Account No.", Currency."Realized Gains Acc.");
        GLEntry.CalcSums(Amount);
        _Assert.AreEqual(-2, GLEntry.Amount, 'The rate movement since the sale must be realized FX.');
    end;

    [Test]
    procedure EcomReturnRefund_WithoutInvoiceRate_PaysShopifyAmountLCY()
    var
        Currency: Record Currency;
        ReturnOrder: Record "Sales Header";
        PaymentMethod: Record "Payment Method";
        GLEntry: Record "G/L Entry";
        LibrarySales: Codeunit "Library - Sales";
        CreditMemoNo: Code[20];
    begin
        // [SCENARIO] A Shopify return that could not keep the order invoice's rate still pays out the LCY Shopify booked for the refund, as a legacy refund does.
        Initialize();
        // [GIVEN] A foreign currency whose table rate differs from 0.13
        CreateCurrency(Currency);
        // [GIVEN] A Shopify return order of 13.00 at 0.13 (100.00 LCY), balanced through a payment method, which Shopify refunded at 98.00 LCY
        CreateEcomReturnWithShopifyRefund(Currency.Code, ReturnOrder, PaymentMethod);
        // [GIVEN] The return order kept no invoice rate (no invoice, one in another currency, or invoices at different rates)
        ReturnOrder."NPR Spfy Currency Factor" := 0;
        ReturnOrder."NPR Spfy Currency Code" := '';
        ReturnOrder.Modify();

        // [WHEN] The return order is posted
        CreditMemoNo := LibrarySales.PostSalesDocument(ReturnOrder, true, true);

        // [THEN] The balancing account pays out 98.00
        GLEntry.SetRange("G/L Account No.", PaymentMethod."Bal. Account No.");
        GLEntry.SetRange("Document Type", GLEntry."Document Type"::Refund);
        GLEntry.SetRange("Document No.", CreditMemoNo);
        GLEntry.CalcSums(Amount);
        _Assert.AreEqual(-98, GLEntry.Amount, 'The refund must pay out what Shopify booked in LCY.');
        // [THEN] The 2.00 between the credit's rate and Shopify's refund is booked as realized FX
        GLEntry.SetRange("G/L Account No.", Currency."Realized Gains Acc.");
        GLEntry.CalcSums(Amount);
        _Assert.AreEqual(-2, GLEntry.Amount, 'The rate movement must be realized FX.');
    end;

    [Test]
    procedure RefundOfCreditWithoutShopifyAmountsOrKeptRate_KeepsDocumentRate()
    var
        Currency: Record Currency;
        ReturnOrder: Record "Sales Header";
        PaymentMethod: Record "Payment Method";
        PaymentLine: Record "NPR Magento Payment Line";
        GLEntry: Record "G/L Entry";
        LibrarySales: Codeunit "Library - Sales";
        CreditMemoNo: Code[20];
    begin
        // [SCENARIO] A credit that carries neither amounts booked by Shopify nor a kept rate keeps BC's behaviour: its balancing entry pays out at the credit's own rate.
        Initialize();
        // [GIVEN] A foreign currency whose table rate differs from 0.13
        CreateCurrency(Currency);
        // [GIVEN] A return order of 13.00 at 0.13 (100.00 LCY), balanced through a payment method
        CreateEcomReturnWithShopifyRefund(Currency.Code, ReturnOrder, PaymentMethod);
        // [GIVEN] It holds no kept rate
        ReturnOrder."NPR Spfy Currency Factor" := 0;
        ReturnOrder."NPR Spfy Currency Code" := '';
        ReturnOrder.Modify();
        // [GIVEN] Its refund line holds no store currency amount
        PaymentLine.Get(Database::"Sales Header", ReturnOrder."Document Type", ReturnOrder."No.", 10000);
        PaymentLine."Amount (Store Currency)" := 0;
        PaymentLine."Requested Amt. (Store Curr.)" := 0;
        PaymentLine."Store Currency Code" := '';
        PaymentLine.Modify();

        // [WHEN] The return order is posted
        CreditMemoNo := LibrarySales.PostSalesDocument(ReturnOrder, true, true);

        // [THEN] The balancing account pays out the credit at its own rate, 100.00
        GLEntry.SetRange("G/L Account No.", PaymentMethod."Bal. Account No.");
        GLEntry.SetRange("Document Type", GLEntry."Document Type"::Refund);
        GLEntry.SetRange("Document No.", CreditMemoNo);
        GLEntry.CalcSums(Amount);
        _Assert.AreEqual(-100, GLEntry.Amount, 'A credit without Shopify''s amounts must keep BC''s behaviour.');
    end;

    [Test]
    procedure EcomReturnRefundInForeignStoreCurrency_PaysAtRefundDateRate()
    var
        Currency: Record Currency;
        StoreCurrency: Record Currency;
        ReturnOrder: Record "Sales Header";
        PaymentMethod: Record "Payment Method";
        PaymentLine: Record "NPR Magento Payment Line";
        GLEntry: Record "G/L Entry";
        LibrarySales: Codeunit "Library - Sales";
        CreditMemoNo: Code[20];
    begin
        // [SCENARIO] A Shopify return held at the order invoice's rate in a store whose currency is not the LCY pays its refund out at the table rate on the refund's date, and the difference to the invoice's rate is realized FX.
        Initialize();
        // [GIVEN] A foreign currency whose table rate is 0.05, and a Shopify store currency that is not the LCY
        CreateCurrency(Currency);
        CreateCurrency(StoreCurrency);
        // [GIVEN] A Shopify return order of 13.00 held at the invoice's rate 0.13 (100.00 LCY), balanced through a payment method
        CreateEcomReturnWithShopifyRefund(Currency.Code, ReturnOrder, PaymentMethod);
        // [GIVEN] Its refund line carries Shopify's amount in the store currency, not in the LCY
        PaymentLine.Get(Database::"Sales Header", ReturnOrder."Document Type", ReturnOrder."No.", 10000);
        PaymentLine."Store Currency Code" := StoreCurrency.Code;
        PaymentLine.Modify();

        // [WHEN] The return order is posted
        CreditMemoNo := LibrarySales.PostSalesDocument(ReturnOrder, true, true);

        // [THEN] The balancing account pays out 13.00 at the table rate, 260.00
        GLEntry.SetRange("G/L Account No.", PaymentMethod."Bal. Account No.");
        GLEntry.SetRange("Document Type", GLEntry."Document Type"::Refund);
        GLEntry.SetRange("Document No.", CreditMemoNo);
        GLEntry.CalcSums(Amount);
        _Assert.AreEqual(-260, GLEntry.Amount, 'The refund must pay out at the refund date''s rate.');
        // [THEN] The 160.00 between the invoice's rate and the refund's is booked as realized FX
        GLEntry.SetRange("G/L Account No.", Currency."Realized Losses Acc.");
        GLEntry.CalcSums(Amount);
        _Assert.AreEqual(160, GLEntry.Amount, 'The rate movement since the sale must be realized FX.');
    end;

    [Test]
    procedure EcomReturnRefund_CurrencyWithoutRealizedFXAccounts_KeepsDocumentRate()
    var
        Currency: Record Currency;
        ReturnOrder: Record "Sales Header";
        PaymentMethod: Record "Payment Method";
        GLEntry: Record "G/L Entry";
        LibrarySales: Codeunit "Library - Sales";
        CreditMemoNo: Code[20];
    begin
        // [SCENARIO] When the currency has no accounts to book realized FX on, the refund BC posts as a Shopify return's balancing entry pays out at the credit's own rate and still posts.
        Initialize();
        // [GIVEN] A foreign currency without realized gains and losses accounts
        CreateCurrency(Currency);
        Currency."Realized Gains Acc." := '';
        Currency."Realized Losses Acc." := '';
        Currency.Modify();
        // [GIVEN] A Shopify return order of 13.00 at the order's rate (100.00 LCY), balanced through a payment method, which Shopify refunded at 98.00 LCY
        CreateEcomReturnWithShopifyRefund(Currency.Code, ReturnOrder, PaymentMethod);

        // [WHEN] The return order is posted
        CreditMemoNo := LibrarySales.PostSalesDocument(ReturnOrder, true, true);

        // [THEN] The balancing account pays out the credit at the order's rate, 100.00
        GLEntry.SetRange("G/L Account No.", PaymentMethod."Bal. Account No.");
        GLEntry.SetRange("Document Type", GLEntry."Document Type"::Refund);
        GLEntry.SetRange("Document No.", CreditMemoNo);
        GLEntry.CalcSums(Amount);
        _Assert.AreEqual(-100, GLEntry.Amount, 'Without realized FX accounts the refund must keep the credit''s rate.');
    end;

    [Test]
    procedure EcomRefundPartlyToGiftCard_BooksTheCardShareAtTheVoucherLCY()
    var
        Currency: Record Currency;
        ReturnOrder: Record "Sales Header";
        PaymentMethod: Record "Payment Method";
        Voucher: Record "NPR NpRv Voucher";
        LibrarySales: Codeunit "Library - Sales";
        CreditMemoNo: Code[20];
    begin
        // [SCENARIO] A Shopify credit refunded partly to a gift card books the card's share in its balancing entry at the LCY the voucher is credited with; only the money paid out follows the refund's rate.
        Initialize();
        // [GIVEN] A foreign currency whose table rate, 0.05, differs from Shopify's
        CreateCurrency(Currency);
        // [GIVEN] A corrective Shopify return order of 13.00 held at 0.13, balanced through a payment method: 9.00 refunded by card without Shopify's LCY, 4.00 put back on a gift card that Shopify booked at 30.00 LCY
        CreateEcomReturnPartlyToGiftCard(Currency.Code, 0, 'SPFYDRGC10', '944500107', ReturnOrder, PaymentMethod, Voucher);

        // [WHEN] The return order is posted
        CreditMemoNo := LibrarySales.PostSalesDocument(ReturnOrder, true, true);

        // [THEN] The voucher is credited with the 30.00 Shopify booked for the card's share
        _Assert.AreEqual(30, VoucherEntryAmount(Voucher."No.", Voucher."Reference No.", CreditMemoNo), 'The card must get back what Shopify booked for it.');
        // [THEN] The balancing entry books the card's share at those 30.00 and the 9.00 card refund at the table rate, 180.00
        _Assert.AreEqual(-210, RefundGLAmount(PaymentMethod."Bal. Account No.", CreditMemoNo), 'The card''s share must be booked at the voucher''s LCY, only the rest at the refund''s rate.');
    end;

    [Test]
    procedure EcomRefundPartlyToGiftCardWithShopifyAmountLCY_BooksEachShareAtItsLCY()
    var
        Currency: Record Currency;
        ReturnOrder: Record "Sales Header";
        PaymentMethod: Record "Payment Method";
        Voucher: Record "NPR NpRv Voucher";
        LibrarySales: Codeunit "Library - Sales";
        CreditMemoNo: Code[20];
    begin
        // [SCENARIO] A Shopify credit refunded partly to a gift card, with Shopify's LCY on both lines, books the card refund at its own Shopify LCY and the gift card's share at the voucher's, with the voucher line kept out of the card refund's rate.
        Initialize();
        // [GIVEN] A foreign currency whose table rate differs from Shopify's
        CreateCurrency(Currency);
        // [GIVEN] A corrective Shopify return order of 13.00 held at 0.13, balanced through a payment method: 9.00 refunded by card that Shopify booked at 67.85 LCY, 4.00 put back on a gift card that Shopify booked at 30.00 LCY
        CreateEcomReturnPartlyToGiftCard(Currency.Code, 67.85, 'SPFYDRGC12', '944500127', ReturnOrder, PaymentMethod, Voucher);

        // [WHEN] The return order is posted
        CreditMemoNo := LibrarySales.PostSalesDocument(ReturnOrder, true, true);

        // [THEN] The voucher is credited with the 30.00 Shopify booked for the card's share
        _Assert.AreEqual(30, VoucherEntryAmount(Voucher."No.", Voucher."Reference No.", CreditMemoNo), 'The card must get back what Shopify booked for it.');
        // [THEN] The balancing entry books 67.85 for the card refund and 30.00 for the gift card's share
        _Assert.AreEqual(-97.85, RefundGLAmount(PaymentMethod."Bal. Account No.", CreditMemoNo), 'Each share must be booked at its own Shopify LCY.');
    end;

    [Test]
    procedure EcomRefundPartlyToGiftCard_CurrencyWithoutRealizedFXAccounts_KeepsDocumentRate()
    var
        Currency: Record Currency;
        ReturnOrder: Record "Sales Header";
        PaymentMethod: Record "Payment Method";
        Voucher: Record "NPR NpRv Voucher";
        LibrarySales: Codeunit "Library - Sales";
        CreditMemoNo: Code[20];
    begin
        // [SCENARIO] When the currency has no accounts to book realized FX on, a Shopify credit refunded partly to a gift card still posts, with its balancing entry at the credit's own rate.
        Initialize();
        // [GIVEN] A foreign currency without realized gains and losses accounts
        CreateCurrency(Currency);
        Currency."Realized Gains Acc." := '';
        Currency."Realized Losses Acc." := '';
        Currency.Modify();
        // [GIVEN] A corrective Shopify return order of 13.00 held at 0.13, balanced through a payment method: 9.00 refunded by card without Shopify's LCY, 4.00 put back on a gift card that Shopify booked at 30.00 LCY
        CreateEcomReturnPartlyToGiftCard(Currency.Code, 0, 'SPFYDRGC11', '944500117', ReturnOrder, PaymentMethod, Voucher);

        // [WHEN] The return order is posted
        CreditMemoNo := LibrarySales.PostSalesDocument(ReturnOrder, true, true);

        // [THEN] The balancing entry pays out the credit at its own rate, 100.00
        _Assert.AreEqual(-100, RefundGLAmount(PaymentMethod."Bal. Account No.", CreditMemoNo), 'Without realized FX accounts the balancing entry must keep the credit''s rate.');
    end;

    #endregion

    #region Legacy refunds

    [Test]
    procedure LegacyReturn_TakesOrderInvoiceRateAndRefundPaysShopifyAmountLCY()
    var
        Currency: Record Currency;
        ShopifyStore: Record "NPR Spfy Store";
        ReturnOrder: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GLEntry: Record "G/L Entry";
        LibraryRefund: Codeunit "NPR Library Spfy Legacy Refund";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ReturnOrderNo: Code[20];
        Posted: Boolean;
    begin
        // [SCENARIO] A Shopify return of a foreign currency order reverses at the rate the order's invoice posted at, and its refund pays out the LCY Shopify booked for it.
        Initialize();
        // [GIVEN] A legacy-path store and a foreign currency whose table rate differs from Shopify's
        _LibraryReturn.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _LibraryReturn.GetStore(StoreCode, ShopifyStore);
        CreateCurrency(Currency);
        // [GIVEN] A Shopify order of 100.00 in that currency, invoiced at Shopify's rate (769.23 LCY) and paid
        PostPaidShopifyOrder('94450003', StoreCode, Sku, CustomerNo, LocationCode, Currency.Code, ShopifyStore, SalesInvoiceHeader);
        // [GIVEN] A return of the order, refunded by card at 100.00 that Shopify booked at 760.00 LCY
        BuildReturn('94450003', StoreCode, Sku, Currency.Code, ReturnOrder);
        ReturnOrderNo := ReturnOrder."No.";

        // [WHEN] The return order is posted
        Posted := LibraryRefund.PostReturnOrder(ReturnOrder);

        // [THEN] Posting succeeds
        _Assert.IsTrue(Posted, 'Posting must succeed: ' + GetLastErrorText());
        // [THEN] The credit memo reverses at the invoice's rate
        _LibraryReturn.GetCreditMemoForReturnOrder(ReturnOrderNo, SalesCrMemoHeader);
        _Assert.AreEqual(SalesInvoiceHeader."Currency Factor", SalesCrMemoHeader."Currency Factor", 'The return must reverse at the invoice''s rate.');
        // [THEN] The clearing account pays out 760.00
        GLEntry.SetRange("G/L Account No.", ShopifyStore."Return Refund G/L Account No.");
        GLEntry.SetRange("Document Type", GLEntry."Document Type"::Refund);
        GLEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        GLEntry.CalcSums(Amount);
        _Assert.AreEqual(-760, GLEntry.Amount, 'The refund must pay out what Shopify booked in LCY.');
        // [THEN] The 9.23 between the invoice's rate and Shopify's refund is booked as realized FX
        GLEntry.SetRange("G/L Account No.", Currency."Realized Gains Acc.");
        GLEntry.CalcSums(Amount);
        _Assert.AreEqual(-9.23, GLEntry.Amount, 'The rate movement since the sale must be realized FX.');
        // [THEN] The credit memo is settled
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields("Remaining Amount");
        _Assert.AreEqual(0, CustLedgerEntry."Remaining Amount", 'The credit memo must be settled.');
    end;

    [Test]
    procedure LegacyReturnInForeignStoreCurrency_RefundPaysAtRefundDateRate()
    var
        Currency: Record Currency;
        StoreCurrency: Record Currency;
        ShopifyStore: Record "NPR Spfy Store";
        ReturnOrder: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GLEntry: Record "G/L Entry";
        LibraryRefund: Codeunit "NPR Library Spfy Legacy Refund";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ReturnOrderNo: Code[20];
        Posted: Boolean;
    begin
        // [SCENARIO] A Shopify return in a store whose currency is not the LCY reverses at the order invoice's rate, and its refund pays out at the table rate on the refund's date, with the difference booked as realized FX.
        Initialize();
        // [GIVEN] A legacy-path store, a foreign currency whose table rate is 0.05, and a Shopify store currency that is not the LCY
        _LibraryReturn.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _LibraryReturn.GetStore(StoreCode, ShopifyStore);
        CreateCurrency(Currency);
        CreateCurrency(StoreCurrency);
        // [GIVEN] A paid Shopify order of 100.00 in that currency, invoiced at 0.13 (769.23 LCY)
        PostPaidShopifyOrder('94450007', StoreCode, Sku, CustomerNo, LocationCode, Currency.Code, ShopifyStore, SalesInvoiceHeader);
        // [GIVEN] A return of the order, refunded by card at 100.00 that Shopify booked in the store currency
        BuildReturn('94450007', StoreCode, Sku, Currency.Code, 90, StoreCurrency.Code, ReturnOrder);
        ReturnOrderNo := ReturnOrder."No.";

        // [WHEN] The return order is posted
        Posted := LibraryRefund.PostReturnOrder(ReturnOrder);

        // [THEN] Posting succeeds
        _Assert.IsTrue(Posted, 'Posting must succeed: ' + GetLastErrorText());
        // [THEN] The credit memo reverses at the invoice's rate
        _LibraryReturn.GetCreditMemoForReturnOrder(ReturnOrderNo, SalesCrMemoHeader);
        _Assert.AreEqual(SalesInvoiceHeader."Currency Factor", SalesCrMemoHeader."Currency Factor", 'The return must reverse at the invoice''s rate.');
        // [THEN] The clearing account pays out 100.00 at the table rate, 2000.00
        GLEntry.SetRange("G/L Account No.", ShopifyStore."Return Refund G/L Account No.");
        GLEntry.SetRange("Document Type", GLEntry."Document Type"::Refund);
        GLEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        GLEntry.CalcSums(Amount);
        _Assert.AreEqual(-2000, GLEntry.Amount, 'The refund must pay out at the refund date''s rate.');
        // [THEN] The 1230.77 between the invoice's rate and the refund's is booked as realized FX
        GLEntry.SetRange("G/L Account No.", Currency."Realized Losses Acc.");
        GLEntry.CalcSums(Amount);
        _Assert.AreEqual(1230.77, GLEntry.Amount, 'The rate movement since the sale must be realized FX.');
        // [THEN] The credit memo is settled
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields("Remaining Amount");
        _Assert.AreEqual(0, CustLedgerEntry."Remaining Amount", 'The credit memo must be settled.');
    end;

    [Test]
    procedure LegacyReturn_CurrencyWithoutRealizedFXAccounts_RefundKeepsDocumentRate()
    var
        Currency: Record Currency;
        ShopifyStore: Record "NPR Spfy Store";
        ReturnOrder: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        GLEntry: Record "G/L Entry";
        LibraryRefund: Codeunit "NPR Library Spfy Legacy Refund";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ReturnOrderNo: Code[20];
        Posted: Boolean;
    begin
        // [SCENARIO] When the currency has no accounts to book realized FX on, a Shopify refund pays out at the credit's own rate and still posts.
        Initialize();
        // [GIVEN] A legacy-path store and a foreign currency without realized gains and losses accounts
        _LibraryReturn.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _LibraryReturn.GetStore(StoreCode, ShopifyStore);
        CreateCurrency(Currency);
        Currency."Realized Gains Acc." := '';
        Currency."Realized Losses Acc." := '';
        Currency.Modify();
        // [GIVEN] A paid Shopify order of 100.00 invoiced at Shopify's rate, and its return refunded at 760.00 LCY in Shopify
        PostPaidShopifyOrder('94450004', StoreCode, Sku, CustomerNo, LocationCode, Currency.Code, ShopifyStore, SalesInvoiceHeader);
        BuildReturn('94450004', StoreCode, Sku, Currency.Code, ReturnOrder);
        ReturnOrderNo := ReturnOrder."No.";

        // [WHEN] The return order is posted
        Posted := LibraryRefund.PostReturnOrder(ReturnOrder);

        // [THEN] Posting succeeds
        _Assert.IsTrue(Posted, 'Posting must succeed: ' + GetLastErrorText());
        // [THEN] The clearing account pays out the credit at the invoice's rate, 769.23
        _LibraryReturn.GetCreditMemoForReturnOrder(ReturnOrderNo, SalesCrMemoHeader);
        GLEntry.SetRange("G/L Account No.", ShopifyStore."Return Refund G/L Account No.");
        GLEntry.SetRange("Document Type", GLEntry."Document Type"::Refund);
        GLEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        GLEntry.CalcSums(Amount);
        _Assert.AreEqual(-Round(100 / ShopifyFactor(), 0.01), GLEntry.Amount, 'Without realized FX accounts the refund must keep the credit''s rate.');
    end;

    [Test]
    procedure LegacyGiftCardRefundInForeignStoreCurrency_GiftCardAccountMatchesVoucher()
    var
        Currency: Record Currency;
        StoreCurrency: Record Currency;
        ShopifyStore: Record "NPR Spfy Store";
        ReturnOrder: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        Voucher: Record "NPR NpRv Voucher";
        LibraryRefund: Codeunit "NPR Library Spfy Legacy Refund";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ReturnOrderNo: Code[20];
        Posted: Boolean;
    begin
        // [SCENARIO] A Shopify refund partly put back on a gift card, in a store whose currency is not the LCY, books the card's share at the credit memo's rate on both the gift card account and the voucher.
        Initialize();
        // [GIVEN] A legacy-path store, a foreign currency whose table rate is 0.05, and a Shopify store currency that is not the LCY
        _LibraryReturn.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _LibraryReturn.GetStore(StoreCode, ShopifyStore);
        CreateCurrency(Currency);
        CreateCurrency(StoreCurrency);
        // [GIVEN] A paid Shopify order of 100.00 in that currency, invoiced at 0.13, of which gift card 944500087 paid 40.00
        PostPaidShopifyOrder('94450008', StoreCode, Sku, CustomerNo, LocationCode, Currency.Code, ShopifyStore, SalesInvoiceHeader);
        _LibraryReturn.CreateVoucherWithGiftCardId('SPFYDRGC08', StoreCode, '944500087', Voucher);
        _LibraryReturn.AddVoucherPaymentToPostedInvoice(SalesInvoiceHeader."No.", Voucher."No.", 40);
        // [GIVEN] A return of the order, refunded 60.00 by card and 40.00 to the gift card, both booked by Shopify in the store currency
        LibraryRefund.BuildReturnOrderWithoutQueue(StoreCode,
            _LibraryReturn.ReturnDetailResponse('944500089', '94450008', '#94450008', Sku, '944500081', 1, 80, 20, 25, '71001',
                _LibraryReturn.RefundTxnJsonWithShopMoney('944500088', 'shopify_payments', 60, Currency.Code, 54, StoreCurrency.Code) + ',' +
                _LibraryReturn.GiftCardRefundTxnJsonWithShopMoney('944500086', 40, Currency.Code, 36, StoreCurrency.Code, '944500087'), Currency.Code),
            '944500089', ReturnOrder);
        ReturnOrderNo := ReturnOrder."No.";

        // [WHEN] The return order is posted
        Posted := LibraryRefund.PostReturnOrder(ReturnOrder);

        // [THEN] Posting succeeds and the credit memo reverses at the invoice's rate
        _Assert.IsTrue(Posted, 'Posting must succeed: ' + GetLastErrorText());
        _LibraryReturn.GetCreditMemoForReturnOrder(ReturnOrderNo, SalesCrMemoHeader);
        _Assert.AreEqual(SalesInvoiceHeader."Currency Factor", SalesCrMemoHeader."Currency Factor", 'The return must reverse at the invoice''s rate.');
        // [THEN] The card gets back the 307.69 its 40.00 was worth at the invoice's rate
        _Assert.AreEqual(Round(40 / ShopifyFactor(), 0.01), VoucherEntryAmount(Voucher."No.", Voucher."Reference No.", SalesCrMemoHeader."No."), 'The card must get back what it spent.');
        // [THEN] The gift card account moves by the same LCY as the voucher
        _Assert.AreEqual(-VoucherEntryAmount(Voucher."No.", Voucher."Reference No.", SalesCrMemoHeader."No."), RefundGLAmount(ShopifyStore."Ret. Gift Card Refund G/L Acc.", SalesCrMemoHeader."No."), 'The gift card account and the voucher must reconcile.');
        // [THEN] The card refund pays out its 60.00 at the table rate, 1200.00
        _Assert.AreEqual(-1200, RefundGLAmount(ShopifyStore."Return Refund G/L Account No.", SalesCrMemoHeader."No."), 'The card refund must pay out at the refund date''s rate.');
        // [THEN] The credit memo is settled
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields("Remaining Amount");
        _Assert.AreEqual(0, CustLedgerEntry."Remaining Amount", 'The credit memo must be settled.');
    end;

    [Test]
    procedure LegacyGiftCardRefundWithShopifyAmountLCY_GiftCardAccountMatchesVoucher()
    var
        Currency: Record Currency;
        ShopifyStore: Record "NPR Spfy Store";
        ReturnOrder: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        Voucher: Record "NPR NpRv Voucher";
        LibraryRefund: Codeunit "NPR Library Spfy Legacy Refund";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ReturnOrderNo: Code[20];
        Posted: Boolean;
    begin
        // [SCENARIO] A Shopify refund partly put back on a gift card, with the card's share booked by Shopify in the LCY, books that LCY on both the gift card account and the voucher.
        Initialize();
        // [GIVEN] A legacy-path store and a foreign currency whose table rate differs from Shopify's
        _LibraryReturn.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _LibraryReturn.GetStore(StoreCode, ShopifyStore);
        CreateCurrency(Currency);
        // [GIVEN] A paid Shopify order of 100.00 in that currency, invoiced at 0.13, of which gift card 944500097 paid 40.00
        PostPaidShopifyOrder('94450009', StoreCode, Sku, CustomerNo, LocationCode, Currency.Code, ShopifyStore, SalesInvoiceHeader);
        _LibraryReturn.CreateVoucherWithGiftCardId('SPFYDRGC09', StoreCode, '944500097', Voucher);
        _LibraryReturn.AddVoucherPaymentToPostedInvoice(SalesInvoiceHeader."No.", Voucher."No.", 40);
        // [GIVEN] A return of the order, refunded 60.00 by card that Shopify booked at 456.00 LCY and 40.00 to the gift card that it booked at 303.33 LCY
        LibraryRefund.BuildReturnOrderWithoutQueue(StoreCode,
            _LibraryReturn.ReturnDetailResponse('944500099', '94450009', '#94450009', Sku, '944500091', 1, 80, 20, 25, '71001',
                _LibraryReturn.RefundTxnJsonWithShopMoney('944500098', 'shopify_payments', 60, Currency.Code, 456, LcyCode()) + ',' +
                _LibraryReturn.GiftCardRefundTxnJsonWithShopMoney('944500096', 40, Currency.Code, 303.33, LcyCode(), '944500097'), Currency.Code),
            '944500099', ReturnOrder);
        ReturnOrderNo := ReturnOrder."No.";

        // [WHEN] The return order is posted
        Posted := LibraryRefund.PostReturnOrder(ReturnOrder);

        // [THEN] Posting succeeds
        _Assert.IsTrue(Posted, 'Posting must succeed: ' + GetLastErrorText());
        _LibraryReturn.GetCreditMemoForReturnOrder(ReturnOrderNo, SalesCrMemoHeader);
        // [THEN] The card gets back the 303.33 Shopify booked for its share
        _Assert.AreEqual(303.33, VoucherEntryAmount(Voucher."No.", Voucher."Reference No.", SalesCrMemoHeader."No."), 'The card must get back what Shopify booked for it.');
        // [THEN] The gift card account moves by the same LCY as the voucher
        _Assert.AreEqual(-303.33, RefundGLAmount(ShopifyStore."Ret. Gift Card Refund G/L Acc.", SalesCrMemoHeader."No."), 'The gift card account and the voucher must reconcile.');
        // [THEN] The card refund pays out the 456.00 Shopify booked for it, unaffected by the gift card's ratio
        _Assert.AreEqual(-456, RefundGLAmount(ShopifyStore."Return Refund G/L Account No.", SalesCrMemoHeader."No."), 'The card refund must pay out what Shopify booked for it.');
        // [THEN] The credit memo is settled
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields("Remaining Amount");
        _Assert.AreEqual(0, CustLedgerEntry."Remaining Amount", 'The credit memo must be settled.');
    end;

    [Test]
    procedure LegacyGiftCardReturnAcrossInvoicesIssuedAtDifferentAmounts_IsNotTiedToIssuedAmount()
    var
        Currency: Record Currency;
        ShopifyStore: Record "NPR Spfy Store";
        ReturnOrder: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        LibraryRefund: Codeunit "NPR Library Spfy Legacy Refund";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A Shopify return of gift cards sold on two invoices that issued them at different amounts has no single amount to write off at, so it converts as before.
        Initialize();
        // [GIVEN] A legacy-path store and a foreign currency whose table rate differs from Shopify's
        _LibraryReturn.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _LibraryReturn.GetStore(StoreCode, ShopifyStore);
        CreateCurrency(Currency);
        // [GIVEN] Shopify order line 944500061 invoiced and paid twice, its gift card of 100 issued at 765.00 on one invoice and at 760.00 on the other
        PostShopifyGiftCardSale('94450006', StoreCode, CustomerNo, LocationCode, Currency.Code, 765, SalesInvoiceHeader);
        PayInvoiceAtItsRate(SalesInvoiceHeader, ShopifyStore."Return Refund G/L Account No.");
        PostShopifyGiftCardSale('94450006', StoreCode, CustomerNo, LocationCode, Currency.Code, 760, SalesInvoiceHeader);
        PayInvoiceAtItsRate(SalesInvoiceHeader, ShopifyStore."Return Refund G/L Account No.");

        // [WHEN] A return of both cards is built, refunded by card at 200 that Shopify booked at 1,520.00 LCY
        LibraryRefund.BuildReturnOrderWithoutQueue(StoreCode,
            _LibraryReturn.ReturnDetailResponseGiftCard('944500069', '94450006', '#94450006', '944500061', 2, 200, '71001',
                _LibraryReturn.RefundTxnJsonWithShopMoney('944500068', 'shopify_payments', 200, Currency.Code, 1520, LcyCode()), Currency.Code),
            '944500069', ReturnOrder);

        // [THEN] The return's voucher line carries no issued amount
        NpRvSalesLine.SetRange("Document Type", ReturnOrder."Document Type");
        NpRvSalesLine.SetRange("Document No.", ReturnOrder."No.");
        NpRvSalesLine.FindFirst();
        _Assert.AreEqual(0, NpRvSalesLine."Issued Unit Amount (LCY)", 'Cards issued at different amounts give no single amount to reverse.');
    end;

    [Test]
    procedure LegacyGiftCardReturn_WritesCardOffAtIssuedAmount()
    var
        Currency: Record Currency;
        ShopifyStore: Record "NPR Spfy Store";
        ReturnOrder: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        Voucher: Record "NPR NpRv Voucher";
        LibraryRefund: Codeunit "NPR Library Spfy Legacy Refund";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ReturnOrderNo: Code[20];
        Posted: Boolean;
    begin
        // [SCENARIO] A Shopify return of a gift card sold in a foreign currency writes the card off at the LCY it was issued at, not at the conversion of its price.
        Initialize();
        // [GIVEN] A legacy-path store and a foreign currency whose table rate differs from Shopify's
        _LibraryReturn.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _LibraryReturn.GetStore(StoreCode, ShopifyStore);
        CreateCurrency(Currency);
        // [GIVEN] A Shopify order that sold a gift card of 100 in that currency, issued at the 765.00 LCY Shopify booked for it (769.23 by conversion)
        PostShopifyGiftCardSale('94450005', StoreCode, CustomerNo, LocationCode, Currency.Code, SalesInvoiceHeader);
        Voucher.Get(IssuedVoucherNo(SalesInvoiceHeader."No."));
        // [GIVEN] A return of the gift card, refunded by card at 100 that Shopify booked at 760.00 LCY
        LibraryRefund.BuildReturnOrderWithoutQueue(StoreCode,
            _LibraryReturn.ReturnDetailResponseGiftCard('944500059', '94450005', '#94450005', '944500051', 1, 100, '71001',
                _LibraryReturn.RefundTxnJsonWithShopMoney('944500058', 'shopify_payments', 100, Currency.Code, 760, LcyCode()), Currency.Code),
            '944500059', ReturnOrder);
        ReturnOrderNo := ReturnOrder."No.";

        // [WHEN] The return order is posted
        Posted := LibraryRefund.PostReturnOrder(ReturnOrder);

        // [THEN] Posting succeeds
        _Assert.IsTrue(Posted, 'Posting must succeed: ' + GetLastErrorText());
        // [THEN] The card is written off at the 765.00 it was issued at
        _LibraryReturn.GetCreditMemoForReturnOrder(ReturnOrderNo, SalesCrMemoHeader);
        _Assert.AreEqual(-765, VoucherEntryAmount(Voucher."No.", Voucher."Reference No.", SalesCrMemoHeader."No."), 'The write-off must equal the issued amount.');
        // [THEN] Nothing is left on the card
        _Assert.AreEqual(0, VoucherEntryAmount(Voucher."No.", Voucher."Reference No.", ''), 'A returned card must keep no balance.');
    end;

    #endregion

    #region Helpers

    /// <summary>
    /// A Shopify order of 100.00 in the currency, invoiced at Shopify's rate and paid at it.
    /// </summary>
    local procedure PostPaidShopifyOrder(OrderId: Text[20]; StoreCode: Code[20]; Sku: Code[20]; CustomerNo: Code[20]; LocationCode: Code[10]; CurrencyCode: Code[10]; ShopifyStore: Record "NPR Spfy Store"; var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LibrarySales: Codeunit "Library - Sales";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, CustomerNo);
        SalesHeader.Validate("Location Code", LocationCode);
        SalesHeader.Validate("Prices Including VAT", true);
        SalesHeader.Validate("Currency Code", CurrencyCode);
        SalesHeader.Validate("Currency Factor", ShopifyFactor());
        SalesHeader.Modify(true);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Sku, 1);
        SalesLine.Validate("Unit Price", 100);
        SalesLine.Modify(true);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID", OrderId, false);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Store Code", StoreCode, false);
        SpfyAssignedIDMgt.AssignShopifyID(SalesLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", OrderId + '1', false);
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
        PayInvoiceAtItsRate(SalesInvoiceHeader, ShopifyStore."Return Refund G/L Account No.");
    end;

    /// <summary>
    /// A Shopify order that sold one gift card of 100.00 in the currency at Shopify's rate, its voucher issued at the LCY Shopify booked (765.00 unless given); the line is Shopify line item OrderId + '1'.
    /// </summary>
    local procedure PostShopifyGiftCardSale(OrderId: Text[20]; StoreCode: Code[20]; CustomerNo: Code[20]; LocationCode: Code[10]; CurrencyCode: Code[10]; var SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        PostShopifyGiftCardSale(OrderId, StoreCode, CustomerNo, LocationCode, CurrencyCode, 765, SalesInvoiceHeader);
    end;

    local procedure PostShopifyGiftCardSale(OrderId: Text[20]; StoreCode: Code[20]; CustomerNo: Code[20]; LocationCode: Code[10]; CurrencyCode: Code[10]; ShopifyAmountLCY: Decimal; var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SalesHeader: Record "Sales Header";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        SalesLine: Record "Sales Line";
        LibrarySales: Codeunit "Library - Sales";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyDocumentRate: Codeunit "NPR Spfy Document Rate";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, CustomerNo);
        SalesHeader.Validate("Location Code", LocationCode);
        SalesHeader.Validate("Prices Including VAT", true);
        SalesHeader.Validate("Currency Code", CurrencyCode);
        SalesHeader.Validate("Currency Factor", ShopifyFactor());
        SpfyDocumentRate.SetShopifyCurrencyFactor(SalesHeader);
        SalesHeader.Modify(true);
        AddVoucherLine(SalesHeader, 100, NpRvSalesLine);
        StampShopifyAmount(NpRvSalesLine, ShopifyAmountLCY, LcyCode(), 100);
        SalesLine.Get(NpRvSalesLine."Document Type", NpRvSalesLine."Document No.", NpRvSalesLine."Document Line No.");
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID", OrderId, false);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Store Code", StoreCode, false);
        SpfyAssignedIDMgt.AssignShopifyID(SalesLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", OrderId + '1', false);
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    /// <summary>
    /// A return of the order's one unit, refunded by card at 100.00 that Shopify booked at 760.00 LCY.
    /// </summary>
    local procedure BuildReturn(OrderId: Text[20]; StoreCode: Code[20]; Sku: Code[20]; CurrencyCode: Code[10]; var ReturnOrder: Record "Sales Header")
    begin
        BuildReturn(OrderId, StoreCode, Sku, CurrencyCode, 760, LcyCode(), ReturnOrder);
    end;

    /// <summary>
    /// A legacy return order for the order's one line, refunded by card at 100.00 that Shopify booked at ShopAmount in ShopCurrencyCode.
    /// </summary>
    local procedure BuildReturn(OrderId: Text[20]; StoreCode: Code[20]; Sku: Code[20]; CurrencyCode: Code[10]; ShopAmount: Decimal; ShopCurrencyCode: Code[10]; var ReturnOrder: Record "Sales Header")
    var
        LibraryRefund: Codeunit "NPR Library Spfy Legacy Refund";
    begin
        LibraryRefund.BuildReturnOrderWithoutQueue(StoreCode,
            _LibraryReturn.ReturnDetailResponse(OrderId + '9', OrderId, '#' + OrderId, Sku, OrderId + '1', 1, 80, 20, 25, '71001',
                _LibraryReturn.RefundTxnJsonWithShopMoney(OrderId + '8', 'shopify_payments', 100, CurrencyCode, ShopAmount, ShopCurrencyCode), CurrencyCode),
            OrderId + '9', ReturnOrder);
    end;

    local procedure Initialize()
    var
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        if _Initialized then
            exit;
        LibraryPOSMasterData.CreatePartialVoucherType(_VoucherType, false);
        _Initialized := true;
        Commit();
    end;

    local procedure ShopifyFactor(): Decimal
    begin
        exit(0.13);
    end;

    local procedure TableFactor(): Decimal
    begin
        exit(0.05);
    end;

    local procedure RevaluedFactor(): Decimal
    begin
        exit(0.08);
    end;

    /// <summary>
    /// A Sales Order of the Shopify store's fallback customer, as the legacy import leaves it, so updating its header confirms no change of customer.
    /// </summary>
    local procedure CreateLegacyImportOrder(var StoreCode: Code[20]; var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        NpEcStore: Record "NPR NpEc Store";
        LibrarySales: Codeunit "Library - Sales";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        Sku: Code[20];
        ItemNo: Code[20];
    begin
        LibrarySpfyImport.SetupSimpleItemOrder(StoreCode, Sku, ItemNo);
        LibrarySales.CreateCustomer(Customer);
        NpEcStore.SetRange("Shopify Store Code", StoreCode);
        NpEcStore.FindFirst();
        NpEcStore."Spfy Customer No." := Customer."No.";
        NpEcStore.Modify();
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
    end;

    local procedure LcyCode(): Code[10]
    var
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get();
        exit(GLSetup."LCY Code");
    end;

    /// <summary>
    /// A foreign currency whose table rate, 0.05, is unmistakably not Shopify's. It applies from before both the work date and the dates the Shopify mock documents carry.
    /// </summary>
    local procedure CreateCurrency(var Currency: Record Currency)
    var
        LibraryERM: Codeunit "Library - ERM";
        StartingDate: Date;
    begin
        LibraryERM.CreateCurrency(Currency);
        Currency.InitRoundingPrecision();
        Currency."Realized Gains Acc." := LibraryERM.CreateGLAccountNo();
        Currency."Realized Losses Acc." := LibraryERM.CreateGLAccountNo();
        Currency.Modify();
        StartingDate := CalcDate('<-30D>', WorkDate());
        if StartingDate > 20260101D then
            StartingDate := 20260101D;
        LibraryERM.CreateExchangeRate(Currency.Code, StartingDate, TableFactor(), TableFactor());
    end;

    local procedure CreateShopifyOrder(var SalesHeader: Record "Sales Header"; CurrencyCode: Code[10]; KeepShopifyRate: Boolean)
    var
        Customer: Record Customer;
        LibrarySales: Codeunit "Library - Sales";
        SpfyDocumentRate: Codeunit "NPR Spfy Document Rate";
    begin
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        SalesHeader.Validate("Currency Code", CurrencyCode);
        SalesHeader.Validate("Prices Including VAT", true);
        SalesHeader.Validate("Currency Factor", ShopifyFactor());
        if KeepShopifyRate then
            SpfyDocumentRate.SetShopifyCurrencyFactor(SalesHeader);
        SalesHeader.Modify(true);
    end;

    /// <summary>
    /// A posted invoice of 100.00 at the given factor, marked as an invoice of the Shopify order in the store.
    /// </summary>
    local procedure PostInvoiceOfShopifyOrder(OrderId: Text[30]; StoreCode: Code[20]; CurrencyCode: Code[10]; CurrencyFactor: Decimal)
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        LibrarySales: Codeunit "Library - Sales";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        SalesHeader.Validate("Currency Code", CurrencyCode);
        SalesHeader.Validate("Currency Factor", CurrencyFactor);
        SalesHeader.Modify(true);
        AddGLLine(SalesHeader, 100);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID", OrderId, false);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Store Code", StoreCode, false);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
    end;

    local procedure InsertRefundPaymentLine(var TempPaymentLine: Record "NPR Magento Payment Line" temporary; LineNo: Integer; Amount: Decimal; AmountStoreCurrency: Decimal; StoreCurrencyCode: Code[10])
    begin
        TempPaymentLine.Init();
        TempPaymentLine."Document Table No." := Database::"Sales Cr.Memo Header";
        TempPaymentLine."Document No." := 'SPFYDR445';
        TempPaymentLine."Line No." := LineNo;
        TempPaymentLine."Payment Type" := TempPaymentLine."Payment Type"::"Payment Method";
        TempPaymentLine.Amount := Amount;
        TempPaymentLine."Amount (Store Currency)" := AmountStoreCurrency;
        TempPaymentLine."Store Currency Code" := StoreCurrencyCode;
        TempPaymentLine.Insert();
    end;

    local procedure IssuedAmountOnLine(InvoiceNo: Code[20]; LineNo: Integer): Decimal
    var
        VoucherEntry: Record "NPR NpRv Voucher Entry";
    begin
        VoucherEntry.SetRange("Entry Type", VoucherEntry."Entry Type"::"Issue Voucher");
        VoucherEntry.SetRange("Document Type", VoucherEntry."Document Type"::Invoice);
        VoucherEntry.SetRange("Document No.", InvoiceNo);
        VoucherEntry.SetRange("Document Line No.", LineNo);
        VoucherEntry.CalcSums(Amount);
        exit(VoucherEntry.Amount);
    end;

    /// <summary>
    /// A Shopify return order of 13.00 at Shopify's rate, balanced through a payment method, with a refund payment line Shopify booked at 98.00 LCY.
    /// </summary>
    local procedure CreateEcomReturnWithShopifyRefund(CurrencyCode: Code[10]; var ReturnOrder: Record "Sales Header"; var PaymentMethod: Record "Payment Method")
    var
        Customer: Record Customer;
        PaymentLine: Record "NPR Magento Payment Line";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
        SpfyDocumentRate: Codeunit "NPR Spfy Document Rate";
    begin
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesHeader(ReturnOrder, ReturnOrder."Document Type"::"Return Order", Customer."No.");
        ReturnOrder.Validate("Currency Code", CurrencyCode);
        ReturnOrder.Validate("Prices Including VAT", true);
        ReturnOrder.Validate("Currency Factor", ShopifyFactor());
        SpfyDocumentRate.SetShopifyCurrencyFactor(ReturnOrder);
        LibraryERM.CreatePaymentMethodWithBalAccount(PaymentMethod);
        ReturnOrder.Validate("Payment Method Code", PaymentMethod.Code);
        ReturnOrder.Modify(true);
        AddGLLine(ReturnOrder, 13);
        PaymentLine.Init();
        PaymentLine."Document Table No." := Database::"Sales Header";
        PaymentLine."Document Type" := ReturnOrder."Document Type";
        PaymentLine."Document No." := ReturnOrder."No.";
        PaymentLine."Line No." := 10000;
        PaymentLine."Payment Type" := PaymentLine."Payment Type"::"Payment Method";
        PaymentLine.Amount := 13;
        PaymentLine."Requested Amount" := 13;
        PaymentLine."Amount (Store Currency)" := 98;
        PaymentLine."Requested Amt. (Store Curr.)" := 98;
        PaymentLine."Store Currency Code" := LcyCode();
        PaymentLine."Posting Date" := ReturnOrder."Posting Date";
        PaymentLine.Insert();
    end;

    /// <summary>
    /// A corrective Shopify return order of 13.00 held at 0.13, balanced through a payment method: 9.00 refunded by card that Shopify booked at CardAmountLCY (0 when it carries no Shopify LCY), and 4.00 put back on a new gift card voucher that Shopify booked at 30.00 LCY.
    /// </summary>
    local procedure CreateEcomReturnPartlyToGiftCard(CurrencyCode: Code[10]; CardAmountLCY: Decimal; VoucherNo: Code[20]; GiftCardId: Text[30]; var ReturnOrder: Record "Sales Header"; var PaymentMethod: Record "Payment Method"; var Voucher: Record "NPR NpRv Voucher")
    var
        PaymentLine: Record "NPR Magento Payment Line";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        _LibraryReturn.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _LibraryReturn.CreateVoucherWithGiftCardId(VoucherNo, StoreCode, GiftCardId, Voucher);
        CreateEcomReturnWithShopifyRefund(CurrencyCode, ReturnOrder, PaymentMethod);
        ReturnOrder.Correction := true;
        ReturnOrder.Modify();
        PaymentLine.Get(Database::"Sales Header", ReturnOrder."Document Type", ReturnOrder."No.", 10000);
        PaymentLine.Amount := 9;
        PaymentLine."Requested Amount" := 9;
        PaymentLine."Amount (Store Currency)" := CardAmountLCY;
        PaymentLine."Requested Amt. (Store Curr.)" := CardAmountLCY;
        PaymentLine."Store Currency Code" := '';
        if CardAmountLCY <> 0 then
            PaymentLine."Store Currency Code" := LcyCode();
        PaymentLine.Modify();
        PaymentLine."Line No." := 20000;
        PaymentLine."Payment Type" := PaymentLine."Payment Type"::Voucher;
        PaymentLine."Account No." := Voucher."Account No.";
        PaymentLine."No." := Voucher."Reference No.";
        PaymentLine."Source Table No." := Database::"NPR NpRv Voucher";
        PaymentLine."Source No." := Voucher."No.";
        PaymentLine.Amount := 4;
        PaymentLine."Requested Amount" := 4;
        PaymentLine."Amount (Store Currency)" := 30;
        PaymentLine."Requested Amt. (Store Curr.)" := 30;
        PaymentLine."Store Currency Code" := LcyCode();
        PaymentLine.Insert();
    end;

    local procedure AddGLLine(SalesHeader: Record "Sales Header"; UnitPrice: Decimal)
    var
        SalesLine: Record "Sales Line";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::"G/L Account", LibraryERM.CreateGLAccountWithSalesSetup(), 1);
        SalesLine.Validate("Unit Price", UnitPrice);
        SalesLine.Modify(true);
    end;

    local procedure AddVoucherLine(SalesHeader: Record "Sales Header"; UnitPrice: Decimal; var NpRvSalesLine: Record "NPR NpRv Sales Line")
    var
        GLAccount: Record "G/L Account";
        GeneralPostingSetup: Record "General Posting Setup";
        SalesLine: Record "Sales Line";
        LibraryERM: Codeunit "Library - ERM";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
    begin
        GLAccount.Get(_VoucherType."Account No.");
        if not GeneralPostingSetup.Get(SalesHeader."Gen. Bus. Posting Group", GLAccount."Gen. Prod. Posting Group") then begin
            GeneralPostingSetup."Gen. Bus. Posting Group" := SalesHeader."Gen. Bus. Posting Group";
            GeneralPostingSetup."Gen. Prod. Posting Group" := GLAccount."Gen. Prod. Posting Group";
            GeneralPostingSetup.Insert();
        end;
        LibraryERM.SetGeneralPostingSetupSalesAccounts(GeneralPostingSetup);
        GeneralPostingSetup.Modify();
        LibraryPOSMasterData.CreateVATPostingSetupForSaleItem(SalesHeader."VAT Bus. Posting Group", GLAccount."VAT Prod. Posting Group");

        NpRvSalesDocMgt.IssueVoucher(SalesHeader, _VoucherType);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindLast();
        SalesLine.Validate("Unit Price", UnitPrice);
        SalesLine.Modify(true);

        NpRvSalesLine.SetRange("Document Type", SalesLine."Document Type");
        NpRvSalesLine.SetRange("Document No.", SalesLine."Document No.");
        NpRvSalesLine.SetRange("Document Line No.", SalesLine."Line No.");
        NpRvSalesLine.FindFirst();
    end;

    /// <summary>
    /// What the legacy import stores on a gift card's voucher line.
    /// </summary>
    local procedure StampShopifyAmount(var NpRvSalesLine: Record "NPR NpRv Sales Line"; StoreCurrencyAmount: Decimal; StoreCurrencyCode: Code[10]; CapturedUnitPrice: Decimal)
    begin
        NpRvSalesLine."Spfy Amount (Store Currency)" := StoreCurrencyAmount;
        NpRvSalesLine."Spfy Store Currency Code" := StoreCurrencyCode;
        NpRvSalesLine."Spfy Captured Unit Price" := CapturedUnitPrice;
        NpRvSalesLine.Modify();
    end;

    local procedure IssuedVoucherNo(InvoiceNo: Code[20]): Code[20]
    var
        VoucherEntry: Record "NPR NpRv Voucher Entry";
    begin
        VoucherEntry.SetRange("Entry Type", VoucherEntry."Entry Type"::"Issue Voucher");
        VoucherEntry.SetRange("Document Type", VoucherEntry."Document Type"::Invoice);
        VoucherEntry.SetRange("Document No.", InvoiceNo);
        VoucherEntry.FindFirst();
        exit(VoucherEntry."Voucher No.");
    end;

    /// <summary>
    /// What the credit memo's refund entries posted to the G/L account.
    /// </summary>
    local procedure RefundGLAmount(GLAccountNo: Code[20]; CreditMemoNo: Code[20]): Decimal
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("G/L Account No.", GLAccountNo);
        GLEntry.SetRange("Document Type", GLEntry."Document Type"::Refund);
        GLEntry.SetRange("Document No.", CreditMemoNo);
        GLEntry.CalcSums(Amount);
        exit(GLEntry.Amount);
    end;

    /// <summary>
    /// The sum of the voucher's entries for the credit memo, or of all of them when no credit memo is given, whether the voucher is still live or archived under a new number.
    /// </summary>
    local procedure VoucherEntryAmount(VoucherNo: Code[20]; ReferenceNo: Text[50]; CreditMemoNo: Code[20]): Decimal
    var
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        ArchVoucherEntry: Record "NPR NpRv Arch. Voucher Entry";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
    begin
        VoucherEntry.SetRange("Voucher No.", VoucherNo);
        ArchVoucher.SetRange("Reference No.", ReferenceNo);
        if ArchVoucher.FindFirst() then
            ArchVoucherEntry.SetRange("Arch. Voucher No.", ArchVoucher."No.")
        else
            ArchVoucherEntry.SetRange("Arch. Voucher No.", VoucherNo);
        // The invoice and the credit memo can share a number, so the document type tells them apart.
        if CreditMemoNo <> '' then begin
            VoucherEntry.SetRange("Document Type", VoucherEntry."Document Type"::"Credit Memo");
            VoucherEntry.SetRange("Document No.", CreditMemoNo);
            ArchVoucherEntry.SetRange("Document Type", ArchVoucherEntry."Document Type"::"Credit Memo");
            ArchVoucherEntry.SetRange("Document No.", CreditMemoNo);
        end;
        VoucherEntry.CalcSums(Amount);
        ArchVoucherEntry.CalcSums(Amount);
        exit(VoucherEntry.Amount + ArchVoucherEntry.Amount);
    end;

    local procedure IssuedAmount(InvoiceNo: Code[20]): Decimal
    var
        VoucherEntry: Record "NPR NpRv Voucher Entry";
    begin
        VoucherEntry.SetRange("Entry Type", VoucherEntry."Entry Type"::"Issue Voucher");
        VoucherEntry.SetRange("Document Type", VoucherEntry."Document Type"::Invoice);
        VoucherEntry.SetRange("Document No.", InvoiceNo);
        VoucherEntry.FindFirst();
        exit(VoucherEntry.Amount);
    end;

    local procedure CreateCorrectiveCreditMemo(SalesInvoiceHeader: Record "Sales Invoice Header"; var CreditMemo: Record "Sales Header")
    var
        CopyDocMgt: Codeunit "Copy Document Mgt.";
    begin
        Clear(CreditMemo);
        CreditMemo."Document Type" := CreditMemo."Document Type"::"Credit Memo";
        CreditMemo.SetAllowSelectNoSeries();
        CreditMemo.Insert(true);
        CopyDocMgt.SetPropertiesForCreditMemoCorrection();
        CopyDocMgt.CopySalesDocForInvoiceCancelling(SalesInvoiceHeader."No.", CreditMemo);
        CreditMemo.Find();
    end;

    local procedure PayInvoiceAtItsRate(SalesInvoiceHeader: Record "Sales Invoice Header"; BalAccountNo: Code[20])
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GenJnlLine: Record "Gen. Journal Line";
        GLSetup: Record "General Ledger Setup";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange("Document No.", SalesInvoiceHeader."No.");
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields("Remaining Amount");
        GenJnlLine.Init();
        GenJnlLine."Copy VAT Setup to Jnl. Lines" := false;
        GLSetup.Get();
        if GLSetup."Journal Templ. Name Mandatory" then
            GenJnlLine."Journal Template Name" := CustLedgerEntry."Journal Templ. Name";
        GenJnlLine."Posting Date" := CustLedgerEntry."Posting Date";
        GenJnlLine."Document Date" := CustLedgerEntry."Posting Date";
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
        GenJnlLine."Document No." := SalesInvoiceHeader."No.";
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
        GenJnlLine.Validate("Account No.", CustLedgerEntry."Customer No.");
        GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
        GenJnlLine.Validate("Bal. Account No.", BalAccountNo);
        GenJnlLine."Currency Code" := SalesInvoiceHeader."Currency Code";
        GenJnlLine."Currency Factor" := SalesInvoiceHeader."Currency Factor";
        GenJnlLine.Validate(Amount, -CustLedgerEntry."Remaining Amount");
        GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Invoice;
        GenJnlLine."Applies-to Doc. No." := SalesInvoiceHeader."No.";
        GenJnlLine."Source Code" := CustLedgerEntry."Source Code";
        GenJnlPostLine.RunWithCheck(GenJnlLine);
    end;

    local procedure AddShopifyGiftCardLine(StoreCode: Code[20]; SalesHeader: Record "Sales Header"; OrderLineId: Text[30]; var GiftCardLine: Record "Sales Line")
    var
        ShopifyStore: Record "NPR Spfy Store";
        LibrarySales: Codeunit "Library - Sales";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        ShopifyStore.Get(StoreCode);
        ShopifyStore."Voucher Type (Sold at Shopify)" := _VoucherType.Code;
        ShopifyStore.Modify();
        LibrarySales.CreateSalesLine(GiftCardLine, SalesHeader, GiftCardLine.Type::"G/L Account", _VoucherType."Account No.", 1);
        GiftCardLine.Validate("Unit Price", 50);
        GiftCardLine.Modify(true);
        SpfyAssignedIDMgt.AssignShopifyID(GiftCardLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", OrderLineId, false);
    end;

    local procedure GiftCardOrderLineText(LineId: Text; UnitPrice: Decimal; ShopAmount: Decimal; ShopCurrency: Code[10]): Text
    begin
        exit(
            '{"id":' + LineId + ',"sku":"","title":"Gift card","variant_title":null,"name":"Gift card",' +
            '"quantity":1,"fulfillable_quantity":0,"fulfillment_status":"fulfilled","gift_card":true,' +
            '"price_set":{"presentment_money":{"amount":"' + Format(UnitPrice, 0, 9) + '"},' +
            '"shop_money":{"amount":"' + Format(ShopAmount, 0, 9) + '","currency_code":"' + ShopCurrency + '"}},' +
            '"discount_allocations":[],"properties":[]}');
    end;

    local procedure LegacyOrderHeaderJson(OrderId: Text; PresentmentCurrency: Code[10]; PresentmentTotal: Decimal; ShopTotal: Decimal): JsonToken
    begin
        exit(LegacyOrderHeaderJsonInStoreCurrency(OrderId, PresentmentCurrency, LcyCode(), PresentmentTotal, ShopTotal));
    end;

    local procedure LegacyOrderHeaderJsonInStoreCurrency(OrderId: Text; PresentmentCurrency: Code[10]; StoreCurrency: Code[10]; PresentmentTotal: Decimal; ShopTotal: Decimal) Order: JsonToken
    var
        CreatedAt: Text;
    begin
        CreatedAt := Format(WorkDate(), 0, 9) + 'T10:00:00Z';
        Order.ReadFrom(
            '{"id":' + OrderId + ',"order_number":' + OrderId + ',"name":"#' + OrderId + '","source_name":"web",' +
            '"created_at":"' + CreatedAt + '","closed_at":null,' +
            '"presentment_currency":"' + PresentmentCurrency + '","currency":"' + StoreCurrency + '",' +
            '"total_price_set":{"presentment_money":{"amount":"' + Format(PresentmentTotal, 0, 9) + '"},"shop_money":{"amount":"' + Format(ShopTotal, 0, 9) + '"}},' +
            '"line_items":[],"shipping_lines":[],"fulfillments":[],"note":null,"note_attributes":[]}');
    end;

    local procedure EcomGiftCardLineText(VariantPrice: Decimal; PresentmentPrice: Decimal; ShopPrice: Decimal): Text
    begin
        exit(
            '{"id":"gid://shopify/LineItem/944500000040","sku":"","title":"Gift card","variantTitle":null,' +
            '"quantity":1,"unfulfilledQuantity":1,"currentQuantity":1,"nonFulfillableQuantity":0,"isGiftCard":true,' +
            '"product":{"id":"gid://shopify/Product/2","productType":"giftcard"},' +
            '"variant":{"price":"' + Format(VariantPrice, 0, 9) + '"},' +
            '"originalUnitPriceSet":{"presentmentMoney":{"amount":"' + Format(PresentmentPrice, 0, 9) + '"},"shopMoney":{"amount":"' + Format(ShopPrice, 0, 9) + '"}},' +
            '"taxLines":[],"discountAllocations":[]}');
    end;

    /// <summary>
    /// A Shopify ecommerce document without lines, in the ecommerce store SetupSimpleItemOrder creates, routed to the current import implementation.
    /// </summary>
    local procedure InsertShopifyEcomHeader(DocumentType: Enum "NPR Ecom Sales Doc Type"; ExternalNo: Code[20]; CustomerNo: Code[20]; CurrencyCode: Code[10]; CurrencyExchangeRate: Decimal; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        EcomSalesDocImplV2: Codeunit "NPR Ecom Sales Doc Impl V2";
    begin
        Clear(EcomSalesHeader);
        EcomSalesHeader."Document Type" := DocumentType;
        EcomSalesHeader."Document Source" := EcomSalesHeader."Document Source"::Shopify;
        EcomSalesHeader."External No." := ExternalNo;
        EcomSalesHeader."Ecommerce Store Code" := LibrarySpfyImport.EcStoreCode();
        EcomSalesHeader."Sell-to Customer No." := CustomerNo;
        EcomSalesHeader."Currency Code" := CurrencyCode;
        EcomSalesHeader."Currency Exchange Rate" := CurrencyExchangeRate;
        EcomSalesHeader."API Version Date" := EcomSalesDocImplV2.GetApiVersion();
        EcomSalesHeader."Received Date" := WorkDate();
        EcomSalesHeader.Insert(true);
    end;

    local procedure ProcessEcomDocument(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesDocProcess: Codeunit "NPR EcomSalesDocProcess";
    begin
        Commit();
        EcomSalesDocProcess.SetShowError(true);
        EcomSalesDocProcess.Run(EcomSalesHeader);
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        _Assert.AreNotEqual('', EcomSalesHeader."Created Doc No.", 'The ecommerce document must have become a sales document.');
    end;

    local procedure InsertShopifyLogEntry(var LogEntry: Record "NPR Spfy Event Log Entry"; ShopifyId: Text[30]; DocType: Enum "NPR SpfyEventLogDocType"; PresentmentCurrency: Code[10]; AmountPCY: Decimal; AmountSCY: Decimal)
    begin
        LogEntry.Init();
        LogEntry."Entry No." := 0;
        LogEntry.Type := LogEntry.Type::"Incoming Sales Order";
        LogEntry."Shopify ID" := ShopifyId;
        LogEntry."Document Type" := DocType;
        LogEntry."Presentment Currency Code" := PresentmentCurrency;
        LogEntry."Store Currency Code" := LcyCode();
        LogEntry."Amount (PCY)" := AmountPCY;
        LogEntry."Amount (SCY)" := AmountSCY;
        LogEntry."Event Date-Time" := CurrentDateTime();
        LogEntry.Insert(true);
    end;

    [ConfirmHandler]
    procedure ConfirmYes(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [ConfirmHandler]
    procedure ConfirmNo(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := false;
    end;

    [MessageHandler]
    procedure MessageOk(Message: Text[1024])
    begin
    end;

    #endregion
}
