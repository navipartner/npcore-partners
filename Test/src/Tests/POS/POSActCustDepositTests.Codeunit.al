codeunit 85096 "NPR POS Act. CustDeposit Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";
        SalesHeader: record "Sales Header";
        SalePOS: Record "NPR POS Sale";
        AppliesToIDLbl: Label '%1-%2', Locked = true;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('OpenApplyCustLedgEntries')]
    procedure ApplyCustomerEntries()
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSActionBusinessLogic: Codeunit "NPR POS Action: Cust.Deposit B";
        DepositType: Option ApplyCustomerEntries,InvoiceNoPrompt,AmountPrompt,MatchCustomerBalance,CrMemoNoPrompt;
        CustomerEntryView: Text;
        PromptValue: Text;
        PromptAmt: Decimal;
        LibrarySales: Codeunit "Library - Sales";
        SaleLinePOS: Record "NPR POS Sale Line";
        PostedSalesInv: Code[20];
        CustLedgEntry: Record "Cust. Ledger Entry";
        BALANCING_OF: Label 'Balancing of %1 %2';
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibrarySales.CreateSalesInvoice(SalesHeader);
        PostedSalesInv := LibrarySales.PostSalesDocument(SalesHeader, false, true);
        POSSale.GetCurrentSale(SalePOS);

        SalePOS.Validate("Customer No.", SalesHeader."Bill-to Customer No.");
        POSSale.RefreshCurrent();

        PromptAmt := 0;
        PromptValue := '';
        DepositType := DepositType::ApplyCustomerEntries;
        CustomerEntryView := '';

        POSActionBusinessLogic.CreateDeposit(DepositType, CustomerEntryView, POSSale, POSSaleLine, PromptValue, PromptAmt, false);

        POSSale.GetCurrentSale(SalePOS);

        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindFirst() then;

        GetCustLedgerEntry(CustLedgEntry, PostedSalesInv);

        Assert.IsTrue(SaleLinePOS."Line Type" = SaleLinePOS."Line Type"::"Customer Deposit", 'Line type inserted');
        Assert.IsTrue(SaleLinePOS."No." = CustLedgEntry."Customer No.", 'Customer inserted');
        Assert.IsTrue(SaleLinePOS."Buffer Document Type" = CustLedgEntry."Document Type", 'Document Type inserted');
        Assert.IsTrue(SaleLinePOS."Buffer Document No." = CustLedgEntry."Document No.", 'Document No. inserted');
        Assert.IsTrue(SaleLinePOS."Posted Sales Document Type" = SaleLinePOS."Posted Sales Document Type"::INVOICE, 'Posted Sales Document Type inserted');
        Assert.IsTrue(SaleLinePOS."Posted Sales Document No." = CustLedgEntry."Document No.", 'Posted Sales Document No, inserted');
        Assert.IsTrue(SaleLinePOS.Quantity = 1, 'Quantity inserted');
        Assert.IsTrue(SaleLinePOS.Description = StrSubStno(BALANCING_OF, FORMAT(CustLedgEntry."Document Type"), CustLedgEntry."Document No."), 'Description inserted');
        Assert.IsTrue(SaleLinePOS."Line Amount" = CustLedgEntry."Remaining Amount", 'Remaining Amount inserted');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure InvoiceNo()
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSActionBusinessLogic: Codeunit "NPR POS Action: Cust.Deposit B";
        DepositType: Option ApplyCustomerEntries,InvoiceNoPrompt,AmountPrompt,MatchCustomerBalance,CrMemoNoPrompt;
        CustomerEntryView: Text;
        PromptValue: Text;
        PromptAmt: Decimal;
        LibrarySales: Codeunit "Library - Sales";
        SaleLinePOS: Record "NPR POS Sale Line";
        PostedSalesInv: Code[20];
        CustLedgEntry: Record "Cust. Ledger Entry";
        BALANCING_OF: Label 'Balancing of %1 %2';
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibrarySales.CreateSalesInvoice(SalesHeader);
        PostedSalesInv := LibrarySales.PostSalesDocument(SalesHeader, false, true);
        POSSale.GetCurrentSale(SalePOS);

        SalePOS.Validate("Customer No.", SalesHeader."Bill-to Customer No.");
        POSSale.RefreshCurrent();

        PromptAmt := 0;
        PromptValue := PostedSalesInv;
        DepositType := DepositType::InvoiceNoPrompt;
        CustomerEntryView := '';

        POSActionBusinessLogic.CreateDeposit(DepositType, CustomerEntryView, POSSale, POSSaleLine, PromptValue, PromptAmt, false);

        POSSale.GetCurrentSale(SalePOS);

        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindFirst() then;

        GetCustLedgerEntry(CustLedgEntry, PostedSalesInv);

        Assert.IsTrue(SaleLinePOS."Line Type" = SaleLinePOS."Line Type"::"Customer Deposit", 'Line type inserted');
        Assert.IsTrue(SaleLinePOS."No." = CustLedgEntry."Customer No.", 'Customer inserted');
        Assert.IsTrue(SaleLinePOS."Buffer Document Type" = CustLedgEntry."Document Type", 'Document Type inserted');
        Assert.IsTrue(SaleLinePOS."Buffer Document No." = CustLedgEntry."Document No.", 'Document No. inserted');
        Assert.IsTrue(SaleLinePOS."Posted Sales Document Type" = SaleLinePOS."Posted Sales Document Type"::INVOICE, 'Posted Sales Document Type inserted');
        Assert.IsTrue(SaleLinePOS."Posted Sales Document No." = CustLedgEntry."Document No.", 'Posted Sales Document No, inserted');
        Assert.IsTrue(SaleLinePOS.Quantity = 1, 'Quantity inserted');
        Assert.IsTrue(SaleLinePOS.Description = StrSubStno(BALANCING_OF, FORMAT(CustLedgEntry."Document Type"), CustLedgEntry."Document No."), 'Description inserted');
        Assert.IsTrue(SaleLinePOS."Line Amount" = CustLedgEntry."Remaining Amount", 'Remaining Amount inserted');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure CreditMemo()
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSActionBusinessLogic: Codeunit "NPR POS Action: Cust.Deposit B";
        DepositType: Option ApplyCustomerEntries,InvoiceNoPrompt,AmountPrompt,MatchCustomerBalance,CrMemoNoPrompt;
        CustomerEntryView: Text;
        PromptValue: Text;
        PromptAmt: Decimal;
        LibrarySales: Codeunit "Library - Sales";
        SaleLinePOS: Record "NPR POS Sale Line";
        PostedSalesCrMemo: Code[20];
        CustLedgEntry: Record "Cust. Ledger Entry";
        BALANCING_OF: Label 'Balancing of %1 %2';
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibrarySales.CreateSalesCreditMemo(SalesHeader);
        PostedSalesCrMemo := LibrarySales.PostSalesDocument(SalesHeader, false, true);
        POSSale.GetCurrentSale(SalePOS);

        SalePOS.Validate("Customer No.", SalesHeader."Bill-to Customer No.");
        POSSale.RefreshCurrent();

        PromptAmt := 0;
        PromptValue := PostedSalesCrMemo;
        DepositType := DepositType::CrMemoNoPrompt;
        CustomerEntryView := '';

        POSActionBusinessLogic.CreateDeposit(DepositType, CustomerEntryView, POSSale, POSSaleLine, PromptValue, PromptAmt, false);

        POSSale.GetCurrentSale(SalePOS);

        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindFirst() then;

        GetCustLedgerEntry(CustLedgEntry, PostedSalesCrMemo);

        Assert.IsTrue(SaleLinePOS."Line Type" = SaleLinePOS."Line Type"::"Customer Deposit", 'Line type inserted');
        Assert.IsTrue(SaleLinePOS."No." = CustLedgEntry."Customer No.", 'Customer inserted');
        Assert.IsTrue(SaleLinePOS."Buffer Document Type" = CustLedgEntry."Document Type", 'Document Type inserted');
        Assert.IsTrue(SaleLinePOS."Buffer Document No." = CustLedgEntry."Document No.", 'Document No. inserted');
        Assert.IsTrue(SaleLinePOS."Posted Sales Document Type" = SaleLinePOS."Posted Sales Document Type"::CREDIT_MEMO, 'Posted Sales Document Type inserted');
        Assert.IsTrue(SaleLinePOS."Posted Sales Document No." = CustLedgEntry."Document No.", 'Posted Sales Document No, inserted');
        Assert.IsTrue(SaleLinePOS.Quantity = 1, 'Quantity inserted');
        Assert.IsTrue(SaleLinePOS.Description = StrSubStno(BALANCING_OF, FORMAT(CustLedgEntry."Document Type"), CustLedgEntry."Document No."), 'Description inserted');
        Assert.IsTrue(SaleLinePOS."Line Amount" = CustLedgEntry."Remaining Amount", 'Remaining Amount inserted');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Amount()
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSActionBusinessLogic: Codeunit "NPR POS Action: Cust.Deposit B";
        DepositType: Option ApplyCustomerEntries,InvoiceNoPrompt,AmountPrompt,MatchCustomerBalance,CrMemoNoPrompt;
        CustomerEntryView: Text;
        PromptValue: Text;
        PromptAmt: Decimal;
        LibrarySales: Codeunit "Library - Sales";
        SaleLinePOS: Record "NPR POS Sale Line";
        PostedSalesInv: Code[20];
        TextDeposit: Label 'Deposit from: %1';
        LibraryRandom: Codeunit "Library - Random";
        Customer: Record Customer;
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibrarySales.CreateCustomer(Customer);

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        POSSale.GetCurrentSale(SalePOS);

        SalePOS.Validate("Customer No.", Customer."No.");
        POSSale.RefreshCurrent();

        PromptAmt := LibraryRandom.RandDec(10, 0);
        PromptValue := PostedSalesInv;
        DepositType := DepositType::AmountPrompt;
        CustomerEntryView := '';

        POSActionBusinessLogic.CreateDeposit(DepositType, CustomerEntryView, POSSale, POSSaleLine, PromptValue, PromptAmt, false);

        POSSale.GetCurrentSale(SalePOS);

        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindFirst() then;

        Assert.IsTrue(SaleLinePOS."Line Type" = SaleLinePOS."Line Type"::"Customer Deposit", 'Line type inserted');
        Assert.IsTrue(SaleLinePOS."No." = SalePOS."Customer No.", 'Customer inserted');
        Assert.IsTrue(SaleLinePOS.Quantity = 1, 'Quantity inserted');
        Assert.IsTrue(SaleLinePOS.Description = StrSubStno(TextDeposit, SalePOS.Name), 'Description inserted');
        Assert.IsTrue(SaleLinePOS.Amount = PromptAmt, 'Amount inserted');
        Assert.IsTrue(SaleLinePOS."Unit Price" = PromptAmt, 'Unit price inserted');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MatchCustomerBalance()
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSActionBusinessLogic: Codeunit "NPR POS Action: Cust.Deposit B";
        DepositType: Option ApplyCustomerEntries,InvoiceNoPrompt,AmountPrompt,MatchCustomerBalance,CrMemoNoPrompt;
        CustomerEntryView: Text;
        PromptValue: Text;
        PromptAmt: Decimal;
        LibrarySales: Codeunit "Library - Sales";
        SaleLinePOS: Record "NPR POS Sale Line";
        PostedSalesInv: Code[20];
        TextDeposit: Label 'Deposit from: %1';
        Customer: Record Customer;
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        LibrarySales.CreateSalesInvoice(SalesHeader);
        PostedSalesInv := LibrarySales.PostSalesDocument(SalesHeader, false, true);

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        POSSale.GetCurrentSale(SalePOS);

        SalePOS.Validate("Customer No.", SalesHeader."Bill-to Customer No.");
        POSSale.RefreshCurrent();

        PromptAmt := 0;
        PromptValue := PostedSalesInv;
        DepositType := DepositType::MatchCustomerBalance;
        CustomerEntryView := '';

        POSActionBusinessLogic.CreateDeposit(DepositType, CustomerEntryView, POSSale, POSSaleLine, PromptValue, PromptAmt, false);

        Customer.Get(SalePOS."Customer No.");
        Customer.CalcFields("Balance (LCY)");

        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindFirst() then;

        Assert.IsTrue(SaleLinePOS."Line Type" = SaleLinePOS."Line Type"::"Customer Deposit", 'Line type inserted');
        Assert.IsTrue(SaleLinePOS."No." = Customer."No.", 'Customer inserted');
        Assert.IsTrue(SaleLinePOS.Quantity = 1, 'Quantity inserted');
        Assert.IsTrue(SaleLinePOS.Description = StrSubStno(TextDeposit, Customer."No."), 'Description inserted');
        Assert.IsTrue(SaleLinePOS."Line Amount" = Customer."Balance (LCY)", 'Remaining Amount inserted');
    end;

    [ModalPageHandler]
    procedure OpenApplyCustLedgEntries(var ApplyCustLedgEntries: TestPage "NPR POS Apply Cust. Entries")
    var
    begin
        ApplyCustLedgEntries.AppliesToID.Value := StrSubstNo(AppliesToIDLbl, SalePOS."Register No.", SalePOS."Sales Ticket No.");
        ApplyCustLedgEntries.OK().Invoke();
    end;

    local procedure GetCustLedgerEntry(var CustLedgEntry: Record "Cust. Ledger Entry"; PostedSalesInv: Code[20])
    begin
        CustLedgEntry.Reset();
        CustLedgEntry.SetCurrentKey("Customer No.", "Applies-to ID", Open);
        CustLedgEntry.SetAutoCalcFields("Remaining Amount");
        CustLedgEntry.SetRange("Customer No.", SalePOS."Customer No.");
        CustLedgEntry.SetRange(Open, true);
        CustLedgEntry.SetRange("Document No.", PostedSalesInv);
        if CustLedgEntry.FindFirst() then;
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;
}