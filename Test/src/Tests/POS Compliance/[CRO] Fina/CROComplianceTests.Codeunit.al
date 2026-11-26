codeunit 85163 "NPR CRO Compliance Tests"
{
    Subtype = Test;

    var
        _Item: Record Item;
        _VoucherTypeDefault: Record "NPR NpRv Voucher Type";
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _POSPostingProfile: Record "NPR POS Posting Profile";
        _POSUnit: Record "NPR POS Unit";
        _ReturnReason: Record "Return Reason";
        _Salesperson: Record "Salesperson/Purchaser";
        _Assert: Codeunit Assert;
        _POSSession: Codeunit "NPR POS Session";
        _Initialized: Boolean;
        _LastMessage: Text;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NormalPOSSaleFiscalization()
    var
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
        LibraryCROFiscal: Codeunit "NPR Library CRO Fiscal";
        EntryNumber: Integer;
    begin
        // [Scenario] Check that successful cash sales gets successful response by the tax authority when CRO audit handler is enabled on POS unit.
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryCROFiscal);

        // [Given] POS and CRO audit setup
        InitializeData();

        // [When] Ending normal cash sale
        EntryNumber := DoItemSale();

        // [Then] For normal cash sale CRO Audit Log is created and filled by the Tax Authority
        CROPOSAuditLogAuxInfo.SetRange("Audit Entry Type", CROPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
        CROPOSAuditLogAuxInfo.SetRange("POS Entry No.", EntryNumber);
        CROPOSAuditLogAuxInfo.FindFirst();
        _Assert.IsTrue(CROPOSAuditLogAuxInfo."JIR Code" <> '', 'Fiscal Bill must be signed by the Tax Authority.');

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit 
        UnbindSubscription(LibraryCROFiscal);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ReturnPOSSaleFiscalization()
    var
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
        POSEntry: Record "NPR POS Entry";
        LibraryCROFiscal: Codeunit "NPR Library CRO Fiscal";
        EntryNumber: Integer;
        ReturnEntryNumber: Integer;
    begin
        // [Scenario] Check that successful cash sales refund gets successful response by the tax authority when CRO audit handler is enabled on POS unit.
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryCROFiscal);

        // [Given] POS and CRO audit setup
        InitializeData();

        // [When] Ending and returning receipt
        EntryNumber := DoItemSale();
        POSEntry.Get(EntryNumber);
        ReturnEntryNumber := DoReturnSale(POSEntry."Document No.");

        // [Then] For normal cash sale CRO Audit Log is created and filled by the Tax Authority for both sales and refund
        CROPOSAuditLogAuxInfo.SetRange("Audit Entry Type", CROPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
        CROPOSAuditLogAuxInfo.SetRange("POS Entry No.", EntryNumber);
        CROPOSAuditLogAuxInfo.FindFirst();
        _Assert.IsTrue(CROPOSAuditLogAuxInfo."JIR Code" <> '', 'Fiscal Bill must be signed by the Tax Authority.');

        CROPOSAuditLogAuxInfo.SetRange("Audit Entry Type", CROPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
        CROPOSAuditLogAuxInfo.SetRange("POS Entry No.", ReturnEntryNumber);
        CROPOSAuditLogAuxInfo.FindFirst();
        _Assert.IsTrue(CROPOSAuditLogAuxInfo."JIR Code" <> '', 'Fiscal Bill must be signed by the Tax Authority.');

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit 
        UnbindSubscription(LibraryCROFiscal);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NormalSaleWithParagonNumber()
    var
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
        LibraryCROFiscal: Codeunit "NPR Library CRO Fiscal";
        EntryNumber: Integer;
    begin
        // [Scenario] Check that successful cash sale with paragon number gets successful response by the tax authority when CRO audit handler is enabled on POS unit.
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryCROFiscal);

        // [Given] POS and CRO audit setup
        InitializeData();

        // [When] Ending and returning receipt
        EntryNumber := DoItemSaleWithParagon();

        // [Then] For normal cash sale with paragon number CRO Audit Log is created and fields are filled by the Tax Authority
        CROPOSAuditLogAuxInfo.SetRange("Audit Entry Type", CROPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
        CROPOSAuditLogAuxInfo.SetRange("POS Entry No.", EntryNumber);
        CROPOSAuditLogAuxInfo.FindFirst();
        _Assert.IsTrue(CROPOSAuditLogAuxInfo."JIR Code" <> '', 'Fiscal Bill must be signed by the Tax Authority.');

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit
        UnbindSubscription(LibraryCROFiscal);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SalespersonOIBWithWrongCheckDigitIsRejected()
    var
        CROAuxSalespersonPurch: Record "NPR CRO Aux Salesperson/Purch.";
    begin
        // [Scenario] An OIB whose last digit isn't its ISO 7064 MOD 11,10 check digit is rejected when entered, because the tax authority rejects bills that carry it (error 179)
        // [When] Entering an OIB with a wrong check digit (the check digit of 1112999567 is 1)
        asserterror CROAuxSalespersonPurch.Validate("NPR CRO Salesperson OIB", ToBigInteger('11129995674'));

        // [Then] The OIB is rejected
        _Assert.ExpectedError(InvalidEnteredOIBTxt());
        _Assert.ExpectedErrorCode('Dialog');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SalespersonOIBStartingWithZeroIsAccepted()
    var
        CROAuxSalespersonPurch: Record "NPR CRO Aux Salesperson/Purch.";
    begin
        // [Scenario] A valid OIB that starts with 0 can be entered, although the field stores it without the leading zero
        // [When] Entering the valid OIB 02994650199
        CROAuxSalespersonPurch.Validate("NPR CRO Salesperson OIB", ToBigInteger('02994650199'));

        // [Then] The OIB is kept
        _Assert.AreEqual(ToBigInteger('02994650199'), CROAuxSalespersonPurch."NPR CRO Salesperson OIB", 'A valid OIB that starts with 0 must be accepted.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SalespersonOIBWithCheckDigitZeroIsAccepted()
    var
        CROAuxSalespersonPurch: Record "NPR CRO Aux Salesperson/Purch.";
    begin
        // [Scenario] A valid OIB whose check digit is 0 is accepted. Its MOD 11,10 calculation gives 10, which only becomes 0 through the final mod 10
        // [When] Entering the valid OIB 11129995680
        CROAuxSalespersonPurch.Validate("NPR CRO Salesperson OIB", ToBigInteger('11129995680'));

        // [Then] The OIB is kept
        _Assert.AreEqual(ToBigInteger('11129995680'), CROAuxSalespersonPurch."NPR CRO Salesperson OIB", 'A valid OIB whose check digit is 0 must be accepted.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NegativeSalespersonOIBIsRejected()
    var
        CROAuxSalespersonPurch: Record "NPR CRO Aux Salesperson/Purch.";
    begin
        // [Scenario] A negative number is rejected as an OIB, although its minus sign makes it 11 characters long
        // [When] Entering -1234567890
        asserterror CROAuxSalespersonPurch.Validate("NPR CRO Salesperson OIB", -1234567890);

        // [Then] The OIB is rejected
        _Assert.ExpectedError(InvalidEnteredOIBTxt());
        _Assert.ExpectedErrorCode('Dialog');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SalespersonOIBWithMoreThan11DigitsIsRejected()
    var
        CROAuxSalespersonPurch: Record "NPR CRO Aux Salesperson/Purch.";
    begin
        // [Scenario] A number with more than 11 digits is rejected as an OIB, even when 11 of its digits form a valid OIB
        // [When] Entering a valid OIB (67603909448) with an extra digit at the end
        asserterror CROAuxSalespersonPurch.Validate("NPR CRO Salesperson OIB", ToBigInteger('676039094480'));

        // [Then] The OIB is rejected
        _Assert.ExpectedError(InvalidEnteredOIBTxt());
        _Assert.ExpectedErrorCode('Dialog');

        // [When] Entering a valid OIB (67603909448) with an extra digit at the start
        asserterror CROAuxSalespersonPurch.Validate("NPR CRO Salesperson OIB", ToBigInteger('167603909448'));

        // [Then] The OIB is rejected
        _Assert.ExpectedError(InvalidEnteredOIBTxt());
        _Assert.ExpectedErrorCode('Dialog');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SalespersonOIBStartingWithTwoZerosIsAccepted()
    var
        CROAuxSalespersonPurch: Record "NPR CRO Aux Salesperson/Purch.";
    begin
        // [Scenario] The first 10 digits of an OIB are random, so a real OIB can start with 00. It can be entered, although the field stores it without its leading zeros
        // [When] Entering the valid OIB 00123456785
        CROAuxSalespersonPurch.Validate("NPR CRO Salesperson OIB", ToBigInteger('00123456785'));

        // [Then] The OIB is kept, and it is formatted back to all 11 digits
        _Assert.AreEqual(ToBigInteger('00123456785'), CROAuxSalespersonPurch."NPR CRO Salesperson OIB", 'A valid OIB that starts with 00 must be accepted.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleCannotStartWithInvalidSalespersonOIB()
    var
        Salesperson: Record "Salesperson/Purchaser";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleWrapper: Codeunit "NPR POS Sale";
    begin
        // [Scenario] A salesperson whose stored OIB has a wrong check digit cannot start a sale, so no bill is created that the tax authority would reject
        // [Given] POS and CRO audit setup
        InitializeData();

        // [Given] A salesperson whose OIB was saved with a wrong check digit
        CreateSalespersonWithOIB(Salesperson, '11129995674');

        // [When] Starting a sale as that salesperson
        asserterror NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, Salesperson, POSSaleWrapper);

        // [Then] The sale is blocked
        _Assert.ExpectedError(InvalidSalespersonOIBTxt());
        _Assert.ExpectedErrorCode('Dialog');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleCannotEndAfterSwitchingToSalespersonWithInvalidOIB()
    var
        POSEntry: Record "NPR POS Entry";
        POSSaleRecord: Record "NPR POS Sale";
        Salesperson: Record "Salesperson/Purchaser";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSActionQuickLoginB: Codeunit "NPR POS Action: Quick Login B.";
        POSSaleWrapper: Codeunit "NPR POS Sale";
    begin
        // [Scenario] A sale can't end with a bill the tax authority would reject when the salesperson is switched during the sale to one whose OIB has a wrong check digit
        // [Given] POS and CRO audit setup, and a salesperson whose OIB was saved with a wrong check digit
        InitializeData();
        CreateSalespersonWithOIB(Salesperson, '11129995674');

        // [Given] A sale started by a salesperson with a valid OIB, then switched to that salesperson with Quick Login
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSaleRecord);
        NPRLibraryPOSMock.CreateItemLine(_POSSession, _Item."No.", 1);
        POSActionQuickLoginB.ApplySalespersonCode(Salesperson.Code, POSSaleWrapper);

        // [When] Paying and ending the sale
        asserterror NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, _Item."Unit Price", '');

        // [Then] The sale doesn't end
        _Assert.ExpectedError(InvalidSalespersonOIBTxt());
        _Assert.ExpectedErrorCode('Dialog');
        POSEntry.SetRange("Document No.", POSSaleRecord."Sales Ticket No.");
        _Assert.RecordIsEmpty(POSEntry);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FiscalBillKeepsLeadingZeroOfOperatorOIB()
    var
        Salesperson: Record "Salesperson/Purchaser";
        LibraryCROFiscal: Codeunit "NPR Library CRO Fiscal";
    begin
        // [Scenario] The operator OIB sent to the tax authority keeps its leading zero, so it has all 11 digits
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryCROFiscal);

        // [Given] POS and CRO audit setup, and a salesperson with the valid OIB 02994650199
        InitializeData();
        CreateSalespersonWithOIB(Salesperson, '02994650199');

        // [When] Ending a cash sale as that salesperson
        DoItemSale(Salesperson);

        // [Then] The bill sent for signing carries the operator OIB with its leading zero
        _Assert.AreEqual('02994650199', GetOperatorOIB(LibraryCROFiscal.GetLastSigningContent()), 'OibOper must keep the leading zero of the operator OIB.');

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit
        UnbindSubscription(LibraryCROFiscal);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SubsequentFiscalizationUsesCorrectedSalespersonOIB()
    var
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
        Salesperson: Record "Salesperson/Purchaser";
        CROAuditMgt: Codeunit "NPR CRO Audit Mgt.";
        LibraryCROFiscal: Codeunit "NPR Library CRO Fiscal";
    begin
        // [Scenario] A bill the tax authority rejected for its operator OIB is sent with the salesperson's corrected OIB when it is fiscalized again
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryCROFiscal);

        // [Given] POS and CRO audit setup, and a salesperson whose OIB has been corrected to 67603909448, which differs from the default salesperson's OIB
        InitializeData();
        CreateSalespersonWithOIB(Salesperson, '67603909448');

        // [Given] A bill by that salesperson that wasn't fiscalized because it carried the old OIB 11129995674
        CreateRejectedBill(CROPOSAuditLogAuxInfo, Salesperson, '11129995674');
        LibraryCROFiscal.ClearLastSigningContent();

        // [When] Fiscalizing the bill again with the Subsequently Fiscalize Bill action
        CROAuditMgt.FiscalizeSubsequently(CROPOSAuditLogAuxInfo);

        // [Then] The bill is sent with the corrected OIB of its own salesperson, keeps it and is fiscalized
        _Assert.AreEqual('67603909448', GetOperatorOIB(LibraryCROFiscal.GetLastSigningContent()), 'The bill must be sent with the salesperson''s corrected OIB.');
        CROPOSAuditLogAuxInfo.Find();
        _Assert.AreEqual(ToBigInteger('67603909448'), CROPOSAuditLogAuxInfo."Cashier ID", 'The bill must keep the salesperson''s corrected OIB.');
        _Assert.AreEqual(Salesperson.Code, CROPOSAuditLogAuxInfo."Salesperson Code", 'The bill must keep its own salesperson.');
        _Assert.AreNotEqual('', CROPOSAuditLogAuxInfo."JIR Code", 'The bill must be fiscalized by the tax authority.');

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit
        UnbindSubscription(LibraryCROFiscal);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SubsequentFiscalizationKeepsValidOperatorOIB()
    var
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
        Salesperson: Record "Salesperson/Purchaser";
        CROAuditMgt: Codeunit "NPR CRO Audit Mgt.";
        LibraryCROFiscal: Codeunit "NPR Library CRO Fiscal";
    begin
        // [Scenario] A bill keeps the valid OIB of the person who issued it, even if that salesperson's OIB has changed since
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryCROFiscal);

        // [Given] POS and CRO audit setup, and a bill that wasn't fiscalized yet, issued with the valid OIB 67603909448, which differs from the default salesperson's OIB
        InitializeData();
        CreateSalespersonWithOIB(Salesperson, '67603909448');
        CreateRejectedBill(CROPOSAuditLogAuxInfo, Salesperson, '67603909448');

        // [Given] The salesperson now has another valid OIB
        SetSalespersonOIB(Salesperson, '02994650199');
        LibraryCROFiscal.ClearLastSigningContent();

        // [When] Fiscalizing the bill again with the Subsequently Fiscalize Bill action
        CROAuditMgt.FiscalizeSubsequently(CROPOSAuditLogAuxInfo);

        // [Then] The bill is sent with the OIB it was issued with
        _Assert.AreEqual('67603909448', GetOperatorOIB(LibraryCROFiscal.GetLastSigningContent()), 'The bill must keep the OIB of the person who issued it.');

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit
        UnbindSubscription(LibraryCROFiscal);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SubsequentFiscalizationStopsWhileOperatorOIBIsInvalid()
    var
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
        Salesperson: Record "Salesperson/Purchaser";
        CROAuditMgt: Codeunit "NPR CRO Audit Mgt.";
        LibraryCROFiscal: Codeunit "NPR Library CRO Fiscal";
    begin
        // [Scenario] The Subsequently Fiscalize Bill action doesn't send a bill whose operator OIB has a wrong check digit while the salesperson's OIB is still wrong, and tells the user why
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryCROFiscal);

        // [Given] POS and CRO audit setup, and a bill that wasn't fiscalized because it carried the OIB 11129995674
        InitializeData();
        CreateSalespersonWithOIB(Salesperson, '11129995671');
        CreateRejectedBill(CROPOSAuditLogAuxInfo, Salesperson, '11129995674');

        // [Given] The salesperson's OIB still has the wrong check digit
        SetSalespersonOIB(Salesperson, '11129995674');
        LibraryCROFiscal.ClearLastSigningContent();

        // [When] Fiscalizing the bill again with the Subsequently Fiscalize Bill action
        asserterror CROAuditMgt.FiscalizeSubsequently(CROPOSAuditLogAuxInfo);

        // [Then] The user is told the operator OIB is invalid, and the bill isn't sent
        _Assert.ExpectedError(InvalidCashierIDTxt());
        _Assert.ExpectedErrorCode('Dialog');
        _Assert.AreEqual('', LibraryCROFiscal.GetLastSigningContent(), 'The bill must not be sent.');

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit
        UnbindSubscription(LibraryCROFiscal);
    end;

    [Test]
    [HandlerFunctions('InvalidOperatorOIBMessageHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AutomaticFiscalizationLeavesBillUnfiscalizedWhileOperatorOIBIsInvalid()
    var
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
        Salesperson: Record "Salesperson/Purchaser";
        LibraryCROFiscal: Codeunit "NPR Library CRO Fiscal";
        SentryCapture: Codeunit "NPR Library - Sentry Capture";
        CROTaxCommunicationMgt: Codeunit "NPR CRO Tax Communication Mgt.";
    begin
        // [Scenario] When a bill is fiscalized right after a sale or posting and its operator OIB is invalid, it isn't sent, and the user is told with a message instead of an error.
        // An error there would roll back the new bill after the posted document is already committed, leaving nothing to fiscalize later.
        _LastMessage := '';
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryCROFiscal);

        // [Given] POS and CRO audit setup, and a bill with the operator OIB 11129995674 by a salesperson whose OIB is also 11129995674
        InitializeData();
        CreateSalespersonWithOIB(Salesperson, '11129995671');
        CreateRejectedBill(CROPOSAuditLogAuxInfo, Salesperson, '11129995674');
        SetSalespersonOIB(Salesperson, '11129995674');
        LibraryCROFiscal.ClearLastSigningContent();

        // [When] The bill is fiscalized automatically, with its Sentry report captured instead of sent
        SentryCapture.Start();
        CROTaxCommunicationMgt.CreateNormalSale(CROPOSAuditLogAuxInfo, true);
        SentryCapture.Stop();

        // [Then] The bill isn't sent and stays unfiscalized for a later Subsequently Fiscalize Bill
        _Assert.AreEqual('', LibraryCROFiscal.GetLastSigningContent(), 'The bill must not be sent.');
        CROPOSAuditLogAuxInfo.Find();
        _Assert.IsFalse(CROPOSAuditLogAuxInfo."Receipt Fiscalized", 'The bill must stay unfiscalized.');

        // [Then] The user is told the bill wasn't sent because of its operator OIB
        _Assert.ExpectedMessage(BillNotSentForInvalidOIBTxt(), _LastMessage);

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit
        UnbindSubscription(LibraryCROFiscal);
    end;

    [Test]
    [HandlerFunctions('InvalidOperatorOIBMessageHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AutomaticFiscalizationReportsBillWithInvalidOperatorOIBToSentry()
    var
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
        Salesperson: Record "Salesperson/Purchaser";
        LibraryCROFiscal: Codeunit "NPR Library CRO Fiscal";
        SentryCapture: Codeunit "NPR Library - Sentry Capture";
        CROTaxCommunicationMgt: Codeunit "NPR CRO Tax Communication Mgt.";
    begin
        // [Scenario] A bill that isn't sent because of its invalid operator OIB reaches Sentry, also when no Sentry transaction is running, as in back-office posting or a job queue
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryCROFiscal);

        // [Given] POS and CRO audit setup, and a bill with the operator OIB 11129995674 by a salesperson whose OIB is also 11129995674
        InitializeData();
        CreateSalespersonWithOIB(Salesperson, '11129995671');
        CreateRejectedBill(CROPOSAuditLogAuxInfo, Salesperson, '11129995674');
        SetSalespersonOIB(Salesperson, '11129995674');

        // [When] The bill is fiscalized automatically with no Sentry transaction running
        SentryCapture.Start();
        CROTaxCommunicationMgt.CreateNormalSale(CROPOSAuditLogAuxInfo, true);
        SentryCapture.Stop();

        // [Then] Sentry gets the error, with the bill's entry type and salesperson
        _Assert.IsTrue(SentryCapture.Contains('was created with an operator OIB that is not valid'), 'A bill that was not sent for its invalid operator OIB must be reported to Sentry.');
        _Assert.IsTrue(SentryCapture.Count(Format(CROPOSAuditLogAuxInfo."Audit Entry Type"), Salesperson.Code) > 0, 'The Sentry report must name the bill''s entry type and salesperson.');

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit
        UnbindSubscription(LibraryCROFiscal);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SalesOrderFromPOSCannotBePostedWithInvalidOIBOfPOSSalesperson()
    var
        SalesHeader: Record "Sales Header";
        Salesperson: Record "Salesperson/Purchaser";
        LibraryCROFiscal: Codeunit "NPR Library CRO Fiscal";
        LibrarySales: Codeunit "Library - Sales";
    begin
        // [Scenario] A sales order created from POS carries the OIB of the POS salesperson on its bill, so it can't be posted while that OIB has a wrong check digit, even when the order's own salesperson has a valid OIB
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryCROFiscal);

        // [Given] POS and CRO audit setup, and a salesperson whose OIB was saved with a wrong check digit
        InitializeData();
        CreateSalespersonWithOIB(Salesperson, '11129995674');

        // [Given] A sales order for the CRO POS unit, created from a POS entry by that salesperson, whose own salesperson has a valid OIB
        CreateSalesOrderFromPOSEntry(SalesHeader, Salesperson);

        // [When] Shipping and invoicing the order
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [Then] Posting is blocked before anything is posted
        _Assert.ExpectedError(InvalidSalespersonOIBTxt());
        _Assert.ExpectedErrorCode('Dialog');

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit
        UnbindSubscription(LibraryCROFiscal);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SalesDocumentCannotBePostedWithInvalidSalespersonOIB()
    var
        CROAuxSalesHeader: Record "NPR CRO Aux Sales Header";
        CROPaymentMethodMapping: Record "NPR CRO Payment Method Mapping";
        PaymentMethod: Record "Payment Method";
        SalesHeader: Record "Sales Header";
        Salesperson: Record "Salesperson/Purchaser";
        LibraryCROFiscal: Codeunit "NPR Library CRO Fiscal";
        LibraryInventory: Codeunit "Library - Inventory";
        LibrarySales: Codeunit "Library - Sales";
    begin
        // [Scenario] A sales document fiscalized through a CRO POS unit can't be posted while its salesperson's OIB has a wrong check digit
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryCROFiscal);

        // [Given] POS and CRO audit setup, and a salesperson whose OIB was saved with a wrong check digit
        InitializeData();
        CreateSalespersonWithOIB(Salesperson, '11129995674');

        // [Given] A sales invoice for the CRO POS unit, sold by that salesperson
        LibraryInventory.CreatePaymentMethod(PaymentMethod);
        CROPaymentMethodMapping.Init();
        CROPaymentMethodMapping."Payment Method Code" := PaymentMethod.Code;
        CROPaymentMethodMapping.Insert();
        LibrarySales.CreateSalesInvoice(SalesHeader);
        SalesHeader.Validate("Salesperson Code", Salesperson.Code);
        SalesHeader.Validate("Payment Method Code", PaymentMethod.Code);
        SalesHeader.Modify(true);
        CROAuxSalesHeader.ReadCROAuxSalesHeaderFields(SalesHeader);
        CROAuxSalesHeader."NPR CRO POS Unit" := _POSUnit."No.";
        CROAuxSalesHeader.SaveCROAuxSalesHeaderFields();

        // [When] Posting the invoice
        asserterror LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [Then] Posting is blocked before anything is posted
        _Assert.ExpectedError(InvalidSalespersonOIBTxt());
        _Assert.ExpectedErrorCode('Dialog');

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit
        UnbindSubscription(LibraryCROFiscal);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SalesInvoicePostedFromPageCannotBePostedWithInvalidSalespersonOIB()
    var
        SalesHeader: Record "Sales Header";
        Salesperson: Record "Salesperson/Purchaser";
        LibraryCROFiscal: Codeunit "NPR Library CRO Fiscal";
    begin
        // [Scenario] The Post action on a sales invoice runs Sales-Post with Invoice still false, because Sales-Post only sets it after OnBeforePostSalesDoc. The invoice still creates a bill, so it can't be posted while its salesperson's OIB has a wrong check digit
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryCROFiscal);

        // [Given] POS and CRO audit setup, and a salesperson whose OIB was saved with a wrong check digit
        InitializeData();
        CreateSalespersonWithOIB(Salesperson, '11129995674');

        // [Given] A sales invoice for the CRO POS unit, sold by that salesperson, with the posting flags not set
        CreateCROSalesDocument(SalesHeader, SalesHeader."Document Type"::Invoice, Salesperson);

        // [When] Posting the invoice the way the Post action does
        asserterror Codeunit.Run(Codeunit::"Sales-Post", SalesHeader);

        // [Then] Posting is blocked before anything is posted
        _Assert.ExpectedError(InvalidSalespersonOIBTxt());
        _Assert.ExpectedErrorCode('Dialog');

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit
        UnbindSubscription(LibraryCROFiscal);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SalesCreditMemoPostedFromPageCannotBePostedWithInvalidSalespersonOIB()
    var
        SalesHeader: Record "Sales Header";
        Salesperson: Record "Salesperson/Purchaser";
        LibraryCROFiscal: Codeunit "NPR Library CRO Fiscal";
    begin
        // [Scenario] The Post action on a sales credit memo runs Sales-Post with Invoice still false, because Sales-Post only sets it after OnBeforePostSalesDoc. The credit memo still creates a bill, so it can't be posted while its salesperson's OIB has a wrong check digit
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryCROFiscal);

        // [Given] POS and CRO audit setup, and a salesperson whose OIB was saved with a wrong check digit
        InitializeData();
        CreateSalespersonWithOIB(Salesperson, '11129995674');

        // [Given] A sales credit memo for the CRO POS unit, sold by that salesperson, with the posting flags not set
        CreateCROSalesDocument(SalesHeader, SalesHeader."Document Type"::"Credit Memo", Salesperson);

        // [When] Posting the credit memo the way the Post action does
        asserterror Codeunit.Run(Codeunit::"Sales-Post", SalesHeader);

        // [Then] Posting is blocked before anything is posted
        _Assert.ExpectedError(InvalidSalespersonOIBTxt());
        _Assert.ExpectedErrorCode('Dialog');

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit
        UnbindSubscription(LibraryCROFiscal);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SalesOrderFromPOSCanBeShippedWithInvalidOIBOfPOSSalesperson()
    var
        SalesHeader: Record "Sales Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        Salesperson: Record "Salesperson/Purchaser";
        LibraryCROFiscal: Codeunit "NPR Library CRO Fiscal";
        LibrarySales: Codeunit "Library - Sales";
    begin
        // [Scenario] Shipping without invoicing creates no bill, so the OIB of the POS salesperson that the bill will carry doesn't block it
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryCROFiscal);

        // [Given] POS and CRO audit setup, and a salesperson whose OIB was saved with a wrong check digit
        InitializeData();
        CreateSalespersonWithOIB(Salesperson, '11129995674');

        // [Given] A sales order for the CRO POS unit, created from a POS entry by that salesperson, whose own salesperson has a valid OIB
        CreateSalesOrderFromPOSEntry(SalesHeader, Salesperson);

        // [When] Shipping the order without invoicing it
        LibrarySales.PostSalesDocument(SalesHeader, true, false);

        // [Then] The shipment is posted
        SalesShipmentHeader.SetRange("Order No.", SalesHeader."No.");
        _Assert.RecordIsNotEmpty(SalesShipmentHeader);

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit
        UnbindSubscription(LibraryCROFiscal);
    end;

    [Test]
    [HandlerFunctions('FiscalizedMessageHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure InvoicedSalesOrderFromPOSIsFiscalizedWithOIBOfPOSSalesperson()
    var
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
        OrderSalesperson: Record "Salesperson/Purchaser";
        POSSalesperson: Record "Salesperson/Purchaser";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        LibraryCROFiscal: Codeunit "NPR Library CRO Fiscal";
        LibrarySales: Codeunit "Library - Sales";
    begin
        // [Scenario] The bill of an invoiced sales order created from POS carries the OIB of the POS salesperson. The check before posting and the bill pick the same salesperson, so an invalid OIB of the order's own salesperson neither blocks posting nor ends up on the bill
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryCROFiscal);

        // [Given] POS and CRO audit setup, a POS salesperson with the valid OIB 67603909448, and an order salesperson whose OIB has a wrong check digit
        InitializeData();
        CreateSalespersonWithOIB(POSSalesperson, '67603909448');
        CreateSalespersonWithOIB(OrderSalesperson, '11129995674');

        // [Given] A sales order for the CRO POS unit, created from a POS entry by the POS salesperson and sold by the order salesperson
        CreateSalesDocumentFromPOSEntry(SalesHeader, SalesHeader."Document Type"::Order, POSSalesperson, OrderSalesperson);
        LibraryCROFiscal.ClearLastSigningContent();

        // [When] Shipping and invoicing the order
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [Then] The invoice's bill is sent and kept with the POS salesperson's OIB
        SalesInvoiceHeader.SetRange("Order No.", SalesHeader."No.");
        SalesInvoiceHeader.FindFirst();
        FindPostedDocumentBill(CROPOSAuditLogAuxInfo, CROPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Invoice", SalesInvoiceHeader."No.");
        _Assert.AreEqual('67603909448', GetOperatorOIB(LibraryCROFiscal.GetLastSigningContent()), 'The invoice''s bill must be sent with the POS salesperson''s OIB.');
        _Assert.AreEqual(ToBigInteger('67603909448'), CROPOSAuditLogAuxInfo."Cashier ID", 'The invoice''s bill must keep the POS salesperson''s OIB.');
        _Assert.AreEqual(POSSalesperson.Code, CROPOSAuditLogAuxInfo."Salesperson Code", 'The invoice''s bill must record the POS salesperson.');

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit
        UnbindSubscription(LibraryCROFiscal);
    end;

    [Test]
    [HandlerFunctions('FiscalizedMessageHandler')]
    [TestPermissions(TestPermissions::Disabled)]
    procedure InvoicedReturnOrderFromPOSIsFiscalizedWithOIBOfPOSSalesperson()
    var
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
        OrderSalesperson: Record "Salesperson/Purchaser";
        POSSalesperson: Record "Salesperson/Purchaser";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesHeader: Record "Sales Header";
        LibraryCROFiscal: Codeunit "NPR Library CRO Fiscal";
        LibrarySales: Codeunit "Library - Sales";
    begin
        // [Scenario] The bill of an invoiced return order created from POS carries the OIB of the POS salesperson. The check before posting and the bill pick the same salesperson, so an invalid OIB of the return order's own salesperson neither blocks posting nor ends up on the bill
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryCROFiscal);

        // [Given] POS and CRO audit setup, a POS salesperson with the valid OIB 67603909448, and a return order salesperson whose OIB has a wrong check digit
        InitializeData();
        CreateSalespersonWithOIB(POSSalesperson, '67603909448');
        CreateSalespersonWithOIB(OrderSalesperson, '11129995674');

        // [Given] A return order for the CRO POS unit, created from a POS entry by the POS salesperson and sold by the return order salesperson
        CreateSalesDocumentFromPOSEntry(SalesHeader, SalesHeader."Document Type"::"Return Order", POSSalesperson, OrderSalesperson);
        LibraryCROFiscal.ClearLastSigningContent();

        // [When] Receiving and invoicing the return order
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [Then] The credit memo's bill is sent and kept with the POS salesperson's OIB
        SalesCrMemoHeader.SetRange("Return Order No.", SalesHeader."No.");
        SalesCrMemoHeader.FindFirst();
        FindPostedDocumentBill(CROPOSAuditLogAuxInfo, CROPOSAuditLogAuxInfo."Audit Entry Type"::"Sales Credit Memo", SalesCrMemoHeader."No.");
        _Assert.AreEqual('67603909448', GetOperatorOIB(LibraryCROFiscal.GetLastSigningContent()), 'The credit memo''s bill must be sent with the POS salesperson''s OIB.');
        _Assert.AreEqual(ToBigInteger('67603909448'), CROPOSAuditLogAuxInfo."Cashier ID", 'The credit memo''s bill must keep the POS salesperson''s OIB.');
        _Assert.AreEqual(POSSalesperson.Code, CROPOSAuditLogAuxInfo."Salesperson Code", 'The credit memo''s bill must record the POS salesperson.');

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit
        UnbindSubscription(LibraryCROFiscal);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SubsequentFiscalizationOfBillWithoutSalespersonUsesSalespersonOfPOSEntry()
    var
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
        Salesperson: Record "Salesperson/Purchaser";
        CROAuditMgt: Codeunit "NPR CRO Audit Mgt.";
        LibraryCROFiscal: Codeunit "NPR Library CRO Fiscal";
    begin
        // [Scenario] Bills created before the CRO audit log stored the salesperson have no Salesperson Code. A rejected one is fiscalized again with the corrected OIB of the salesperson on its POS entry
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryCROFiscal);

        // [Given] POS and CRO audit setup, and a salesperson whose OIB has been corrected to 67603909448, which differs from the default salesperson's OIB
        InitializeData();
        CreateSalespersonWithOIB(Salesperson, '67603909448');

        // [Given] A bill by that salesperson with the old OIB 11129995674 and no Salesperson Code, like a bill from before the field existed
        CreateRejectedBill(CROPOSAuditLogAuxInfo, Salesperson, '11129995674');
        CROPOSAuditLogAuxInfo."Salesperson Code" := '';
        CROPOSAuditLogAuxInfo.Modify();
        LibraryCROFiscal.ClearLastSigningContent();

        // [When] Fiscalizing the bill again with the Subsequently Fiscalize Bill action
        CROAuditMgt.FiscalizeSubsequently(CROPOSAuditLogAuxInfo);

        // [Then] The bill is sent with the corrected OIB, records the salesperson it came from and is fiscalized
        _Assert.AreEqual('67603909448', GetOperatorOIB(LibraryCROFiscal.GetLastSigningContent()), 'The bill must be sent with the corrected OIB of the POS entry''s salesperson.');
        CROPOSAuditLogAuxInfo.Find();
        _Assert.AreEqual(Salesperson.Code, CROPOSAuditLogAuxInfo."Salesperson Code", 'The bill must record the salesperson whose OIB it now carries.');
        _Assert.AreNotEqual('', CROPOSAuditLogAuxInfo."JIR Code", 'The bill must be fiscalized by the tax authority.');

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit
        UnbindSubscription(LibraryCROFiscal);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SubsequentFiscalizationStopsWhenBillSalespersonNoLongerExists()
    var
        CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info";
        Salesperson: Record "Salesperson/Purchaser";
        CROAuditMgt: Codeunit "NPR CRO Audit Mgt.";
        LibraryCROFiscal: Codeunit "NPR Library CRO Fiscal";
    begin
        // [Scenario] When the salesperson of a rejected bill has been deleted, no corrected OIB can be found, and the user is told that instead of being asked to correct a salesperson that doesn't exist
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryCROFiscal);

        // [Given] POS and CRO audit setup, and a bill with the invalid OIB 11129995674 by a salesperson who has since been deleted
        InitializeData();
        CreateSalespersonWithOIB(Salesperson, '11129995671');
        CreateRejectedBill(CROPOSAuditLogAuxInfo, Salesperson, '11129995674');
        Salesperson.Delete(true);
        LibraryCROFiscal.ClearLastSigningContent();

        // [When] Fiscalizing the bill again with the Subsequently Fiscalize Bill action
        asserterror CROAuditMgt.FiscalizeSubsequently(CROPOSAuditLogAuxInfo);

        // [Then] The user is told the bill has no salesperson whose OIB could replace the invalid one
        _Assert.ExpectedError(NoSalespersonForCashierIDTxt());
        _Assert.ExpectedErrorCode('Dialog');

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit
        UnbindSubscription(LibraryCROFiscal);
    end;

    internal procedure InitializeData()
    var
        ObjectOutputSelection: Record "NPR Object Output Selection";
        POSAuditLog: Record "NPR POS Audit Log";
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSEndOfDayProfile: Record "NPR POS End of Day Profile";
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        TemplateHeader: Record "NPR RP Template Header";
        LibraryERM: Codeunit "Library - ERM";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryRPTemplate: Codeunit "NPR Library - RP Template Data";
        LibraryCROFiscal: Codeunit "NPR Library CRO Fiscal";
    begin
        //Clean any previous mock session
        _POSSession.ClearAll();
        Clear(_POSSession);

        if not _Initialized then begin
            NPRLibraryPOSMasterData.CreatePOSSetup(POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultVoucherType(_VoucherTypeDefault, false);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(_POSPostingProfile);
            _POSPostingProfile."POS Period Register No. Series" := '';
            _POSPostingProfile.Modify();
            NPRLibraryPOSMasterData.CreatePOSStore(POSStore, _POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(GetTestPOSUnitNo(), _POSUnit, POSStore.Code, _POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_POSPaymentMethod, _POSPaymentMethod."Processing Type"::CASH, '', false);
            NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(_Item, _POSUnit, POSStore);
            NPRLibraryPOSMasterData.CreateSalespersonForPOSUsage(_Salesperson);

            POSEndOfDayProfile.Code := 'EOD-TEST';
            POSEndOfDayProfile."Z-Report UI" := POSEndOfDayProfile."Z-Report UI"::BALANCING;
            POSEndOfDayProfile.Insert();

            _POSUnit."POS End of Day Profile" := POSEndOfDayProfile.Code;
            _POSUnit.Modify();

            LibraryERM.CreateReturnReasonCode(_ReturnReason);
            _Item."Unit Price" := 10;
            _Item.Modify();

            LibraryCROFiscal.CreateAuditProfileAndCROSetup(POSAuditProfile, _POSUnit, _POSPaymentMethod, _Salesperson);

            ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::"Sales Receipt (POS Entry)");
            ReportSelectionRetail.DeleteAll();
            ObjectOutputSelection.DeleteAll();

            LibraryRPTemplate.CreateDummySalesReceipt(TemplateHeader);
            LibraryRPTemplate.ConfigureReportSelection(ReportSelectionRetail."Report Type"::"Sales Receipt (POS Entry)", TemplateHeader);

            _Initialized := true;
        end;

        POSAuditLog.DeleteAll(true); //Clean in between tests
        Commit();
    end;

    local procedure DoItemSale(): Integer
    begin
        exit(DoItemSale(_Salesperson));
    end;

    local procedure DoItemSale(Salesperson: Record "Salesperson/Purchaser"): Integer
    var
        POSEntry: Record "NPR POS Entry";
        POSSaleRecord: Record "NPR POS Sale";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleWrapper: Codeunit "NPR POS Sale";
    begin
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSaleRecord);
        NPRLibraryPOSMock.CreateItemLine(_POSSession, _Item."No.", 1);
        if not (NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, _Item."Unit Price", '')) then
            Error('Sale did not end as expected');
        POSEntry.SetRange("Document No.", POSSaleRecord."Sales Ticket No.");
        POSEntry.FindFirst();
        _POSSession.ClearAll();
        Clear(_POSSession);
        exit(POSEntry."Entry No.");
    end;

    local procedure DoItemSaleWithParagon(): Integer
    var
        POSEntry: Record "NPR POS Entry";
        POSSaleRecord: Record "NPR POS Sale";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSActionParagonInsert: Codeunit "NPR POS Action: CROParagon Ins";
        POSSaleWrapper: Codeunit "NPR POS Sale";
    begin
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSaleRecord);
        POSActionParagonInsert.InputAuditParagonNumberTest(GetTestParagonNo(), POSSaleRecord);
        NPRLibraryPOSMock.CreateItemLine(_POSSession, _Item."No.", 1);
        if not (NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, _Item."Unit Price", '')) then
            Error('Sale did not end as expected');
        POSEntry.SetRange("Document No.", POSSaleRecord."Sales Ticket No.");
        POSEntry.FindFirst();
        _POSSession.ClearAll();
        Clear(_POSSession);
        exit(POSEntry."Entry No.");
    end;

    local procedure DoReturnSale(ReceiptNumberToReturn: Code[20]): Integer
    var
        POSEntry: Record "NPR POS Entry";
        POSSaleRecord: Record "NPR POS Sale";
        NPRLibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSActionRevDirSale: Codeunit "NPR POS Action: Rev.Dir.Sale B";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        ChangeAmount: Decimal;
        PaidAmount: Decimal;
        RoundingAmount: Decimal;
        SalesAmount: Decimal;
    begin
        NPRLibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSaleRecord);
        POSActionRevDirSale.ReverseSalesTicket(POSSaleRecord, ReceiptNumberToReturn, _ReturnReason.Code, true);
        POSSaleWrapper.GetTotals(SalesAmount, PaidAmount, ChangeAmount, RoundingAmount);
        if not (NPRLibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, SalesAmount, '')) then
            Error('Sale did not end as expected');
        POSEntry.SetRange("Document No.", POSSaleRecord."Sales Ticket No.");
        POSEntry.FindFirst();
        _POSSession.ClearAll();
        Clear(_POSSession);
        exit(POSEntry."Entry No.");
    end;

    local procedure GetTestPOSUnitNo(): Code[10]
    begin
        exit('077');
    end;

    local procedure GetTestParagonNo(): Text
    begin
        exit('123/777');
    end;

    local procedure CreateSalespersonWithOIB(var Salesperson: Record "Salesperson/Purchaser"; OIBText: Text)
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        NPRLibraryPOSMasterData.CreateSalespersonForPOSUsage(Salesperson);
        SetSalespersonOIB(Salesperson, OIBText);
    end;

    local procedure SetSalespersonOIB(Salesperson: Record "Salesperson/Purchaser"; OIBText: Text)
    var
        CROAuxSalespersonPurch: Record "NPR CRO Aux Salesperson/Purch.";
    begin
        // Assigned without validation, like an OIB that was saved before its check digit was checked
        CROAuxSalespersonPurch.ReadCROAuxSalespersonFields(Salesperson);
        CROAuxSalespersonPurch."NPR CRO Salesperson OIB" := ToBigInteger(OIBText);
        CROAuxSalespersonPurch.SaveCROAuxSalespersonFields();
    end;

    local procedure CreateRejectedBill(var CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; Salesperson: Record "Salesperson/Purchaser"; CashierOIBText: Text)
    var
        EntryNumber: Integer;
    begin
        EntryNumber := DoItemSale(Salesperson);
        CROPOSAuditLogAuxInfo.SetRange("Audit Entry Type", CROPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
        CROPOSAuditLogAuxInfo.SetRange("POS Entry No.", EntryNumber);
        CROPOSAuditLogAuxInfo.FindFirst();
        // Back to how the bill looked after the tax authority rejected it
        CROPOSAuditLogAuxInfo."Cashier ID" := ToBigInteger(CashierOIBText);
        CROPOSAuditLogAuxInfo."JIR Code" := '';
        CROPOSAuditLogAuxInfo."Receipt Fiscalized" := false;
        CROPOSAuditLogAuxInfo.Modify();
    end;

    local procedure CreateSalesOrderFromPOSEntry(var SalesHeader: Record "Sales Header"; POSSalesperson: Record "Salesperson/Purchaser")
    begin
        // A POS entry by POSSalesperson, and a sales order for the CRO POS unit linked to it, sold by the default salesperson whose OIB is valid
        CreateSalesDocumentFromPOSEntry(SalesHeader, SalesHeader."Document Type"::Order, POSSalesperson, _Salesperson);
    end;

    local procedure CreateSalesDocumentFromPOSEntry(var SalesHeader: Record "Sales Header"; DocumentType: Enum "Sales Document Type"; POSSalesperson: Record "Salesperson/Purchaser"; DocumentSalesperson: Record "Salesperson/Purchaser")
    var
        CROAuxSalesHeader: Record "NPR CRO Aux Sales Header";
        CROPaymentMethodMapping: Record "NPR CRO Payment Method Mapping";
        PaymentMethod: Record "Payment Method";
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
        SalesLine: Record "Sales Line";
        LibraryInventory: Codeunit "Library - Inventory";
        LibrarySales: Codeunit "Library - Sales";
    begin
        // A POS entry by POSSalesperson, and a sales order or return order for the CRO POS unit linked to it, sold by DocumentSalesperson
        POSEntry.Get(DoItemSale());
        POSEntry."Salesperson Code" := POSSalesperson.Code;
        POSEntry.Modify();

        LibraryInventory.CreatePaymentMethod(PaymentMethod);
        CROPaymentMethodMapping.Init();
        CROPaymentMethodMapping."Payment Method Code" := PaymentMethod.Code;
        CROPaymentMethodMapping.Insert();
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, LibrarySales.CreateCustomerNo());
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, LibraryInventory.CreateItemNo(), 1);
        SalesHeader.Validate("Salesperson Code", DocumentSalesperson.Code);
        SalesHeader.Validate("Payment Method Code", PaymentMethod.Code);
        SalesHeader.Modify(true);
        CROAuxSalesHeader.ReadCROAuxSalesHeaderFields(SalesHeader);
        CROAuxSalesHeader."NPR CRO POS Unit" := _POSUnit."No.";
        CROAuxSalesHeader.SaveCROAuxSalesHeaderFields();

        POSEntrySalesDocLink.Init();
        POSEntrySalesDocLink."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesDocLink."POS Entry Reference Type" := POSEntrySalesDocLink."POS Entry Reference Type"::HEADER;
        if DocumentType = SalesHeader."Document Type"::"Return Order" then
            POSEntrySalesDocLink."Sales Document Type" := POSEntrySalesDocLink."Sales Document Type"::RETURN_ORDER
        else
            POSEntrySalesDocLink."Sales Document Type" := POSEntrySalesDocLink."Sales Document Type"::ORDER;
        POSEntrySalesDocLink."Sales Document No" := SalesHeader."No.";
        POSEntrySalesDocLink.Insert();
    end;

    local procedure FindPostedDocumentBill(var CROPOSAuditLogAuxInfo: Record "NPR CRO POS Aud. Log Aux. Info"; AuditEntryType: Enum "NPR CRO Audit Entry Type"; PostedDocumentNo: Code[20])
    begin
        CROPOSAuditLogAuxInfo.SetRange("Audit Entry Type", AuditEntryType);
        CROPOSAuditLogAuxInfo.SetRange("Source Document No.", PostedDocumentNo);
        CROPOSAuditLogAuxInfo.FindFirst();
    end;

    local procedure CreateCROSalesDocument(var SalesHeader: Record "Sales Header"; DocumentType: Enum "Sales Document Type"; Salesperson: Record "Salesperson/Purchaser")
    var
        CROAuxSalesHeader: Record "NPR CRO Aux Sales Header";
        CROPaymentMethodMapping: Record "NPR CRO Payment Method Mapping";
        PaymentMethod: Record "Payment Method";
        SalesLine: Record "Sales Line";
        LibraryInventory: Codeunit "Library - Inventory";
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibraryInventory.CreatePaymentMethod(PaymentMethod);
        CROPaymentMethodMapping.Init();
        CROPaymentMethodMapping."Payment Method Code" := PaymentMethod.Code;
        CROPaymentMethodMapping.Insert();
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, LibrarySales.CreateCustomerNo());
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, LibraryInventory.CreateItemNo(), 1);
        SalesHeader.Validate("Salesperson Code", Salesperson.Code);
        SalesHeader.Validate("Payment Method Code", PaymentMethod.Code);
        SalesHeader.Ship := false;
        SalesHeader.Receive := false;
        SalesHeader.Invoice := false;
        SalesHeader.Modify(true);
        CROAuxSalesHeader.ReadCROAuxSalesHeaderFields(SalesHeader);
        CROAuxSalesHeader."NPR CRO POS Unit" := _POSUnit."No.";
        CROAuxSalesHeader.SaveCROAuxSalesHeaderFields();
    end;

    local procedure GetOperatorOIB(SigningContent: Text): Text
    var
        EndPos: Integer;
        StartPos: Integer;
    begin
        StartPos := StrPos(SigningContent, '<OibOper>');
        EndPos := StrPos(SigningContent, '</OibOper>');
        if (StartPos = 0) or (EndPos = 0) then
            exit('');
        StartPos += StrLen('<OibOper>');
        exit(CopyStr(SigningContent, StartPos, EndPos - StartPos));
    end;

    local procedure ToBigInteger(ValueText: Text) Value: BigInteger
    begin
        Evaluate(Value, ValueText);
    end;

    local procedure InvalidEnteredOIBTxt(): Text
    begin
        exit('is not a valid OIB. An OIB has 11 digits');
    end;

    local procedure InvalidSalespersonOIBTxt(): Text
    begin
        exit('is not a valid OIB, so the tax authority would reject its bills');
    end;

    local procedure InvalidCashierIDTxt(): Text
    begin
        exit('is not a valid OIB, so the tax authority would reject the bill.');
    end;

    local procedure NoSalespersonForCashierIDTxt(): Text
    begin
        exit('whose OIB could replace it.');
    end;

    local procedure BillNotSentForInvalidOIBTxt(): Text
    begin
        exit('is not a valid OIB, so the bill was not sent to the tax authority.');
    end;

    [MessageHandler]
    procedure InvalidOperatorOIBMessageHandler(Message: Text[1024])
    begin
        _LastMessage := Message;
    end;

    [MessageHandler]
    procedure FiscalizedMessageHandler(Message: Text[1024])
    begin
        _Assert.ExpectedMessage('has been fiscalized successfully', Message);
    end;
}