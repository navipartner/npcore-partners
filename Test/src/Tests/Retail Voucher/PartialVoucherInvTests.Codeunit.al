codeunit 85553 "NPR Partial Voucher Inv. Tests"
{
    // [FEATURE] Partial invoicing of sales orders paid with a retail voucher
    Subtype = Test;

    var
        _GLSetup: Record "General Ledger Setup";
        _Item: Record Item;
        _POSPaymentMethodCash: Record "NPR POS Payment Method";
        _POSSetup: Record "NPR POS Setup";
        _POSStore: Record "NPR POS Store";
        _POSUnit: Record "NPR POS Unit";
        _VoucherTypeDefault: Record "NPR NpRv Voucher Type";
        _VoucherTypePartial: Record "NPR NpRv Voucher Type";
        _VoucherTypeShopify: Record "NPR NpRv Voucher Type";
        _VoucherTypeCustom: Record "NPR NpRv Voucher Type";
        _Assert: Codeunit Assert;
        _LibrarySales: Codeunit "Library - Sales";
        _POSSession: Codeunit "NPR POS Session";
        _CardGLAccountNo: Code[20];
        _Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FirstPartialInvoiceRedeemsOnlyItsShareOfThePartialVoucher()
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        SalesHeader: Record "Sales Header";
        Voucher: Record "NPR NpRv Voucher";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] The first partial invoice of an order paid by a PARTIAL voucher and a card is paid by the voucher first, redeems only the invoice amount and keeps the rest of the voucher payment reserved.
        Initialize();

        // [GIVEN] The new voucher calculation on release is on, as in production
        SetNewVoucherCalculation(true);
        // [GIVEN] An order of 400.98 + 399.96, paid 0.94 by card and 800 by a PARTIAL voucher holding 1000
        CreateOrderPaidByCardAndVoucher(SalesHeader, Voucher, _VoucherTypePartial.Code, 1000, 0.94, 400.98, 399.96, 0);
        // [GIVEN] Only the first line is shipped and invoiced
        SetLinesToPost(SalesHeader, 1);

        // [WHEN] The order is posted
        InvoiceNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] The invoice carries 400.98 of the voucher and nothing of the card
        _Assert.AreEqual(400.98, InvoicePaymentAmount(InvoiceNo, "NPR Magento Payment Type"::Voucher), 'The first invoice must take its whole amount from the voucher.');
        _Assert.AreEqual(0, InvoicePaymentAmount(InvoiceNo, "NPR Magento Payment Type"::"Payment Method"), 'The card pays nothing on an invoice the voucher already covers.');
        // [THEN] The voucher is redeemed by 400.98 on that invoice and still holds 599.02
        _Assert.AreEqual(-400.98, VoucherPaymentEntryAmount(Voucher."No.", InvoiceNo), 'The voucher must be redeemed by the invoice share only.');
        Voucher.CalcFields(Amount, "Reserved Amount");
        _Assert.AreEqual(599.02, Voucher.Amount, 'The voucher must keep what the first invoice did not use.');
        // [THEN] The order keeps 399.02 of the voucher payment, still reserved on the voucher
        _Assert.AreEqual(399.02, OrderPaymentAmount(SalesHeader, "NPR Magento Payment Type"::Voucher), 'The order voucher payment line must keep the remainder.');
        _Assert.AreEqual(399.02, Voucher."Reserved Amount", 'The remainder must stay reserved on the voucher.');
        FindOrderVoucherSalesLine(SalesHeader, NpRvSalesLine);
        _Assert.IsFalse(NpRvSalesLine.Posted, 'The voucher reservation must stay open until the order has used it up.');
        // [THEN] The customer owes nothing for the invoice
        _Assert.AreEqual(0, CustomerBalance(SalesHeader."Bill-to Customer No."), 'The invoice must be fully paid by its share of the payments.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SecondPartialInvoiceRedeemsTheRestOfTheVoucherAndTakesTheCard()
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        SalesHeader: Record "Sales Header";
        Voucher: Record "NPR NpRv Voucher";
        FirstInvoiceNo: Code[20];
        SecondInvoiceNo: Code[20];
        OrderNo: Code[20];
    begin
        // [SCENARIO] The last partial invoice redeems what is left of the voucher payment and takes the card payment, and the voucher has been redeemed by exactly what the order used.
        Initialize();

        // [GIVEN] The new voucher calculation on release is on, as in production
        SetNewVoucherCalculation(true);
        // [GIVEN] An order of 400.98 + 399.96, paid 0.94 by card and 800 by a PARTIAL voucher holding 1000
        CreateOrderPaidByCardAndVoucher(SalesHeader, Voucher, _VoucherTypePartial.Code, 1000, 0.94, 400.98, 399.96, 0);
        OrderNo := SalesHeader."No.";
        // [GIVEN] The first line has been shipped and invoiced
        SetLinesToPost(SalesHeader, 1);
        FirstInvoiceNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);
        // [GIVEN] The second line is shipped and invoiced next
        SalesHeader.Get(SalesHeader."Document Type"::Order, OrderNo);
        SetLinesToPost(SalesHeader, 2);

        // [WHEN] The order is posted again
        SecondInvoiceNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] The second invoice carries the remaining 399.02 of the voucher and the 0.94 card payment
        _Assert.AreEqual(399.02, InvoicePaymentAmount(SecondInvoiceNo, "NPR Magento Payment Type"::Voucher), 'The second invoice must take the rest of the voucher payment.');
        _Assert.AreEqual(0.94, InvoicePaymentAmount(SecondInvoiceNo, "NPR Magento Payment Type"::"Payment Method"), 'The card must pay what the voucher leaves of the second invoice.');
        // [THEN] The voucher was redeemed by 800 over both invoices and keeps the 200 the order never used
        _Assert.AreEqual(-399.02, VoucherPaymentEntryAmount(Voucher."No.", SecondInvoiceNo), 'The second invoice must redeem the rest of the voucher payment.');
        _Assert.AreEqual(-800, VoucherPaymentEntryAmount(Voucher."No.", FirstInvoiceNo) + VoucherPaymentEntryAmount(Voucher."No.", SecondInvoiceNo), 'Both invoices together must redeem exactly the voucher payment of the order.');
        Voucher.CalcFields(Amount, "Reserved Amount");
        _Assert.AreEqual(200, Voucher.Amount, 'The voucher must keep the amount the order did not use.');
        _Assert.AreEqual(0, Voucher."Reserved Amount", 'Nothing may stay reserved once the order is fully invoiced.');
        NpRvSalesLine.SetRange("Voucher No.", Voucher."No.");
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::Payment);
        NpRvSalesLine.SetRange(Posted, false);
        _Assert.IsTrue(NpRvSalesLine.IsEmpty(), 'The voucher reservation must be closed once the order has used it up.');
        // [THEN] The customer owes nothing after both invoices
        _Assert.AreEqual(0, CustomerBalance(SalesHeader."Bill-to Customer No."), 'Both invoices must be fully paid.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TwoVouchersPayThePartialInvoiceInLineOrder()
    var
        SalesHeader: Record "Sales Header";
        SecondVoucher: Record "NPR NpRv Voucher";
        Voucher: Record "NPR NpRv Voucher";
        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] With two vouchers on the order, a partial invoice uses up the first voucher, takes the rest from the second and keeps the second's remainder reserved.
        Initialize();

        // [GIVEN] The new voucher calculation on release is on, as in production
        SetNewVoucherCalculation(true);
        // [GIVEN] An order of 400.98 + 399.96, paid 300.94 by card, 300 by a PARTIAL voucher holding 300 and 200 by a SHOPIFY gift card holding 200
        CreateOrderPaidByCardAndVoucher(SalesHeader, Voucher, _VoucherTypePartial.Code, 300, 300.94, 400.98, 399.96, 0);
        CreateVoucher(SecondVoucher, _VoucherTypeShopify.Code, 200);
        NpRvSalesDocMgt.RedeemVoucher(SalesHeader, SecondVoucher."Reference No.");
        // [GIVEN] Only the first line is shipped and invoiced
        SetLinesToPost(SalesHeader, 1);

        // [WHEN] The order is posted
        InvoiceNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] The first voucher pays 300, the second 100.98 and the card nothing
        _Assert.AreEqual(-300, VoucherPaymentEntryAmount(Voucher."No.", InvoiceNo), 'The first voucher must be used up before the second one.');
        _Assert.AreEqual(-100.98, VoucherPaymentEntryAmount(SecondVoucher."No.", InvoiceNo), 'The second voucher must pay only what the first leaves of the invoice.');
        _Assert.AreEqual(0, InvoicePaymentAmount(InvoiceNo, "NPR Magento Payment Type"::"Payment Method"), 'The card pays nothing on an invoice the vouchers cover.');
        // [THEN] The second voucher keeps 99.02 reserved for the order
        SecondVoucher.CalcFields("Reserved Amount");
        _Assert.AreEqual(99.02, SecondVoucher."Reserved Amount", 'The rest of the second voucher payment must stay reserved.');
        _Assert.AreEqual(0, CustomerBalance(SalesHeader."Bill-to Customer No."), 'The invoice must be fully paid by its share of the payments.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VoucherWithNoShareOnTheInvoiceStaysReservedAndUnredeemed()
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        SalesHeader: Record "Sales Header";
        SecondVoucher: Record "NPR NpRv Voucher";
        Voucher: Record "NPR NpRv Voucher";
        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] When the first voucher covers a partial invoice on its own, the second voucher is not redeemed on it and stays fully reserved for the order.
        Initialize();

        // [GIVEN] The new voucher calculation on release is on, as in production
        SetNewVoucherCalculation(true);
        // [GIVEN] An order of 400.98 + 399.96, paid 0.94 by card, 500 by a PARTIAL voucher holding 500 and 300 by a SHOPIFY gift card holding 300
        CreateOrderPaidByCardAndVoucher(SalesHeader, Voucher, _VoucherTypePartial.Code, 500, 0.94, 400.98, 399.96, 0);
        CreateVoucher(SecondVoucher, _VoucherTypeShopify.Code, 300);
        NpRvSalesDocMgt.RedeemVoucher(SalesHeader, SecondVoucher."Reference No.");
        // [GIVEN] Only the first line is shipped and invoiced
        SetLinesToPost(SalesHeader, 1);

        // [WHEN] The order is posted
        InvoiceNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] The first voucher pays the whole invoice and keeps 99.02 reserved
        _Assert.AreEqual(-400.98, VoucherPaymentEntryAmount(Voucher."No.", InvoiceNo), 'The first voucher must pay the invoice on its own.');
        Voucher.CalcFields("Reserved Amount");
        _Assert.AreEqual(99.02, Voucher."Reserved Amount", 'The rest of the first voucher payment must stay reserved.');
        // [THEN] The second voucher is not redeemed, keeps its 300 reserved and its reservation stays open
        _Assert.AreEqual(0, VoucherPaymentEntryAmount(SecondVoucher."No.", InvoiceNo), 'A voucher with no share on the invoice must not be redeemed.');
        SecondVoucher.CalcFields(Amount, "Reserved Amount");
        _Assert.AreEqual(300, SecondVoucher.Amount, 'A voucher with no share on the invoice must keep its balance.');
        _Assert.AreEqual(300, SecondVoucher."Reserved Amount", 'A voucher with no share on the invoice must stay fully reserved.');
        NpRvSalesLine.SetRange("Voucher No.", SecondVoucher."No.");
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::Payment);
        NpRvSalesLine.FindFirst();
        _Assert.IsFalse(NpRvSalesLine.Posted, 'The reservation of a voucher with no share on the invoice must stay open.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VoucherCappedByAnOrderChangeIsNotRaisedOnTheLastInvoice()
    var
        SalesHeader: Record "Sales Header";
        Voucher: Record "NPR NpRv Voucher";
        SecondInvoiceNo: Code[20];
        OrderNo: Code[20];
    begin
        // [SCENARIO] A voucher payment cut to the order total after a line was removed is not raised back to its original request on a later invoice, so the balance it freed can be spent elsewhere meanwhile.
        Initialize();

        // [GIVEN] The new voucher calculation on release is on, as in production
        SetNewVoucherCalculation(true);
        // [GIVEN] An order of 400 + 400 + 100, paid 900 by a PARTIAL voucher holding 900
        CreateOrderPaidByCardAndVoucher(SalesHeader, Voucher, _VoucherTypePartial.Code, 900, 0, 400, 400, 100);
        OrderNo := SalesHeader."No.";
        // [GIVEN] The 100 line is removed, so the voucher only has 800 left to pay
        DeleteLastItemLine(SalesHeader);
        // [GIVEN] The order is released, which cuts the voucher payment to the 800 left to pay and keeps 900 as requested
        _LibrarySales.ReleaseSalesDocument(SalesHeader);
        // [GIVEN] The first line has been invoiced
        SetLinesToPost(SalesHeader, 1);
        _LibrarySales.PostSalesDocument(SalesHeader, true, true);
        // [GIVEN] The 100 the order no longer needs is spent elsewhere
        SpendFromVoucher(Voucher."No.", 100);
        // [GIVEN] The second line is shipped and invoiced next
        SalesHeader.Get(SalesHeader."Document Type"::Order, OrderNo);
        SetLinesToPost(SalesHeader, 2);

        // [WHEN] The order is posted again
        SecondInvoiceNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] The voucher pays exactly the 400 of the second invoice
        _Assert.AreEqual(-400, VoucherPaymentEntryAmount(Voucher."No.", SecondInvoiceNo), 'The last invoice must take only what is left to invoice from the voucher.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VoucherCutToZeroAtReleaseHoldsNoReservation()
    var
        SalesHeader: Record "Sales Header";
        SecondVoucher: Record "NPR NpRv Voucher";
        Voucher: Record "NPR NpRv Voucher";
    begin
        // [SCENARIO] When releasing the order cuts a voucher payment to 0 because other vouchers cover the order, that voucher is no longer reserved for it.
        Initialize();

        // [GIVEN] The new voucher calculation on release is on, as in production
        SetNewVoucherCalculation(true);
        // [GIVEN] An order of 400 + 400 + 300, paid 800 by a PARTIAL voucher and 300 by a SHOPIFY gift card
        CreateOrderPaidByTwoVouchers(SalesHeader, Voucher, SecondVoucher);
        // [GIVEN] The 300 line is removed, so the first voucher covers the order on its own
        DeleteLastItemLine(SalesHeader);

        // [WHEN] The order is released
        _LibrarySales.ReleaseSalesDocument(SalesHeader);

        // [THEN] The gift card is no longer reserved and the first voucher stays reserved for the whole order
        SecondVoucher.CalcFields("Reserved Amount");
        _Assert.AreEqual(0, SecondVoucher."Reserved Amount", 'A voucher the order no longer pays with must not stay reserved.');
        Voucher.CalcFields("Reserved Amount");
        _Assert.AreEqual(800, Voucher."Reserved Amount", 'The voucher that pays the order must stay reserved for it.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VoucherThatPaysNothingDoesNotBlockLaterInvoices()
    var
        SalesHeader: Record "Sales Header";
        SecondVoucher: Record "NPR NpRv Voucher";
        Voucher: Record "NPR NpRv Voucher";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] A voucher that pays nothing on the order can be used up and archived elsewhere without stopping the order's next invoice.
        Initialize();

        // [GIVEN] The new voucher calculation on release is on, as in production
        SetNewVoucherCalculation(true);
        // [GIVEN] An order of 400 + 400 + 300, paid 800 by a PARTIAL voucher and 300 by a SHOPIFY gift card
        CreateOrderPaidByTwoVouchers(SalesHeader, Voucher, SecondVoucher);
        // [GIVEN] The 300 line is removed and the order released, so the gift card pays nothing
        DeleteLastItemLine(SalesHeader);
        _LibrarySales.ReleaseSalesDocument(SalesHeader);
        // [GIVEN] The gift card is used up elsewhere and archived
        RemoveVoucher(SecondVoucher."No.");
        // [GIVEN] Only the first line is shipped and invoiced
        SetLinesToPost(SalesHeader, 1);

        // [WHEN] The order is posted
        InvoiceNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] The first voucher pays the invoice
        _Assert.AreEqual(-400, VoucherPaymentEntryAmount(Voucher."No.", InvoiceNo), 'The voucher that pays the order must be redeemed for the invoice.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VoucherRedeemedAtCaptureIsSplitLikeACardPayment()
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        SalesHeader: Record "Sales Header";
        Voucher: Record "NPR NpRv Voucher";
        VoucherPaymentLine: Record "NPR Magento Payment Line";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] An order whose gift card the ecommerce capture already redeemed and archived can still be invoiced in parts: the captured voucher line is split like a card payment and not redeemed again.
        Initialize();

        // [GIVEN] The new voucher calculation on release is on, as in production
        SetNewVoucherCalculation(true);
        // [GIVEN] An order of 400 + 400, paid 400 by card and 400 by a PARTIAL voucher holding 400
        CreateOrderPaidByCardAndVoucher(SalesHeader, Voucher, _VoucherTypePartial.Code, 400, 400, 400, 400, 0);
        // [GIVEN] The ecommerce capture redeemed the whole voucher, which archived it
        FindOrderVoucherSalesLine(SalesHeader, NpRvSalesLine);
        VoucherPaymentLine.Get(Database::"Sales Header", SalesHeader."Document Type", SalesHeader."No.", NpRvSalesLine."Document Line No.");
        NpRvVoucherMgt.PostIncEcomPayment(NpRvSalesLine, VoucherPaymentLine);
        _Assert.IsFalse(Voucher.Get(Voucher."No."), 'The capture must have used up and archived the voucher for this scenario.');
        // [GIVEN] Only the first line is shipped and invoiced
        SetLinesToPost(SalesHeader, 1);

        // [WHEN] The order is posted
        InvoiceNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] The invoice carries 400 of the captured voucher payment and nothing of the card
        _Assert.AreEqual(400, InvoicePaymentAmount(InvoiceNo, "NPR Magento Payment Type"::Voucher), 'The captured voucher payment must pay the first invoice.');
        _Assert.AreEqual(0, InvoicePaymentAmount(InvoiceNo, "NPR Magento Payment Type"::"Payment Method"), 'The card pays nothing on an invoice the captured voucher covers.');
        // [THEN] The voucher is not redeemed again on the invoice and the customer owes nothing
        _Assert.AreEqual(0, VoucherPaymentEntryAmount(Voucher."No.", InvoiceNo), 'A voucher redeemed at capture must not be redeemed again on the invoice.');
        _Assert.AreEqual(0, CustomerBalance(SalesHeader."Bill-to Customer No."), 'The invoice must be fully paid by its share of the payments.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CardRebalanceOnALaterInvoiceMeasuresWhatIsLeftToInvoice()
    var
        SalesHeader: Record "Sales Header";
        Voucher: Record "NPR NpRv Voucher";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] On a later partial invoice the release-time rebalance gives the card only what is left to invoice after the vouchers, not what the whole order total would leave it.
        Initialize();

        // [GIVEN] The new voucher calculation on release is on, as in production
        SetNewVoucherCalculation(true);
        // [GIVEN] An order of 400 + 300 + 100, paid 500 by a PARTIAL voucher and 400 by card, released and with the 400 line invoiced, so the voucher keeps 100 and the card 300 of its 400 requested
        CreateOrderWithFirstLineInvoicedByVoucher(SalesHeader, Voucher);
        // [GIVEN] The 300 line is shipped and invoiced next
        SetLinesToPost(SalesHeader, 2);

        // [WHEN] The order is posted again
        InvoiceNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] The invoice takes the voucher's 100 and 200 from the card
        _Assert.AreEqual(100, InvoicePaymentAmount(InvoiceNo, "NPR Magento Payment Type"::Voucher), 'The voucher must pay what it has left first.');
        _Assert.AreEqual(200, InvoicePaymentAmount(InvoiceNo, "NPR Magento Payment Type"::"Payment Method"), 'The card must pay what the voucher leaves of the invoice.');
        // [THEN] The card keeps exactly the 100 of the line still to invoice, not the 200 the whole order total would leave it
        _Assert.AreEqual(100, OrderPaymentAmount(SalesHeader, "NPR Magento Payment Type"::"Payment Method"), 'The rebalance must measure the card against what is left to invoice.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PaymentsAboveWhatIsLeftToInvoiceStopPosting()
    var
        SalesHeader: Record "Sales Header";
        Voucher: Record "NPR NpRv Voucher";
    begin
        // [SCENARIO] After a partial invoice, payments that exceed what is left to invoice stop posting, the same way payments above the order total do before the first invoice.
        Initialize();

        // [GIVEN] The new voucher calculation on release is on, as in production
        SetNewVoucherCalculation(true);
        // [GIVEN] An order of 400 + 300 + 100, paid 500 by a PARTIAL voucher and 400 by card, released and with the 400 line invoiced, so the voucher keeps 100 and the card 300
        CreateOrderWithFirstLineInvoicedByVoucher(SalesHeader, Voucher);
        // [GIVEN] The order is reopened and its 100 line removed, so 300 is left to invoice against 400 of payments
        _LibrarySales.ReopenSalesDocument(SalesHeader);
        DeleteLastItemLine(SalesHeader);

        // [WHEN] The rest of the order is posted
        asserterror _LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Posting stops because the payments exceed what is left to invoice
        _Assert.ExpectedError('Order Amount 300 is lower than Payment Amount 400');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CapturedVoucherAboveWhatIsLeftToInvoiceStopsPosting()
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        SalesHeader: Record "Sales Header";
        Voucher: Record "NPR NpRv Voucher";
        VoucherPaymentLine: Record "NPR Magento Payment Line";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        // [SCENARIO] A gift card the ecommerce capture redeemed for more than is left on the order stops posting, rather than the excess being left behind on the order.
        Initialize();

        // [GIVEN] The new voucher calculation on release is on, as in production
        SetNewVoucherCalculation(true);
        // [GIVEN] An order of 300 + 100, paid 400 by a PARTIAL voucher holding 400
        CreateOrderPaidByCardAndVoucher(SalesHeader, Voucher, _VoucherTypePartial.Code, 400, 0, 300, 100, 0);
        // [GIVEN] The ecommerce capture redeemed the whole voucher, which archived it
        FindOrderVoucherSalesLine(SalesHeader, NpRvSalesLine);
        VoucherPaymentLine.Get(Database::"Sales Header", SalesHeader."Document Type", SalesHeader."No.", NpRvSalesLine."Document Line No.");
        NpRvVoucherMgt.PostIncEcomPayment(NpRvSalesLine, VoucherPaymentLine);
        // [GIVEN] The 100 line is removed, so 300 is left to invoice against 400 captured
        DeleteLastItemLine(SalesHeader);

        // [WHEN] The order is posted
        asserterror _LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Posting stops because the captured payment exceeds what is left to invoice
        _Assert.ExpectedError('Order Amount 300 is lower than Payment Amount 400');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreditMemoForAnInvoicePaidByVoucherAndCardReversesBoth()
    var
        CreditMemoHeader: Record "Sales Header";
        GLSetup: Record "General Ledger Setup";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Voucher: Record "NPR NpRv Voucher";
        CopyDocMgt: Codeunit "Copy Document Mgt.";
        CreditMemoNo: Code[20];
        SecondInvoiceNo: Code[20];
        OrderNo: Code[20];
        MarkCrMemosAsCorrections: Boolean;
    begin
        // [SCENARIO] A corrective credit memo for a partial invoice paid partly by the voucher and partly by card refunds the card share and gives exactly the voucher share back to the voucher.
        Initialize();

        // [GIVEN] The new voucher calculation on release is on, as in production
        SetNewVoucherCalculation(true);
        // [GIVEN] Credit memos copied from an invoice are posted as corrections
        GLSetup.Get();
        MarkCrMemosAsCorrections := GLSetup."Mark Cr. Memos as Corrections";
        GLSetup."Mark Cr. Memos as Corrections" := true;
        GLSetup.Modify();
        // [GIVEN] An order of 400.98 + 399.96, paid 0.94 by card and 800 by a PARTIAL voucher holding 1000
        CreateOrderPaidByCardAndVoucher(SalesHeader, Voucher, _VoucherTypePartial.Code, 1000, 0.94, 400.98, 399.96, 0);
        OrderNo := SalesHeader."No.";
        // [GIVEN] Both lines invoiced separately, so the second invoice is paid 399.02 by the voucher and 0.94 by card
        SetLinesToPost(SalesHeader, 1);
        _LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesHeader.Get(SalesHeader."Document Type"::Order, OrderNo);
        SetLinesToPost(SalesHeader, 2);
        SecondInvoiceNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);
        // [GIVEN] A corrective credit memo copied from the second invoice
        SalesInvoiceHeader.Get(SecondInvoiceNo);
        CreditMemoHeader."Document Type" := CreditMemoHeader."Document Type"::"Credit Memo";
        CreditMemoHeader.SetAllowSelectNoSeries();
        CreditMemoHeader.Insert(true);
        CopyDocMgt.SetPropertiesForCreditMemoCorrection();
        CopyDocMgt.CopySalesDocForInvoiceCancelling(SalesInvoiceHeader."No.", CreditMemoHeader);
        CreditMemoHeader.Find();
        _Assert.IsTrue(CreditMemoHeader.Correction, 'The credit memo must be a correction for this scenario.');

        // [WHEN] The credit memo is posted
        CreditMemoNo := _LibrarySales.PostSalesDocument(CreditMemoHeader, true, true);

        // [THEN] The credit memo refunds 0.94 to the card and 399.02 to the voucher
        _Assert.AreEqual(0.94, PostedPaymentAmount(Database::"Sales Cr.Memo Header", CreditMemoNo, "NPR Magento Payment Type"::"Payment Method"), 'The card must get back its share of the invoice.');
        _Assert.AreEqual(399.02, PostedPaymentAmount(Database::"Sales Cr.Memo Header", CreditMemoNo, "NPR Magento Payment Type"::Voucher), 'The voucher must get back its share of the invoice.');
        // [THEN] The voucher holds the 399.02 again on top of the 200 the order never used
        Voucher.CalcFields(Amount);
        _Assert.AreEqual(599.02, Voucher.Amount, 'The correction must give back exactly the voucher share of the invoice.');

        GLSetup.Get();
        GLSetup."Mark Cr. Memos as Corrections" := MarkCrMemosAsCorrections;
        GLSetup.Modify();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ShopifyGiftCardIsSplitOverPartialInvoices()
    var
        SalesHeader: Record "Sales Header";
        Voucher: Record "NPR NpRv Voucher";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] A voucher type with the SHOPIFY apply payment module is split over partial invoices like a PARTIAL one.
        Initialize();

        // [GIVEN] The new voucher calculation on release is on, as in production
        SetNewVoucherCalculation(true);
        // [GIVEN] An order of 400.98 + 399.96, paid 0.94 by card and 800 by a SHOPIFY gift card holding 800
        CreateOrderPaidByCardAndVoucher(SalesHeader, Voucher, _VoucherTypeShopify.Code, 800, 0.94, 400.98, 399.96, 0);
        // [GIVEN] Only the first line is shipped and invoiced
        SetLinesToPost(SalesHeader, 1);

        // [WHEN] The order is posted
        InvoiceNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] The gift card pays the invoice and keeps 399.02 reserved for the rest of the order
        _Assert.AreEqual(-400.98, VoucherPaymentEntryAmount(Voucher."No.", InvoiceNo), 'The gift card must be redeemed by the invoice share only.');
        Voucher.CalcFields(Amount, "Reserved Amount");
        _Assert.AreEqual(399.02, Voucher.Amount, 'The gift card must keep what the first invoice did not use.');
        _Assert.AreEqual(399.02, Voucher."Reserved Amount", 'The remainder must stay reserved for the order.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CustomModuleDeclaredThroughEventIsSplitOverPartialInvoices()
    var
        SalesHeader: Record "Sales Header";
        Voucher: Record "NPR NpRv Voucher";
        CustomPaymentModule: Codeunit "NPR Custom Voucher Pay. Module";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] A voucher type whose apply payment module is declared partial through OnSupportsPartialPayment is split over partial invoices like a PARTIAL one.
        Initialize();

        // [GIVEN] The new voucher calculation on release is on, as in production
        SetNewVoucherCalculation(true);
        // [GIVEN] A custom apply payment module that declares partial payment support through OnSupportsPartialPayment
        BindSubscription(CustomPaymentModule);
        // [GIVEN] An order of 400.98 + 399.96, paid 0.94 by card and 800 by a voucher of that module
        CreateOrderPaidByCardAndVoucher(SalesHeader, Voucher, _VoucherTypeCustom.Code, 1000, 0.94, 400.98, 399.96, 0);
        // [GIVEN] Only the first line is shipped and invoiced
        SetLinesToPost(SalesHeader, 1);

        // [WHEN] The order is posted
        InvoiceNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] The voucher is redeemed by the invoice amount and the rest stays reserved
        _Assert.AreEqual(-400.98, VoucherPaymentEntryAmount(Voucher."No.", InvoiceNo), 'The voucher must be redeemed by the invoice share only.');
        Voucher.CalcFields("Reserved Amount");
        _Assert.AreEqual(399.02, Voucher."Reserved Amount", 'The remainder must stay reserved on the voucher.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PartialInvoiceWithNewVoucherCalculationOff()
    var
        SalesHeader: Record "Sales Header";
        Voucher: Record "NPR NpRv Voucher";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] With the new voucher calculation off, a partial invoice still redeems only its share of the PARTIAL voucher.
        Initialize();

        // [GIVEN] The new voucher calculation on release is off
        SetNewVoucherCalculation(false);
        // [GIVEN] An order of 400.98 + 399.96, paid 0.94 by card and 800 by a PARTIAL voucher holding 1000
        CreateOrderPaidByCardAndVoucher(SalesHeader, Voucher, _VoucherTypePartial.Code, 1000, 0.94, 400.98, 399.96, 0);
        // [GIVEN] Only the first line is shipped and invoiced
        SetLinesToPost(SalesHeader, 1);

        // [WHEN] The order is posted
        InvoiceNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] The voucher is redeemed by the invoice amount and the rest stays reserved
        _Assert.AreEqual(-400.98, VoucherPaymentEntryAmount(Voucher."No.", InvoiceNo), 'The voucher must be redeemed by the invoice share only.');
        Voucher.CalcFields("Reserved Amount");
        _Assert.AreEqual(399.02, Voucher."Reserved Amount", 'The remainder must stay reserved on the voucher.');
        _Assert.AreEqual(0, CustomerBalance(SalesHeader."Bill-to Customer No."), 'The invoice must be fully paid by its share of the payments.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ForeignCurrencyPartialInvoiceLeavesTheRoundingToTheLastInvoice()
    var
        SalesHeader: Record "Sales Header";
        Voucher: Record "NPR NpRv Voucher";
        FirstInvoiceNo: Code[20];
        SecondInvoiceNo: Code[20];
        OrderNo: Code[20];
    begin
        // [SCENARIO] In a foreign currency order, a partial invoice that leaves a few cents of the voucher payment on the order redeems only its own share, so the last invoice can still redeem the rest.
        Initialize();

        // [GIVEN] The new voucher calculation on release is on, as in production
        SetNewVoucherCalculation(true);
        // [GIVEN] An order in a foreign currency at an exchange rate of 1, of 99.99 + 0.01, paid 100 by a PARTIAL voucher holding 100
        CreateOrderPaidByCardAndVoucher(SalesHeader, Voucher, _VoucherTypePartial.Code, 100, 0, 99.99, 0.01, 0, CreateForeignCurrency());
        OrderNo := SalesHeader."No.";
        // [GIVEN] The first line has been invoiced, within the 0.02 rounding tolerance of the whole voucher
        SetLinesToPost(SalesHeader, 1);
        FirstInvoiceNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);
        // [GIVEN] The second line is shipped and invoiced next
        SalesHeader.Get(SalesHeader."Document Type"::Order, OrderNo);
        SetLinesToPost(SalesHeader, 2);

        // [WHEN] The order is posted again
        SecondInvoiceNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] The first invoice redeemed only its 99.99 and the second the remaining 0.01
        _Assert.AreEqual(-99.99, VoucherPaymentEntryAmount(Voucher."No.", FirstInvoiceNo), 'A partial invoice must not absorb the rounding tolerance while part of the voucher payment stays on the order.');
        _Assert.AreEqual(-0.01, VoucherPaymentEntryAmount(Voucher."No.", SecondInvoiceNo), 'The last invoice must redeem what is left of the voucher payment.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CardOnlyPartialInvoiceAfterTheVoucherIsUsedUp()
    var
        SalesHeader: Record "Sales Header";
        Voucher: Record "NPR NpRv Voucher";
        SecondInvoiceNo: Code[20];
        OrderNo: Code[20];
    begin
        // [SCENARIO] Once the first invoice used up the voucher, a later partial invoice is paid by the card alone and is not blocked by the spent voucher line.
        Initialize();

        // [GIVEN] The new voucher calculation on release is on, as in production
        SetNewVoucherCalculation(true);
        // [GIVEN] An order of 400.98 + 200 + 199.96, paid 500.94 by card and 300 by a PARTIAL voucher holding 300
        CreateOrderPaidByCardAndVoucher(SalesHeader, Voucher, _VoucherTypePartial.Code, 300, 500.94, 400.98, 200, 199.96);
        OrderNo := SalesHeader."No.";
        // [GIVEN] The first line has been invoiced, using up the voucher
        SetLinesToPost(SalesHeader, 1);
        _LibrarySales.PostSalesDocument(SalesHeader, true, true);
        // [GIVEN] The second line is shipped and invoiced next, while the third stays open
        SalesHeader.Get(SalesHeader."Document Type"::Order, OrderNo);
        SetLinesToPost(SalesHeader, 2);

        // [WHEN] The order is posted again
        SecondInvoiceNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] The card pays the whole second invoice and no voucher is redeemed on it
        _Assert.AreEqual(200, InvoicePaymentAmount(SecondInvoiceNo, "NPR Magento Payment Type"::"Payment Method"), 'The card must pay the invoice once the voucher is used up.');
        _Assert.AreEqual(0, InvoicePaymentAmount(SecondInvoiceNo, "NPR Magento Payment Type"::Voucher), 'A used-up voucher must not pay anything more.');
        _Assert.AreEqual(0, VoucherPaymentEntryAmount(Voucher."No.", SecondInvoiceNo), 'A used-up voucher must not be redeemed again.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WholeOrderInvoicedAtOnceIsUnchanged()
    var
        SalesHeader: Record "Sales Header";
        Voucher: Record "NPR NpRv Voucher";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] An order paid by a PARTIAL voucher and a card that is invoiced in one go still carries both payments in full on the one invoice.
        Initialize();

        // [GIVEN] The new voucher calculation on release is on, as in production
        SetNewVoucherCalculation(true);
        // [GIVEN] An order of 400.98 + 399.96, paid 0.94 by card and 800 by a PARTIAL voucher holding 1000
        CreateOrderPaidByCardAndVoucher(SalesHeader, Voucher, _VoucherTypePartial.Code, 1000, 0.94, 400.98, 399.96, 0);

        // [WHEN] The whole order is shipped and invoiced
        InvoiceNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] The invoice carries the whole voucher payment and the whole card payment
        _Assert.AreEqual(800, InvoicePaymentAmount(InvoiceNo, "NPR Magento Payment Type"::Voucher), 'The invoice must carry the whole voucher payment.');
        _Assert.AreEqual(0.94, InvoicePaymentAmount(InvoiceNo, "NPR Magento Payment Type"::"Payment Method"), 'The invoice must carry the whole card payment.');
        // [THEN] The voucher is redeemed by 800, keeps 200 and nothing stays reserved
        _Assert.AreEqual(-800, VoucherPaymentEntryAmount(Voucher."No.", InvoiceNo), 'The voucher must be redeemed by the whole payment.');
        Voucher.CalcFields(Amount, "Reserved Amount");
        _Assert.AreEqual(200, Voucher.Amount, 'The voucher must keep the amount the order did not use.');
        _Assert.AreEqual(0, Voucher."Reserved Amount", 'Nothing may stay reserved once the order is invoiced.');
        _Assert.AreEqual(0, CustomerBalance(SalesHeader."Bill-to Customer No."), 'The invoice must be fully paid.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PartialInvoiceIsStillBlockedForDefaultVoucher()
    var
        SalesHeader: Record "Sales Header";
        Voucher: Record "NPR NpRv Voucher";
    begin
        // [SCENARIO] A voucher type with the DEFAULT apply payment module, which issues a return voucher for what is left, still blocks partial invoicing.
        Initialize();

        // [GIVEN] The new voucher calculation on release is on, as in production
        SetNewVoucherCalculation(true);
        // [GIVEN] An order of 400.98 + 399.96, paid 0.94 by card and 800 by a DEFAULT voucher holding 800
        CreateOrderPaidByCardAndVoucher(SalesHeader, Voucher, _VoucherTypeDefault.Code, 800, 0.94, 400.98, 399.96, 0);
        // [GIVEN] Only the first line is shipped and invoiced
        SetLinesToPost(SalesHeader, 1);

        // [WHEN] The order is posted
        asserterror _LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Posting fails with the partial posting error
        _Assert.ExpectedError('Partial posting is not allowed when vouchers are in use');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreditMemoForFirstPartialInvoiceRefundsOnlyItsVoucherShare()
    var
        CreditMemoHeader: Record "Sales Header";
        GLSetup: Record "General Ledger Setup";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        CopyDocMgt: Codeunit "Copy Document Mgt.";
        CreditMemoNo: Code[20];
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] A credit memo for the first partial invoice refunds only that invoice's share of the voucher payment, while the rest of the order's voucher payment stays reserved.
        Initialize();

        // [GIVEN] The new voucher calculation on release is on, as in production
        SetNewVoucherCalculation(true);
        // [GIVEN] Credit memos copied from an invoice are not posted as corrections, so the refund is issued as a return voucher
        GLSetup.Get();
        GLSetup."Mark Cr. Memos as Corrections" := false;
        GLSetup.Modify();
        // [GIVEN] An order of 400.98 + 399.96, paid 0.94 by card and 800 by a PARTIAL voucher holding 1000
        CreateOrderPaidByCardAndVoucher(SalesHeader, Voucher, _VoucherTypePartial.Code, 1000, 0.94, 400.98, 399.96, 0);
        // [GIVEN] The first line has been shipped and invoiced
        SetLinesToPost(SalesHeader, 1);
        InvoiceNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);
        // [GIVEN] A credit memo copied from that invoice
        SalesInvoiceHeader.Get(InvoiceNo);
        CreditMemoHeader."Document Type" := CreditMemoHeader."Document Type"::"Credit Memo";
        CreditMemoHeader.SetAllowSelectNoSeries();
        CreditMemoHeader.Insert(true);
        CopyDocMgt.SetPropertiesForCreditMemoCorrection();
        CopyDocMgt.CopySalesDocForInvoiceCancelling(SalesInvoiceHeader."No.", CreditMemoHeader);

        // [WHEN] The credit memo is posted
        CreditMemoNo := _LibrarySales.PostSalesDocument(CreditMemoHeader, true, true);

        // [THEN] The credit memo refunds the 400.98 the invoice took from the voucher, as a return voucher
        VoucherEntry.SetRange("Entry Type", VoucherEntry."Entry Type"::"Issue Voucher");
        VoucherEntry.SetRange("Document Type", VoucherEntry."Document Type"::"Credit Memo");
        VoucherEntry.SetRange("Document No.", CreditMemoNo);
        VoucherEntry.CalcSums(Amount);
        _Assert.AreEqual(400.98, VoucherEntry.Amount, 'The credit memo must refund exactly the voucher share of the invoice.');
        // [THEN] The original voucher is untouched and the order's 399.02 stays reserved on it
        Voucher.CalcFields(Amount, "Reserved Amount");
        _Assert.AreEqual(599.02, Voucher.Amount, 'The credit memo must not touch the rest of the original voucher.');
        _Assert.AreEqual(399.02, Voucher."Reserved Amount", 'The order voucher payment must stay reserved for its next invoice.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CorrectiveCreditMemoGivesTheInvoiceShareBackToTheVoucher()
    var
        CreditMemoHeader: Record "Sales Header";
        GLSetup: Record "General Ledger Setup";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Voucher: Record "NPR NpRv Voucher";
        CopyDocMgt: Codeunit "Copy Document Mgt.";
        InvoiceNo: Code[20];
        MarkCrMemosAsCorrections: Boolean;
    begin
        // [SCENARIO] A corrective credit memo for the first partial invoice gives exactly that invoice's share back to the original voucher, while the rest of the order's voucher payment stays reserved.
        Initialize();

        // [GIVEN] The new voucher calculation on release is on, as in production
        SetNewVoucherCalculation(true);
        // [GIVEN] Credit memos copied from an invoice are posted as corrections
        GLSetup.Get();
        MarkCrMemosAsCorrections := GLSetup."Mark Cr. Memos as Corrections";
        GLSetup."Mark Cr. Memos as Corrections" := true;
        GLSetup.Modify();
        // [GIVEN] An order of 400.98 + 399.96, paid 0.94 by card and 800 by a PARTIAL voucher holding 1000
        CreateOrderPaidByCardAndVoucher(SalesHeader, Voucher, _VoucherTypePartial.Code, 1000, 0.94, 400.98, 399.96, 0);
        // [GIVEN] The first line has been shipped and invoiced
        SetLinesToPost(SalesHeader, 1);
        InvoiceNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);
        // [GIVEN] A corrective credit memo copied from that invoice
        SalesInvoiceHeader.Get(InvoiceNo);
        CreditMemoHeader."Document Type" := CreditMemoHeader."Document Type"::"Credit Memo";
        CreditMemoHeader.SetAllowSelectNoSeries();
        CreditMemoHeader.Insert(true);
        CopyDocMgt.SetPropertiesForCreditMemoCorrection();
        CopyDocMgt.CopySalesDocForInvoiceCancelling(SalesInvoiceHeader."No.", CreditMemoHeader);
        CreditMemoHeader.Find();
        _Assert.IsTrue(CreditMemoHeader.Correction, 'The credit memo must be a correction for this scenario.');

        // [WHEN] The credit memo is posted
        _LibrarySales.PostSalesDocument(CreditMemoHeader, true, true);

        // [THEN] The voucher gets back the 400.98 of the first invoice and the order's 399.02 stays reserved
        Voucher.CalcFields(Amount, "Reserved Amount");
        _Assert.AreEqual(1000, Voucher.Amount, 'The correction must give back exactly the share the invoice redeemed.');
        _Assert.AreEqual(399.02, Voucher."Reserved Amount", 'The order voucher payment must stay reserved for its next invoice.');

        GLSetup.Get();
        GLSetup."Mark Cr. Memos as Corrections" := MarkCrMemosAsCorrections;
        GLSetup.Modify();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PartialVoucherCutOnReleaseKeepsItsStoreCurrencyAmountInStep()
    var
        SalesHeader: Record "Sales Header";
        Voucher: Record "NPR NpRv Voucher";
    begin
        // [SCENARIO] When releasing a foreign currency order cuts a PARTIAL voucher payment, its store currency amount and the voucher's reservation are cut in the same proportion.
        Initialize();

        // [GIVEN] The new voucher calculation on release is on, as in production
        SetNewVoucherCalculation(true);
        // [GIVEN] A foreign currency order of 50 + 30 + 20, paid 100 by a PARTIAL voucher whose payment line holds 746.00 in the local store currency
        CreateForeignCurrencyOrderPaidByVoucher(SalesHeader, Voucher, _VoucherTypePartial.Code);
        // [GIVEN] The 20 line is removed, so the voucher only has 80 left to pay
        DeleteLastItemLine(SalesHeader);

        // [WHEN] The order is released
        _LibrarySales.ReleaseSalesDocument(SalesHeader);

        // [THEN] The voucher payment is cut to 80 and its store currency amount to 596.80
        _Assert.AreEqual(80, OrderPaymentAmount(SalesHeader, "NPR Magento Payment Type"::Voucher), 'The voucher payment must be cut to the order total.');
        _Assert.AreEqual(596.80, OrderStoreCurrencyAmount(SalesHeader, "NPR Magento Payment Type"::Voucher), 'The store currency amount must be cut with the payment.');
        // [THEN] The voucher is reserved for 596.80
        Voucher.CalcFields("Reserved Amount");
        _Assert.AreEqual(596.80, Voucher."Reserved Amount", 'The reservation must follow the cut store currency amount.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PartialInvoiceAfterAVoucherCutRedeemsItsStoreCurrencyShare()
    var
        SalesHeader: Record "Sales Header";
        Voucher: Record "NPR NpRv Voucher";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] A partial invoice of a foreign currency order whose voucher payment was cut on release redeems the invoice's share of the cut store currency amount.
        Initialize();

        // [GIVEN] The new voucher calculation on release is on, as in production
        SetNewVoucherCalculation(true);
        // [GIVEN] A foreign currency order of 50 + 30 + 20, paid 100 by a PARTIAL voucher whose payment line holds 746.00 in the local store currency
        CreateForeignCurrencyOrderPaidByVoucher(SalesHeader, Voucher, _VoucherTypePartial.Code);
        // [GIVEN] The 20 line is removed and the order released, which cuts the voucher payment to 80
        DeleteLastItemLine(SalesHeader);
        _LibrarySales.ReleaseSalesDocument(SalesHeader);
        // [GIVEN] Only the 50 line is shipped and invoiced
        SetLinesToPost(SalesHeader, 1);

        // [WHEN] The order is posted
        InvoiceNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] The invoice carries 373.00 of store currency amount and redeems 373.00 from the voucher
        _Assert.AreEqual(373, PostedStoreCurrencyAmount(Database::"Sales Invoice Header", InvoiceNo, "NPR Magento Payment Type"::Voucher), 'The invoice must carry its share of the cut store currency amount.');
        _Assert.AreEqual(-373, VoucherPaymentEntryAmount(Voucher."No.", InvoiceNo), 'The invoice must redeem its share of the cut store currency amount.');
        // [THEN] The rest of the cut payment, 223.80, stays reserved
        Voucher.CalcFields("Reserved Amount");
        _Assert.AreEqual(223.80, Voucher."Reserved Amount", 'The rest of the cut payment must stay reserved.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PartialVoucherCutWithNewVoucherCalculationOffKeepsItsStoreCurrencyAmountInStep()
    var
        SalesHeader: Record "Sales Header";
        Voucher: Record "NPR NpRv Voucher";
    begin
        // [SCENARIO] With the new voucher calculation off, the PARTIAL module's cut of a foreign currency voucher payment also cuts its store currency amount in the same proportion.
        Initialize();

        // [GIVEN] The new voucher calculation on release is off
        SetNewVoucherCalculation(false);
        // [GIVEN] A foreign currency order of 50 + 30 + 20, paid 100 by a PARTIAL voucher whose payment line holds 746.00 in the local store currency
        CreateForeignCurrencyOrderPaidByVoucher(SalesHeader, Voucher, _VoucherTypePartial.Code);
        // [GIVEN] The 20 line is removed, so the voucher only has 80 left to pay
        DeleteLastItemLine(SalesHeader);

        // [WHEN] The order is released
        _LibrarySales.ReleaseSalesDocument(SalesHeader);

        // [THEN] The voucher payment is cut to 80 and its store currency amount to 596.80
        _Assert.AreEqual(80, OrderPaymentAmount(SalesHeader, "NPR Magento Payment Type"::Voucher), 'The voucher payment must be cut by what the order no longer needs.');
        _Assert.AreEqual(596.80, OrderStoreCurrencyAmount(SalesHeader, "NPR Magento Payment Type"::Voucher), 'The store currency amount must be cut with the payment.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DefaultVoucherSetToItsAvailableAmountTakesItInStoreCurrency()
    var
        SalesHeader: Record "Sales Header";
        Voucher: Record "NPR NpRv Voucher";
    begin
        // [SCENARIO] When releasing a foreign currency order raises a DEFAULT voucher payment to the voucher's whole available amount, the store currency amount becomes exactly that available amount.
        Initialize();

        // [GIVEN] The new voucher calculation on release is on, as in production
        SetNewVoucherCalculation(true);
        // [GIVEN] A foreign currency order of 50 + 30 + 20, paid 100 by a DEFAULT voucher holding 100, whose payment line holds 746.00 in the local store currency
        CreateOrderPaidByCardAndVoucher(SalesHeader, Voucher, _VoucherTypeDefault.Code, 100, 0, 50, 30, 20, CreateForeignCurrency());
        SetStoreCurrencyRate(SalesHeader, "NPR Magento Payment Type"::Voucher, 7.46);
        // [GIVEN] The voucher is topped up by 900, so 1000 of it is available to the order
        TopUpVoucher(Voucher."No.", 900);

        // [WHEN] The order is released
        _LibrarySales.ReleaseSalesDocument(SalesHeader);

        // [THEN] The store currency amount is the voucher's available 1000.00
        _Assert.AreEqual(1000, OrderStoreCurrencyAmount(SalesHeader, "NPR Magento Payment Type"::Voucher), 'The store currency amount must be the voucher amount the payment now takes.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DefaultVoucherRaisedOnReleaseIsRedeemedForItsAvailableAmount()
    var
        SalesHeader: Record "Sales Header";
        Voucher: Record "NPR NpRv Voucher";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] A DEFAULT voucher payment that releasing a foreign currency order raised to the voucher's whole available amount is posted and redeemed for exactly that amount.
        Initialize();

        // [GIVEN] The new voucher calculation on release is on, as in production
        SetNewVoucherCalculation(true);
        // [GIVEN] A foreign currency order of 50 + 30 + 20, paid 100 by a DEFAULT voucher holding 100, whose payment line holds 746.00 in the local store currency
        CreateOrderPaidByCardAndVoucher(SalesHeader, Voucher, _VoucherTypeDefault.Code, 100, 0, 50, 30, 20, CreateForeignCurrency());
        SetStoreCurrencyRate(SalesHeader, "NPR Magento Payment Type"::Voucher, 7.46);
        // [GIVEN] The voucher is topped up by 900 and the order released, which raises the payment to the 1000 now available
        TopUpVoucher(Voucher."No.", 900);
        _LibrarySales.ReleaseSalesDocument(SalesHeader);

        // [WHEN] The order is posted
        InvoiceNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] The voucher is redeemed for its 1000.00, not for the requested rate applied to the raised payment
        _Assert.AreEqual(-1000, VoucherPaymentEntryAmount(Voucher."No.", InvoiceNo), 'The voucher must be redeemed for the amount the payment took.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreditMemoForAForeignCurrencyInvoiceIssuesTheStoreCurrencyAmountAsAReturnVoucher()
    var
        CreditMemoHeader: Record "Sales Header";
        GLSetup: Record "General Ledger Setup";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        CopyDocMgt: Codeunit "Copy Document Mgt.";
        CreditMemoNo: Code[20];
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] A credit memo for a foreign currency invoice paid by a voucher whose payment line holds a local store currency amount issues that amount as a return voucher.
        Initialize();

        // [GIVEN] The new voucher calculation on release is on, as in production
        SetNewVoucherCalculation(true);
        // [GIVEN] Credit memos copied from an invoice are not posted as corrections, so the refund is issued as a return voucher
        GLSetup.Get();
        GLSetup."Mark Cr. Memos as Corrections" := false;
        GLSetup.Modify();
        // [GIVEN] A foreign currency order of 50 + 30 + 20, paid 100 by a PARTIAL voucher whose payment line holds 746.00 in the local store currency, invoiced in full
        CreateForeignCurrencyOrderPaidByVoucher(SalesHeader, Voucher, _VoucherTypePartial.Code);
        InvoiceNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);
        // [GIVEN] A credit memo copied from that invoice
        SalesInvoiceHeader.Get(InvoiceNo);
        CreditMemoHeader."Document Type" := CreditMemoHeader."Document Type"::"Credit Memo";
        CreditMemoHeader.SetAllowSelectNoSeries();
        CreditMemoHeader.Insert(true);
        CopyDocMgt.SetPropertiesForCreditMemoCorrection();
        CopyDocMgt.CopySalesDocForInvoiceCancelling(SalesInvoiceHeader."No.", CreditMemoHeader);

        // [WHEN] The credit memo is posted
        CreditMemoNo := _LibrarySales.PostSalesDocument(CreditMemoHeader, true, true);

        // [THEN] A return voucher is issued for the 746.00 the invoice redeemed
        VoucherEntry.SetRange("Entry Type", VoucherEntry."Entry Type"::"Issue Voucher");
        VoucherEntry.SetRange("Document Type", VoucherEntry."Document Type"::"Credit Memo");
        VoucherEntry.SetRange("Document No.", CreditMemoNo);
        VoucherEntry.CalcSums(Amount);
        _Assert.AreEqual(746, VoucherEntry.Amount, 'The credit memo must refund the store currency amount as a return voucher.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreditMemoForAnInvoicePaidByTwoVouchersReturnsBothStoreCurrencyAmounts()
    var
        CreditMemoHeader: Record "Sales Header";
        GLSetup: Record "General Ledger Setup";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SecondVoucher: Record "NPR NpRv Voucher";
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        CopyDocMgt: Codeunit "Copy Document Mgt.";
        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
        CreditMemoNo: Code[20];
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] A credit memo for a foreign currency invoice paid by two vouchers of the same type, whose refunds are merged into one return voucher, returns the sum of both store currency amounts.
        Initialize();

        // [GIVEN] The new voucher calculation on release is on, as in production
        SetNewVoucherCalculation(true);
        // [GIVEN] Credit memos copied from an invoice are not posted as corrections, so the refund is issued as a return voucher
        GLSetup.Get();
        GLSetup."Mark Cr. Memos as Corrections" := false;
        GLSetup.Modify();
        // [GIVEN] A foreign currency order of 50 + 30 + 20, paid 60 by a PARTIAL voucher and 40 by a second PARTIAL voucher, whose payment lines hold 447.60 and 298.40 in the local store currency
        CreateOrderPaidByCardAndVoucher(SalesHeader, Voucher, _VoucherTypePartial.Code, 60, 0, 50, 30, 20, CreateForeignCurrency());
        TopUpVoucher(Voucher."No.", 387.60);
        CreateVoucher(SecondVoucher, _VoucherTypePartial.Code, 1000);
        NpRvSalesDocMgt.RedeemVoucher(SalesHeader, SecondVoucher."Reference No.");
        SetStoreCurrencyRate(SalesHeader, "NPR Magento Payment Type"::Voucher, 7.46);
        // [GIVEN] The order is invoiced in full
        InvoiceNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);
        // [GIVEN] A credit memo copied from that invoice
        SalesInvoiceHeader.Get(InvoiceNo);
        CreditMemoHeader."Document Type" := CreditMemoHeader."Document Type"::"Credit Memo";
        CreditMemoHeader.SetAllowSelectNoSeries();
        CreditMemoHeader.Insert(true);
        CopyDocMgt.SetPropertiesForCreditMemoCorrection();
        CopyDocMgt.CopySalesDocForInvoiceCancelling(SalesInvoiceHeader."No.", CreditMemoHeader);

        // [WHEN] The credit memo is posted
        CreditMemoNo := _LibrarySales.PostSalesDocument(CreditMemoHeader, true, true);

        // [THEN] The return voucher amounts to the 746.00 both vouchers paid
        VoucherEntry.SetRange("Entry Type", VoucherEntry."Entry Type"::"Issue Voucher");
        VoucherEntry.SetRange("Document Type", VoucherEntry."Document Type"::"Credit Memo");
        VoucherEntry.SetRange("Document No.", CreditMemoNo);
        VoucherEntry.CalcSums(Amount);
        _Assert.AreEqual(746, VoucherEntry.Amount, 'The credit memo must refund the store currency amounts of both vouchers.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AdjustedCardPaymentKeepsItsStoreCurrencyAmountInStep()
    var
        SalesHeader: Record "Sales Header";
        Voucher: Record "NPR NpRv Voucher";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] When posting raises a card payment that allows its amount to be adjusted up to the order total, its store currency amount is raised in the same proportion.
        Initialize();

        // [GIVEN] The new voucher calculation on release is on, as in production
        SetNewVoucherCalculation(true);
        // [GIVEN] A foreign currency order of 120, paid 80 by a card that allows adjusting its amount and holds 596.80 in the local store currency, and 20 by a PARTIAL voucher
        CreateOrderPaidByCardAndVoucher(SalesHeader, Voucher, _VoucherTypePartial.Code, 20, 80, 120, 0, 0, CreateForeignCurrency());
        SetStoreCurrencyRate(SalesHeader, "NPR Magento Payment Type"::"Payment Method", 7.46);
        AllowAdjustingCardAmount(SalesHeader);

        // [WHEN] The order is posted
        InvoiceNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] The card pays 100 on the invoice, and its store currency amount is 746.00
        _Assert.AreEqual(100, InvoicePaymentAmount(InvoiceNo, "NPR Magento Payment Type"::"Payment Method"), 'The card must be raised to what the voucher leaves of the order.');
        _Assert.AreEqual(746, PostedStoreCurrencyAmount(Database::"Sales Invoice Header", InvoiceNo, "NPR Magento Payment Type"::"Payment Method"), 'The store currency amount must be raised with the card payment.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreditMemoTakesItsStoreCurrencyShareOfALargerCardRefund()
    var
        CreditMemoHeader: Record "Sales Header";
        CreditMemoNo: Code[20];
    begin
        // [SCENARIO] A credit memo smaller than its card refund payment takes the same share of the refund's store currency amount as of its amount.
        Initialize();

        // [GIVEN] A foreign currency credit memo of 60 with a card refund of 100 that holds 746.00 in the local store currency
        CreateCreditMemoWithLargerCardRefund(CreditMemoHeader, _GLSetup."LCY Code");

        // [WHEN] The credit memo is posted
        CreditMemoNo := _LibrarySales.PostSalesDocument(CreditMemoHeader, true, true);

        // [THEN] The posted credit memo refunds 60 by card, with 447.60 of store currency amount
        _Assert.AreEqual(60, PostedPaymentAmount(Database::"Sales Cr.Memo Header", CreditMemoNo, "NPR Magento Payment Type"::"Payment Method"), 'The credit memo must take only its own amount of the card refund.');
        _Assert.AreEqual(447.60, PostedStoreCurrencyAmount(Database::"Sales Cr.Memo Header", CreditMemoNo, "NPR Magento Payment Type"::"Payment Method"), 'The credit memo must take the same share of the store currency amount.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreditMemoRoundsItsStoreCurrencyShareToTheStoreCurrency()
    var
        CreditMemoHeader: Record "Sales Header";
        StoreCurrency: Record Currency;
        LibraryERM: Codeunit "Library - ERM";
        CreditMemoNo: Code[20];
    begin
        // [SCENARIO] A credit memo's share of a larger card refund is rounded to the store currency's own rounding precision, not to cents.
        Initialize();

        // [GIVEN] A store currency whose amounts are rounded to whole units
        LibraryERM.CreateCurrency(StoreCurrency);
        StoreCurrency."Amount Rounding Precision" := 1;
        StoreCurrency.Modify();
        // [GIVEN] A foreign currency credit memo of 60 with a card refund of 100 that holds 746 in that store currency
        CreateCreditMemoWithLargerCardRefund(CreditMemoHeader, StoreCurrency.Code);

        // [WHEN] The credit memo is posted
        CreditMemoNo := _LibrarySales.PostSalesDocument(CreditMemoHeader, true, true);

        // [THEN] The posted credit memo's store currency share is 448, not 447.60
        _Assert.AreEqual(448, PostedStoreCurrencyAmount(Database::"Sales Cr.Memo Header", CreditMemoNo, "NPR Magento Payment Type"::"Payment Method"), 'The store currency share must be rounded to the store currency.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure InvoiceGivesBackTheStoreCurrencyShareOfAnEarlierPostingThatNoLongerExists()
    var
        SalesHeader: Record "Sales Header";
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] When the invoice an earlier posting named no longer exists, the card payment it took comes back to the order with its store currency share.
        Initialize();

        // [GIVEN] A foreign currency order of 100 paid 100 by card, which holds 746.00 in the local store currency
        CreateDocumentPaidByCard(SalesHeader, SalesHeader."Document Type"::Order, 100, 100, _GLSetup."LCY Code");
        // [GIVEN] An earlier posting took 60 of the card and named an invoice that no longer exists, so the line holds 40 and 298.40
        SimulateVanishedEarlierPosting(SalesHeader, 60);

        // [WHEN] The order is posted
        InvoiceNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] The invoice carries the whole card payment of 100 with its 746.00 of store currency amount
        _Assert.AreEqual(100, InvoicePaymentAmount(InvoiceNo, "NPR Magento Payment Type"::"Payment Method"), 'The share of the vanished posting must come back to the card payment.');
        _Assert.AreEqual(746, PostedStoreCurrencyAmount(Database::"Sales Invoice Header", InvoiceNo, "NPR Magento Payment Type"::"Payment Method"), 'The store currency share must come back with it.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreditMemoGivesBackTheStoreCurrencyShareOfAnEarlierPostingThatNoLongerExists()
    var
        ReturnOrderHeader: Record "Sales Header";
        CreditMemoNo: Code[20];
    begin
        // [SCENARIO] When the credit memo an earlier posting of a return order named no longer exists, the card refund it took comes back with its store currency share.
        Initialize();

        // [GIVEN] A foreign currency return order of 100 refunded 100 by card, which holds 746.00 in the local store currency
        CreateDocumentPaidByCard(ReturnOrderHeader, ReturnOrderHeader."Document Type"::"Return Order", 100, 100, _GLSetup."LCY Code");
        // [GIVEN] An earlier posting took 60 of the refund and named a credit memo that no longer exists, so the line holds 40 and 298.40
        SimulateVanishedEarlierPosting(ReturnOrderHeader, 60);

        // [WHEN] The return order is posted
        CreditMemoNo := _LibrarySales.PostSalesDocument(ReturnOrderHeader, true, true);

        // [THEN] The credit memo carries the whole card refund of 100 with its 746.00 of store currency amount
        _Assert.AreEqual(100, PostedPaymentAmount(Database::"Sales Cr.Memo Header", CreditMemoNo, "NPR Magento Payment Type"::"Payment Method"), 'The share of the vanished posting must come back to the card refund.');
        _Assert.AreEqual(746, PostedStoreCurrencyAmount(Database::"Sales Cr.Memo Header", CreditMemoNo, "NPR Magento Payment Type"::"Payment Method"), 'The store currency share must come back with it.');
    end;

    local procedure Initialize()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        NpRvRetVouchType: Record "NPR NpRv Ret. Vouch. Type";
        LibraryERM: Codeunit "Library - ERM";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        _POSSession.ClearAll();
        Clear(_POSSession);

        if _Initialized then
            exit;

        if not _GLSetup.Get() then begin
            _GLSetup.Init();
            _GLSetup.Insert();
        end;
        if _GLSetup."LCY Code" = '' then
            _GLSetup."LCY Code" := 'LCY';
        _GLSetup."Amount Rounding Precision" := 0.01;
        _GLSetup."Unit-Amount Rounding Precision" := 0.00001;
        _GLSetup.Modify();

        NPRLibraryPOSMasterData.CreatePartialVoucherType(_VoucherTypePartial, false);
        NPRLibraryPOSMasterData.CreateDefaultVoucherType(_VoucherTypeDefault, false);
        if not NpRvRetVouchType.Get(_VoucherTypeDefault.Code) then
            NPRLibraryPOSMasterData.CreateReturnVoucherType(_VoucherTypePartial.Code, _VoucherTypeDefault.Code);
        CreateShopifyVoucherType();
        CreateCustomModuleVoucherType();
        NPRLibraryPOSMasterData.CreatePOSSetup(_POSSetup);
        NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
        NPRLibraryPOSMasterData.CreatePOSStore(_POSStore, POSPostingProfile.Code);
        NPRLibraryPOSMasterData.CreatePOSUnit(_POSUnit, _POSStore.Code, POSPostingProfile.Code);
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(_Item, _POSUnit, _POSStore);
        NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_POSPaymentMethodCash, _POSPaymentMethodCash."Processing Type"::CASH, '', false);
        _CardGLAccountNo := LibraryERM.CreateGLAccountNo();

        _Initialized := true;
        Commit();
    end;

    local procedure CreateShopifyVoucherType()
    var
        VoucherModule: Record "NPR NpRv Voucher Module";
        ModulePayShopify: Codeunit "NPR NpRv Module Pay. - Shopify";
    begin
        if not VoucherModule.Get(VoucherModule.Type::"Apply Payment", ModulePayShopify.ModuleCode()) then
            ModulePayShopify.CreateShopifyRetailVoucherModule();

        _VoucherTypeShopify := _VoucherTypePartial;
        _VoucherTypeShopify.Code := 'PVI-SHOPIFY';
        _VoucherTypeShopify."Apply Payment Module" := ModulePayShopify.ModuleCode();
        if not _VoucherTypeShopify.Insert() then
            _VoucherTypeShopify.Modify();
    end;

    local procedure CreateCustomModuleVoucherType()
    var
        CustomPaymentModule: Codeunit "NPR Custom Voucher Pay. Module";
    begin
        _VoucherTypeCustom := _VoucherTypePartial;
        _VoucherTypeCustom.Code := 'PVI-CUSTOM';
        _VoucherTypeCustom."Apply Payment Module" := CustomPaymentModule.ModuleCode();
        if not _VoucherTypeCustom.Insert() then
            _VoucherTypeCustom.Modify();
    end;

    local procedure SetNewVoucherCalculation(Enabled: Boolean)
    var
        FeatureFlag: Record "NPR Feature Flag";
        NewVoucherCalculationFeatureFlagTok: Label 'newvouchercalculationonsalesorderreleasedoc', Locked = true;
    begin
        if not FeatureFlag.Get(NewVoucherCalculationFeatureFlagTok) then begin
            FeatureFlag.Name := NewVoucherCalculationFeatureFlagTok;
            FeatureFlag.Value := Format(Enabled);
            FeatureFlag.Insert();
            exit;
        end;
        FeatureFlag.Value := Format(Enabled);
        FeatureFlag.Modify();
    end;

    /// <summary>
    /// Creates an order with up to three lines, a card payment line first, as the Shopify import creates it, and then the voucher payment for what the card leaves.
    /// </summary>
    local procedure CreateOrderPaidByCardAndVoucher(var SalesHeader: Record "Sales Header"; var Voucher: Record "NPR NpRv Voucher"; VoucherTypeCode: Code[20]; VoucherBalance: Decimal; CardAmount: Decimal; Line1Amount: Decimal; Line2Amount: Decimal; Line3Amount: Decimal)
    begin
        CreateOrderPaidByCardAndVoucher(SalesHeader, Voucher, VoucherTypeCode, VoucherBalance, CardAmount, Line1Amount, Line2Amount, Line3Amount, '');
    end;

    local procedure CreateOrderPaidByCardAndVoucher(var SalesHeader: Record "Sales Header"; var Voucher: Record "NPR NpRv Voucher"; VoucherTypeCode: Code[20]; VoucherBalance: Decimal; CardAmount: Decimal; Line1Amount: Decimal; Line2Amount: Decimal; Line3Amount: Decimal; CurrencyCode: Code[10])
    var
        Customer: Record Customer;
        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
    begin
        CreateVoucher(Voucher, VoucherTypeCode, VoucherBalance);

        _LibrarySales.CreateCustomer(Customer);
        EnsureSalesPostingSetup(Customer."Gen. Bus. Posting Group", Customer."VAT Bus. Posting Group");
        _LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        SalesHeader.Validate("Currency Code", CurrencyCode);
        SalesHeader.Validate("Prices Including VAT", true);
        SalesHeader.Modify(true);
        AddItemLine(SalesHeader, Line1Amount);
        AddItemLine(SalesHeader, Line2Amount);
        AddItemLine(SalesHeader, Line3Amount);

        if CardAmount <> 0 then
            AddCardPaymentLine(SalesHeader, CardAmount);
        NpRvSalesDocMgt.RedeemVoucher(SalesHeader, Voucher."Reference No.");
        Voucher.Find();
    end;

    local procedure CreateVoucher(var Voucher: Record "NPR NpRv Voucher"; VoucherTypeCode: Code[20]; Balance: Decimal)
    var
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        Voucher.Init();
        Voucher."No." := LibraryUtility.GenerateRandomCode20(Voucher.FieldNo("No."), Database::"NPR NpRv Voucher");
        Voucher."Voucher Type" := VoucherTypeCode;
        Voucher."Reference No." := 'PVI' + Voucher."No.";
        Voucher.Description := Voucher."Reference No.";
        Voucher."Account No." := _VoucherTypePartial."Account No.";
        Voucher.Insert();

        VoucherEntry.Init();
        VoucherEntry."Entry No." := 0;
        VoucherEntry."Voucher No." := Voucher."No.";
        VoucherEntry."Voucher Type" := VoucherTypeCode;
        VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Issue Voucher";
        VoucherEntry.Amount := Balance;
        VoucherEntry."Remaining Amount" := Balance;
        VoucherEntry.Positive := true;
        VoucherEntry.Open := true;
        VoucherEntry."Posting Date" := WorkDate();
        VoucherEntry.Insert();
    end;

    /// <summary>
    /// Creates an order of 400 + 400 + 300 paid 800 by a PARTIAL voucher holding 800 and 300 by a SHOPIFY gift card holding 300.
    /// </summary>
    local procedure CreateOrderPaidByTwoVouchers(var SalesHeader: Record "Sales Header"; var Voucher: Record "NPR NpRv Voucher"; var SecondVoucher: Record "NPR NpRv Voucher")
    var
        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
    begin
        CreateOrderPaidByCardAndVoucher(SalesHeader, Voucher, _VoucherTypePartial.Code, 800, 0, 400, 400, 300);
        CreateVoucher(SecondVoucher, _VoucherTypeShopify.Code, 300);
        NpRvSalesDocMgt.RedeemVoucher(SalesHeader, SecondVoucher."Reference No.");
    end;

    local procedure DeleteLastItemLine(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.FindLast();
        SalesLine.Delete(true);
    end;

    /// <summary>
    /// Removes a voucher and its entries, as when it is used up and archived elsewhere. The order's payment line and reservation line stay.
    /// </summary>
    local procedure RemoveVoucher(VoucherNo: Code[20])
    var
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
    begin
        VoucherEntry.SetRange("Voucher No.", VoucherNo);
        VoucherEntry.DeleteAll();
        Voucher.Get(VoucherNo);
        Voucher.Delete();
    end;

    /// <summary>
    /// Takes an amount off the voucher, as a payment at a till or on another order would.
    /// </summary>
    local procedure SpendFromVoucher(VoucherNo: Code[20]; Amount: Decimal)
    var
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
    begin
        Voucher.Get(VoucherNo);
        VoucherEntry.Init();
        VoucherEntry."Entry No." := 0;
        VoucherEntry."Voucher No." := VoucherNo;
        VoucherEntry."Voucher Type" := Voucher."Voucher Type";
        VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::Payment;
        VoucherEntry.Amount := -Amount;
        VoucherEntry."Remaining Amount" := -Amount;
        VoucherEntry.Positive := false;
        VoucherEntry.Open := true;
        VoucherEntry."Posting Date" := WorkDate();
        VoucherEntry.Insert();
    end;

    local procedure AddItemLine(SalesHeader: Record "Sales Header"; AmountInclVAT: Decimal)
    var
        SalesLine: Record "Sales Line";
    begin
        if AmountInclVAT = 0 then
            exit;
        _LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, _Item."No.", 1);
        SalesLine.Validate("Unit Price", AmountInclVAT);
        SalesLine.Modify(true);
    end;

    local procedure AddCardPaymentLine(SalesHeader: Record "Sales Header"; Amount: Decimal)
    var
        PaymentLine: Record "NPR Magento Payment Line";
        LineNo: Integer;
    begin
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        if PaymentLine.FindLast() then
            LineNo := PaymentLine."Line No.";

        PaymentLine.Init();
        PaymentLine."Document Table No." := Database::"Sales Header";
        PaymentLine."Document Type" := SalesHeader."Document Type";
        PaymentLine."Document No." := SalesHeader."No.";
        PaymentLine."Line No." := LineNo + 10000;
        PaymentLine."Payment Type" := PaymentLine."Payment Type"::"Payment Method";
        PaymentLine.Description := 'Card';
        PaymentLine."Account Type" := PaymentLine."Account Type"::"G/L Account";
        PaymentLine."Account No." := _CardGLAccountNo;
        PaymentLine."No." := 'CARD-' + SalesHeader."No.";
        PaymentLine."Transaction ID" := 'TX-' + SalesHeader."No.";
        PaymentLine."Posting Date" := SalesHeader."Posting Date";
        PaymentLine.Amount := Amount;
        PaymentLine."Requested Amount" := Amount;
        PaymentLine.Insert(true);
    end;

    /// <summary>
    /// Ships and invoices only the given line of the order (1-based, in line order) and leaves the other lines for later.
    /// </summary>
    local procedure SetLinesToPost(SalesHeader: Record "Sales Header"; LineToPost: Integer)
    var
        SalesLine: Record "Sales Line";
        LineIndex: Integer;
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.FindSet(true);
        repeat
            LineIndex += 1;
            if LineIndex = LineToPost then
                SalesLine.Validate("Qty. to Ship", SalesLine."Outstanding Quantity")
            else
                SalesLine.Validate("Qty. to Ship", 0);
            SalesLine.Modify(true);
        until SalesLine.Next() = 0;
    end;

    local procedure EnsureSalesPostingSetup(GenBusPostingGroup: Code[20]; VATBusPostingGroup: Code[20])
    var
        GeneralPostingSetup: Record "General Posting Setup";
        LibraryERM: Codeunit "Library - ERM";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        GeneralPostingSetup."Gen. Bus. Posting Group" := GenBusPostingGroup;
        GeneralPostingSetup."Gen. Prod. Posting Group" := _Item."Gen. Prod. Posting Group";
        if not GeneralPostingSetup.Find() then begin
            GeneralPostingSetup.Init();
            GeneralPostingSetup.Insert();
        end;
        LibraryERM.SetGeneralPostingSetupSalesAccounts(GeneralPostingSetup);
        GeneralPostingSetup.Modify();
        NPRLibraryPOSMasterData.CreateVATPostingSetupForSaleItem(VATBusPostingGroup, _Item."VAT Prod. Posting Group");
    end;

    local procedure InvoicePaymentAmount(InvoiceNo: Code[20]; PaymentType: Enum "NPR Magento Payment Type"): Decimal
    begin
        exit(PostedPaymentAmount(Database::"Sales Invoice Header", InvoiceNo, PaymentType));
    end;

    local procedure PostedPaymentAmount(DocumentTableNo: Integer; DocumentNo: Code[20]; PaymentType: Enum "NPR Magento Payment Type"): Decimal
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.SetRange("Document Table No.", DocumentTableNo);
        PaymentLine.SetRange("Document No.", DocumentNo);
        PaymentLine.SetRange("Payment Type", PaymentType);
        PaymentLine.CalcSums(Amount);
        exit(PaymentLine.Amount);
    end;

    local procedure OrderPaymentAmount(SalesHeader: Record "Sales Header"; PaymentType: Enum "NPR Magento Payment Type"): Decimal
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.SetRange("Payment Type", PaymentType);
        PaymentLine.CalcSums(Amount);
        exit(PaymentLine.Amount);
    end;

    /// <summary>
    /// Sums the voucher's payment entries for an invoice, including those moved to the archive once the voucher was used up.
    /// </summary>
    local procedure VoucherPaymentEntryAmount(VoucherNo: Code[20]; InvoiceNo: Code[20]): Decimal
    var
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        ArchVoucherEntry: Record "NPR NpRv Arch. Voucher Entry";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        Amount: Decimal;
    begin
        VoucherEntry.SetRange("Voucher No.", VoucherNo);
        VoucherEntry.SetRange("Entry Type", VoucherEntry."Entry Type"::Payment);
        VoucherEntry.SetRange("Document Type", VoucherEntry."Document Type"::Invoice);
        VoucherEntry.SetRange("Document No.", InvoiceNo);
        VoucherEntry.CalcSums(Amount);
        Amount := VoucherEntry.Amount;

        ArchVoucher.SetRange("Arch. No.", VoucherNo);
        if ArchVoucher.FindFirst() then begin
            ArchVoucherEntry.SetRange("Arch. Voucher No.", ArchVoucher."No.");
            ArchVoucherEntry.SetRange("Entry Type", ArchVoucherEntry."Entry Type"::Payment);
            ArchVoucherEntry.SetRange("Document Type", ArchVoucherEntry."Document Type"::Invoice);
            ArchVoucherEntry.SetRange("Document No.", InvoiceNo);
            ArchVoucherEntry.CalcSums(Amount);
            Amount += ArchVoucherEntry.Amount;
        end;
        exit(Amount);
    end;

    local procedure FindOrderVoucherSalesLine(SalesHeader: Record "Sales Header"; var NpRvSalesLine: Record "NPR NpRv Sales Line")
    begin
        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Payment Line");
        NpRvSalesLine.SetRange("Document Type", SalesHeader."Document Type");
        NpRvSalesLine.SetRange("Document No.", SalesHeader."No.");
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::Payment);
        NpRvSalesLine.FindFirst();
    end;

    /// <summary>
    /// Creates an order of 400 + 300 + 100 paid 500 by a PARTIAL voucher holding 500 and 400 by card, releases it, which cuts the card to the 300 the voucher leaves while 400 stays requested, and invoices the first line, which the voucher pays alone.
    /// </summary>
    local procedure CreateOrderWithFirstLineInvoicedByVoucher(var SalesHeader: Record "Sales Header"; var Voucher: Record "NPR NpRv Voucher")
    var
        OrderNo: Code[20];
    begin
        CreateOrderPaidByCardAndVoucher(SalesHeader, Voucher, _VoucherTypePartial.Code, 500, 0, 400, 300, 100);
        AddCardPaymentLine(SalesHeader, 400);
        _LibrarySales.ReleaseSalesDocument(SalesHeader);
        OrderNo := SalesHeader."No.";
        SetLinesToPost(SalesHeader, 1);
        _LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesHeader.Get(SalesHeader."Document Type"::Order, OrderNo);
    end;

    local procedure CustomerBalance(CustomerNo: Code[20]): Decimal
    var
        Customer: Record Customer;
    begin
        Customer.Get(CustomerNo);
        Customer.CalcFields("Balance (LCY)");
        exit(Customer."Balance (LCY)");
    end;

    /// <summary>
    /// Creates a foreign currency at an exchange rate of 1, so a converted amount is not taken as precalculated.
    /// </summary>
    local procedure CreateForeignCurrency(): Code[10]
    var
        Currency: Record Currency;
        LibraryERM: Codeunit "Library - ERM";
    begin
        LibraryERM.CreateCurrency(Currency);
        Currency.InitRoundingPrecision();
        Currency.Modify();
        LibraryERM.CreateExchangeRate(Currency.Code, WorkDate(), 1, 1);
        exit(Currency.Code);
    end;

    /// <summary>
    /// Adds an amount to the voucher, as a top-up at a till would.
    /// </summary>
    local procedure TopUpVoucher(VoucherNo: Code[20]; Amount: Decimal)
    var
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
    begin
        Voucher.Get(VoucherNo);
        VoucherEntry.Init();
        VoucherEntry."Entry No." := 0;
        VoucherEntry."Voucher No." := VoucherNo;
        VoucherEntry."Voucher Type" := Voucher."Voucher Type";
        VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Top-up";
        VoucherEntry.Amount := Amount;
        VoucherEntry."Remaining Amount" := Amount;
        VoucherEntry.Positive := true;
        VoucherEntry.Open := true;
        VoucherEntry."Posting Date" := WorkDate();
        VoucherEntry.Insert();
    end;

    /// <summary>
    /// Creates a foreign currency order of 50 + 30 + 20 paid 100 by a voucher holding 1000, whose payment line holds 746.00 in the local store currency, as a Shopify order from a store whose shop currency is the local currency at a rate of 7.46.
    /// </summary>
    local procedure CreateForeignCurrencyOrderPaidByVoucher(var SalesHeader: Record "Sales Header"; var Voucher: Record "NPR NpRv Voucher"; VoucherTypeCode: Code[20])
    begin
        CreateOrderPaidByCardAndVoucher(SalesHeader, Voucher, VoucherTypeCode, 1000, 0, 50, 30, 20, CreateForeignCurrency());
        SetStoreCurrencyRate(SalesHeader, "NPR Magento Payment Type"::Voucher, 7.46);
    end;

    /// <summary>
    /// Gives each payment line of the type a store currency amount in the local currency at the given rate, as a Shopify order from a store whose shop currency is the local currency carries it.
    /// </summary>
    local procedure SetStoreCurrencyRate(SalesHeader: Record "Sales Header"; PaymentType: Enum "NPR Magento Payment Type"; StoreCurrencyRate: Decimal)
    begin
        SetStoreCurrencyRate(SalesHeader, PaymentType, StoreCurrencyRate, _GLSetup."LCY Code");
    end;

    local procedure SetStoreCurrencyRate(SalesHeader: Record "Sales Header"; PaymentType: Enum "NPR Magento Payment Type"; StoreCurrencyRate: Decimal; StoreCurrencyCode: Code[10])
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.SetRange("Payment Type", PaymentType);
        PaymentLine.FindSet(true);
        repeat
            PaymentLine."Store Currency Code" := StoreCurrencyCode;
            PaymentLine."Amount (Store Currency)" := Round(PaymentLine.Amount * StoreCurrencyRate, 0.01);
            PaymentLine."Requested Amt. (Store Curr.)" := Round(PaymentLine."Requested Amount" * StoreCurrencyRate, 0.01);
            PaymentLine.Modify();
        until PaymentLine.Next() = 0;
    end;

    /// <summary>
    /// Creates a foreign currency credit memo of 60 with a card refund of 100 that holds 746 in the given store currency.
    /// </summary>
    local procedure CreateCreditMemoWithLargerCardRefund(var CreditMemoHeader: Record "Sales Header"; StoreCurrencyCode: Code[10])
    begin
        CreateDocumentPaidByCard(CreditMemoHeader, CreditMemoHeader."Document Type"::"Credit Memo", 60, 100, StoreCurrencyCode);
    end;

    /// <summary>
    /// Creates a foreign currency document with one item line and a card payment that holds its amount at 7.46 in the given store currency.
    /// </summary>
    local procedure CreateDocumentPaidByCard(var SalesHeader: Record "Sales Header"; DocumentType: Enum "Sales Document Type"; LineAmount: Decimal; CardAmount: Decimal; StoreCurrencyCode: Code[10])
    var
        Customer: Record Customer;
    begin
        _LibrarySales.CreateCustomer(Customer);
        EnsureSalesPostingSetup(Customer."Gen. Bus. Posting Group", Customer."VAT Bus. Posting Group");
        _LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, Customer."No.");
        SalesHeader.Validate("Currency Code", CreateForeignCurrency());
        SalesHeader.Validate("Prices Including VAT", true);
        SalesHeader.Modify(true);
        AddItemLine(SalesHeader, LineAmount);
        AddCardPaymentLine(SalesHeader, CardAmount);
        SetStoreCurrencyRate(SalesHeader, "NPR Magento Payment Type"::"Payment Method", 7.46, StoreCurrencyCode);
    end;

    /// <summary>
    /// Leaves the card payment line as an earlier posting of LastAmount left it, with that posting's document no longer in the database: Amount and the store currency amount are reduced by the share it took, and Last Posting No. names a document that does not exist.
    /// </summary>
    local procedure SimulateVanishedEarlierPosting(SalesHeader: Record "Sales Header"; LastAmount: Decimal)
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.SetRange("Payment Type", PaymentLine."Payment Type"::"Payment Method");
        PaymentLine.FindFirst();
        PaymentLine.Amount -= LastAmount;
        PaymentLine."Amount (Store Currency)" -= Round(LastAmount * 7.46, 0.01);
        PaymentLine."Last Amount" := LastAmount;
        PaymentLine."Last Posting No." := 'PVI-GONE';
        PaymentLine.Modify();
    end;

    local procedure AllowAdjustingCardAmount(SalesHeader: Record "Sales Header")
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.SetRange("Payment Type", PaymentLine."Payment Type"::"Payment Method");
        PaymentLine.ModifyAll("Allow Adjust Amount", true);
    end;

    local procedure OrderStoreCurrencyAmount(SalesHeader: Record "Sales Header"; PaymentType: Enum "NPR Magento Payment Type"): Decimal
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.SetRange("Payment Type", PaymentType);
        PaymentLine.CalcSums("Amount (Store Currency)");
        exit(PaymentLine."Amount (Store Currency)");
    end;

    local procedure PostedStoreCurrencyAmount(DocumentTableNo: Integer; DocumentNo: Code[20]; PaymentType: Enum "NPR Magento Payment Type"): Decimal
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.SetRange("Document Table No.", DocumentTableNo);
        PaymentLine.SetRange("Document No.", DocumentNo);
        PaymentLine.SetRange("Payment Type", PaymentType);
        PaymentLine.CalcSums("Amount (Store Currency)");
        exit(PaymentLine."Amount (Store Currency)");
    end;
}
