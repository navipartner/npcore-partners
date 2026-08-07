codeunit 85359 "NPR POS EFT DocPayRsrv Tests"
{
    // [Feature] POS EFT document payment reservation (EFT_RESERVE_DOC_PAY) tests

    Subtype = Test;

    var
        _Initialized: Boolean;
        _POSSession: Codeunit "NPR POS Session";
        _POSSetup: Record "NPR POS Setup";
        _POSStore: Record "NPR POS Store";
        _POSUnit: Record "NPR POS Unit";
        _Salesperson: Record "Salesperson/Purchaser";
        _Customer: Record Customer;
        _Item: Record Item;
        _EFTPaymentMethod: Record "NPR POS Payment Method";
        _CashPaymentMethod: Record "NPR POS Payment Method";
        _VoucherPaymentMethod: Record "NPR POS Payment Method";
        _VoucherTypeDefault: Record "NPR NpRv Voucher Type";
        _PaymentGateway: Record "NPR Magento Payment Gateway";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FinalizePartialEFTReservationCreatesCreditSale()
    var
        SalesHeader: Record "Sales Header";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        POSEntry: Record "NPR POS Entry";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
        POSSale: Codeunit "NPR POS Sale";
        POSActEFTDocPayRsrvB: Codeunit "NPR POSActionEFTDocPayRsrvB";
        Assert: Codeunit "Assert";
        SavedRegisterNo: Code[10];
        SavedTicketNo: Code[20];
    begin
        // [Scenario] Reserving part of a sales order's amount via EFT converts the payment line into a Magento
        // reservation, creates a non-posted credit-sale POS entry linked to the order and ends & deletes the sale,
        // even though only part of the order amount was reserved (partial reservations are by design).

        // [Given] POS setup, a 100 LCY sales order and a POS sale with its reservation amount line imported
        InitializeData();
        CreateSalesOrder(SalesHeader, 100);
        StartSaleWithCustomer(POSSale, SalePOS);
        ImportReservationLine(SalePOS, SalesHeader);
        SavedRegisterNo := SalePOS."Register No.";
        SavedTicketNo := SalePOS."Sales Ticket No.";

        // [Given] A 40 LCY EFT payment line with a matching authorized EFT transaction request
        AddEFTPaymentLineWithAuth(SalePOS, 40, 'PSP-PARTIAL-40');

        // [When] Finalizing the reservation
        _POSSession.GetSale(POSSale);
        POSActEFTDocPayRsrvB.FinalizeReservation(POSSale);

        // [Then] Exactly one Magento reservation line exists on the order carrying the PSP reference and amount
        FilterMagentoPaymentLines(MagentoPaymentLine, SalesHeader);
        Assert.AreEqual(1, MagentoPaymentLine.Count(), 'Exactly one Magento reservation line expected on the order.');
        MagentoPaymentLine.FindFirst();
        Assert.AreEqual('PSP-PARTIAL-40', MagentoPaymentLine."No.", 'PSP reference expected in Magento payment line No.');
        Assert.AreEqual('PSP-PARTIAL-40', MagentoPaymentLine."Transaction ID", 'PSP reference expected as Transaction ID.');
        Assert.AreEqual(40, MagentoPaymentLine.Amount, 'Reservation amount must equal the EFT payment amount.');
        Assert.AreEqual(40, MagentoPaymentLine."Requested Amount", 'Requested amount must equal the EFT payment amount.');
        Assert.AreEqual(MagentoPaymentLine."Account Type"::"G/L Account", MagentoPaymentLine."Account Type", 'Account type must come from Adyen Setup.');
        Assert.AreEqual(Today(), MagentoPaymentLine."Date Authorized", 'Date authorized must be stamped with the reservation date.');
        Assert.AreEqual(_PaymentGateway.Code, MagentoPaymentLine."Payment Gateway Code", 'Gateway must come from Adyen Setup EFT reservation gateway.');

        // [Then] A credit-sale POS entry exists, not to be posted, linked to the order
        POSEntry.SetRange("POS Unit No.", SavedRegisterNo);
        POSEntry.SetRange("Document No.", SavedTicketNo);
        Assert.IsTrue(POSEntry.FindFirst(), 'POS entry for the reservation sale not found.');
        POSEntry.TestField("Entry Type", POSEntry."Entry Type"::"Credit Sale");
        POSEntry.TestField("Post Entry Status", POSEntry."Post Entry Status"::"Not To Be Posted");
        POSEntry.TestField("Post Item Entry Status", POSEntry."Post Item Entry Status"::"Not To Be Posted");
        POSEntry.TestField("Sales Document No.", SalesHeader."No.");

        POSEntrySalesDocLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesDocLink.SetRange("POS Entry Reference Type", POSEntrySalesDocLink."POS Entry Reference Type"::HEADER);
        Assert.AreEqual(1, POSEntrySalesDocLink.Count(), 'Exactly one header sales document link expected.');
        POSEntrySalesDocLink.FindFirst();
        Assert.AreEqual(SalesHeader."No.", POSEntrySalesDocLink."Sales Document No", 'Sales document link must reference the order.');

        // [Then] The POS entry carries exactly the EFT payment line with its amount
        POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        Assert.AreEqual(1, POSEntryPaymentLine.Count(), 'Exactly one POS entry payment line expected.');
        POSEntryPaymentLine.FindFirst();
        POSEntryPaymentLine.TestField("POS Payment Method Code", _EFTPaymentMethod.Code);
        Assert.AreEqual(40, POSEntryPaymentLine.Amount, 'POS entry payment line amount mismatch.');

        // [Then] The POS sale and its lines are deleted; the order is still open and unposted
        Assert.IsFalse(SalePOS.Get(SavedRegisterNo, SavedTicketNo), 'POS sale must be deleted after finalization.');
        SaleLinePOS.SetRange("Register No.", SavedRegisterNo);
        SaleLinePOS.SetRange("Sales Ticket No.", SavedTicketNo);
        Assert.IsTrue(SaleLinePOS.IsEmpty(), 'All POS sale lines of the finalized sale must be deleted.');

        SalesHeader.Get(SalesHeader."Document Type"::Order, SalesHeader."No.");
        SalesHeader.TestField("Last Posting No.", '');
        SalesHeader.TestField("Last Shipping No.", '');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FinalizeReservationDeletesOnlyCurrentSale()
    var
        SalesHeader: Record "Sales Header";
        SalePOS: Record "NPR POS Sale";
        BystanderSalePOS: Record "NPR POS Sale";
        BystanderCrossRegister: Record "NPR POS Sale";
        BystanderLine: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSActEFTDocPayRsrvB: Codeunit "NPR POSActionEFTDocPayRsrvB";
        Assert: Codeunit "Assert";
    begin
        // [Scenario] Regression for the previously unfiltered SaleLinePOS.DeleteAll(): finalizing a reservation
        // must delete only the current sale's lines. Another register's in-flight sale must survive intact -
        // the original bug wiped every open sale in the company. The bystander deliberately carries the SAME
        // ticket number (ticket series can overlap across registers), pinning the Register No. filter dimension.

        // [Given] POS setup, a sales order and a reservation sale ready to finalize
        InitializeData();
        CreateSalesOrder(SalesHeader, 100);
        StartSaleWithCustomer(POSSale, SalePOS);
        ImportReservationLine(SalePOS, SalesHeader);
        AddEFTPaymentLineWithAuth(SalePOS, 40, 'PSP-BYSTANDER');

        // [Given] Two unrelated open POS sales: same register with a different ticket, and a different
        // register carrying the SAME ticket number - together they pin both dimensions of the delete filter
        CreateBystanderSale(BystanderSalePOS, _POSUnit."No.", GenerateTicketNo());
        CreateBystanderSale(BystanderCrossRegister, 'ZZ-BYSTD', SalePOS."Sales Ticket No.");

        // [When] Finalizing the reservation on the current sale
        _POSSession.GetSale(POSSale);
        POSActEFTDocPayRsrvB.FinalizeReservation(POSSale);

        // [Then] The current sale itself was finalized and deleted (the tripwire is not vacuous)
        Assert.IsFalse(SalePOS.Get(SalePOS."Register No.", SalePOS."Sales Ticket No."), 'Current sale must be deleted by finalization.');

        // [Then] Both bystander sales and all of their lines still exist
        Assert.IsTrue(BystanderSalePOS.Get(BystanderSalePOS."Register No.", BystanderSalePOS."Sales Ticket No."), 'Same-register bystander sale must survive finalization of another sale.');
        BystanderLine.SetRange("Register No.", BystanderSalePOS."Register No.");
        BystanderLine.SetRange("Sales Ticket No.", BystanderSalePOS."Sales Ticket No.");
        Assert.AreEqual(2, BystanderLine.Count(), 'Same-register bystander sale lines must survive (ticket filter).');

        Assert.IsTrue(BystanderCrossRegister.Get(BystanderCrossRegister."Register No.", BystanderCrossRegister."Sales Ticket No."), 'Cross-register bystander sale must survive finalization of another sale.');
        BystanderLine.SetRange("Register No.", BystanderCrossRegister."Register No.");
        BystanderLine.SetRange("Sales Ticket No.", BystanderCrossRegister."Sales Ticket No.");
        Assert.AreEqual(2, BystanderLine.Count(), 'Cross-register bystander sale lines must survive (register filter).');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExportOrderWithEFTReservationConvertsPayment()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalePOS: Record "NPR POS Sale";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
        POSSale: Codeunit "NPR POS Sale";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalesDocumentExportMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
        Assert: Codeunit "Assert";
    begin
        // [Scenario] The shared doc-export flow (SALES_DOC_EXP with POS payment reservation) converts a fabricated
        // EFT payment line into a Magento reservation on the created order and creates a non-posted credit sale.

        // [Given] A POS sale with one item line and a 40 LCY authorized EFT payment line
        InitializeData();
        StartSaleWithCustomer(POSSale, SalePOS);
        NPRLibraryPOSMock.CreateItemLine(_POSSession, _Item."No.", 1);
        AddEFTPaymentLineWithAuth(SalePOS, 40, 'PSP-EXPORT-40');

        // [When] Exporting the sale to an order with the payment line check skipped (reservation mode)
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalesDocumentExportMgt.SetDocumentTypeOrder();
        SalesDocumentExportMgt.SetSkipPaymentLineCheck(true);
        SalesDocumentExportMgt.ProcessPOSSale(POSSale);

        // [Then] A credit-sale POS entry links to the created order
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        Assert.IsTrue(POSEntry.FindFirst(), 'POS entry for the exported sale not found.');
        POSEntry.TestField("Entry Type", POSEntry."Entry Type"::"Credit Sale");
        POSEntrySalesDocLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesDocLink.SetRange("POS Entry Reference Type", POSEntrySalesDocLink."POS Entry Reference Type"::HEADER);
        Assert.IsTrue(POSEntrySalesDocLink.FindFirst(), 'POS entry sales document link not found.');
        SalesHeader.Get(SalesHeader."Document Type"::Order, POSEntrySalesDocLink."Sales Document No");

        // [Then] The order got exactly one Magento reservation with the PSP reference and amount
        FilterMagentoPaymentLines(MagentoPaymentLine, SalesHeader);
        Assert.AreEqual(1, MagentoPaymentLine.Count(), 'Exactly one Magento reservation line expected on the exported order.');
        MagentoPaymentLine.FindFirst();
        Assert.AreEqual('PSP-EXPORT-40', MagentoPaymentLine."Transaction ID", 'PSP reference expected as Transaction ID.');
        Assert.AreEqual(40, MagentoPaymentLine.Amount, 'Reservation amount must equal the EFT payment amount.');

        // [Then] No sales line was derived from the POS payment line (only the item line)
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter(Type, '<>%1', SalesLine.Type::" ");
        Assert.AreEqual(1, SalesLine.Count(), 'Only the item sales line may exist on the exported order.');
        SalesLine.FindFirst();
        SalesLine.TestField(Type, SalesLine.Type::Item);
        SalesLine.TestField("No.", _Item."No.");
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExportOrderWithMixedEFTAndVoucherReservations()
    var
        SalesHeader: Record "Sales Header";
        SalePOS: Record "NPR POS Sale";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
        POSSale: Codeunit "NPR POS Sale";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalesDocumentExportMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
        Assert: Codeunit "Assert";
    begin
        // [Scenario] The shared doc-export flow converts an EFT payment line and a voucher payment line
        // into one EFT reservation and one voucher payment line on the created order.

        // [Given] A POS sale with one item line, a 40 LCY EFT payment and a 25 LCY voucher payment
        InitializeData();
        StartSaleWithCustomer(POSSale, SalePOS);
        NPRLibraryPOSMock.CreateItemLine(_POSSession, _Item."No.", 1);
        AddEFTPaymentLineWithAuth(SalePOS, 40, 'PSP-MIXED-40');
        AddVoucherPaymentLine(SalePOS, 25);

        // [When] Exporting the sale to an order in reservation mode
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalesDocumentExportMgt.SetDocumentTypeOrder();
        SalesDocumentExportMgt.SetSkipPaymentLineCheck(true);
        SalesDocumentExportMgt.ProcessPOSSale(POSSale);

        // [Then] The created order carries one EFT reservation and one voucher payment line
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        Assert.IsTrue(POSEntry.FindFirst(), 'POS entry for the exported sale not found.');
        POSEntrySalesDocLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesDocLink.SetRange("POS Entry Reference Type", POSEntrySalesDocLink."POS Entry Reference Type"::HEADER);
        Assert.IsTrue(POSEntrySalesDocLink.FindFirst(), 'POS entry sales document link not found.');
        SalesHeader.Get(SalesHeader."Document Type"::Order, POSEntrySalesDocLink."Sales Document No");

        FilterMagentoPaymentLines(MagentoPaymentLine, SalesHeader);
        Assert.AreEqual(2, MagentoPaymentLine.Count(), 'One EFT and one voucher Magento payment line expected on the exported order.');

        MagentoPaymentLine.SetRange("Transaction ID", 'PSP-MIXED-40');
        Assert.IsTrue(MagentoPaymentLine.FindFirst(), 'EFT reservation line not found on the exported order.');
        Assert.AreEqual(40, MagentoPaymentLine.Amount, 'EFT reservation amount mismatch.');
        MagentoPaymentLine.SetRange("Transaction ID");

        MagentoPaymentLine.SetRange("Payment Type", MagentoPaymentLine."Payment Type"::Voucher);
        Assert.IsTrue(MagentoPaymentLine.FindFirst(), 'Voucher payment line not found on the exported order.');
        Assert.AreEqual(25, MagentoPaymentLine.Amount, 'Voucher payment amount mismatch.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExistingReservationReducesImportedReservationAmount()
    var
        SalesHeader: Record "Sales Header";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSActEFTDocPayRsrvB: Codeunit "NPR POSActionEFTDocPayRsrvB";
        Assert: Codeunit "Assert";
        OrderAmountInclVAT: Decimal;
    begin
        // [Scenario] Partial reservations are by design: after reserving 40, re-running the action against the
        // same order imports only the remaining amount (order total minus existing reservations).

        // [Given] A sales order partially reserved with 40 LCY through the real reservation flow
        InitializeData();
        CreateSalesOrder(SalesHeader, 100);
        SalesHeader.CalcFields("Amount Including VAT");
        OrderAmountInclVAT := SalesHeader."Amount Including VAT";

        StartSaleWithCustomer(POSSale, SalePOS);
        ImportReservationLine(SalePOS, SalesHeader);
        AddEFTPaymentLineWithAuth(SalePOS, 40, 'PSP-FIRST-40');
        _POSSession.GetSale(POSSale);
        POSActEFTDocPayRsrvB.FinalizeReservation(POSSale);

        // [When] Starting a new sale and importing the reservation amount for the same order again
        StartSaleWithCustomer(POSSale, SalePOS);
        ImportReservationLine(SalePOS, SalesHeader);

        // [Then] Exactly one line imported for this order, worth the order total minus the existing 40 reservation
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Sales Document No.", SalesHeader."No.");
        Assert.AreEqual(1, SaleLinePOS.Count(), 'Exactly one imported reservation line expected for the order.');
        SaleLinePOS.FindFirst();
        Assert.AreEqual(OrderAmountInclVAT - 40, SaleLinePOS."Amount Including VAT", 'Imported reservation amount must be reduced by the existing reservation.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FullyReservedDocumentCannotBeImported()
    var
        SalesHeader: Record "Sales Header";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        POSActEFTDocPayRsrvB: Codeunit "NPR POSActionEFTDocPayRsrvB";
        Assert: Codeunit "Assert";
        OrderAmountInclVAT: Decimal;
    begin
        // [Scenario] Once the whole order amount is reserved, importing a reservation line errors.

        // [Given] A sales order fully reserved through the real reservation flow
        InitializeData();
        CreateSalesOrder(SalesHeader, 100);
        SalesHeader.CalcFields("Amount Including VAT");
        OrderAmountInclVAT := SalesHeader."Amount Including VAT";

        StartSaleWithCustomer(POSSale, SalePOS);
        ImportReservationLine(SalePOS, SalesHeader);
        AddEFTPaymentLineWithAuth(SalePOS, OrderAmountInclVAT, 'PSP-FULL');
        _POSSession.GetSale(POSSale);
        POSActEFTDocPayRsrvB.FinalizeReservation(POSSale);

        // [When] Attempting to import a reservation line for the same order again
        StartSaleWithCustomer(POSSale, SalePOS);
        asserterror ImportReservationLine(SalePOS, SalesHeader);

        // [Then] The whole-amount-already-reserved error is raised
        Assert.ExpectedError('has already been reserved');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VoucherPaymentLineCreatesVoucherReservation()
    var
        SalesHeader: Record "Sales Header";
        SalePOS: Record "NPR POS Sale";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        POSSale: Codeunit "NPR POS Sale";
        POSActEFTDocPayRsrvB: Codeunit "NPR POSActionEFTDocPayRsrvB";
        Assert: Codeunit "Assert";
    begin
        // [Scenario] A voucher payment line in the reservation sale becomes a voucher Magento payment line on the order.

        // [Given] A reservation sale with a 25 LCY voucher payment line
        InitializeData();
        CreateSalesOrder(SalesHeader, 100);
        StartSaleWithCustomer(POSSale, SalePOS);
        ImportReservationLine(SalePOS, SalesHeader);
        AddVoucherPaymentLine(SalePOS, 25);

        // [When] Finalizing the reservation
        _POSSession.GetSale(POSSale);
        POSActEFTDocPayRsrvB.FinalizeReservation(POSSale);

        // [Then] Exactly one voucher Magento payment line exists on the order, carrying the voucher identity
        FilterMagentoPaymentLines(MagentoPaymentLine, SalesHeader);
        Assert.AreEqual(1, MagentoPaymentLine.Count(), 'Exactly one Magento payment line expected on the order.');
        MagentoPaymentLine.FindFirst();
        Assert.AreEqual(MagentoPaymentLine."Payment Type"::Voucher, MagentoPaymentLine."Payment Type", 'Voucher payment type expected.');
        Assert.AreEqual(25, MagentoPaymentLine.Amount, 'Voucher payment amount mismatch.');
        Assert.AreEqual(25, MagentoPaymentLine."Requested Amount", 'Voucher requested amount mismatch.');
        Assert.AreEqual('V-TEST-REF', MagentoPaymentLine."No.", 'Voucher reference expected as payment line No.');
        Assert.AreEqual('V-TEST', MagentoPaymentLine."Source No.", 'Voucher number expected as Source No.');
        Assert.AreEqual(_VoucherTypeDefault."Account No.", MagentoPaymentLine."Account No.", 'Voucher type account expected on the payment line.');

        // [Then] The voucher sales line is back-linked to the created payment line
        NpRvSalesLine.SetRange("Document No.", SalesHeader."No.");
        Assert.IsTrue(NpRvSalesLine.FindFirst(), 'Voucher sales line must be linked to the order.');
        Assert.AreEqual(NpRvSalesLine."Document Source"::"Payment Line", NpRvSalesLine."Document Source", 'Voucher sales line document source mismatch.');
        Assert.AreEqual(MagentoPaymentLine.SystemId, NpRvSalesLine."Reservation Line Id", 'Voucher sales line must reference the Magento payment line.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ZeroAndUnsupportedPaymentLinesAreSkipped()
    var
        SalesHeader: Record "Sales Header";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        POSSale: Codeunit "NPR POS Sale";
        POSActEFTDocPayRsrvB: Codeunit "NPR POSActionEFTDocPayRsrvB";
        Assert: Codeunit "Assert";
        LineNo: Integer;
    begin
        // [Scenario] Zero-amount EFT lines, cash lines and EFT lines without a matching transaction request are
        // silently skipped by the reservation conversion (current accepted behavior).

        // [Given] A reservation sale with a zero-amount EFT line (with auth request), a 10 LCY cash line
        // (with auth request pointing at the cash method) and a 15 LCY EFT line without any EFT transaction request
        InitializeData();
        CreateSalesOrder(SalesHeader, 100);
        StartSaleWithCustomer(POSSale, SalePOS);
        ImportReservationLine(SalePOS, SalesHeader);
        LineNo := AddPaymentLine(_EFTPaymentMethod.Code, 0);
        AddAuthRequest(SalePOS, LineNo, _EFTPaymentMethod.Code, 0, 'PSP-ZERO');
        LineNo := AddPaymentLine(_CashPaymentMethod.Code, 10);
        AddAuthRequest(SalePOS, LineNo, _CashPaymentMethod.Code, 10, 'PSP-CASH');
        AddPaymentLine(_EFTPaymentMethod.Code, 15);

        // [Then] All three payment lines actually exist before conversion (guards fixture drift)
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::"POS Payment");
        Assert.AreEqual(3, SaleLinePOS.Count(), 'Fixture must hold all three payment lines before conversion.');

        // [When] Converting the payment lines
        POSSale.GetCurrentSale(SalePOS);
        POSActEFTDocPayRsrvB.CreateDocumentPaymentReservationLines(SalePOS);

        // [Then] No Magento payment line was created and no error was raised
        FilterMagentoPaymentLines(MagentoPaymentLine, SalesHeader);
        Assert.IsTrue(MagentoPaymentLine.IsEmpty(), 'No Magento payment line may be created for skipped payment lines.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TwoEFTPaymentLinesCreateTwoReservations()
    var
        SalesHeader: Record "Sales Header";
        SalePOS: Record "NPR POS Sale";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        POSSale: Codeunit "NPR POS Sale";
        POSActEFTDocPayRsrvB: Codeunit "NPR POSActionEFTDocPayRsrvB";
        Assert: Codeunit "Assert";
    begin
        // [Scenario] Two EFT payment lines in one reservation sale each become their own Magento
        // reservation line with the right PSP reference (multi-line conversion loop + line numbering).

        // [Given] A reservation sale with two authorized EFT payment lines
        InitializeData();
        CreateSalesOrder(SalesHeader, 100);
        StartSaleWithCustomer(POSSale, SalePOS);
        ImportReservationLine(SalePOS, SalesHeader);
        AddEFTPaymentLineWithAuth(SalePOS, 40, 'PSP-TWO-A');
        AddEFTPaymentLineWithAuth(SalePOS, 30, 'PSP-TWO-B');

        // [When] Finalizing the reservation
        _POSSession.GetSale(POSSale);
        POSActEFTDocPayRsrvB.FinalizeReservation(POSSale);

        // [Then] Two Magento reservation lines exist, each carrying its own PSP reference and amount
        FilterMagentoPaymentLines(MagentoPaymentLine, SalesHeader);
        Assert.AreEqual(2, MagentoPaymentLine.Count(), 'Two Magento reservation lines expected on the order.');
        MagentoPaymentLine.SetRange("Transaction ID", 'PSP-TWO-A');
        Assert.IsTrue(MagentoPaymentLine.FindFirst(), 'First EFT reservation not found.');
        Assert.AreEqual(40, MagentoPaymentLine.Amount, 'First reservation amount mismatch.');
        MagentoPaymentLine.SetRange("Transaction ID", 'PSP-TWO-B');
        Assert.IsTrue(MagentoPaymentLine.FindFirst(), 'Second EFT reservation not found.');
        Assert.AreEqual(30, MagentoPaymentLine.Amount, 'Second reservation amount mismatch.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SharedExportDoesNotEnforceManualCapture()
    var
        SalesHeader: Record "Sales Header";
        SalePOS: Record "NPR POS Sale";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
        POSSale: Codeunit "NPR POS Sale";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SalesDocumentExportMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
        Assert: Codeunit "Assert";
    begin
        // [Scenario] CHARACTERIZATION of current behavior: the shared doc-export flow creates EFT reservations
        // even when manual capture is disabled on the Adyen payment type setup. If this test starts failing
        // because validation was added, update it deliberately - it pins a known, accepted gap.

        // [Given] Manual capture disabled and a POS sale with an item line and an authorized EFT payment line
        InitializeData();
        SetManualCapture(false);
        StartSaleWithCustomer(POSSale, SalePOS);
        NPRLibraryPOSMock.CreateItemLine(_POSSession, _Item."No.", 1);
        AddEFTPaymentLineWithAuth(SalePOS, 40, 'PSP-NOCAPT-40');

        // [When] Exporting the sale to an order in reservation mode
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalesDocumentExportMgt.SetDocumentTypeOrder();
        SalesDocumentExportMgt.SetSkipPaymentLineCheck(true);
        SalesDocumentExportMgt.ProcessPOSSale(POSSale);

        // [Then] The export succeeds and the reservation is created despite manual capture being disabled
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        Assert.IsTrue(POSEntry.FindFirst(), 'POS entry for the exported sale not found.');
        POSEntrySalesDocLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesDocLink.SetRange("POS Entry Reference Type", POSEntrySalesDocLink."POS Entry Reference Type"::HEADER);
        Assert.IsTrue(POSEntrySalesDocLink.FindFirst(), 'POS entry sales document link not found.');
        SalesHeader.Get(SalesHeader."Document Type"::Order, POSEntrySalesDocLink."Sales Document No");
        FilterMagentoPaymentLines(MagentoPaymentLine, SalesHeader);
        Assert.AreEqual(1, MagentoPaymentLine.Count(), 'Reservation is currently created even without manual capture.');

        SetManualCapture(true);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidatePOSSaleRequiresNewSale()
    var
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSActEFTDocPayRsrvB: Codeunit "NPR POSActionEFTDocPayRsrvB";
        Assert: Codeunit "Assert";
    begin
        // [Scenario] The reservation action only accepts an empty (new) sale.

        // [Given] An empty POS sale
        InitializeData();
        StartSaleWithCustomer(POSSale, SalePOS);

        // [Then] Validation passes on the empty sale
        POSActEFTDocPayRsrvB.ValidatePOSSale(SalePOS, _EFTPaymentMethod.Code);

        // [When] The sale contains any line
        NPRLibraryPOSMock.CreateItemLine(_POSSession, _Item."No.", 1);
        POSSale.GetCurrentSale(SalePOS);

        // [Then] Validation errors
        asserterror POSActEFTDocPayRsrvB.ValidatePOSSale(SalePOS, _EFTPaymentMethod.Code);
        Assert.ExpectedError('must be done in a new sale');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateAdyenManualCapture()
    var
        POSActEFTDocPayRsrvB: Codeunit "NPR POSActionEFTDocPayRsrvB";
        Assert: Codeunit "Assert";
    begin
        // [Scenario] The standalone action's payment method validation requires manual capture on the Adyen setup.

        InitializeData();

        // [Then] Validation passes with manual capture enabled
        SetManualCapture(true);
        POSActEFTDocPayRsrvB.ValidatePOSPaymentMethod(_EFTPaymentMethod.Code, _POSUnit."No.");

        // [Then] Validation errors with manual capture disabled
        SetManualCapture(false);
        asserterror POSActEFTDocPayRsrvB.ValidatePOSPaymentMethod(_EFTPaymentMethod.Code, _POSUnit."No.");
        Assert.ExpectedError('Manual capture is not enabled');

        SetManualCapture(true);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ReservationSetupRequiresAccountAndGateway()
    var
        AdyenSetup: Record "NPR Adyen Setup";
        POSActEFTDocPayRsrvB: Codeunit "NPR POSActionEFTDocPayRsrvB";
        Assert: Codeunit "Assert";
        SavedAccountNo: Code[20];
        SavedGatewayCode: Code[10];
    begin
        // [Scenario] The reservation setup check requires the Adyen reservation account and gateway to be filled.

        InitializeData();
        AdyenSetup.Get();
        SavedAccountNo := AdyenSetup."EFT Res. Account No.";
        SavedGatewayCode := AdyenSetup."EFT Res. Payment Gateway Code";

        // [Then] Blank reservation account errors
        AdyenSetup."EFT Res. Account No." := '';
        AdyenSetup.Modify();
        asserterror POSActEFTDocPayRsrvB.CheckPOSEFTPaymentReservationSetup();
        Assert.ExpectedError('must have a value');

        // [Then] Blank reservation gateway errors
        AdyenSetup.Get();
        AdyenSetup."EFT Res. Account No." := SavedAccountNo;
        AdyenSetup."EFT Res. Payment Gateway Code" := '';
        AdyenSetup.Modify();
        asserterror POSActEFTDocPayRsrvB.CheckPOSEFTPaymentReservationSetup();
        Assert.ExpectedError('must have a value');

        // [Then] Complete setup passes
        AdyenSetup.Get();
        AdyenSetup."EFT Res. Account No." := SavedAccountNo;
        AdyenSetup."EFT Res. Payment Gateway Code" := SavedGatewayCode;
        AdyenSetup.Modify();
        POSActEFTDocPayRsrvB.CheckPOSEFTPaymentReservationSetup();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FinalizeWithoutLinkedOrderLeavesSaleActive()
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        POSEntry: Record "NPR POS Entry";
        POSSale: Codeunit "NPR POS Sale";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSActEFTDocPayRsrvB: Codeunit "NPR POSActionEFTDocPayRsrvB";
        Assert: Codeunit "Assert";
    begin
        // [Scenario] CHARACTERIZATION of current behavior: finalizing a sale without a document-linked line
        // exits silently - no POS entry, no reservation, and the sale stays open. Accepted by design
        // (concurrent order deletion is out of scope).

        // [Given] A POS sale with an item line and an authorized EFT payment line, but no sales document link
        InitializeData();
        StartSaleWithCustomer(POSSale, SalePOS);
        NPRLibraryPOSMock.CreateItemLine(_POSSession, _Item."No.", 1);
        AddEFTPaymentLineWithAuth(SalePOS, 40, 'PSP-NO-DOC');

        // [When] Finalizing the reservation
        _POSSession.GetSale(POSSale);
        POSActEFTDocPayRsrvB.FinalizeReservation(POSSale);

        // [Then] The sale and its lines still exist and no POS entry or reservation was created
        Assert.IsTrue(SalePOS.Get(SalePOS."Register No.", SalePOS."Sales Ticket No."), 'Sale without document link must remain after finalization attempt.');
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        Assert.AreEqual(2, SaleLinePOS.Count(), 'Item and payment line must remain when no sales document is linked.');
        POSEntry.SetRange("POS Unit No.", SalePOS."Register No.");
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        Assert.IsTrue(POSEntry.IsEmpty(), 'No POS entry may be created when no sales document is linked.');
        MagentoPaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        MagentoPaymentLine.SetRange("Transaction ID", 'PSP-NO-DOC');
        Assert.IsTrue(MagentoPaymentLine.IsEmpty(), 'No reservation may be created when no sales document is linked.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PostingSetupAccountFallbackOrder()
    var
        SalesHeader: Record "Sales Header";
        SalePOS: Record "NPR POS Sale";
        AdyenSetup: Record "NPR Adyen Setup";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        POSSale: Codeunit "NPR POS Sale";
        POSActEFTDocPayRsrvB: Codeunit "NPR POSActionEFTDocPayRsrvB";
        Assert: Codeunit "Assert";
    begin
        // [Scenario] The reservation account number resolution falls back:
        // store+method -> store default -> global method -> Adyen Setup reservation account.

        InitializeData();

        // [Given] All three posting setup candidates exist at once - the most specific (store+method) must win
        ClearReservationPostingSetups();
        SetPostingSetupAccount(_POSStore.Code, _EFTPaymentMethod.Code, 'RSRV-A');
        SetPostingSetupAccount(_POSStore.Code, '', 'RSRV-B');
        SetPostingSetupAccount('', _EFTPaymentMethod.Code, 'RSRV-C');
        RunReservationForNewOrder(SalesHeader, SalePOS, POSSale, 'PSP-FB-A');
        AssertReservationAccount(SalesHeader, 'RSRV-A');

        // [Given] Store+method row still present but with a blank account - it must fall through to store default
        SetPostingSetupAccount(_POSStore.Code, _EFTPaymentMethod.Code, '');
        RunReservationForNewOrder(SalesHeader, SalePOS, POSSale, 'PSP-FB-A2');
        AssertReservationAccount(SalesHeader, 'RSRV-B');

        // [Given] Store+method removed - store default must win over the still-present global method row
        DeletePostingSetup(_POSStore.Code, _EFTPaymentMethod.Code);
        RunReservationForNewOrder(SalesHeader, SalePOS, POSSale, 'PSP-FB-B');
        AssertReservationAccount(SalesHeader, 'RSRV-B');

        // [Given] Store default removed - the global method row must win
        DeletePostingSetup(_POSStore.Code, '');
        RunReservationForNewOrder(SalesHeader, SalePOS, POSSale, 'PSP-FB-C');
        AssertReservationAccount(SalesHeader, 'RSRV-C');

        // [Given] No posting setup rows left - Adyen Setup reservation account is the final fallback
        DeletePostingSetup('', _EFTPaymentMethod.Code);
        AdyenSetup.Get();
        RunReservationForNewOrder(SalesHeader, SalePOS, POSSale, 'PSP-FB-D');
        AssertReservationAccount(SalesHeader, AdyenSetup."EFT Res. Account No.");

        // Leave no test accounts behind for any test declared after this one
        ClearReservationPostingSetups();
    end;

    local procedure InitializeData()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        NPRLibraryEFT: Codeunit "NPR Library - EFT";
        LibrarySales: Codeunit "Library - Sales";
    begin
        _POSSession.ClearAll();
        Clear(_POSSession);

        if not _Initialized then begin
            NPRLibraryPOSMasterData.CreatePOSSetup(_POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            NPRLibraryPOSMasterData.CreatePOSStore(_POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(_POSUnit, _POSStore.Code, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreateSalespersonForPOSUsage(_Salesperson);
            NPRLibraryPOSMasterData.CreateDefaultVoucherType(_VoucherTypeDefault, false);
            LibrarySales.CreateCustomerWithAddress(_Customer);

            NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(_Item, _POSUnit, _POSStore);
            _Item."Unit Price" := 100;
            _Item.Modify();

            NPRLibraryEFT.CreateEFTPaymentTypePOS(_EFTPaymentMethod, _POSUnit, _POSStore);
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_CashPaymentMethod, _CashPaymentMethod."Processing Type"::CASH, '', false);
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_VoucherPaymentMethod, _VoucherPaymentMethod."Processing Type"::VOUCHER, '', false);

            CreateAdyenCloudEFTSetup(_EFTPaymentMethod.Code, _POSUnit."No.");

            _Initialized := true;
        end;

        // Re-assert mutable fixture state on every test so a failed test cannot contaminate later ones
        SetManualCapture(true);
        EnsureAdyenReservationSetup();

        Commit();
    end;

    local procedure CreateAdyenCloudEFTSetup(PaymentMethodCode: Code[10]; POSUnitNo: Code[10])
    var
        EFTSetup: Record "NPR EFT Setup";
    begin
        if not EFTSetup.Get(PaymentMethodCode, POSUnitNo) then begin
            EFTSetup.Init();
            EFTSetup."Payment Type POS" := PaymentMethodCode;
            EFTSetup."POS Unit No." := POSUnitNo;
            EFTSetup."EFT Integration Type" := 'ADYEN_CLOUD';
            EFTSetup.Insert();
        end;

        SetManualCapture(true);
    end;

    local procedure SetManualCapture(ManualCapture: Boolean)
    var
        EFTAdyenPaymTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
    begin
        if not EFTAdyenPaymTypeSetup.Get(_EFTPaymentMethod.Code) then begin
            EFTAdyenPaymTypeSetup.Init();
            EFTAdyenPaymTypeSetup."Payment Type POS" := _EFTPaymentMethod.Code;
            EFTAdyenPaymTypeSetup.Insert();
        end;
        EFTAdyenPaymTypeSetup."Manual Capture" := ManualCapture;
        EFTAdyenPaymTypeSetup.Modify();
    end;

    local procedure EnsureAdyenReservationSetup()
    var
        AdyenSetup: Record "NPR Adyen Setup";
        GLAccount: Record "G/L Account";
        LibraryERM: Codeunit "Library - ERM";
    begin
        if not _PaymentGateway.Get('EFTRSRV') then begin
            _PaymentGateway.Init();
            _PaymentGateway.Code := 'EFTRSRV';
            _PaymentGateway.Insert();
        end;

        if not AdyenSetup.Get() then begin
            AdyenSetup.Init();
            AdyenSetup.Insert();
        end;

        if (AdyenSetup."EFT Res. Account No." = '') or (not GLAccount.Get(AdyenSetup."EFT Res. Account No.")) then begin
            LibraryERM.CreateGLAccount(GLAccount);
            GLAccount."Direct Posting" := true;
            GLAccount.Modify();
            AdyenSetup."EFT Res. Account No." := GLAccount."No.";
        end;
        AdyenSetup."EFT Res. Account Type" := AdyenSetup."EFT Res. Account Type"::"G/L Account";
        AdyenSetup."EFT Res. Payment Gateway Code" := _PaymentGateway.Code;
        AdyenSetup.Modify();
    end;

    local procedure CreateSalesOrder(var SalesHeader: Record "Sales Header"; UnitPrice: Decimal)
    var
        SalesLine: Record "Sales Line";
        LibrarySales: Codeunit "Library - Sales";
    begin
        Clear(SalesHeader);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, _Customer."No.");
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, _Item."No.", 1);
        SalesLine.Validate("Unit Price", UnitPrice);
        SalesLine.Modify(true);
    end;

    local procedure StartSaleWithCustomer(var POSSale: Codeunit "NPR POS Sale"; var SalePOS: Record "NPR POS Sale")
    var
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        SelectCustomerAction: Codeunit "NPR POS Action: Cust. Select-B";
    begin
        _POSSession.ClearAll();
        Clear(_POSSession);
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SelectCustomerAction.AttachCustomer(SalePOS, '', 0, _Customer."No.", false);
        POSSale.GetCurrentSale(SalePOS);
    end;

    local procedure ImportReservationLine(SalePOS: Record "NPR POS Sale"; SalesHeader: Record "Sales Header")
    var
        POSActEFTDocPayRsrvB: Codeunit "NPR POSActionEFTDocPayRsrvB";
    begin
        POSActEFTDocPayRsrvB.CreateDocumentReservationAmountSalesLine(_POSSession, SalePOS, SalesHeader, _EFTPaymentMethod.Code);
    end;

    local procedure AddPaymentLine(PaymentMethodCode: Code[10]; Amount: Decimal) LineNo: Integer
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
    begin
        _POSSession.GetPaymentLine(POSPaymentLine);
        SaleLinePOS.Init();
        SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::"POS Payment";
        SaleLinePOS."No." := PaymentMethodCode;
        SaleLinePOS.Description := PaymentMethodCode;
        SaleLinePOS."Amount Including VAT" := Amount;
        SaleLinePOS."Currency Amount" := Amount;
        POSPaymentLine.InsertPaymentLine(SaleLinePOS, 0);
        POSPaymentLine.GetCurrentPaymentLine(SaleLinePOS);
        LineNo := SaleLinePOS."Line No.";
    end;

    local procedure AddEFTPaymentLineWithAuth(SalePOS: Record "NPR POS Sale"; Amount: Decimal; PSPReference: Text)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        LineNo: Integer;
    begin
        LineNo := AddPaymentLine(_EFTPaymentMethod.Code, Amount);

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Line No.", LineNo);
        SaleLinePOS.FindFirst();
        SaleLinePOS."EFT Approved" := true;
        SaleLinePOS.Modify();

        AddAuthRequest(SalePOS, LineNo, _EFTPaymentMethod.Code, Amount, PSPReference);
    end;

    local procedure AddAuthRequest(SalePOS: Record "NPR POS Sale"; LineNo: Integer; PaymentMethodCode: Code[10]; Amount: Decimal; PSPReference: Text)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTransactionRequest.Init();
        EFTTransactionRequest."Entry No." := 0;
        EFTTransactionRequest."Register No." := SalePOS."Register No.";
        EFTTransactionRequest."Sales Ticket No." := SalePOS."Sales Ticket No.";
        EFTTransactionRequest."Sales Line No." := LineNo;
        EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::PAYMENT;
        EFTTransactionRequest."POS Payment Type Code" := PaymentMethodCode;
        EFTTransactionRequest."Original POS Payment Type Code" := PaymentMethodCode;
        EFTTransactionRequest."PSP Reference" := CopyStr(PSPReference, 1, MaxStrLen(EFTTransactionRequest."PSP Reference"));
        // Deliberately skewed from the POS line amount: the reservation flow must source amounts from
        // the POS payment line, never from the EFT request - the skew pins that basis in every assert.
        EFTTransactionRequest."Amount Output" := Amount + 1;
        EFTTransactionRequest."Result Amount" := Amount + 1;
        EFTTransactionRequest.Successful := true;
        EFTTransactionRequest.Insert();
    end;

    local procedure AddVoucherPaymentLine(SalePOS: Record "NPR POS Sale"; Amount: Decimal)
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        LineNo: Integer;
    begin
        LineNo := AddPaymentLine(_VoucherPaymentMethod.Code, Amount);

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Line No.", LineNo);
        SaleLinePOS.FindFirst();

        NpRvSalesLine.Init();
        NpRvSalesLine.Id := CreateGuid();
        NpRvSalesLine."Register No." := SalePOS."Register No.";
        NpRvSalesLine."Sales Ticket No." := SalePOS."Sales Ticket No.";
        NpRvSalesLine."Sale Date" := SalePOS.Date;
        NpRvSalesLine."Sale Line No." := LineNo;
        NpRvSalesLine.Type := NpRvSalesLine.Type::Payment;
        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::POS;
        NpRvSalesLine."Voucher Type" := _VoucherTypeDefault.Code;
        NpRvSalesLine."Voucher No." := 'V-TEST';
        NpRvSalesLine."Reference No." := 'V-TEST-REF';
        NpRvSalesLine."Retail ID" := SaleLinePOS.SystemId;
        NpRvSalesLine.Insert();
    end;

    local procedure GenerateTicketNo(): Code[20]
    begin
        exit(CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, 20));
    end;

    local procedure CreateBystanderSale(var BystanderSalePOS: Record "NPR POS Sale"; RegisterNo: Code[10]; TicketNo: Code[20])
    var
        BystanderLine: Record "NPR POS Sale Line";
        i: Integer;
    begin
        BystanderSalePOS.Init();
        BystanderSalePOS."Register No." := RegisterNo;
        BystanderSalePOS."Sales Ticket No." := TicketNo;
        BystanderSalePOS.Date := WorkDate();
        BystanderSalePOS.Insert();

        for i := 1 to 2 do begin
            BystanderLine.Init();
            BystanderLine."Register No." := BystanderSalePOS."Register No.";
            BystanderLine."Sales Ticket No." := BystanderSalePOS."Sales Ticket No.";
            BystanderLine.Date := BystanderSalePOS.Date;
            BystanderLine."Line No." := i * 10000;
            BystanderLine."Line Type" := BystanderLine."Line Type"::Item;
            BystanderLine.Description := 'Bystander line';
            BystanderLine.Insert();
        end;
    end;

    local procedure FilterMagentoPaymentLines(var MagentoPaymentLine: Record "NPR Magento Payment Line"; SalesHeader: Record "Sales Header")
    begin
        MagentoPaymentLine.Reset();
        MagentoPaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        MagentoPaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        MagentoPaymentLine.SetRange("Document No.", SalesHeader."No.");
    end;

    local procedure ClearReservationPostingSetups()
    begin
        DeletePostingSetup(_POSStore.Code, _EFTPaymentMethod.Code);
        DeletePostingSetup(_POSStore.Code, '');
        DeletePostingSetup('', _EFTPaymentMethod.Code);
    end;

    local procedure DeletePostingSetup(StoreCode: Code[10]; PaymentMethodCode: Code[10])
    var
        POSPostingSetup: Record "NPR POS Posting Setup";
    begin
        if POSPostingSetup.Get(StoreCode, PaymentMethodCode, '') then
            POSPostingSetup.Delete();
    end;

    local procedure SetPostingSetupAccount(StoreCode: Code[10]; PaymentMethodCode: Code[10]; AccountNo: Code[20])
    var
        POSPostingSetup: Record "NPR POS Posting Setup";
    begin
        if POSPostingSetup.Get(StoreCode, PaymentMethodCode, '') then begin
            POSPostingSetup."Account No." := AccountNo;
            POSPostingSetup.Modify();
            exit;
        end;
        POSPostingSetup.Init();
        POSPostingSetup."POS Store Code" := StoreCode;
        POSPostingSetup."POS Payment Method Code" := PaymentMethodCode;
        POSPostingSetup."POS Payment Bin Code" := '';
        POSPostingSetup."Account No." := AccountNo;
        POSPostingSetup.Insert();
    end;

    local procedure RunReservationForNewOrder(var SalesHeader: Record "Sales Header"; var SalePOS: Record "NPR POS Sale"; var POSSale: Codeunit "NPR POS Sale"; PSPReference: Text)
    var
        POSActEFTDocPayRsrvB: Codeunit "NPR POSActionEFTDocPayRsrvB";
    begin
        CreateSalesOrder(SalesHeader, 100);
        StartSaleWithCustomer(POSSale, SalePOS);
        ImportReservationLine(SalePOS, SalesHeader);
        AddEFTPaymentLineWithAuth(SalePOS, 40, PSPReference);
        _POSSession.GetSale(POSSale);
        POSActEFTDocPayRsrvB.FinalizeReservation(POSSale);
    end;

    local procedure AssertReservationAccount(SalesHeader: Record "Sales Header"; ExpectedAccountNo: Code[20])
    var
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        Assert: Codeunit "Assert";
    begin
        FilterMagentoPaymentLines(MagentoPaymentLine, SalesHeader);
        Assert.IsTrue(MagentoPaymentLine.FindFirst(), 'Magento reservation line not found for fallback assertion.');
        Assert.AreEqual(ExpectedAccountNo, MagentoPaymentLine."Account No.", 'Reservation account fallback resolved to the wrong account.');
    end;
}
